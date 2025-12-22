import 'package:ap_ui/shared/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ap_ui/customer/bloc/customer_bloc.dart';
import 'package:ap_ui/customer/bloc/customer_event.dart';
import 'package:ap_ui/customer/bloc/customer_state.dart';

class CustomerFormPage extends StatefulWidget {
  final Map<String, dynamic>? editCustomer;

  const CustomerFormPage({super.key, this.editCustomer});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();

  // CONTROLLERS
  final _nameController = TextEditingController();
  final _houseNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _quantityController = TextEditingController();
  final _phoneController = TextEditingController(); // ✅ ADDED

  String? _milkType = 'Cow';

  @override
  void initState() {
    super.initState();

    if (widget.editCustomer != null) {
      _nameController.text = widget.editCustomer!['name'] ?? '';
      _houseNameController.text = widget.editCustomer!['house_name'] ?? '';
      _locationController.text = widget.editCustomer!['location'] ?? '';
      _milkType = widget.editCustomer!['milk'];
      _quantityController.text =
          widget.editCustomer!['quantity']?.toString() ?? '';
      _phoneController.text = widget.editCustomer!['phone'] ?? ''; // ✅ ADDED
    }
  }

  /// SAVE BUTTON HANDLER
  void _submit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(), // ✅ ADDED
        'house_name': _houseNameController.text.trim(),
        'location': _locationController.text.trim(),
        'milk': _milkType,
        'quantity': int.tryParse(_quantityController.text.trim()),
      };

      if (widget.editCustomer != null) {
        context.read<CustomerBloc>().add(
          UpdateCustomer(widget.editCustomer!['id'], data),
        );
      } else {
        context.read<CustomerBloc>().add(AddCustomer(data));
      }
    }
  }

  /// DISCARD POPUP
  void _showDiscardPopup() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Discard Changes?"),
            content: const Text(
              "Are you sure you want to discard the changes?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Discard"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: whiteColor),
        title: Text(
          widget.editCustomer != null ? "Edit Customer" : "Add Customer",
          style: const TextStyle(color: whiteColor),
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),

      body: BlocListener<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerSuccess) {
            context.read<CustomerBloc>().add(FetchCustomers());
            if (widget.editCustomer != null) {
              context.read<CustomerBloc>().add(
                GetCustomerDetails(widget.editCustomer!['id']),
              );
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          } else if (state is CustomerError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// NAME
                  const Text(
                    "Name",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    validator: (v) => v!.isEmpty ? "Enter name" : null,
                    decoration: const InputDecoration(
                      hintText: "Enter name",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// PHONE  📞   (NEW FIELD)
                  const Text(
                    "Phone Number",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10, // required for limiting input
                    buildCounter:
                        (
                          _, {
                          required int currentLength,
                          required bool isFocused,
                          required int? maxLength,
                        }) => null,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Enter phone number";
                      if (v.length != 10)
                        return "Phone number must be 10 digits";
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: "Enter phone number",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// HOUSE NAME
                  const Text(
                    "House Name",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _houseNameController,
                    decoration: const InputDecoration(
                      hintText: "Enter house name",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// LOCATION
                  const Text(
                    "Location",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      hintText: "Enter location",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// MILK
                  const Text(
                    "Milk",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _milkType,
                    items:
                        ["Cow", "Buffalo"]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _milkType = v),
                    validator: (v) => v == null ? "Select milk type" : null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// QUANTITY
                  const Text(
                    "Quantity (Liters)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "Enter quantity" : null,
                    decoration: const InputDecoration(
                      hintText: "Enter quantity",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),

      /// SAVE + DISCARD FAB
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton.extended(
            heroTag: "discardBtn",
            backgroundColor: Colors.red,
            onPressed: _showDiscardPopup,
            icon: const Icon(Icons.close, color: whiteColor),
            label: const Text("Discard", style: TextStyle(color: whiteColor)),
          ),

          FloatingActionButton.extended(
            heroTag: "saveBtn",
            backgroundColor: const Color(0xFF2E7D32),
            onPressed: _submit,
            icon: const Icon(Icons.save, color: whiteColor),
            label: const Text("Save", style: TextStyle(color: whiteColor)),
          ),
        ],
      ),
    );
  }
}
