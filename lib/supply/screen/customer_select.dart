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

  @override
  void initState() {
    super.initState();

    if (widget.initialSelected != null) {
      selectedCustomers.addAll(widget.initialSelected!);
    }

    context.read<CustomerBloc>().add(FetchCustomers());
    supplyCubit = context.read<SupplyCubitCubit>();

    _searchController.addListener(_onSearchChanged);
  }

  /// 🔍 SEARCH (NAME / PHONE / LOCATION / HOUSE NAME)
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

  void _startSearch() {
    setState(() => _isSearching = true);
  }

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: whiteColor),
        backgroundColor: const Color(0xFF2E7D32),

        /// 🔍 TITLE / SEARCH
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
                    style: const TextStyle(color: Colors.black),
                    cursorColor: Colors.black,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: const InputDecoration(
                      hintText: "Search name, phone, house, location...",
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
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
            if (!_isSearching) {
              _filteredCustomers = _allCustomers;
            }

            final customers = _filteredCustomers;

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: customers.length,
              itemBuilder: (_, index) {
                final c = customers[index];
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
                          c['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              "🏠 ${c['house_name'] ?? ''}",
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text("📞 ${c['phone'] ?? '-'}"),
                            const SizedBox(height: 2),
                            Text(
                              "📍 ${c['location'] ?? ''}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        trailing: Icon(
                          c['is_active'] == 1
                              ? Icons.check_circle
                              : Icons.cancel,
                          color:
                              c['is_active'] == 1 ? Colors.green : Colors.red,
                        ),
                      ),

                      /// QUANTITY FIELD
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
