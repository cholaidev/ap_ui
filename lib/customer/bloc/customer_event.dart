import 'package:equatable/equatable.dart';

sealed class CustomerEvent {
  const CustomerEvent();
}

class FetchCustomers extends CustomerEvent {
  final String status;
  FetchCustomers({required this.status});
}

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

class DeleteCustomer extends CustomerEvent {
  final int id;
  DeleteCustomer(this.id);
}

class BulkCustomer extends CustomerEvent {
  final List<Map<String, dynamic>> validCustomers;
  BulkCustomer(this.validCustomers);
}

class ReactivateCustomer extends CustomerEvent {
  final int id;
  ReactivateCustomer(this.id);
}
