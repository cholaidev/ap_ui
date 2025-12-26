abstract class SupplyState {}

class SupplyInitial extends SupplyState {}

class SupplyLoading extends SupplyState {}

class SupplyLoaded extends SupplyState {
  final List supplies;
  SupplyLoaded(this.supplies);
}

class SupplyDetailLoaded extends SupplyState {
  final Map<String, dynamic> supply;
  SupplyDetailLoaded(this.supply);
}

class SupplySuccess extends SupplyState {
  final String message;
  SupplySuccess(this.message);
}

class SupplyCreateSuccess extends SupplyState {
  final String message;
  SupplyCreateSuccess(this.message);
}

class SupplyUpdateSuccess extends SupplyState {
  final String message;
  SupplyUpdateSuccess(this.message);
}

class SupplyDeleteSuccess extends SupplyState {
  final String message;
  SupplyDeleteSuccess(this.message);
}

class SupplyError extends SupplyState {
  final String error;
  SupplyError(this.error);
}

class AssignSupplySuccessState extends SupplyState {
  AssignSupplySuccessState();
}
