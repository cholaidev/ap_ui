sealed class SupplyEvent {}

class LoadSupplies extends SupplyEvent {
  final DateTime? from;
  final DateTime? to;
  final is_from_assigned;

  LoadSupplies({this.from, this.to, required this.is_from_assigned});
}

class GetSupplyDetails extends SupplyEvent {
  final int id;
  GetSupplyDetails(this.id);
}

class CreateSupply extends SupplyEvent {
  final Map<String, dynamic> data;
  CreateSupply(this.data);
}

class UpdateSupply extends SupplyEvent {
  final int id;
  final Map<String, dynamic> data;
  UpdateSupply(this.id, this.data);
}

class DeleteSupply extends SupplyEvent {
  final int id;
  DeleteSupply(this.id);
}

class assignSupply extends SupplyEvent {
  assignSupply();
}
