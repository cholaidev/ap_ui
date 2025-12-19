part of 'customer_history_bloc.dart';

sealed class CustomerHistoryEvent {}

class GetCustomerDeliveryHistoryEvent extends CustomerHistoryEvent {
  final int customerId;
  final DateTime? from;
  final DateTime? to;

  GetCustomerDeliveryHistoryEvent({
    required this.customerId,
    this.from,
    this.to,
  });
}
