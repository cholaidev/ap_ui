import 'package:ap_ui/setting/bloc/setting_bloc.dart';
import 'package:ap_ui/setting/bloc/setting_event.dart';
import 'package:ap_ui/shared/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ap_ui/supply/cubit/supply_cubit_cubit.dart';
import 'package:ap_ui/supply/screen/customer_select.dart';
import 'package:ap_ui/supply/screen/employee_select_list.dart';

import '../bloc/supply_bloc.dart';
import '../bloc/supply_event.dart';
import '../bloc/supply_state.dart';

class SupplyFormPage extends StatefulWidget {
  final Map<String, dynamic>? editSupply;
  final bool is_from_assigned;

  const SupplyFormPage({
    super.key,
    this.editSupply,
    required this.is_from_assigned,
  });

  @override
  State<SupplyFormPage> createState() => _SupplyFormPageState();
}

class _SupplyFormPageState extends State<SupplyFormPage> {
  late SupplyCubitCubit supplyCubit;
  final Map<int, TextEditingController> _qtyControllers = {};
  late SettingBloc settingBloc;

  @override
  void initState() {
    super.initState();
    print('check init supply ${widget.is_from_assigned}');
    settingBloc = context.read<SettingBloc>();
    settingBloc.add(LoadSettings());
    supplyCubit = context.read<SupplyCubitCubit>();
    supplyCubit.resetState();
    supplyCubit.updatePriceOfMilk(settingBloc.milkPrice ?? 50);

    print('milk price ${settingBloc.milkPrice}');

    /// PREFILL EDIT DATA
    if (widget.editSupply != null) {
      print('check edit supply ${widget.editSupply}');

      supplyCubit.setEmployee(widget.editSupply!['employee']);
      double _d(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0;

      final items = widget.editSupply?['items'] as List<dynamic>? ?? [];
      print('items in edit $items');
      final customers =
          items.where((item) => item['customer'] != null).map((item) {
            final customer = Map<String, dynamic>.from(item['customer']);

            final cowQty = _d(item['cow_milk_quantity']);
            final buffaloQty = _d(item['buffalo_milk_quantity']);

            customer['cow_milk_quantity'] = cowQty;
            customer['buffalo_milk_quantity'] = buffaloQty;

            /// ✅ TOTAL = COW + BUFFALO
            customer['quantity'] = cowQty + buffaloQty;

            /// price (safe)
            customer['price_per_liter'] =
                _d(item['cow_price_per_liter']) > 0
                    ? _d(item['cow_price_per_liter'])
                    : _d(item['buffalo_price_per_liter']);

            return customer;
          }).toList();

      print('check liters after fix $customers');

      supplyCubit.setCustomers(customers);

      if (widget.editSupply!['supply_date'] != null) {
        supplyCubit.setSupplyDate(
          DateTime.parse(widget.editSupply!['supply_date']),
        );
      }
    }
  }

  Future<void> _pickSupplyDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: supplyCubit.supplyDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      supplyCubit.setSupplyDate(picked);
    }
  }

  void _selectEmployee() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => EmployeeSelectListPage(
              selectedEmployee: supplyCubit.selectedEmployee,
            ),
      ),
    );
  }

  void _selectCustomers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CustomerSelectListPage(
              initialSelected: supplyCubit.selectedCustomers,
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
    double _d(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0;

    final payload = {
      "employee": supplyCubit.selectedEmployee,
      "total_quantity": supplyCubit.totalLiters,
      "total_amount": supplyCubit.totalAmountOfMilk,
      "supply_date":
          widget.is_from_assigned == true
              ? null
              : supplyCubit.supplyDate.toIso8601String(),
      "is_assigned_only": widget.is_from_assigned == true ? 1 : 0,

      "items":
          supplyCubit.selectedCustomers.map((c) {
            final cowQty = _d(c['cow_milk_quantity']);
            final buffaloQty = _d(c['buffalo_milk_quantity']);
            final price =
                _d(c['price_per_liter']) > 0
                    ? _d(c['price_per_liter'])
                    : supplyCubit.priceofMilk;

            return {
              "customer_id": c['id'],

              // 🐄 COW
              "cow_milk_quantity": cowQty,
              "cow_price_per_liter": cowQty > 0 ? price : 0,

              // 🐃 BUFFALO
              "buffalo_milk_quantity": buffaloQty,
              "buffalo_price_per_liter": buffaloQty > 0 ? price : 0,
            };
          }).toList(),
    };

    print('check supply payload $payload');
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
  void dispose() {
    for (final c in _qtyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: whiteColor),
        title: Text(
          widget.editSupply != null ? "Edit Supply" : "Add Supply",
          style: TextStyle(color: whiteColor),
        ),
        backgroundColor: Colors.green.shade700,
      ),

      /// ✅ BLOC LISTENER (SAME AS CUSTOMER FORM)
      body: BlocListener<SupplyBloc, SupplyState>(
        listener: (context, state) {
          if (state is SupplySuccess) {
            context.read<SupplyBloc>().add(
              LoadSupplies(is_from_assigned: widget.is_from_assigned),
            );

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));

            Navigator.pop(context);
          }

          if (state is SupplyError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: _buildForm(),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton.extended(
            heroTag: "discard",
            backgroundColor: Colors.red,
            icon: const Icon(Icons.close, color: whiteColor),
            label: const Text("Discard", style: TextStyle(color: whiteColor)),
            onPressed: _discard,
          ),
          FloatingActionButton.extended(
            heroTag: "save",
            backgroundColor: Colors.green,
            icon: const Icon(Icons.save, color: whiteColor),
            label: const Text("Save", style: TextStyle(color: whiteColor)),
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  /// ================= FORM UI =================
  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          /// ================= EMPLOYEE =================
          const Text("Employee", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          BlocBuilder<SupplyCubitCubit, SupplyCubitState>(
            builder: (context, state) {
              final emp = supplyCubit.selectedEmployee;

              if (emp == null) {
                return ElevatedButton.icon(
                  onPressed: _selectEmployee,
                  icon: const Icon(Icons.person),
                  label: const Text("Select Employee"),
                );
              }

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.green),
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
          if (widget.is_from_assigned! == false)
            const Text(
              "Supply Date",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          if (widget.is_from_assigned! == false) const SizedBox(height: 8),
          if (widget.is_from_assigned! == false)
            BlocBuilder<SupplyCubitCubit, SupplyCubitState>(
              builder: (context, state) {
                final date = supplyCubit.supplyDate;

                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Colors.green,
                    ),
                    title: Text(
                      "${date.day.toString().padLeft(2, '0')}/"
                      "${date.month.toString().padLeft(2, '0')}/"
                      "${date.year}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_calendar),
                      onPressed: _pickSupplyDate,
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 20),

          /// ================= CUSTOMERS =================
          BlocBuilder<SupplyCubitCubit, SupplyCubitState>(
            builder: (context, state) {
              final customers = supplyCubit.selectedCustomers;
              print('slected customers $customers');

              if (customers.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Customers",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _selectCustomers,
                            icon: const Icon(Icons.group),
                            label: const Text("Select Customers"),
                          ),
                        ),
                      ],
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
                    height: 280,
                    child: ListView.builder(
                      itemCount: customers.length,
                      itemBuilder: (_, i) {
                        final c = customers[i];
                        double _d(dynamic v) =>
                            double.tryParse(v?.toString() ?? '0') ?? 0;
                        final controller = _qtyControllers.putIfAbsent(
                          c['id'],
                          () => TextEditingController(
                            text: c['quantity'].toString(),
                          ),
                        );
                        final newValue = c['quantity'].toString();
                        if (controller.text != newValue) {
                          controller.text = newValue;
                        }

                        print('qty controller ${controller.text}');
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
                                            c['house_name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            c['name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),

                                          Text("${c['phone']}"),
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

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_d(c['cow_milk_quantity']) > 0)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "🐄 Cow",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            "${_d(c['cow_milk_quantity']).toStringAsFixed(2)} L",
                                          ),
                                        ],
                                      ),

                                    if (_d(c['buffalo_milk_quantity']) > 0)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "🐃 Buffalo",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            "${_d(c['buffalo_milk_quantity']).toStringAsFixed(2)} L",
                                          ),
                                        ],
                                      ),

                                    const SizedBox(height: 4),

                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "Total: ${_d(c['quantity']).toStringAsFixed(2)} L",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
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

          /// ================= SUPPLY DATE =================

          /// ================= TOTAL =================
          BlocBuilder<SupplyCubitCubit, SupplyCubitState>(
            builder: (context, state) {
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
                      "Total: ${supplyCubit.totalLiters.toStringAsFixed(2)} L",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 18,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          supplyCubit.selectedCustomers.length.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
