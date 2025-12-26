import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'assigned_supply_state.dart';

import 'package:ap_ui/dashboard/repo/assigned_supply_repository.dart';
part 'assigned_supply_event.dart';

class AssignedSupplyBloc
    extends Bloc<AssignedSupplyEvent, AssignedSupplyState> {
  final AssignedSupplyRepository repo = AssignedSupplyRepository();

  AssignedSupplyBloc() : super(AssignedSupplyInitial()) {
    on<AssignSupplyDate>(_onAssignSupplyDate);
  }

  Future<void> _onAssignSupplyDate(
    AssignSupplyDate event,
    Emitter<AssignedSupplyState> emit,
  ) async {
    try {
      emit(AssignedSupplyLoading());

      await repo.assignSupplyDate(event.supplyDate);

      emit(
        AssignedSupplySuccess(
          "Supply generated for ${event.supplyDate.toIso8601String().split('T')[0]}",
        ),
      );
    } catch (e) {
      emit(AssignedSupplyError(e.toString()));
    }
  }
}
