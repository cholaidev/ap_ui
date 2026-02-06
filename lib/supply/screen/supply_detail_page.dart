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
  final bool is_from_assigned;

  const SupplyDetailPage({
    super.key,
    required this.id,
    required this.is_from_assigned,
  });

  @override
  State<SupplyDetailPage> createState() => _SupplyDetailPageState();
}

class _SupplyDetailPageState extends State<SupplyDetailPage> {
  DateFilterType _filter = DateFilterType.today;
  DateTimeRange? _customRange;

  double _d(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0;

  @override
  void initState() {
    super.initState();
    context.read<SupplyBloc>().add(GetSupplyDetails(widget.id));
  }

  Future<bool> _onPhoneBackPressed() async {
    context.read<SupplyBloc>().add(
      LoadSupplies(is_from_assigned: widget.is_from_assigned),
    );
    return true;
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
        if (state is SupplyDeleteSuccess || state is SupplySuccess) {
          context.read<SupplyBloc>().add(
            LoadSupplies(is_from_assigned: widget.is_from_assigned),
          );
          Navigator.pop(context);
        }

        if (state is SupplyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          if (didPop) _onPhoneBackPressed();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: BackButton(color: whiteColor),
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
                        builder:
                            (_) => SupplyFormPage(
                              editSupply: state.supply,
                              is_from_assigned: widget.is_from_assigned,
                            ),
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

              double deliveredCow = 0;
              double deliveredBuffalo = 0;
              double undeliveredCow = 0;
              double undeliveredBuffalo = 0;

              int deliveredCount = 0;
              int undeliveredCount = 0;

              for (final item in items) {
                final date = DateTime.parse(item['created_at']);

                if (!DateFilterHelper.isInRange(
                  date: date,
                  filter: _filter,
                  customRange: _customRange,
                ))
                  continue;

                final cowQty = _d(item['cow_milk_quantity']);
                final buffaloQty = _d(item['buffalo_milk_quantity']);

                if (item['is_delivered'] == 1) {
                  deliveredCow += cowQty;
                  deliveredBuffalo += buffaloQty;
                  deliveredCount++;
                } else {
                  undeliveredCow += cowQty;
                  undeliveredBuffalo += buffaloQty;
                  undeliveredCount++;
                }
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _info("Employee", s['employee']['name']),
                        _info("Phone", s['employee']['phone'] ?? "N/A"),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _metricSplitCard(
                          title: "Delivered ($deliveredCount)",
                          cow: deliveredCow,
                          buffalo: deliveredBuffalo,
                          color: Colors.green,
                          icon: Icons.check_circle,
                        ),
                        const SizedBox(width: 6),
                        _metricSplitCard(
                          title: "Undelivered ($undeliveredCount)",
                          cow: undeliveredCow,
                          buffalo: undeliveredBuffalo,
                          color: Colors.red,
                          icon: Icons.pending_actions,
                        ),
                      ],
                    ),

                    const Divider(),
                    const Text(
                      "Supply Items",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    ...items.map<Widget>((i) {
                      final customerName =
                          i['customer']?['name'] ??
                          'Customer #${i['customer_id']}';

                      return Card(
                        child: ListTile(
                          title: Text(customerName),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_d(i['cow_milk_quantity']) > 0)
                                Text("🐄 Cow : ${i['cow_milk_quantity']} L"),

                              if (_d(i['buffalo_milk_quantity']) > 0)
                                Text(
                                  "🐃 Buffalo : ${i['buffalo_milk_quantity']} L",
                                ),

                              Text(
                                "Total : ${i['total_quantity']} L",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),

                          trailing: Text(
                            i['is_delivered'] == 1 ? "Delivered" : "Pending",
                            style: TextStyle(
                              color:
                                  i['is_delivered'] == 1
                                      ? Colors.green
                                      : Colors.red,
                              fontWeight: FontWeight.bold,
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

  Widget _metricSplitCard({
    required String title,
    required double cow,
    required double buffalo,
    required Color color,
    required IconData icon,
  }) {
    final total = cow + buffalo;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
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
            const SizedBox(height: 6),

            if (cow > 0) Text("🐄 Cow : ${cow.toStringAsFixed(2)} L"),

            if (buffalo > 0)
              Text("🐃 Buffalo : ${buffalo.toStringAsFixed(2)} L"),

            const SizedBox(height: 4),
            Text(
              "Total : ${total.toStringAsFixed(2)} L",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
