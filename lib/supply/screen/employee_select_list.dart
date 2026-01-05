import 'package:ap_ui/employee/bloc/employee_bloc.dart';
import 'package:ap_ui/employee/bloc/employee_event.dart';
import 'package:ap_ui/employee/bloc/employee_state.dart';
import 'package:ap_ui/shared/constant/colors.dart';
import 'package:ap_ui/supply/cubit/supply_cubit_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeSelectListPage extends StatefulWidget {
  final Map? selectedEmployee;

  const EmployeeSelectListPage({super.key, this.selectedEmployee});

  @override
  State<EmployeeSelectListPage> createState() => _EmployeeSelectListPageState();
}

class _EmployeeSelectListPageState extends State<EmployeeSelectListPage> {
  Map? selected;
  late SupplyCubitCubit supplyCubit;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _allEmployees = [];
  List<dynamic> _filteredEmployees = [];

  @override
  void initState() {
    super.initState();

    if (widget.selectedEmployee != null) {
      selected = widget.selectedEmployee;
    }

    context.read<EmployeeBloc>().add(LoadEmployees());
    supplyCubit = context.read<SupplyCubitCubit>();

    _searchController.addListener(_onSearchChanged);
  }

  /// 🔍 SEARCH (NAME + PHONE)
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

  void _onDone() {
    supplyCubit.setEmployee(selected);
    Navigator.pop(context, selected);
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
                : const Text(
                  "Select Employee",
                  style: TextStyle(color: whiteColor),
                ),

        actions: [
          /// SEARCH ICON
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: whiteColor,
            ),
            onPressed: () => _isSearching ? _stopSearch() : _startSearch(),
          ),

          /// DONE
          TextButton(
            onPressed: selected == null ? null : _onDone,
            child: const Text(
              "DONE",
              style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
            ),
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

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: employees.length,
              itemBuilder: (_, index) {
                final emp = employees[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        selected = selected?['id'] == emp['id'] ? null : emp;
                      });
                    },

                    /// RADIO (SINGLE SELECT)
                    leading: Radio<int>(
                      value: emp['id'],
                      groupValue: selected?['id'],
                      onChanged: (_) {
                        setState(() {
                          selected = selected?['id'] == emp['id'] ? null : emp;
                        });
                      },
                    ),

                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("📞 ${emp['phone'] ?? '-'}"),
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
            );
          }

          if (state is EmployeeError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
