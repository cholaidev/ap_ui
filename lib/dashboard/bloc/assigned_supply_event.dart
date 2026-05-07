part of 'assigned_supply_bloc.dart';

sealed class AssignedSupplyEvent {}

class AssignSupplyDate extends AssignedSupplyEvent {
  final DateTime supplyDate;
  AssignSupplyDate(this.supplyDate);
}

class AssignMultipleSupplyDates extends AssignedSupplyEvent {
  final List<DateTime> supplyDates;

  AssignMultipleSupplyDates(this.supplyDates);
}
