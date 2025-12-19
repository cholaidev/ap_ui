import 'package:ap_ui/shared/date_filtered_helper.dart';
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
  DateFilterType _filter = DateFilterType.today;
  DateTimeRange? _customRange;

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
        /// ✅ DELETE SUCCESS
        if (state is SupplyDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );

          context.read<SupplyBloc>().add(LoadSupplies());
          Navigator.pop(context);
        }

        /// ✅ UPDATE / EDIT SUCCESS
        if (state is SupplySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );

          context.read<SupplyBloc>().add(LoadSupplies());
          Navigator.pop(context);
        }

        /// ❌ ERROR
        if (state is SupplyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
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
                  (_) => const [
                    PopupMenuItem(value: "edit", child: Text("Edit")),
                    PopupMenuItem(
                      value: "delete",
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
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

            if (state is! SupplyDetailLoaded) {
              return const Center(child: Text("Unable to load supply"));
            }

            final s = state.supply;
            final List items = s['items'] ?? [];

            double deliveredQty = 0;
            double deliveredAmount = 0;
            int deliveredCount = 0;

            double undeliveredQty = 0;
            double undeliveredAmount = 0;
            int undeliveredCount = 0;

            for (final item in items) {
              final date = DateTime.parse(item['created_at']);

              if (!DateFilterHelper.isInRange(
                date: date,
                filter: _filter,
                customRange: _customRange,
              ))
                continue;

              final qty = (item['quantity'] ?? 0).toDouble();
              final amount = (item['amount'] ?? 0).toDouble();

              if (item['is_delivered'] == 1) {
                deliveredQty += qty;
                deliveredAmount += amount;
                deliveredCount++;
              } else {
                undeliveredQty += qty;
                undeliveredAmount += amount;
                undeliveredCount++;
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _info("Employee", s['employee']['name']),
                      _info("Phone", s['employee']['phone'] ?? "N/A"),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _info("Total Liters", "${s['total_quantity']} L"),
                      _info("Total Amount", "₹ ${s['total_amount']}"),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _metricCard(
                        "Delivered ($deliveredCount)",
                        "$deliveredQty L",
                        "₹ $deliveredAmount",
                        Colors.green,
                        Icons.check_circle,
                      ),
                      const SizedBox(width: 2),
                      _metricCard(
                        "Undelivered ($undeliveredCount)",
                        "$undeliveredQty L",
                        "₹ $undeliveredAmount",
                        Colors.red,
                        Icons.pending_actions,
                      ),
                    ],
                  ),
                  const Divider(),
                  const Text(
                    "Supply Items",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...items.map<Widget>((i) {
                    final customerName =
                        i['customer']?['name'] ??
                        'Customer #${i['customer_id']}';

                    return Card(
                      child: ListTile(
                        title: Text(customerName),
                        subtitle: Text("${i['milk']} • ${i['quantity']} L"),
                        trailing: Text(
                          i['is_delivered'] == 1 ? "Delivered" : "Pending",
                          style: TextStyle(
                            color:
                                i['is_delivered'] == 1
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _metricCard(
    String title,
    String qty,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 6),
                  Text(title, style: TextStyle(color: color)),
                ],
              ),
              const SizedBox(height: 8),
              Text(qty, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(amount, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
