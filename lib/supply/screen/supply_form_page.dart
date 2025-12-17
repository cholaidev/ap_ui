import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ap_ui/supply/cubit/supply_cubit_cubit.dart';
import 'package:ap_ui/supply/screen/customer_select.dart';
import 'package:ap_ui/supply/screen/employee_select_list.dart';

import '../bloc/supply_bloc.dart';
import '../bloc/supply_event.dart';

class SupplyFormPage extends StatefulWidget {
  final Map<String, dynamic>? editSupply;

  const SupplyFormPage({super.key, this.editSupply});

  @override
  State<SupplyFormPage> createState() => _SupplyFormPageState();
}

class _SupplyFormPageState extends State<SupplyFormPage> {
  late SupplyCubitCubit supplyCubit;

  @override
  void initState() {
    super.initState();
    supplyCubit = context.read<SupplyCubitCubit>();

    /// PREFILL EDIT DATA
    if (widget.editSupply != null) {
      supplyCubit.setEmployee(widget.editSupply!['employee']);
      supplyCubit.setCustomers(
        List<Map<String, dynamic>>.from(widget.editSupply!['items'] ?? []),
      );
    }
  }

  void _selectEmployee() {
    final cubit = context.read<SupplyCubitCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => EmployeeSelectListPage(
              selectedEmployee: cubit.selectedEmployee,
            ),
      ),
    );
  }

  void _selectCustomers() {
    final cubit = context.read<SupplyCubitCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CustomerSelectListPage(
              initialSelected: cubit.selectedCustomers,
            ),
      ),
    );
  }

  void _save() {
    if (supplyCubit.selectedEmployee == null ||
        supplyCubit.selectedCustomers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select employee & customers")),
      );
      return;
    }
    final cubit = context.read<SupplyCubitCubit>();
    final payload = {
      "employee": cubit.selectedEmployee,
      "total_quantity": cubit.totalLiters,
      "total_amount": cubit.totalAmountOfMilk,
      "items": cubit.selectedCustomers,
    };

    if (widget.editSupply != null) {
      context.read<SupplyBloc>().add(
        UpdateSupply(widget.editSupply!['id'], payload),
      );
    } else {
      context.read<SupplyBloc>().add(CreateSupply(payload));
    }
  }

  void _discard() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editSupply != null ? "Edit Supply" : "Add Supply"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /// ================= EMPLOYEE =================
            const Text(
              "Employee",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            BlocBuilder<SupplyCubitCubit, SupplyCubitState>(
              builder: (context, state) {
                final emp = supplyCubit.selectedEmployee;

                if (emp == null) {
                  return Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _selectEmployee,
                        icon: const Icon(Icons.person),
                        label: const Text("Select Employee"),
                      ),
                    ],
                  );
                }

                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.person,
                      color: Colors.green,
                      size: 32,
                    ),
                    title: Text(emp['name']),
                    subtitle: Text("📞 ${emp['phone']}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _selectEmployee,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// ================= CUSTOMERS =================
            ///
            BlocBuilder<SupplyCubitCubit, SupplyCubitState>(
              builder: (context, state) {
                final customers = supplyCubit.selectedCustomers;

                if (customers.isEmpty) {
                  return Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Customers",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox(height: 8),

                      ElevatedButton.icon(
                        onPressed: _selectCustomers,
                        icon: const Icon(Icons.group),
                        label: const Text("Select Customers"),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Customers",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _selectCustomers,
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text("Edit"),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 280, // customer list scroll area
                      child: ListView.builder(
                        primary: false, // ⭐ IMPORTANT
                        physics: const ClampingScrollPhysics(), // ⭐ IMPORTANT
                        itemCount: customers.length,
                        itemBuilder: (_, i) {
                          final c = customers[i];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person_outline,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              c['name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text("📞 ${c['phone']}"),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          supplyCubit.removeCustomer(c['id']);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text("Milk: ${c['milk']}"),
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: TextFormField(
                                          initialValue: "${c['quantity']}",
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: "Liters",
                                          ),
                                          onChanged: (v) {
                                            supplyCubit.updateCustomerQuantity(
                                              c['id'],
                                              double.tryParse(v) ?? 0,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            /// ================= TOTAL =================
            BlocBuilder<SupplyCubitCubit, SupplyCubitState>(
              builder: (context, state) {
                final cubit = context.read<SupplyCubitCubit>();

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total: ${cubit.totalLiters.toStringAsFixed(2)} L",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "₹ ${cubit.totalAmountOfMilk.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton.extended(
            heroTag: "discard",
            backgroundColor: Colors.red,
            icon: const Icon(Icons.close),
            label: const Text("Discard"),
            onPressed: _discard,
          ),
          FloatingActionButton.extended(
            heroTag: "save",
            backgroundColor: Colors.green,
            icon: const Icon(Icons.save),
            label: const Text("Save"),
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
