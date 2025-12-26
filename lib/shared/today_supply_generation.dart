bool isTodaySupplyGenerated(Map<String, dynamic> settings) {
  if (settings['today_supply_generated'] != true) return false;

  final supplyDate = DateTime.tryParse(settings['supply_date'] ?? '');
  if (supplyDate == null) return false;

  final today = DateTime.now();

  return supplyDate.year == today.year &&
      supplyDate.month == today.month &&
      supplyDate.day == today.day;
}
