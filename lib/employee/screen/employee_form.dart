import 'package:ap_ui/employee/bloc/employee_bloc.dart';
import 'package:ap_ui/employee/bloc/employee_event.dart';
import 'package:ap_ui/employee/bloc/employee_state.dart';
import 'package:ap_ui/shared/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeFormPage extends StatefulWidget {
  final Map<String, dynamic>? editEmployee;

  const EmployeeFormPage({super.key, this.editEmployee});

  @override
  State<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  final _formKey = GlobalKey<FormState>();

  // CONTROLLERS
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  // final _emailController = TextEditingController();
  final _salaryController = TextEditingController();
  final _givenMoneyController = TextEditingController();

  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    if (widget.editEmployee != null) {
      final emp = widget.editEmployee!;
      _nameController.text = emp['name'] ?? '';
      _phoneController.text = emp['phone'] ?? '';
      // _emailController.text = emp['email'] ?? '';
      _salaryController.text = emp['salary']?.toString() ?? '';
      _givenMoneyController.text = emp['given_money']?.toString() ?? '';
      _isActive = emp['is_active'] == 1;
    }
  }

  /// SAVE FORM
  void _save() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        // 'email': _emailController.text.trim(),
        'salary':
            _salaryController.text.isEmpty
                ? null
                : double.parse(_salaryController.text),

        'given_money':
            _givenMoneyController.text.isEmpty
                ? null
                : double.parse(_givenMoneyController.text),

        'is_active': _isActive ? 1 : 0,
      };

      if (widget.editEmployee != null) {
        context.read<EmployeeBloc>().add(
          UpdateEmployee(widget.editEmployee!["id"], data),
        );
      } else {
        context.read<EmployeeBloc>().add(CreateEmployee(data));
      }
    }
  }

  /// DISCARD CONFIRM POPUP
  void _discard() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
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
          widget.editEmployee != null ? "Edit Employee" : "Add Employee",
          style: const TextStyle(color: whiteColor),
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),

      body: BlocListener<EmployeeBloc, EmployeeState>(
        listener: (context, state) {
          if (state is EmployeeSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));

            context.read<EmployeeBloc>().add(LoadEmployees(status: 'active'));
            Navigator.pop(context);
          } else if (state is EmployeeUpdateSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));

            context.read<EmployeeBloc>().add(LoadEmployees(status: 'active'));
            Navigator.pop(context);
          } else if (state is EmployeeError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
                  validator:
                      (v) => v!.isEmpty ? "Employee name is required" : null,
                  decoration: const InputDecoration(
                    hintText: "Enter employee name",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                /// PHONE
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
                    if (v.length != 10) return "Phone number must be 10 digits";
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: "Enter phone number",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                /// EMAIL
                // const Text(
                //   "Email",
                //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                // ),
                // const SizedBox(height: 6),
                // TextFormField(
                //   controller: _emailController,
                //   decoration: const InputDecoration(
                //     hintText: "Enter email ",
                //     border: OutlineInputBorder(),
                //   ),
                // ),

                // const SizedBox(height: 16),

                /// SALARY
                const Text(
                  "Salary (Monthly)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _salaryController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Enter salary",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                /// GIVEN MONEY
                const Text(
                  "Given Money",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _givenMoneyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Enter advance / given money",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                /// ACTIVE STATUS SWITCH
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Is Active",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Switch(
                      value: _isActive,
                      activeColor: Colors.green,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ],
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),

      /// FAB BUTTONS (SAVE & DISCARD)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton.extended(
            backgroundColor: Colors.red,
            heroTag: "discardBtn",
            onPressed: _discard,
            label: const Text("Discard", style: TextStyle(color: whiteColor)),
            icon: const Icon(Icons.close, color: whiteColor),
          ),
          FloatingActionButton.extended(
            backgroundColor: const Color(0xFF2E7D32),
            heroTag: "saveBtn",
            onPressed: _save,
            label: const Text("Save", style: TextStyle(color: whiteColor)),
            icon: const Icon(Icons.save, color: whiteColor),
          ),
        ],
      ),
    );
  }
}
