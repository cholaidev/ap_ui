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
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.editCustomer != null) {
      _nameController.text = widget.editCustomer!['name'] ?? '';
      _phoneController.text = widget.editCustomer!['phone'] ?? '';
      _emailController.text = widget.editCustomer!['email'] ?? '';
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
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

  /// ❗ Show discard confirmation popup
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
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // go back screen
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
            // 👈 Prevent overflow
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

                  /// PHONE
                  const Text(
                    "Phone",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    maxLength: 10,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator:
                        (v) =>
                            v == null || v.length != 10
                                ? "Enter valid 10-digit phone"
                                : null,
                    decoration: const InputDecoration(
                      hintText: "Enter phone number",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// EMAIL (OPTIONAL)
                  const Text(
                    "Email (Optional)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: "Enter email",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 100), // avoid hiding behind FABs
                ],
              ),
            ),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton.extended(
            heroTag: "discardBtn",
            backgroundColor: Colors.red,
            icon: const Icon(Icons.close, color: whiteColor),
            label: const Text("Discard", style: TextStyle(color: whiteColor)),
            onPressed: _showDiscardPopup,
          ),

          FloatingActionButton.extended(
            heroTag: "saveBtn",
            backgroundColor: const Color(0xFF2E7D32),
            icon: const Icon(Icons.save, color: whiteColor),
            label: const Text("Save", style: TextStyle(color: whiteColor)),
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
