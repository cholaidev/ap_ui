import 'package:ap_ui/employee/bloc/employee_bloc.dart';
import 'package:ap_ui/employee/bloc/employee_event.dart';
import 'package:ap_ui/employee/bloc/employee_state.dart';
import 'package:ap_ui/employee/screen/employee_form.dart';
import 'package:ap_ui/shared/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeDetailPage extends StatefulWidget {
  final int id;

  const EmployeeDetailPage({super.key, required this.id});

  @override
  State<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<EmployeeBloc>().add(GetEmployeeDetails(widget.id));
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Delete Employee?"),
            content: const Text(
              "Are you sure you want to delete this employee?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  context.read<EmployeeBloc>().add(DeleteEmployee(id));
                  Navigator.pop(context);
                },
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  num _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? 0;
  }

  num _getBalance(Map emp) {
    final salary = _parseNum(emp['salary']);
    final given = _parseNum(emp['given_money']);
    return salary - given;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmployeeBloc, EmployeeState>(
      listener: (context, state) {
        if (state is EmployeeDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Employee deleted successfully"),
              backgroundColor: Colors.red,
            ),
          );

          context.read<EmployeeBloc>().add(LoadEmployees());
          Navigator.pop(context);
        }

        if (state is EmployeeUpdateSuccess) {
          context.read<EmployeeBloc>().add(GetEmployeeDetails(widget.id));
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2E7D32),
          leading: const BackButton(color: whiteColor),
          title: const Text(
            "Employee Details",
            style: TextStyle(color: whiteColor),
          ),
          actions: [
            PopupMenuButton<String>(
              iconColor: whiteColor,
              onSelected: (value) {
                if (value == "edit") {
                  final emp =
                      (context.read<EmployeeBloc>().state
                              as EmployeeDetailLoaded)
                          .employee;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EmployeeFormPage(editEmployee: emp),
                    ),
                  );
                } else if (value == "delete") {
                  _confirmDelete(widget.id);
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: "edit",
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text("Edit"),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: "delete",
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text("Delete", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),

        body: BlocBuilder<EmployeeBloc, EmployeeState>(
          builder: (context, state) {
            print('check runtime state ${state.runtimeType}');
            if (state is EmployeeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is EmployeeDetailLoaded) {
              final emp = state.employee;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _info("Name", emp["name"]),
                        _info("Phone", emp["phone"] ?? "N/A"),
                      ],
                    ),
                    const SizedBox(height: 18),

                    Row(
                      children: [
                        _info("Email", emp["email"] ?? "N/A"),
                        _info("Salary", "₹${emp['salary'] ?? 0}"),
                      ],
                    ),
                    const SizedBox(height: 18),

                    Row(
                      children: [
                        _info("Given Money", "₹${emp['given_money'] ?? 0}"),

                        _info("Balance", "₹${_getBalance(emp)}"),
                      ],
                    ),

                    const SizedBox(height: 25),
                    const Divider(),

                    const Text(
                      "Payment Transactions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text("Payments list code coming soon..."),

                    const SizedBox(height: 50),
                  ],
                ),
              );
            }

            return const Center(child: Text("Unable to load employee details"));
          },
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
