import 'package:ap_ui/employee/bloc/employee_bloc.dart';
import 'package:ap_ui/employee/bloc/employee_event.dart';
import 'package:ap_ui/employee/bloc/employee_state.dart';
import 'package:ap_ui/shared/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeSelectListPage extends StatefulWidget {
  final Map<String, dynamic>? selectedEmployee;

  const EmployeeSelectListPage({super.key, this.selectedEmployee});

  @override
  State<EmployeeSelectListPage> createState() => _EmployeeSelectListPageState();
}

class _EmployeeSelectListPageState extends State<EmployeeSelectListPage> {
  Map<String, dynamic>? selected;

  @override
  void initState() {
    super.initState();
    selected = widget.selectedEmployee;
    context.read<EmployeeBloc>().add(LoadEmployees());
  }

  void _onDone() {
    Navigator.pop(context, selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: whiteColor),
        title: const Text(
          "Select Employee",
          style: TextStyle(color: whiteColor),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          TextButton(
            onPressed: selected == null ? null : _onDone,
            child: const Text(
              "DONE",
              style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),

      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          if (state is EmployeeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EmployeeLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.employees.length,
              itemBuilder: (_, index) {
                final emp = state.employees[index];
                final isSelected = selected?['id'] == emp['id'];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        selected = emp;
                      });
                    },

                    /// RADIO FOR SINGLE SELECT
                    leading: Radio<int>(
                      value: emp['id'],
                      groupValue: selected?['id'],
                      onChanged: (_) {
                        setState(() {
                          selected = emp;
                        });
                      },
                    ),

                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          emp['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "₹${emp['salary'] ?? 0}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("📞 ${emp['phone'] ?? '-'}"),
                          Icon(
                            emp['is_active'] == 1
                                ? Icons.check_circle
                                : Icons.cancel,
                            color:
                                emp['is_active'] == 1
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          if (state is EmployeeError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
