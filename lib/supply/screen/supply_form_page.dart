import 'package:ap_ui/supply/screen/customer_select.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/supply_bloc.dart';
import '../bloc/supply_state.dart';
import '../bloc/supply_event.dart';
import '../../employee/bloc/employee_bloc.dart';
import '../../employee/bloc/employee_state.dart';
import '../../customer/bloc/customer_bloc.dart';
import '../../customer/bloc/customer_state.dart';

class SupplyFormPage extends StatefulWidget {
  final Map<String, dynamic>? editSupply;

  const SupplyFormPage({super.key, this.editSupply});

  @override
  State<SupplyFormPage> createState() => _SupplyFormPageState();
}

class _SupplyFormPageState extends State<SupplyFormPage> {
  Map<String, dynamic>? selectedEmployee;
  List<Map<String, dynamic>> selectedCustomers = [];

  @override
  void initState() {
    super.initState();
    // context.read<EmployeeBloc>().add(LoadEmployees());
    // context.read<CustomerBloc>().add(FetchCustomers());

    if (widget.editSupply != null) {
      selectedEmployee = widget.editSupply!['employee'];
      selectedCustomers = List<Map<String, dynamic>>.from(
        widget.editSupply!['items'] ?? [],
      );
    }
  }

  double get totalLiters => selectedCustomers.fold(
    0,
    (sum, c) => sum + (double.tryParse("${c['quantity']}") ?? 0),
  );

  double get totalAmount => selectedCustomers.fold(0, (sum, c) {
    final qty = double.tryParse("${c['quantity']}") ?? 0;
    final price = double.tryParse("${c['price_per_liter'] ?? 50}") ?? 50;
    return sum + (qty * price);
  });

  void _save() {
    if (selectedEmployee == null || selectedCustomers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select employee & customers")),
      );
      return;
    }

    final payload = {
      "employee_id": selectedEmployee!['id'],
      "total_quantity": totalLiters,
      "total_amount": totalAmount,
      "items":
          selectedCustomers
              .map(
                (c) => {
                  "customer_id": c['id'],
                  "milk": c['milk'],
                  "quantity": c['quantity'],
                  "price_per_liter": c['price_per_liter'] ?? 50,
                },
              )
              .toList(),
    };

    if (widget.editSupply != null) {
      context.read<SupplyBloc>().add(
        UpdateSupply(widget.editSupply!['id'], payload),
      );
    } else {
      context.read<SupplyBloc>().add(CreateSupply(payload));
    }
  }

  void _discard() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Discard Changes?"),
            content: const Text("Are you sure you want to discard?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Discard"),
              ),
            ],
          ),
    );
  }

  void _selectEmployee() async {
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (_) => const EmployeeSelectPage()),
    // );

    // if (result != null && result is Map<String, dynamic>) {
    //   setState(() {
    //     selectedEmployee = result;
    //   });
    // }
  }

  void _selectCustomers() async {
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => CustomerSelectListPage(
    //       selected: selectedCustomers,
    //     ),
    //   ),
    // );

    // if (result != null && result is List<Map<String, dynamic>>) {
    //   setState(() {
    //     selectedCustomers = result;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editSupply != null ? "Edit Supply" : "Add Supply"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /// SELECT EMPLOYEE
            const Text(
              "Employee",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _selectEmployee,
              icon: const Icon(Icons.person),
              label: Text(
                selectedEmployee != null
                    ? selectedEmployee!['name']
                    : "Select Employee",
              ),
            ),
            const SizedBox(height: 20),

            /// SELECT CUSTOMERS
            const Text(
              "Customers",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _selectCustomers,
              icon: const Icon(Icons.group),
              label: const Text("Select Customers"),
            ),

            const SizedBox(height: 16),

            /// SELECTED CUSTOMER LIST
            ...selectedCustomers.map((c) {
              return Card(
                child: ListTile(
                  title: Text(c['name']),
                  subtitle: Row(
                    children: [
                      Text("Milk: ${c['milk']}"),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 70,
                        child: TextFormField(
                          initialValue: "${c['quantity']}",
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: "Liters"),
                          onChanged: (v) {
                            c['quantity'] = double.tryParse(v) ?? c['quantity'];
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed:
                        () => setState(() => selectedCustomers.remove(c)),
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            /// TOTALS
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total: ${totalLiters.toStringAsFixed(2)} L",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "₹ ${totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton.extended(
            backgroundColor: Colors.red,
            icon: const Icon(Icons.close),
            label: const Text("Discard"),
            onPressed: _discard,
          ),
          FloatingActionButton.extended(
            backgroundColor: Colors.green.shade700,
            icon: const Icon(Icons.save),
            label: const Text("Save"),
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
