import 'package:ap_ui/supply/repo/supply_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'supply_event.dart';
import 'supply_state.dart';

class SupplyBloc extends Bloc<SupplyEvent, SupplyState> {
  final supplyRepo = SupplyRepository();

  SupplyBloc() : super(SupplyInitial()) {
    /// ================= LOAD ALL SUPPLIES =================
    on<LoadSupplies>((event, emit) async {
      try {
        emit(SupplyLoading());

        final supplies = await supplyRepo.fetchSupplies(
          from: event.from,
          to: event.to,
          is_from_assigned: event.is_from_assigned,
        );

        emit(SupplyLoaded(supplies));
      } catch (e) {
        emit(SupplyError(e.toString()));
      }
    });

    /// ================= GET SUPPLY DETAILS =================
    on<GetSupplyDetails>((event, emit) async {
      try {
        emit(SupplyLoading());

        final supply = await supplyRepo.getSupplyDetails(event.id);

        emit(SupplyDetailLoaded(supply));
      } catch (e) {
        emit(SupplyError(e.toString()));
      }
    });

    /// ================= CREATE SUPPLY =================
    on<CreateSupply>((event, emit) async {
      try {
        emit(SupplyLoading());

        await supplyRepo.createSupply(event.data);

        emit(SupplySuccess("Supply created successfully"));
      } catch (e) {
        emit(SupplyError(e.toString()));
      }
    });

    /// ================= UPDATE SUPPLY =================
    on<UpdateSupply>((event, emit) async {
      try {
        emit(SupplyLoading());

        await supplyRepo.updateSupply(event.id, event.data);

        emit(SupplySuccess("Supply updated successfully"));
      } catch (e) {
        emit(SupplyError(e.toString()));
      }
    });

    /// ================= DELETE SUPPLY =================
    on<DeleteSupply>((event, emit) async {
      try {
        emit(SupplyLoading());

        await supplyRepo.deleteSupply(event.id);

        emit(SupplyDeleteSuccess("Supply deleted successfully"));
      } catch (e) {
        emit(SupplyError(e.toString()));
      }
    });
  }
}
