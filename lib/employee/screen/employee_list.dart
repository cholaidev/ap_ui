import 'package:ap_ui/employee/bloc/employee_bloc.dart';
import 'package:ap_ui/employee/bloc/employee_event.dart';
import 'package:ap_ui/employee/bloc/employee_state.dart';
import 'package:ap_ui/employee/screen/employee_details_screen.dart';
import 'package:ap_ui/employee/screen/employee_form.dart';
import 'package:ap_ui/shared/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeListPage extends StatefulWidget {
  final String? status;
  const EmployeeListPage({super.key, this.status = 'active'});

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _allEmployees = [];
  List<dynamic> _filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    context.read<EmployeeBloc>().add(LoadEmployees(status: widget.status!));
    _searchController.addListener(_onSearchChanged);
  }

  /// 🔄 Pull to refresh
  Future<void> _onRefresh() async {
    context.read<EmployeeBloc>().add(LoadEmployees(status: widget.status!));
  }

  /// 🔍 Search by NAME + PHONE
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredEmployees =
          _allEmployees.where((e) {
            return (e['name'] ?? '').toLowerCase().contains(query) ||
                (e['phone'] ?? '').toString().contains(query);
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
      _filteredEmployees = _allEmployees;
    });
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
                      hintText: "Search name or phone...",
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),

                      // ❌ No borders
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,

                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                )
                : const Text("Employees", style: TextStyle(color: whiteColor)),

        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: whiteColor,
            ),
            onPressed: () => _isSearching ? _stopSearch() : _startSearch(),
          ),
        ],
      ),

      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          if (state is EmployeeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EmployeeLoaded) {
            _allEmployees = state.employees;
            if (!_isSearching) {
              _filteredEmployees = _allEmployees;
            }

            final employees = _filteredEmployees;

            final totalEmployees = employees.length;
            final totalSalary = employees.fold<num>(
              0,
              (sum, e) => sum + (num.tryParse(e['salary'].toString()) ?? 0),
            );

            return Column(
              children: [
                /// METRICS
                Container(
                  padding: const EdgeInsets.all(12),
                  color: const Color(0xFF2E7D32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "Total Employees",
                            style: TextStyle(color: whiteColor),
                          ),
                          Text(
                            "$totalEmployees",
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
                            "Total Salary",
                            style: TextStyle(color: whiteColor),
                          ),
                          Text(
                            "₹$totalSalary",
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

                /// LIST + PULL TO REFRESH
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: const Color(0xFF2E7D32),
                    child:
                        employees.isEmpty
                            ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 200),
                                Center(child: Text("No employees found")),
                              ],
                            )
                            : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              itemCount: employees.length,
                              itemBuilder: (context, index) {
                                final emp = employees[index];

                                return Card(
                                  elevation: 1,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => EmployeeDetailPage(
                                                id: emp['id'],
                                              ),
                                        ),
                                      );
                                    },

                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          emp['name'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "₹${emp['salary'] ?? 0}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),

                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("📞 ${emp['phone']}"),
                                          Icon(
                                            emp['is_active'] == 1
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color:
                                                emp['is_active'] == 1
                                                    ? Colors.green
                                                    : Colors.red,
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

          if (state is EmployeeError) {
            return Center(
              child: Text(
                "Error: ${state.message}",
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          return const SizedBox();
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D32),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EmployeeFormPage()),
          );
        },
        child: const Icon(Icons.add, color: whiteColor),
      ),
    );
  }
}
