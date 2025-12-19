import 'package:ap_ui/customer/repo/customer_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'customer_history_event.dart';
part 'customer_history_state.dart';

class CustomerHistoryBloc
    extends Bloc<CustomerHistoryEvent, CustomerHistoryState> {
  CustomerHistoryBloc() : super(CustomerHistoryInitial()) {
    final customerRepo = CustomerRepository();
    on<GetCustomerDeliveryHistoryEvent>((event, emit) async {
      try {
        emit(CustomerDeliveryLoading());

        final history = await customerRepo.customerHistory(
          customerId: event.customerId,
          from: event.from,
          to: event.to,
        );

        emit(CustomerDeliveryHistory(history));
      } catch (e) {
        emit(CustomerDeliveryHistoryError(e.toString()));
      }
    });
  }
}
