import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'supply_cubit_state.dart';

class SupplyCubitCubit extends Cubit<SupplyCubitState> {
  SupplyCubitCubit() : super(SupplyCubitInitial());

  Map? selectedEmployee;
  List<Map<String, dynamic>> selectedCustomers = [];
  double totalLiters = 0;
  double totalAmountOfMilk = 0;
  num priceofMilk = 50;

  DateTime supplyDate = DateTime.now();

  updatePriceOfMilk(num? price) {
    priceofMilk = price!;
    emit(PriceUpdateSuccessState());
  }

  /* ---------------- SUPPLY DATE ---------------- */

  void setSupplyDate(DateTime date) {
    supplyDate = date;
    emit(SupplyDateUpdatedState());
  }

  void calculateTotalAmountOfMilk(List customers) {
    double liters = 0;
    double amount = 0;

    for (final c in customers) {
      final qty = double.tryParse("${c['quantity']}") ?? 0;
      final price = priceofMilk;

      liters += qty;
      amount += qty * price;
    }

    totalLiters = liters;
    totalAmountOfMilk = amount;

    emit(SupplyTotalUpdatedState());
  }

  void setEmployee(Map? emp) {
    selectedEmployee = emp;
    emit(SelectEmployeeSuccessState());
  }

  void setCustomers(List<Map<String, dynamic>> customers) {
    print('select customers set$customers');
    selectedCustomers = customers;
    calculateTotalAmountOfMilk(customers);
    emit(SelectCustomerSuccessState());
  }

  void removeCustomer(int id) {
    selectedCustomers.removeWhere((c) => c['id'] == id);
    emit(SelectCustomerSuccessState());
  }

  void updateCustomerQuantity(int id, double qty) {
    final i = selectedCustomers.indexWhere((c) => c['id'] == id);
    if (i != -1) {
      selectedCustomers[i]['quantity'] = qty;
      calculateTotalAmountOfMilk(selectedCustomers);
      emit(SelectCustomerSuccessState());
    }
  }

  void resetState() {
    selectedEmployee = null;
    selectedCustomers = [];
    totalLiters = 0;
    totalAmountOfMilk = 0;
  }
}
