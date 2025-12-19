import 'package:ap_ui/customer/bloc/history_bloc/customer_history_bloc.dart';
import 'package:ap_ui/shared/resolve_datefilter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ap_ui/shared/date_filtered_helper.dart';
import '../../shared/constant/colors.dart';

import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';

class CustomerDeliveryHistoryWidget extends StatefulWidget {
  final int customerId;
  const CustomerDeliveryHistoryWidget({super.key, required this.customerId});

  @override
  State<CustomerDeliveryHistoryWidget> createState() =>
      _CustomerDeliveryHistoryWidgetState();
}

class _CustomerDeliveryHistoryWidgetState
    extends State<CustomerDeliveryHistoryWidget> {
  DateFilterTypes _filter = DateFilterTypes.today;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// 🔹 Load history from API
  void _load() {
    final range = resolveDateRange(_filter, _customRange);
    context.read<CustomerHistoryBloc>().add(
      GetCustomerDeliveryHistoryEvent(
        customerId: widget.customerId,
        from: range.start,
        to: range.end,
      ),
    );
  }

  Future<void> _changeFilter(DateFilterTypes value) async {
    if (value == DateFilterTypes.custom) {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (range == null) return;
      _customRange = range;
    } else {
      _customRange = null;
    }

    setState(() => _filter = value);
    _load();
  }

  String _formatDate(String date) {
    final d = DateTime.parse(date);
    return "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/"
        "${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔽 FILTER HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Delivery History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<DateFilterTypes>(
              value: _filter,
              underline: const SizedBox(),
              onChanged: (v) => _changeFilter(v!),
              items: const [
                DropdownMenuItem(
                  value: DateFilterTypes.today,
                  child: Text("Today"),
                ),
                DropdownMenuItem(
                  value: DateFilterTypes.week,
                  child: Text("Week"),
                ),
                DropdownMenuItem(
                  value: DateFilterTypes.month,
                  child: Text("Month"),
                ),
                DropdownMenuItem(
                  value: DateFilterTypes.custom,
                  child: Text("Custom"),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        /// 📊 DATA + LIST
        BlocBuilder<CustomerHistoryBloc, CustomerHistoryState>(
          builder: (context, state) {
            if (state is CustomerDeliveryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CustomerDeliveryHistory) {
              final history = state.history;

              /// 🔢 METRICS
              double totalQty = 0;
              double totalAmount = 0;

              for (final h in history) {
                totalQty += (h['quantity'] ?? 0).toDouble();
                totalAmount += (h['amount'] ?? 0).toDouble();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔥 METRIC CARDS
                  Row(
                    children: [
                      _metricCard(
                        "Delivered",
                        "${history.length}",
                        Icons.local_shipping,
                        Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _metricCard(
                        "Total Qty",
                        "$totalQty L",
                        Icons.water_drop,
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _metricCard(
                        "Amount",
                        "₹ $totalAmount",
                        Icons.currency_rupee,
                        Colors.orange,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (history.isEmpty)
                    const Text(
                      "No deliveries found",
                      style: TextStyle(color: Colors.grey),
                    ),

                  /// 📜 DELIVERY LIST
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    itemBuilder: (_, i) {
                      final h = history[i];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          title: Text(
                            "${h['quantity']} L • ₹ ${h['amount']}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "Delivered on ${_formatDate(h['created_at'])}",
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }

            if (state is CustomerDeliveryHistoryError) {
              return Text(state.error);
            }

            return const SizedBox();
          },
        ),
      ],
    );
  }

  /// 🔹 METRIC CARD
  Widget _metricCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
