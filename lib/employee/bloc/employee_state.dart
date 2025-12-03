import 'package:equatable/equatable.dart';

sealed class EmployeeState {}

class EmployeeInitial extends EmployeeState {}

class EmployeeLoading extends EmployeeState {}

class EmployeeLoaded extends EmployeeState {
  final List employees;
  EmployeeLoaded(this.employees);
}

class EmployeeDetailLoaded extends EmployeeState {
  final Map<String, dynamic> employee;
  EmployeeDetailLoaded(this.employee);
}

class EmployeeSuccess extends EmployeeState {
  final String message;
  EmployeeSuccess(this.message);
}

class EmployeeError extends EmployeeState {
  final String message;
  EmployeeError(this.message);
}
