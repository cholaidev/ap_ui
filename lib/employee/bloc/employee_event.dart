sealed class EmployeeEvent {
  const EmployeeEvent();
}

class LoadEmployees extends EmployeeEvent {}

class GetEmployeeDetails extends EmployeeEvent {
  final int id;
  GetEmployeeDetails(this.id);
}

class CreateEmployee extends EmployeeEvent {
  final Map<String, dynamic> employeeData;
  CreateEmployee(this.employeeData);
}

class UpdateEmployee extends EmployeeEvent {
  final int id;
  final Map<String, dynamic> updatedData;

  UpdateEmployee(this.id, this.updatedData);
}

class DeleteEmployee extends EmployeeEvent {
  final int id;
  DeleteEmployee(this.id);
}
