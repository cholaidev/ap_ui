import 'package:ap_ui/employee/bloc/employee_bloc.dart';
import 'package:ap_ui/employee/bloc/employee_event.dart';
import 'package:ap_ui/employee/bloc/employee_state.dart';
import 'package:ap_ui/employee/screen/employee_details_screen.dart';
import 'package:ap_ui/employee/screen/employee_form.dart';
import 'package:ap_ui/shared/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({super.key});

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  @override
  void initState() {
    super.initState();
    context.read<EmployeeBloc>().add(LoadEmployees());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: whiteColor),
        title: const Text("Employees", style: TextStyle(color: whiteColor)),
        backgroundColor: const Color(0xFF2E7D32),
      ),

      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          if (state is EmployeeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EmployeeLoaded) {
            final employees = state.employees;

            final totalEmployees = employees.length;
            num totalSalary = employees.fold(0, (sum, e) {
              final salary = num.tryParse(e["salary"].toString()) ?? 0;
              return sum + salary;
            });

            return Column(
              children: [
                /// 🔥 METRICS CARD
                Container(
                  padding: const EdgeInsets.all(12),
                  color: const Color(0xFF2E7D32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "Total Employees",
                            style: TextStyle(color: whiteColor, fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "$totalEmployees",
                            style: const TextStyle(
                              color: whiteColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            "Total Salary",
                            style: TextStyle(color: whiteColor, fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "₹$totalSalary",
                            style: const TextStyle(
                              color: whiteColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// LIST VIEW
                Expanded(
                  child:
                      employees.isEmpty
                          ? const Center(
                            child: Text(
                              "No employees found",
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            itemCount: employees.length,
                            itemBuilder: (context, index) {
                              final emp = employees[index];

                              return Card(
                                elevation: 1,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => EmployeeDetailPage(
                                              id: emp['id'],
                                            ),
                                      ),
                                    );
                                  },

                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      /// NAME
                                      Text(
                                        emp['name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      /// Salary
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        /// PHONE
                                        Text(
                                          "📞 ${emp['phone']}",
                                          style: const TextStyle(fontSize: 14),
                                        ),

                                        /// ACTIVE STATUS
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
                          ),
                ),
              ],
            );
          }

          if (state is EmployeeError) {
            return Center(
              child: Text(
                "Error: ${state.message}",
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          return const SizedBox();
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D32),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EmployeeFormPage()),
          );
        },
        child: const Icon(Icons.add, color: whiteColor),
      ),
    );
  }
}
