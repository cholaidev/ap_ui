import 'package:ap_ui/employee/bloc/employee_bloc.dart';
import 'package:ap_ui/employee/bloc/employee_event.dart';
import 'package:ap_ui/employee/bloc/employee_state.dart';
import 'package:ap_ui/employee/screen/employee_form.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employee Details"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              context.read<EmployeeBloc>().add(DeleteEmployee(widget.id));
              Navigator.pop(context);
            },
          ),
        ],
      ),

      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          if (state is EmployeeLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is EmployeeDetailLoaded) {
            final emp = state.employee;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emp["name"],
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  Text("Phone: ${emp['phone']}"),
                  Text("Email: ${emp['email'] ?? "-"}"),
                  Text("Salary: ₹${emp['salary']}"),
                  Text("Given: ₹${emp['given_money']}"),

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EmployeeFormPage(editEmployee: emp),
                        ),
                      );
                    },
                    child: Text("Edit Employee"),
                  ),
                ],
              ),
            );
          }

          return Center(child: Text("Error loading details"));
        },
      ),
    );
  }
}
