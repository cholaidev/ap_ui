import 'package:ap_ui/employee/repo/employee_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'employee_event.dart';
import 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final employeeRepo = EmployeeRepository();

  num totalActiveEmp = 0;
  num totalInActiveEmp = 0;

  EmployeeBloc() : super(EmployeeInitial()) {
    on<LoadEmployees>((event, emit) async {
      emit(EmployeeLoading());
      try {
        final result = await employeeRepo.getEmployees(event.status);

        totalActiveEmp = result.where((c) => c['is_active'] == 1).length;
        totalInActiveEmp = result.where((c) => c['is_active'] == 0).length;
        emit(EmployeeLoaded(result));
      } catch (e) {
        emit(EmployeeError("Error loading employees: $e"));
      }
    });
    on<GetEmployeeDetails>((event, emit) async {
      emit(EmployeeLoading());
      try {
        final result = await employeeRepo.getEmployeeDetails(event.id);
        emit(EmployeeDetailLoaded(result));
      } catch (e) {
        print('get error $e');
        emit(EmployeeError(e.toString()));
      }
    });

    // ----------------------------------------------------
    // CREATE EMPLOYEE
    // ----------------------------------------------------
    on<CreateEmployee>((event, emit) async {
      emit(EmployeeLoading());
      try {
        await employeeRepo.createEmployee(event.employeeData);
        emit(EmployeeSuccess("Employee Created Successfully"));
      } catch (e) {
        print('get error $e');
        emit(EmployeeError("Error: ${e}"));
      }
    });

    // ----------------------------------------------------
    // UPDATE EMPLOYEE
    // ----------------------------------------------------
    on<UpdateEmployee>((event, emit) async {
      emit(EmployeeLoading());
      try {
        await employeeRepo.updateEmployee(event.id, event.updatedData);
        emit(EmployeeUpdateSuccess("Employee Updated"));
      } catch (e) {
        emit(EmployeeError("Error: $e"));
      }
    });

    // ----------------------------------------------------
    // DELETE EMPLOYEE
    // ----------------------------------------------------
    on<DeleteEmployee>((event, emit) async {
      emit(EmployeeLoading());
      try {
        await employeeRepo.deleteEmployee(event.id);
        emit(EmployeeDeleteSuccess("Employee Deleted"));
      } catch (e) {
        emit(EmployeeError("Error: $e"));
      }
    });

    on<ReActiveEmlpoyee>((event, emit) async {
      emit(EmployeeLoading());
      try {
        await employeeRepo.reactive(event.id);
        emit(EmployeeReactiveSuccess("Employee reactivated"));
      } catch (e) {
        emit(EmployeeError("Error: $e"));
      }
    });
  }
}
