import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/supply_bloc.dart';
import '../bloc/supply_event.dart';
import '../bloc/supply_state.dart';

class SupplyDetailPage extends StatelessWidget {
  final int id;

  const SupplyDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    context.read<SupplyBloc>().add(GetSupplyDetails(id));

    return Scaffold(
      appBar: AppBar(title: const Text("Supply Details")),
      body: BlocBuilder<SupplyBloc, SupplyState>(
        builder: (context, state) {
          if (state is SupplyDetailLoaded) {
            final s = state.supply;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text("Employee: ${s['employee']['name']}"),
                Text("Total Milk: ${s['total_quantity']} L"),
                Text("Total Amount: ₹${s['total_amount']}"),
                const Divider(),

                ...s['items'].map<Widget>(
                  (i) => ListTile(
                    title: Text(i['customer']['name']),
                    subtitle: Text("${i['milk']} - ${i['quantity']} L"),
                    trailing: Text("₹ ${i['amount']}"),
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
