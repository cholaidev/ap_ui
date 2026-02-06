import 'package:ap_ui/customer/bloc/history_bloc/customer_history_bloc.dart';
import 'package:ap_ui/shared/resolve_datefilter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ap_ui/shared/date_filtered_helper.dart';

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

  double _d(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

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
        /// HEADER
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

        BlocBuilder<CustomerHistoryBloc, CustomerHistoryState>(
          builder: (context, state) {
            if (state is CustomerDeliveryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CustomerDeliveryHistory) {
              final history = state.history;

              final delivered =
                  history.where((h) => h['is_delivered'] == 1).toList();
              final undelivered =
                  history.where((h) => h['is_delivered'] == 0).toList();

              /// 🐄🐃 METRICS
              double deliveredCow = 0, deliveredBuffalo = 0;
              double pendingCow = 0, pendingBuffalo = 0;

              for (final h in delivered) {
                deliveredCow += _d(h['cow_milk_quantity']);
                deliveredBuffalo += _d(h['buffalo_milk_quantity']);
              }

              for (final h in undelivered) {
                pendingCow += _d(h['cow_milk_quantity']);
                pendingBuffalo += _d(h['buffalo_milk_quantity']);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// METRICS
                  Row(
                    children: [
                      _metricCard(
                        "Delivered",
                        "🐄 ${deliveredCow} L\n🐃 ${deliveredBuffalo} L",
                        Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _metricCard(
                        "Pending",
                        "🐄 ${pendingCow} L\n🐃 ${pendingBuffalo} L",
                        Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (history.isEmpty)
                    const Text(
                      "No delivery history found",
                      style: TextStyle(color: Colors.grey),
                    ),

                  /// HISTORY LIST
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    itemBuilder: (_, i) {
                      final h = history[i];
                      final deliveredFlag = h['is_delivered'] == 1;

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    deliveredFlag ? "Delivered" : "Pending",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          deliveredFlag
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                  Text(
                                    deliveredFlag
                                        ? _formatDate(h['updated_at'])
                                        : _formatDate(h['created_at']),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              if (_d(h['cow_milk_quantity']) > 0)
                                Text(
                                  "🐄 Cow : ${_d(h['cow_milk_quantity'])} L",
                                ),

                              if (_d(h['buffalo_milk_quantity']) > 0)
                                Text(
                                  "🐃 Buffalo : ${_d(h['buffalo_milk_quantity'])} L",
                                ),

                              const Divider(),

                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Total : ${_d(h['total_quantity'])} L",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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

  Widget _metricCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
