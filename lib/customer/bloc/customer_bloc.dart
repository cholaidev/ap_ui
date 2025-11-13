import 'package:ap_ui/customer/repo/customer_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  // final String token;
  final customerRepo = CustomerRepository();
  CustomerBloc() : super(CustomerInitial()) {
    on<FetchCustomers>((event, emit) async {
      emit(CustomerLoading());
      try {
        final customers = await customerRepo.fetchCustomers();
        emit(CustomerLoaded(customers));
      } catch (e) {
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
  }
}
