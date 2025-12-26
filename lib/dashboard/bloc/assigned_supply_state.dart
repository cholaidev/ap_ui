sealed class AssignedSupplyState {}

final class AssignedSupplyInitial extends AssignedSupplyState {}

class AssignedSupplyLoading extends AssignedSupplyState {}

class AssignedSupplySuccess extends AssignedSupplyState {
  final String message;
  AssignedSupplySuccess(this.message);
}

class AssignedSupplyError extends AssignedSupplyState {
  final String error;
  AssignedSupplyError(this.error);
}
