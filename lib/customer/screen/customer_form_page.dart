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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editCustomer != null ? "Edit Customer" : "Add Customer",
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  validator: (v) => v!.isEmpty ? "Enter name" : null,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator:
                      (v) =>
                          v == null || v.length != 10
                              ? "Enter valid 10-digit phone"
                              : null,
                  decoration: const InputDecoration(labelText: "Phone"),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 14,
                    ),
                  ),
                  child: Text(widget.editCustomer != null ? "Update" : "Add"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
