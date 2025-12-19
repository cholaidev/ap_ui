import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ap_ui/shared/constant/colors.dart';

import '../bloc/supply_bloc.dart';
import '../bloc/supply_event.dart';
import '../bloc/supply_state.dart';
import 'supply_form_page.dart';

class SupplyDetailPage extends StatefulWidget {
  final int id;

  const SupplyDetailPage({super.key, required this.id});

  @override
  State<SupplyDetailPage> createState() => _SupplyDetailPageState();
}

class _SupplyDetailPageState extends State<SupplyDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<SupplyBloc>().add(GetSupplyDetails(widget.id));
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Delete Supply?"),
            content: const Text("Are you sure you want to delete this supply?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  context.read<SupplyBloc>().add(DeleteSupply(id));
                  Navigator.pop(context);
                },
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupplyBloc, SupplyState>(
      listener: (context, state) {
        print('check state ${state.runtimeType}');
        if (state is SupplySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
          context.read<SupplyBloc>().add(LoadSupplies());
          Navigator.pop(context);
        }

        if (state is SupplyDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
          context.read<SupplyBloc>().add(LoadSupplies());
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: whiteColor),
          title: const Text(
            "Supply Details",
            style: TextStyle(color: whiteColor),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          actions: [
            PopupMenuButton<String>(
              iconColor: whiteColor,
              onSelected: (value) {
                final state = context.read<SupplyBloc>().state;
                if (state is! SupplyDetailLoaded) return;

                if (value == "edit") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SupplyFormPage(editSupply: state.supply),
                    ),
                  );
                } else if (value == "delete") {
                  _confirmDelete(widget.id);
                }
              },
              itemBuilder:
                  (context) => const [
                    PopupMenuItem(
                      value: "edit",
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text("Edit"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "delete",
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text("Delete", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),

        body: BlocBuilder<SupplyBloc, SupplyState>(
          builder: (context, state) {
            if (state is SupplyLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SupplyDetailLoaded) {
              final s = state.supply;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ROW 1: EMPLOYEE + PHONE
                    Row(
                      children: [
                        _info("Employee", s['employee']['name']),
                        _info("Phone", s['employee']['phone'] ?? "N/A"),
                      ],
                    ),
                    const SizedBox(height: 18),

                    /// ROW 2: TOTAL LITERS + AMOUNT
                    Row(
                      children: [
                        _info("Total Liters", "${s['total_quantity']} L"),
                        _info("Total Amount", "₹ ${s['total_amount']}"),
                      ],
                    ),

                    const SizedBox(height: 25),
                    const Divider(),

                    /// ITEMS HEADER
                    const Text(
                      "Supply Items",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// ITEMS LIST
                    ...s['items'].map<Widget>(
                      (i) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(
                            Icons.person_outline,
                            color: Colors.green,
                          ),
                          title: Text(
                            i['customer']['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("${i['milk']} • ${i['quantity']} L"),
                          trailing: Text(
                            "₹ ${i['amount']}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              );
            }

            return const Center(child: Text("Unable to load supply details"));
          },
        ),
      ),
    );
  }

  /// INFO TILE (same as customer page)
  Widget _info(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
