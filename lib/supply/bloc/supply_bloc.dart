import 'package:flutter_bloc/flutter_bloc.dart';
import 'supply_event.dart';
import 'supply_state.dart';

class SupplyBloc extends Bloc<SupplyEvent, SupplyState> {
  SupplyBloc() : super(SupplyInitial()) {
    on<LoadSupplies>((event, emit) async {
      emit(SupplyLoading());
      await Future.delayed(const Duration(milliseconds: 500));

      emit(
        SupplyLoaded([
          {
            "id": 1,
            "employee": {"id": 1, "name": "Manoj"},
            "total_quantity": 45,
            "total_amount": 2250,
            "is_supplied": true,
          },
        ]),
      );
    });

    on<GetSupplyDetails>((event, emit) async {
      emit(SupplyLoading());
      await Future.delayed(const Duration(milliseconds: 500));

      emit(
        SupplyDetailLoaded({
          "id": event.id,
          "employee": {"name": "Manoj"},
          "total_quantity": 45,
          "total_amount": 2250,
          "items": [
            {
              "customer": {"name": "Ravi"},
              "milk": "Cow",
              "quantity": 20,
              "amount": 1000,
            },
            {
              "customer": {"name": "Suresh"},
              "milk": "Buffalo",
              "quantity": 25,
              "amount": 1250,
            },
          ],
        }),
      );
    });

    on<CreateSupply>((event, emit) async {
      emit(SupplyLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      emit(SupplySuccess("Supply Created"));
    });

    on<UpdateSupply>((event, emit) async {
      emit(SupplyLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      emit(SupplySuccess("Supply Updated"));
    });

    on<DeleteSupply>((event, emit) async {
      emit(SupplyLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      emit(SupplySuccess("Supply Deleted"));
    });
  }
}
