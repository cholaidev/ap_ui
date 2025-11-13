import 'package:equatable/equatable.dart';

sealed class CustomerEvent {
  const CustomerEvent();
}

class FetchCustomers extends CustomerEvent {}

class GetCustomerDetails extends CustomerEvent {
  final int id;
  GetCustomerDetails(this.id);
}

class AddCustomer extends CustomerEvent {
  final Map<String, dynamic> data;
  AddCustomer(this.data);
}

class UpdateCustomer extends CustomerEvent {
  final int id;
  final Map<String, dynamic> data;
  UpdateCustomer(this.id, this.data);
}
