import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ap_ui/shared/date_filtered_helper.dart';
import '../../shared/constant/colors.dart';

import '../bloc/supply_bloc.dart';
import '../bloc/supply_event.dart';
import '../bloc/supply_state.dart';
import 'supply_form_page.dart';
import 'supply_detail_page.dart';

class SupplyListPage extends StatefulWidget {
  final bool is_from_assigned;
  const SupplyListPage({super.key, required this.is_from_assigned});

  @override
  State<SupplyListPage> createState() => _SupplyListPageState();
}

class _SupplyListPageState extends State<SupplyListPage> {
  DateFilterType _filter = DateFilterType.today;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();

    /// 🔥 DEFAULT = TODAY
    final range = _resolveDateRange(DateFilterType.today);
    context.read<SupplyBloc>().add(
      LoadSupplies(
        from: range.start,
        to: range.end,
        is_from_assigned: widget.is_from_assigned,
      ),
    );
  }

  /// 🔹 Convert filter → DateTimeRange
  DateTimeRange _resolveDateRange(DateFilterType filter) {
    final now = DateTime.now();

    switch (filter) {
      case DateFilterType.today:
        final start = DateTime(now.year, now.month, now.day);
        final end = start.add(const Duration(days: 1));
        return DateTimeRange(start: start, end: end);

      case DateFilterType.week:
        final start = DateTime(
          now.year,
          now.month,
          now.day - (now.weekday - 1),
        );
        final end = start.add(const Duration(days: 7));
        return DateTimeRange(start: start, end: end);

      case DateFilterType.month:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return DateTimeRange(start: start, end: end);

      case DateFilterType.custom:
        return _customRange!;
    }
  }

  Future<void> _onFilterChange(DateFilterType value) async {
    if (value == DateFilterType.custom) {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );

      if (range == null) return;

      setState(() {
        _filter = value;
        _customRange = range;
      });

      context.read<SupplyBloc>().add(
        LoadSupplies(
          from: range.start,
          to: range.end,
          is_from_assigned: widget.is_from_assigned,
        ),
      );
    } else {
      final range = _resolveDateRange(value);

      setState(() {
        _filter = value;
        _customRange = null;
      });

      context.read<SupplyBloc>().add(
        LoadSupplies(
          from: range.start,
          to: range.end,
          is_from_assigned: widget.is_from_assigned,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supplies", style: TextStyle(color: whiteColor)),
        backgroundColor: const Color(0xFF2E7D32),
      ),

      body: Column(
        children: [
          /// 🔽 DATE FILTER BAR
          Container(
            padding: const EdgeInsets.all(6),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Filter by date",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    DropdownButton<DateFilterType>(
                      value: _filter,
                      underline: const SizedBox(),
                      onChanged: (v) {
                        if (v != null) _onFilterChange(v);
                      },
                      items: const [
                        DropdownMenuItem(
                          value: DateFilterType.today,
                          child: Text("Today"),
                        ),
                        DropdownMenuItem(
                          value: DateFilterType.week,
                          child: Text("This Week"),
                        ),
                        DropdownMenuItem(
                          value: DateFilterType.month,
                          child: Text("This Month"),
                        ),
                        DropdownMenuItem(
                          value: DateFilterType.custom,
                          child: Text("Custom"),
                        ),
                      ],
                    ),
                  ],
                ),

                if (_filter == DateFilterType.custom && _customRange != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "From ${_formatDate(_customRange!.start)} "
                      "to ${_formatDate(_customRange!.end)}",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          /// 📦 SUPPLY LIST (API DATA ONLY)
          Expanded(
            child: BlocBuilder<SupplyBloc, SupplyState>(
              builder: (context, state) {
                if (state is SupplyLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SupplyLoaded) {
                  final supplies = state.supplies;

                  if (supplies.isEmpty) {
                    return const Center(child: Text("No supplies found"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(6),
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
                                builder:
                                    (_) => SupplyDetailPage(
                                      id: s['id'],
                                      is_from_assigned: widget.is_from_assigned,
                                    ),
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

                if (state is SupplyError) {
                  return Center(child: Text(state.error));
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: whiteColor),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) =>
                      SupplyFormPage(is_from_assigned: widget.is_from_assigned),
            ),
          );
        },
      ),
    );
  }
}
