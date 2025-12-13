import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'supply_cubit_state.dart';

class SupplyCubitCubit extends Cubit<SupplyCubitState> {
  SupplyCubitCubit() : super(SupplyCubitInitial());

  /// TOGGLE CUSTOMER

  /// UPDATE LITERS
  void updateQuantity(int id, double qty) {}

  /// SET EMPLOYEE
  void setEmployee(Map<String, dynamic> emp) {
    ;
  }

  /// PRELOAD (EDIT SUPPLY)
  void setInitialCustomers(List list) {}

  void clear() {}
}
