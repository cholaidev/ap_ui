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
          print('check run time ${state.runtimeType}');
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerLoaded) {
            print('customer loder ${state.customers}');
            if (state.customers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 10),
                    const Text(
                      "No customers found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Please add a new customer",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }

            // 🔥 Normal List of customers
            return ListView.builder(
              itemCount: state.customers.length,
              itemBuilder: (context, index) {
                final customer = state.customers[index];
                return ListTile(
                  title: Text(customer['name']),
                  subtitle: Text(customer['phone'] ?? ''),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CustomerDetailPage(id: customer['id']),
                      ),
                    );
                  },
                );
              },
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
