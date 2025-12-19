import 'package:ap_ui/employee/bloc/employee_state.dart';
import 'package:ap_ui/setting/bloc/setting_bloc.dart';
import 'package:ap_ui/setting/bloc/setting_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ap_ui/auth/bloc/auth_bloc.dart';
import 'package:ap_ui/auth/bloc/auth_event.dart';
import 'package:ap_ui/auth/screen/login_page.dart';

import 'package:ap_ui/customer/bloc/customer_bloc.dart';
import 'package:ap_ui/customer/bloc/customer_event.dart';
import 'package:ap_ui/customer/bloc/customer_state.dart';

import 'package:ap_ui/employee/bloc/employee_bloc.dart';
import 'package:ap_ui/employee/bloc/employee_event.dart';

import 'package:ap_ui/supply/cubit/supply_cubit_cubit.dart';

import 'package:ap_ui/shared/constant/colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late CustomerBloc customerBloc;
  late EmployeeBloc employeeBloc;
  late SupplyCubitCubit supplyCubit;
  late SettingBloc settingBloc;

  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();

    customerBloc = context.read<CustomerBloc>()..add(FetchCustomers());
    employeeBloc = context.read<EmployeeBloc>()..add(LoadEmployees());
    supplyCubit = context.read<SupplyCubitCubit>();
    settingBloc = context.read<SettingBloc>();
    settingBloc.add(LoadSettings());
    _priceController = TextEditingController(
      text: supplyCubit.priceofMilk.toString(),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  /// 🔴 Logout
  void _logout() {
    context.read<AuthBloc>().add(LogoutEvent());
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  /// 🔴 Logout confirmation
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  _logout();
                },
                child: const Text("Logout"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      /// 🔹 APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text("Dashboard", style: TextStyle(color: whiteColor)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: whiteColor),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),

      /// 🔹 BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 DASHBOARD STATS
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.9,
              children: [
                BlocBuilder<CustomerBloc, CustomerState>(
                  bloc: customerBloc,
                  builder:
                      (_, __) => _DashboardCard(
                        title: "Active Customers",
                        value: '${customerBloc.totalActiveCustomers}',
                        icon: Icons.people,
                        color: Colors.green,
                      ),
                ),
                BlocBuilder<CustomerBloc, CustomerState>(
                  bloc: customerBloc,
                  builder:
                      (_, __) => _DashboardCard(
                        title: "Inactive Customers",
                        value: '${customerBloc.totalInActiveCustomers}',
                        icon: Icons.people_outline,
                        color: Colors.orange,
                      ),
                ),
                BlocBuilder<EmployeeBloc, EmployeeState>(
                  bloc: employeeBloc,
                  builder:
                      (_, __) => _DashboardCard(
                        title: "Active Employees",
                        value: '${employeeBloc.totalActiveEmp}',
                        icon: Icons.badge,
                        color: Colors.blue,
                      ),
                ),
                BlocBuilder<EmployeeBloc, EmployeeState>(
                  bloc: employeeBloc,
                  builder:
                      (_, __) => _DashboardCard(
                        title: "Inactive Employees",
                        value: '${employeeBloc.totalInActiveEmp}',
                        icon: Icons.badge_outlined,
                        color: Colors.red,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// 🔹 SETTINGS TITLE
            const Text(
              "Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            /// 🔹 MILK PRICE CARD
            BlocBuilder(
              bloc: settingBloc,
              builder: (context, state) {
                final cubit = settingBloc;
                final newValue = cubit.milkPrice;

                if (_priceController.text != newValue) {
                  _priceController.text =
                      newValue != null ? newValue.toString() : 0.toString();
                }

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// TITLE
                        Row(
                          children: const [
                            Icon(Icons.currency_rupee, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              "Milk Price",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// INPUT
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Price per Liter",
                            prefixText: "₹ ",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            final price = num.tryParse(value);
                            if (price != null) {
                              settingBloc.add(UpdateMilkPrice(price));
                            }
                          },
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "This price is used for all supply calculations",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 DASHBOARD CARD
class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              maxLines: 2,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
