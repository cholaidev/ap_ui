import 'package:ap_ui/customer/screen/customer_list_page.dart';
import 'package:ap_ui/dashboard/bloc/assigned_supply_bloc.dart';
import 'package:ap_ui/dashboard/bloc/assigned_supply_state.dart';
import 'package:ap_ui/employee/bloc/employee_state.dart';
import 'package:ap_ui/employee/screen/employee_list.dart';
import 'package:ap_ui/setting/bloc/setting_bloc.dart';
import 'package:ap_ui/setting/bloc/setting_event.dart';
import 'package:ap_ui/setting/bloc/setting_state.dart';
import 'package:ap_ui/supply/bloc/supply_bloc.dart';
import 'package:ap_ui/supply/screen/supply_form_page.dart';
import 'package:ap_ui/supply/screen/supply_list_screen.dart';
import 'package:ap_ui/supply/supply.dart';
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
  late AssignedSupplyBloc assignedSupplyBloc;

  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();

    customerBloc =
        context.read<CustomerBloc>()..add(FetchCustomers(status: 'all'));
    employeeBloc =
        context.read<EmployeeBloc>()..add(LoadEmployees(status: 'all'));
    supplyCubit = context.read<SupplyCubitCubit>();
    settingBloc = context.read<SettingBloc>();
    assignedSupplyBloc = context.read<AssignedSupplyBloc>();
    settingBloc.add(CheckSupply());
    settingBloc.add(LoadSettings());
    _priceController = TextEditingController(
      text: supplyCubit.priceofMilk.toString(),
    );
  }

  Future<void> _confirmAssignSupplyDate(DateTime selectedDate) async {
    final formattedDate = selectedDate.toLocal().toString().split(' ')[0];

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Supply Generation"),
          content: Text(
            "Are you sure you want to generate supply for\n\n📅 $formattedDate ?\n\nThis action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    // ❌ User cancelled
    if (confirmed != true) return;

    // ✅ Dispatch Bloc event
    assignedSupplyBloc.add(AssignSupplyDate(selectedDate));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Supply assigned for $formattedDate")),
    );
  }

  Future<void> _openSupplyDatePicker() async {
    final DateTime today = DateTime.now();

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(today.year - 1),
      lastDate: DateTime(today.year + 1),
    );

    if (selectedDate == null) return;

    // 🔔 Ask confirmation
    await _confirmAssignSupplyDate(selectedDate);
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
        leading: BackButton(color: whiteColor),
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
            BlocBuilder<SettingBloc, SettingState>(
              builder: (context, state) {
                bool isLocked = false;

                if (state is CheckSupplyState) {
                  isLocked = state.isSupplied;
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
                        Row(
                          children: const [
                            Icon(Icons.local_shipping, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              "Supply options",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.list, color: whiteColor),
                          label: Text(
                            style: TextStyle(color: whiteColor),

                            "init supply",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => const SupplyListPage(
                                      is_from_assigned: true,
                                    ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 10),

                        BlocConsumer<AssignedSupplyBloc, AssignedSupplyState>(
                          listener: (context, state) {
                            if (state is AssignedSupplySuccess) {
                              // context.read<SettingBloc>().add(CheckSupply());

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Supply generated successfully",
                                  ),
                                ),
                              );
                            }

                            if (state is AssignedSupplyError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.error)),
                              );
                            }
                          },
                          builder: (context, state) {
                            final bool isLoading =
                                state is AssignedSupplyLoading;

                            return ElevatedButton.icon(
                              icon:
                                  isLoading
                                      ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: whiteColor,
                                        ),
                                      )
                                      : const Icon(
                                        Icons.calendar_today,
                                        color: whiteColor,
                                      ),
                              label: Text(
                                isLocked
                                    ? "Supply Already Generated Today"
                                    : isLoading
                                    ? "Generating Supply..."
                                    : "Select Supply Date",
                                style: const TextStyle(color: whiteColor),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isLocked || isLoading
                                        ? Colors.grey
                                        : const Color(0xFF2E7D32),
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              onPressed:
                                  (isLocked || isLoading)
                                      ? null
                                      : _openSupplyDatePicker,
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        Text(
                          isLocked
                              ? "Supply has already been generated for today"
                              : "This will assign supply to all customers for selected date",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => CustomerListPage(status: 'active'),
                            ),
                          );
                        },
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => CustomerListPage(status: 'cancelled'),
                            ),
                          );
                        },
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => EmployeeListPage(status: 'active'),
                            ),
                          );
                        },
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => EmployeeListPage(status: 'cancelled'),
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// 🔹 SETTINGS TITLE
            // const Text(
            //   "Settings",
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),

            // const SizedBox(height: 10),

            // /// 🔹 MILK PRICE CARD
            // BlocBuilder<SettingBloc, SettingState>(
            //   builder: (context, state) {
            //     print('check runtime state ${state.runtimeType}');
            //     num? milkPrice;

            //     if (state is SettingLoaded) {
            //       milkPrice = state.milkPrice;
            //     }

            //     // sync controller safely
            //     final textValue = milkPrice?.toString() ?? '0';
            //     if (_priceController.text != textValue) {
            //       _priceController.text = textValue;
            //     }

            //     return Card(
            //       elevation: 4,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(16),
            //       ),
            //       child: Padding(
            //         padding: const EdgeInsets.all(16),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             /// TITLE
            //             Row(
            //               children: const [
            //                 Icon(Icons.currency_rupee, color: Colors.green),
            //                 SizedBox(width: 8),
            //                 Text(
            //                   "Milk Price",
            //                   style: TextStyle(
            //                     fontSize: 16,
            //                     fontWeight: FontWeight.bold,
            //                   ),
            //                 ),
            //               ],
            //             ),

            //             const SizedBox(height: 12),

            //             /// INPUT
            //             TextFormField(
            //               controller: _priceController,
            //               keyboardType: TextInputType.number,
            //               decoration: const InputDecoration(
            //                 labelText: "Price per Liter",
            //                 prefixText: "₹ ",
            //                 border: OutlineInputBorder(),
            //               ),
            //               onChanged: (value) {
            //                 final price = num.tryParse(value);
            //                 if (price != null) {
            //                   context.read<SettingBloc>().add(
            //                     UpdateMilkPrice(price),
            //                   );
            //                 }
            //               },
            //             ),

            //             const SizedBox(height: 8),

            //             const Text(
            //               "This price is used for all supply calculations",
            //               style: TextStyle(fontSize: 12, color: Colors.grey),
            //             ),
            //           ],
            //         ),
            //       ),
            //     );
            //   },
            // ),
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
  final VoidCallback? onTap;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
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
      ),
    );
  }
}
