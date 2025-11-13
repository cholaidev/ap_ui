sealed class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<dynamic> customers;
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

class CustomerError extends CustomerState {
  final String error;
  CustomerError(this.error);
}
