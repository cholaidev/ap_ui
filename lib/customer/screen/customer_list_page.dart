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

  /// 🔄 Pull-to-refresh
  Future<void> _onRefresh() async {
    context.read<CustomerBloc>().add(FetchCustomers(status: widget.status!));
  }

  /// 🔍 Search (NAME + PHONE + MILK + LOCATION + HOUSE NAME)
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredCustomers =
          _allCustomers.where((c) {
            return (c['name'] ?? '').toLowerCase().contains(query) ||
                (c['phone'] ?? '').toString().contains(query) ||
                (c['milk'] ?? '').toLowerCase().contains(query) ||
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String formatQuantity(dynamic value) {
    final numVal = double.tryParse(value?.toString() ?? '0') ?? 0;
    return numVal.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  Widget buildStatusChip(dynamic isActive) {
    final bool active = isActive == 1 || isActive == true;

    return Chip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      label: Text(
        active ? "Active" : "Inactive",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
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

        /// 🔍 TITLE / SEARCH FIELD
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
                      hintText: "Search name, phone, house, milk, location...",
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
                : const Text("Customers", style: TextStyle(color: whiteColor)),

        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: whiteColor,
            ),
            onPressed: () => _isSearching ? _stopSearch() : _startSearch(),
          ),

          /// BULK IMPORT
          PopupMenuButton<String>(
            iconColor: whiteColor,
            onSelected: (value) {
              if (value == "bulk") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BulkImportPage()),
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
            if (!_isSearching) {
              _filteredCustomers = _allCustomers;
            }

            final customers = _filteredCustomers;

            /// METRICS
            final totalCustomers = customers.length;
            final totalLiters = customers.fold<double>(
              0.0,
              (sum, e) =>
                  sum +
                  (double.tryParse(e['quantity']?.toString() ?? '0') ?? 0.0),
            );

            return Column(
              children: [
                /// METRICS CARD
                Container(
                  padding: const EdgeInsets.all(8),
                  color: const Color(0xFF2E7D32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "Total Customers",
                            style: TextStyle(color: whiteColor),
                          ),
                          Text(
                            "$totalCustomers",
                            style: const TextStyle(
                              color: whiteColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            "Total Liters",
                            style: TextStyle(color: whiteColor),
                          ),
                          Text(
                            "${formatQuantity(totalLiters)} L",
                            style: const TextStyle(
                              color: whiteColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// CUSTOMER LIST + PULL TO REFRESH
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
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: customers.length,
                              itemBuilder: (context, index) {
                                final c = customers[index];

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  child: ListTile(
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
                                    title: Text(
                                      "🏠 ${c['house_name'] ?? ''}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "👤 ${c['name'] ?? ''}",
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "📞 ${c['phone']}",
                                          style: const TextStyle(fontSize: 13),
                                        ),
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
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${c['milk']} (${formatQuantity(c['quantity'])} L)",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        buildStatusChip(c['is_active']),
                                      ],
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
}
