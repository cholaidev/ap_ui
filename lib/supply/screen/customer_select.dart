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

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _allCustomers = [];
  List<dynamic> _filteredCustomers = [];

  double _d(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0;

  @override
  void initState() {
    super.initState();

    if (widget.initialSelected != null) {
      selectedCustomers.addAll(widget.initialSelected!);
    }

    context.read<CustomerBloc>().add(FetchCustomers(status: 'active'));
    supplyCubit = context.read<SupplyCubitCubit>();

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers =
          _allCustomers.where((c) {
            return (c['name'] ?? '').toLowerCase().contains(query) ||
                (c['phone'] ?? '').toString().contains(query) ||
                (c['location'] ?? '').toLowerCase().contains(query) ||
                (c['house_name'] ?? '').toLowerCase().contains(query);
          }).toList();
    });
  }

  void _startSearch() => setState(() => _isSearching = true);

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _filteredCustomers = _allCustomers;
    });
  }

  bool isSelected(int id) => selectedCustomers.any((e) => e['id'] == id);

  Map<String, dynamic>? selectedCustomer(int id) {
    try {
      return selectedCustomers.firstWhere((e) => e['id'] == id);
    } catch (_) {
      return null;
    }
  }

  // ================= TOGGLE =================
  void toggleCustomer(Map<String, dynamic> customer) {
    setState(() {
      final index = selectedCustomers.indexWhere(
        (e) => e['id'] == customer['id'],
      );

      if (index != -1) {
        selectedCustomers.removeAt(index);
      } else {
        final cow = _d(customer['cow_milk_quantity']);
        final buffalo = _d(customer['buffalo_milk_quantity']);

        selectedCustomers.add({
          ...customer,
          "cow_milk_quantity": cow,
          "buffalo_milk_quantity": buffalo,
          "quantity": cow + buffalo,
          "price_per_liter": supplyCubit.priceofMilk,
        });
      }
    });
  }

  // ================= UPDATE =================
  void updateCow(int id, double value) {
    final index = selectedCustomers.indexWhere((e) => e['id'] == id);
    if (index == -1) return;

    setState(() {
      selectedCustomers[index]['cow_milk_quantity'] = value;
      selectedCustomers[index]['quantity'] =
          value + _d(selectedCustomers[index]['buffalo_milk_quantity']);
    });
  }

  void updateBuffalo(int id, double value) {
    final index = selectedCustomers.indexWhere((e) => e['id'] == id);
    if (index == -1) return;

    setState(() {
      selectedCustomers[index]['buffalo_milk_quantity'] = value;
      selectedCustomers[index]['quantity'] =
          value + _d(selectedCustomers[index]['cow_milk_quantity']);
    });
  }

  void _onDone() {
    final hasValidQty = selectedCustomers.any((c) => _d(c['quantity']) > 0);

    if (!hasValidQty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Quantity must be greater than 0"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    supplyCubit.setCustomers(selectedCustomers);
    Navigator.pop(context, selectedCustomers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: whiteColor),
        backgroundColor: const Color(0xFF2E7D32),
        title:
            _isSearching
                ? Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: "Search customers...",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                )
                : const Text(
                  "Select Customers",
                  style: TextStyle(color: whiteColor),
                ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: whiteColor,
            ),
            onPressed: () => _isSearching ? _stopSearch() : _startSearch(),
          ),
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
            _allCustomers = state.customers;
            if (!_isSearching) _filteredCustomers = _allCustomers;

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filteredCustomers.length,
              itemBuilder: (_, index) {
                final c = _filteredCustomers[index];
                final selected = isSelected(c['id']);
                final sc = selectedCustomer(c['id']);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () => toggleCustomer(c),
                        leading: Checkbox(
                          value: selected,
                          onChanged: (_) => toggleCustomer(c),
                        ),
                        title: Text(
                          "🏠 ${c['house_name'] ?? ''}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("👤 ${c['name']}"),
                            Text("📞 ${c['phone']}"),
                            Text(
                              "📍 ${c['location']}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      /// 🔥 EDITABLE QUANTITIES
                      if (selected)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(56, 0, 16, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text("🐄"),
                                  const SizedBox(width: 4),
                                  SizedBox(
                                    width: 60,
                                    height: 34,
                                    child: TextFormField(
                                      initialValue:
                                          _d(
                                            sc?['cow_milk_quantity'],
                                          ).toString(),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 13),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged:
                                          (v) => updateCow(c['id'], _d(v)),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  const Text("🐃"),
                                  const SizedBox(width: 4),
                                  SizedBox(
                                    width: 60,
                                    height: 34,
                                    child: TextFormField(
                                      initialValue:
                                          _d(
                                            sc?['buffalo_milk_quantity'],
                                          ).toString(),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 13),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged:
                                          (v) => updateBuffalo(c['id'], _d(v)),
                                    ),
                                  ),

                                  const Spacer(),

                                  Text(
                                    "Total ${_d(sc?['quantity']).toStringAsFixed(2)} L",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
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
