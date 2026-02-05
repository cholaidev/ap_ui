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

  // ================= CONTROLLERS =================
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _houseNameController = TextEditingController();
  final _locationController = TextEditingController();

  final _cowQtyController = TextEditingController();
  final _buffaloQtyController = TextEditingController();

  String _milkType = 'Cow'; // Cow | Buffalo | Both

  // ================= SAFE CONVERTER =================
  double _toDouble(dynamic v) {
    return double.tryParse(v?.toString() ?? '0') ?? 0.0;
  }

  // ================= INIT =================
  @override
  void initState() {
    super.initState();

    if (widget.editCustomer != null) {
      final c = widget.editCustomer!;

      _nameController.text = c['name'] ?? '';
      _phoneController.text = c['phone'] ?? '';
      _houseNameController.text = c['house_name'] ?? '';
      _locationController.text = c['location'] ?? '';

      final cowQty = _toDouble(c['cow_milk_quantity']);
      final buffaloQty = _toDouble(c['buffalo_milk_quantity']);

      _cowQtyController.text = cowQty > 0 ? cowQty.toString() : '';
      _buffaloQtyController.text = buffaloQty > 0 ? buffaloQty.toString() : '';

      if (cowQty > 0 && buffaloQty > 0) {
        _milkType = 'Both';
      } else if (buffaloQty > 0) {
        _milkType = 'Buffalo';
      } else {
        _milkType = 'Cow';
      }
    }
  }

  // ================= SUBMIT =================
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.replaceAll(RegExp(r'\D'), ''),
      'house_name': _houseNameController.text.trim(),
      'location': _locationController.text.trim(),
      'cow_milk_quantity':
          _milkType == 'Cow' || _milkType == 'Both'
              ? _toDouble(_cowQtyController.text)
              : 0,
      'buffalo_milk_quantity':
          _milkType == 'Buffalo' || _milkType == 'Both'
              ? _toDouble(_buffaloQtyController.text)
              : 0,
    };

    if (widget.editCustomer != null) {
      context.read<CustomerBloc>().add(
        UpdateCustomer(widget.editCustomer!['id'], data),
      );
    } else {
      context.read<CustomerBloc>().add(AddCustomer(data));
    }
  }

  // ================= QUANTITY FIELD =================
  Widget _quantityField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            final d = _toDouble(v);
            if (d <= 0) return "Enter valid quantity";
            return null;
          },
          decoration: const InputDecoration(
            hintText: "Liters",
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // ================= UI =================
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
            context.read<CustomerBloc>().add(FetchCustomers(status: 'active'));
            if (widget.editCustomer != null) {
              context.read<CustomerBloc>().add(
                GetCustomerDetails(widget.editCustomer!['id']),
              );
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          } else if (state is CustomerUpdateSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));

            context.read<CustomerBloc>().add(
              GetCustomerDetails(widget.editCustomer!['id']),
            );
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
                  _textField("Name", _nameController, required: true),

                  const SizedBox(height: 16),

                  _textField(
                    "Phone Number",
                    _phoneController,
                    required: true,
                    keyboard: TextInputType.phone,
                    maxLength: 10,
                    validator: (v) {
                      final cleaned = v?.replaceAll(RegExp(r'\D'), '') ?? '';
                      if (cleaned.length != 10) {
                        return "Phone number must be 10 digits";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _textField("House Name", _houseNameController),

                  const SizedBox(height: 16),

                  _textField("Location", _locationController),

                  const SizedBox(height: 16),

                  const Text(
                    "Milk Type",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _milkType,
                    items: const [
                      DropdownMenuItem(value: 'Cow', child: Text('Cow')),
                      DropdownMenuItem(
                        value: 'Buffalo',
                        child: Text('Buffalo'),
                      ),
                      DropdownMenuItem(value: 'Both', child: Text('Both')),
                    ],
                    onChanged: (v) => setState(() => _milkType = v!),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_milkType == 'Cow' || _milkType == 'Both')
                    _quantityField(
                      label: "Cow Milk Quantity",
                      controller: _cowQtyController,
                    ),

                  if (_milkType == 'Both') const SizedBox(height: 16),

                  if (_milkType == 'Buffalo' || _milkType == 'Both')
                    _quantityField(
                      label: "Buffalo Milk Quantity",
                      controller: _buffaloQtyController,
                    ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2E7D32),
        onPressed: _submit,
        icon: const Icon(Icons.save, color: whiteColor),
        label: const Text("Save", style: TextStyle(color: whiteColor)),
      ),
    );
  }

  // ================= TEXT FIELD =================
  Widget _textField(
    String label,
    TextEditingController controller, {
    bool required = false,
    TextInputType keyboard = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          maxLength: maxLength,
          buildCounter:
              maxLength != null
                  ? (
                    _, {
                    required int currentLength,
                    required bool isFocused,
                    int? maxLength,
                  }) => null
                  : null,
          validator:
              validator ??
              (required
                  ? (v) => v == null || v.isEmpty ? "Required" : null
                  : null),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }
}
