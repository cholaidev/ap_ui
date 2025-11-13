import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ap_ui/customer/bloc/customer_bloc.dart';
import 'package:ap_ui/customer/bloc/customer_event.dart';
import 'package:ap_ui/customer/bloc/customer_state.dart';
import 'customer_form_page.dart';

class CustomerDetailPage extends StatelessWidget {
  final int id;

  const CustomerDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    context.read<CustomerBloc>().add(GetCustomerDetails(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Details"),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CustomerDetailLoaded) {
            final customer = state.customer;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Name: ${customer['name']}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text("Phone: ${customer['phone'] ?? 'N/A'}"),
                  Text("Email: ${customer['email'] ?? 'N/A'}"),
                  const SizedBox(height: 16),
                  Text(
                    "Supplies Assigned: ${customer['supplies_count'] ?? 0}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Customer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CustomerFormPage(editCustomer: customer),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else if (state is CustomerError) {
            return Center(child: Text(state.error));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
