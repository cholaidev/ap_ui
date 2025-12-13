import 'package:ap_ui/shared/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ap_ui/customer/bloc/customer_bloc.dart';
import 'package:ap_ui/customer/bloc/customer_event.dart';
import 'package:ap_ui/customer/bloc/customer_state.dart';
import 'package:ap_ui/supply/cubit/supply_cubit_cubit.dart';

class CustomerSelectListPage extends StatefulWidget {
  const CustomerSelectListPage({super.key});

  @override
  State<CustomerSelectListPage> createState() => _CustomerSelectListPageState();
}

class _CustomerSelectListPageState extends State<CustomerSelectListPage> {
  /// ✅ LOCAL SELECTED LIST
  final List<Map<String, dynamic>> selectedCustomers = [];

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(FetchCustomers());
  }

  bool isSelected(int id) {
    return selectedCustomers.any((e) => e['id'] == id);
  }

  Map<String, dynamic>? getSelectedCustomer(int id) {
    try {
      return selectedCustomers.firstWhere((e) => e['id'] == id);
    } catch (_) {
      return null;
    }
  }

  void toggleCustomer(Map<String, dynamic> customer) {
    setState(() {
      final exists = selectedCustomers.any((e) => e['id'] == customer['id']);

      if (exists) {
        selectedCustomers.removeWhere((e) => e['id'] == customer['id']);
      } else {
        selectedCustomers.add({
          ...customer,
          "quantity": customer['quantity'] ?? 0,
        });
      }
    });
  }

  void updateQuantity(int id, double qty) {
    setState(() {
      final index = selectedCustomers.indexWhere((e) => e['id'] == id);
      if (index != -1) {
        selectedCustomers[index]['quantity'] = qty;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: whiteColor),
        title: const Text(
          "Select Customers",
          style: TextStyle(color: whiteColor),
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),

      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.customers.length,
              itemBuilder: (_, index) {
                final c = state.customers[index];
                final selected = isSelected(c['id']);
                final selectedCustomer = getSelectedCustomer(c['id']);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: selected,
                              onChanged: (_) => toggleCustomer(c),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c['name'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text("📞 ${c['phone'] ?? '-'}"),
                                ],
                              ),
                            ),
                            Icon(
                              c['is_active'] == 1
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color:
                                  c['is_active'] == 1
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ],
                        ),

                        if (selected)
                          Padding(
                            padding: const EdgeInsets.only(left: 48, top: 8),
                            child: Row(
                              children: [
                                const Text("Liters"),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 100,
                                  child: TextFormField(
                                    initialValue:
                                        "${selectedCustomer?['quantity'] ?? 0}",
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (v) {
                                      updateQuantity(
                                        c['id'],
                                        double.tryParse(v) ?? 0,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
