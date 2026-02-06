import 'package:ap_ui/customer/screen/customer_bulk_import_screen.dart';
import 'package:ap_ui/shared/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ap_ui/customer/bloc/customer_bloc.dart';
import 'package:ap_ui/customer/bloc/customer_event.dart';
import 'package:ap_ui/customer/bloc/customer_state.dart';
import 'customer_detail_page.dart';
import 'customer_form_page.dart';

class CustomerListPage extends StatefulWidget {
  final String? status;
  const CustomerListPage({super.key, this.status = 'active'});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _allCustomers = [];
  List<dynamic> _filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(FetchCustomers(status: widget.status!));
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _onRefresh() async {
    context.read<CustomerBloc>().add(FetchCustomers(status: widget.status!));
  }

  /// 🔍 SEARCH (NAME / PHONE / LOCATION / HOUSE / MILK)
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredCustomers =
          _allCustomers.where((c) {
            final cow = (c['cow_milk_quantity'] ?? 0).toString();
            final buffalo = (c['buffalo_milk_quantity'] ?? 0).toString();

            return (c['name'] ?? '').toLowerCase().contains(query) ||
                (c['phone'] ?? '').toString().contains(query) ||
                (c['location'] ?? '').toLowerCase().contains(query) ||
                (c['house_name'] ?? '').toLowerCase().contains(query) ||
                cow.contains(query) ||
                buffalo.contains(query);
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _d(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0;

  String _fmt(double v) =>
      v.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

  Widget buildStatusChip(dynamic isActive) {
    final bool active = isActive == 1 || isActive == true;
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(
        active ? "Active" : "Inactive",
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: active ? Colors.green : Colors.red,
    );
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
                      hintText: "Search name, phone, milk, location...",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                )
                : const Text("Customers", style: TextStyle(color: whiteColor)),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: whiteColor,
            ),
            onPressed: () => _isSearching ? _stopSearch() : _startSearch(),
          ),
          PopupMenuButton<String>(
            iconColor: whiteColor,
            onSelected: (value) {
              if (value == "bulk") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BulkImportPage()),
                );
              }
            },
            itemBuilder:
                (_) => const [
                  PopupMenuItem(
                    value: "bulk",
                    child: Row(
                      children: [
                        Icon(Icons.upload_file, size: 18),
                        SizedBox(width: 8),
                        Text("Bulk Import"),
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

          if (state is CustomerLoaded) {
            _allCustomers = state.customers;
            if (!_isSearching) _filteredCustomers = _allCustomers;

            final customers = _filteredCustomers;

            final totalCustomers = customers.length;
            final totalCow = customers.fold(
              0.0,
              (s, c) => s + _d(c['cow_milk_quantity']),
            );
            final totalBuffalo = customers.fold(
              0.0,
              (s, c) => s + _d(c['buffalo_milk_quantity']),
            );
            final totalLiters = totalCow + totalBuffalo;

            return Column(
              children: [
                /// 📊 METRICS
                Container(
                  padding: const EdgeInsets.all(8),
                  color: const Color(0xFF2E7D32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metric("Customers", "$totalCustomers"),
                      _metric("Cow Milk", "${_fmt(totalCow)} L"),
                      _metric("Buffalo", "${_fmt(totalBuffalo)} L"),
                      _metric("Total", "${_fmt(totalLiters)} L"),
                    ],
                  ),
                ),

                /// 📋 LIST
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: const Color(0xFF2E7D32),
                    child:
                        customers.isEmpty
                            ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 200),
                                Center(child: Text("No customers found")),
                              ],
                            )
                            : ListView.builder(
                              itemCount: customers.length,
                              itemBuilder: (context, index) {
                                final c = customers[index];
                                final cow = _d(c['cow_milk_quantity']);
                                final buffalo = _d(c['buffalo_milk_quantity']);

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => CustomerDetailPage(
                                                id: c['id'],
                                              ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          /// LEFT SIDE (DETAILS)
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "🏠 ${c['house_name'] ?? ''}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text("👤 ${c['name'] ?? ''}"),
                                                Text("📞 ${c['phone']}"),
                                                Text(
                                                  "📍 ${c['location'] ?? ''}",
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          /// RIGHT SIDE (MILK + STATUS)
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              if (cow > 0)
                                                Text(
                                                  "🐄 ${_fmt(cow)} L",
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              if (buffalo > 0)
                                                Text(
                                                  "🐃 ${_fmt(buffalo)} L",
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              const SizedBox(height: 6),
                                              buildStatusChip(c['is_active']),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ),
              ],
            );
          }

          if (state is CustomerError) {
            return Center(child: Text("Error: ${state.error}"));
          }

          return const SizedBox();
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D32),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CustomerFormPage()),
          );
        },
        child: const Icon(Icons.add, color: whiteColor),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: whiteColor)),
        Text(
          value,
          style: const TextStyle(
            color: whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
