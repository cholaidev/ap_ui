import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/supply_bloc.dart';
import '../bloc/supply_event.dart';
import '../bloc/supply_state.dart';
import 'supply_form_page.dart';
import 'supply_detail_page.dart';
import '../../shared/constant/colors.dart';

class SupplyListPage extends StatefulWidget {
  const SupplyListPage({super.key});

  @override
  State<SupplyListPage> createState() => _SupplyListPageState();
}

class _SupplyListPageState extends State<SupplyListPage> {
  @override
  void initState() {
    super.initState();
    context.read<SupplyBloc>().add(LoadSupplies());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supplies", style: TextStyle(color: whiteColor)),
        backgroundColor: const Color(0xFF2E7D32),
      ),

      body: BlocBuilder<SupplyBloc, SupplyState>(
        builder: (context, state) {
          if (state is SupplyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SupplyLoaded) {
            final supplies = state.supplies;
            print('fetch supplies $supplies');
            if (supplies.isEmpty) {
              return const Center(child: Text("No supplies found"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: supplies.length,
              itemBuilder: (context, index) {
                final s = supplies[index];

                return Card(
                  elevation: 2,
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SupplyDetailPage(id: s['id']),
                        ),
                      );
                    },
                    title: Text(
                      "Employee: ${s['employee']['name']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("🍼 ${s['total_quantity']} L"),
                          Text("₹ ${s['total_amount']}"),
                        ],
                      ),
                    ),
                    trailing: Icon(
                      s['is_supplied'] == true
                          ? Icons.check_circle
                          : Icons.pending,
                      color:
                          s['is_supplied'] == true
                              ? Colors.green
                              : Colors.orange,
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: whiteColor),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SupplyFormPage()),
          );
        },
      ),
    );
  }
}
