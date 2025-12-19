sealed class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List customers;
  CustomerLoaded(this.customers);
}

class CustomerDetailLoaded extends CustomerState {
  final Map<String, dynamic> customer;
  CustomerDetailLoaded(this.customer);
}

class CustomerSuccess extends CustomerState {
  final String message;
  CustomerSuccess(this.message);
}

class DeleteSuccess extends CustomerState {
  final String message;
  DeleteSuccess(this.message);
}

class CustomerError extends CustomerState {
  final String error;
  CustomerError(this.error);
}

class CustomerHistoryError extends CustomerState {
  final String error;
  CustomerHistoryError(this.error);
}
