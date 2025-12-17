import 'package:ap_ui/shared/constant/colors.dart';
import 'package:ap_ui/supply/cubit/supply_cubit_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ap_ui/customer/bloc/customer_bloc.dart';
import 'package:ap_ui/customer/bloc/customer_event.dart';
import 'package:ap_ui/customer/bloc/customer_state.dart';

class CustomerSelectListPage extends StatefulWidget {
  final List<Map<String, dynamic>>? initialSelected;

  const CustomerSelectListPage({super.key, this.initialSelected});

  @override
  State<CustomerSelectListPage> createState() => _CustomerSelectListPageState();
}

class _CustomerSelectListPageState extends State<CustomerSelectListPage> {
  final List<Map<String, dynamic>> selectedCustomers = [];
  late SupplyCubitCubit supplyCubit;

  @override
  void initState() {
    super.initState();

    if (widget.initialSelected != null) {
      selectedCustomers.addAll(widget.initialSelected!);
    }

    context.read<CustomerBloc>().add(FetchCustomers());
    supplyCubit = context.read<SupplyCubitCubit>();
  }

  bool isSelected(int id) => selectedCustomers.any((e) => e['id'] == id);

  Map<String, dynamic>? selectedCustomer(int id) {
    try {
      return selectedCustomers.firstWhere((e) => e['id'] == id);
    } catch (_) {
      return null;
    }
  }

  void toggleCustomer(Map<String, dynamic> customer) {
    setState(() {
      final index = selectedCustomers.indexWhere(
        (e) => e['id'] == customer['id'],
      );

      if (index != -1) {
        selectedCustomers.removeAt(index);
      } else {
        selectedCustomers.add({
          ...customer,
          "quantity": customer['quantity'] ?? 0,
        });
      }
    });
  }

  void updateQuantity(int id, double qty) {
    final index = selectedCustomers.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      setState(() {
        selectedCustomers[index]['quantity'] = qty;
      });
    }
  }

  void _onDone() {
    supplyCubit.setCustomers(selectedCustomers);
    Navigator.pop(context, selectedCustomers);
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
        actions: [
          TextButton(
            onPressed: selectedCustomers.isEmpty ? null : _onDone,
            child: const Text(
              "DONE",
              style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
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
                final sc = selectedCustomer(c['id']);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () => toggleCustomer(c),

                        /// MULTI SELECT
                        leading: Checkbox(
                          value: selected,
                          onChanged: (_) => toggleCustomer(c),
                        ),

                        title: Text(
                          c['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("📞 ${c['phone'] ?? '-'}"),
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
                        ),
                      ),

                      /// QUANTITY (ONLY IF SELECTED)
                      if (selected)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(56, 0, 16, 12),
                          child: Row(
                            children: [
                              const Text(
                                "Liters",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 100,
                                child: TextFormField(
                                  initialValue: "${sc?['quantity'] ?? 0}",
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
