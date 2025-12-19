part of 'customer_history_bloc.dart';

sealed class CustomerHistoryState {}

final class CustomerHistoryInitial extends CustomerHistoryState {}

class CustomerDeliveryHistory extends CustomerHistoryState {
  final List history;
  CustomerDeliveryHistory(this.history);
}

class CustomerDeliveryLoading extends CustomerHistoryState {}

class CustomerDeliveryHistoryError extends CustomerHistoryState {
  final String error;
  CustomerDeliveryHistoryError(this.error);
}
