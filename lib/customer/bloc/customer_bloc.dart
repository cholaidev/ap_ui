import 'package:ap_ui/customer/repo/customer_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  // final String token;
  final customerRepo = CustomerRepository();

  num totalActiveCustomers = 0;
  num totalInActiveCustomers = 0;

  List customerHistory = [];
  CustomerBloc() : super(CustomerInitial()) {
    on<FetchCustomers>((event, emit) async {
      emit(CustomerLoading());
      try {
        final customers = await customerRepo.fetchCustomers();
        print('over all customers $customers');
        totalActiveCustomers =
            customers.where((c) => c['is_active'] == 1).length;
        print('total active customers $totalActiveCustomers');
        totalInActiveCustomers =
            customers.where((c) => c['is_active'] == 0).length;
        print('fetch customers $customers');
        emit(CustomerLoaded(customers));
      } catch (e, trace) {
        print('get customer erro $e $trace');
        emit(CustomerError(e.toString()));
      }
    });

    on<GetCustomerDetails>((event, emit) async {
      emit(CustomerLoading());
      try {
        final customer = await customerRepo.getCustomerDetails(event.id);
        emit(CustomerDetailLoaded(customer));
      } catch (e) {
        emit(CustomerError(e.toString()));
      }
    });

    on<AddCustomer>((event, emit) async {
      emit(CustomerLoading());
      try {
        await customerRepo.addCustomer(event.data);
        emit(CustomerSuccess("Customer added successfully"));
      } catch (e) {
        emit(CustomerError(e.toString()));
      }
    });

    on<UpdateCustomer>((event, emit) async {
      emit(CustomerLoading());
      try {
        await customerRepo.updateCustomer(event.id, event.data);
        emit(CustomerSuccess("Customer updated successfully"));
      } catch (e) {
        emit(CustomerError(e.toString()));
      }
    });

    on<DeleteCustomer>((event, emit) async {
      emit(CustomerLoading());
      try {
        await customerRepo.deleteCustomer(event.id);
        emit(DeleteSuccess("delete customer successfully"));
      } catch (e) {
        emit(CustomerError(e.toString()));
      }
    });
  }
}
