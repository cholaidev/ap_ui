part of 'supply_cubit_cubit.dart';

sealed class SupplyCubitState {}

class SupplyCubitInitial extends SupplyCubitState {}

class SelectEmployeeSuccessState extends SupplyCubitState {}

class SelectCustomerSuccessState extends SupplyCubitState {}

class SupplyTotalUpdatedState extends SupplyCubitState {}

class SupplyDateUpdatedState extends SupplyCubitState {}
