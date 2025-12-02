import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ap_ui/shared/constant/colors.dart';

import 'package:ap_ui/customer/bloc/customer_bloc.dart';
import 'package:ap_ui/customer/bloc/customer_event.dart';
import 'package:ap_ui/customer/bloc/customer_state.dart';

import 'customer_form_page.dart';

class CustomerDetailPage extends StatefulWidget {
  final int id;

  const CustomerDetailPage({super.key, required this.id});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(GetCustomerDetails(widget.id));
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Delete Customer?"),
            content: const Text(
              "Are you sure you want to delete this customer?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  context.read<CustomerBloc>().add(DeleteCustomer(id));
                  Navigator.pop(context);
                },
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerBloc, CustomerState>(
      listener: (context, state) {
        if (state is DeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Customer deleted successfully"),
              backgroundColor: Colors.red,
            ),
          );
          context.read<CustomerBloc>().add(FetchCustomers());
          // Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.pop(context); // Go back after deleting
          // });
        }
      },

      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: whiteColor),
          title: const Text(
            "Customer Details",
            style: TextStyle(color: whiteColor),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          actions: [
            PopupMenuButton<String>(
              iconColor: whiteColor,
              onSelected: (value) {
                if (value == "edit") {
                  final customer =
                      (context.read<CustomerBloc>().state
                              as CustomerDetailLoaded)
                          .customer;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerFormPage(editCustomer: customer),
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

        body: BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, state) {
            if (state is CustomerLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CustomerDetailLoaded) {
              final customer = state.customer;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ROW 1: NAME + PHONE
                    Row(
                      children: [
                        _info("Name", customer["name"]),
                        _info("Phone", customer["phone"] ?? "N/A"),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ROW 2: EMAIL + ASSIGNED SUPPLIER
                    Row(
                      children: [
                        _info("Email", customer["email"] ?? "N/A"),
                        _info(
                          "Assigned",
                          customer["assigned_name"] ?? "Not Assigned",
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ROW 3: SUPPLIES COUNT
                    Row(
                      children: [
                        _info(
                          "Supplies Count",
                          "${customer['supplies_count'] ?? 0}",
                        ),
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

                    const Text("Payments list code commented for now..."),

                    const SizedBox(height: 50),
                  ],
                ),
              );
            }

            return const Center(child: Text("Unable to load customer details"));
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
