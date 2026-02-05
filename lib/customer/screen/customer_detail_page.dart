import 'package:ap_ui/customer/screen/customer_history.dart';
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

  Future<void> _refreshListAndPop() async {
    context.read<CustomerBloc>().add(FetchCustomers(status: 'active'));
    Navigator.pop(context);
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
          _refreshListAndPop();
        }

        if (state is CustomerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(color: whiteColor, onPressed: _refreshListAndPop),
          title: const Text(
            "Customer Details",
            style: TextStyle(color: whiteColor),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          actions: [
            PopupMenuButton<String>(
              iconColor: whiteColor,
              onSelected: (value) {
                final state = context.read<CustomerBloc>().state;
                if (state is! CustomerDetailLoaded) return;

                if (value == "edit") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => CustomerFormPage(editCustomer: state.customer),
                    ),
                  );
                } else if (value == "delete") {
                  _confirmDelete(widget.id);
                }
              },
              itemBuilder:
                  (_) => const [
                    PopupMenuItem(
                      value: "edit",
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text("Edit"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
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

              final double cowQty =
                  double.tryParse(
                    customer['cow_milk_quantity']?.toString() ?? '0',
                  ) ??
                  0.0;

              final double buffaloQty =
                  double.tryParse(
                    customer['buffalo_milk_quantity']?.toString() ?? '0',
                  ) ??
                  0.0;

              final double totalQty = cowQty + buffaloQty;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// BASIC INFO
                    Row(
                      children: [
                        _info("Name", customer["name"] ?? "N/A"),
                        _info("Phone", customer["phone"] ?? "N/A"),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(),

                    /// 🐄🐃 MILK DETAILS
                    const Text(
                      "Milk Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _milkCard(
                          label: "Cow Milk",
                          value: "$cowQty L",
                          icon: Icons.agriculture,
                        ),
                        const SizedBox(width: 12),
                        _milkCard(
                          label: "Buffalo Milk",
                          value: "$buffaloQty L",
                          icon: Icons.water_drop,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _totalMilkCard(totalQty),

                    const SizedBox(height: 16),
                    const Divider(),

                    /// 📦 DELIVERY HISTORY
                    CustomerDeliveryHistoryWidget(customerId: widget.id),

                    const SizedBox(height: 40),
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

  Widget _milkCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.green.shade700),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalMilkCard(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.green.shade100,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Total Milk",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            "$total L",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
