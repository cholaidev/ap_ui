import 'package:ap_ui/shared/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ap_ui/customer/bloc/customer_bloc.dart';
import 'package:ap_ui/customer/bloc/customer_event.dart';
import 'package:ap_ui/customer/bloc/customer_state.dart';
import 'customer_detail_page.dart';
import 'customer_form_page.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(FetchCustomers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: whiteColor),
        title: const Text("Customers", style: TextStyle(color: whiteColor)),
        backgroundColor: const Color(0xFF2E7D32),
      ),

      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          print('check runtime state ${state.runtimeType}');
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerLoaded) {
            final customers = state.customers;

            // 🔢 Total stats
            final totalCustomers = customers.length;
            num totalLiters = customers.fold(
              0,
              (sum, e) => sum + (e["quantity"] ?? 0),
            );

            return Column(
              children: [
                /// 🔥 METRICS CARD
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              "Total Customers",
                              style: TextStyle(color: whiteColor, fontSize: 14),
                            ),
                            const SizedBox(height: 5),
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
                              style: TextStyle(color: whiteColor, fontSize: 14),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "$totalLiters L",
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
                ),

                /// CUSTOMER LIST
                Expanded(
                  child:
                      customers.isEmpty
                          ? const Center(
                            child: Text(
                              "No customers found",
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            itemCount: customers.length,
                            itemBuilder: (context, index) {
                              final c = customers[index];

                              return Card(
                                elevation: 1,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) =>
                                                CustomerDetailPage(id: c['id']),
                                      ),
                                    );
                                  },

                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      /// NAME
                                      Text(
                                        c['name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      /// MILK + LITERS
                                      Text(
                                        "${c['milk']} (${c['quantity']} L)",
                                        style: const TextStyle(
                                          fontSize: 14,
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
                                        /// PHONE
                                        Text(
                                          "📞 ${c['phone'] ?? ''}",
                                          style: const TextStyle(fontSize: 14),
                                        ),

                                        /// ACTIVE/INACTIVE ICON
                                        Icon(
                                          c['is_active'] == 1
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color:
                                              c['is_active'] == 1
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
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomerFormPage()),
            ),
        child: const Icon(Icons.add, color: whiteColor),
      ),
    );
  }
}
