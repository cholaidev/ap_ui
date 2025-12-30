import 'dart:io';

import 'package:ap_ui/customer/bloc/customer_bloc.dart';
import 'package:ap_ui/customer/bloc/customer_event.dart';
import 'package:ap_ui/customer/bloc/customer_state.dart';
import 'package:ap_ui/shared/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BulkImportPage extends StatefulWidget {
  const BulkImportPage({super.key});

  @override
  State<BulkImportPage> createState() => _BulkImportPageState();
}

class _BulkImportPageState extends State<BulkImportPage> {
  List<List<dynamic>> _csvData = [];
  String? _fileName;
  bool _loading = false;

  // ================= HELPERS =================
  void _showSnack(String msg, {Color color = Colors.red}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  bool _isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    return cleaned.length == 10;
  }

  bool _isValidMilk(String milk) {
    final v = milk.toLowerCase().trim();
    return v == 'cow' || v == 'buffalo';
  }

  double? _parseQuantity(dynamic value) {
    try {
      final q = double.parse(value.toString());
      return q > 0 ? q : null;
    } catch (_) {
      return null;
    }
  }

  // ================= CSV PICK =================
  Future<void> _pickCSV() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null) return;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;

    if (!fileName.toLowerCase().endsWith('.csv')) {
      _showSnack("Please select a CSV file", color: Colors.orange);
      return;
    }

    try {
      final content = await file.readAsString();
      final csv = const CsvToListConverter().convert(content);

      if (csv.length < 2) {
        _showSnack("CSV is empty or invalid", color: Colors.orange);
        return;
      }

      setState(() {
        _csvData = csv;
        _fileName = fileName;
      });
    } catch (e) {
      _showSnack("Failed to read CSV file");
    }
  }

  // ================= IMPORT =================
  Future<void> _importCSV() async {
    if (_csvData.length < 2) return;

    setState(() => _loading = true);

    final List<Map<String, dynamic>> validCustomers = [];
    final List<String> errors = [];

    final rows = _csvData.skip(1).toList();

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];

      final name = row[0].toString().trim();
      final phone = row[1].toString().trim();
      final house = row[2].toString().trim();
      final location = row[3].toString().trim();
      final milk = row[4].toString().trim();
      final quantity = row.length > 5 ? row[5] : null;

      if (name.isEmpty) {
        errors.add("Row ${i + 2}: Name is empty");
        continue;
      }

      if (!_isValidPhone(phone)) {
        errors.add("Row ${i + 2}: Invalid phone");
        continue;
      }

      if (location.isEmpty) {
        errors.add("Row ${i + 2}: Location missing");
        continue;
      }

      if (!_isValidMilk(milk)) {
        errors.add("Row ${i + 2}: Milk must be Cow/Buffalo");
        continue;
      }

      final qty = _parseQuantity(quantity);
      if (qty == null) {
        errors.add("Row ${i + 2}: Quantity invalid");
        continue;
      }

      validCustomers.add({
        "name": name,
        "phone": phone.replaceAll(RegExp(r'\D'), ''),
        "house": house,
        "location": location,
        "milk": milk,
        "quantity": qty,
      });
    }

    setState(() => _loading = false);

    if (validCustomers.isEmpty) {
      _showErrorDialog(errors);
      return;
    }

    if (errors.isNotEmpty) {
      _showContinueDialog(errors, validCustomers);
      return;
    }

    _submit(validCustomers);
  }

  void _submit(List<Map<String, dynamic>> customers) {
    setState(() => _loading = true);
    context.read<CustomerBloc>().add(BulkCustomer(customers));
  }

  // ================= DIALOGS =================
  void _showErrorDialog(List<String> errors) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("CSV Errors"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                children: errors.map((e) => Text("• $e")).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  void _showContinueDialog(
    List<String> errors,
    List<Map<String, dynamic>> validCustomers,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Some rows invalid"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Valid: ${validCustomers.length}"),
                Text(
                  "Invalid: ${errors.length}",
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView(
                    children: errors.map((e) => Text("• $e")).toList(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _submit(validCustomers);
                },
                child: const Text("Continue"),
              ),
            ],
          ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerBloc, CustomerState>(
      listener: (context, state) {
        if (state is BulkCustomerSuccessState) {
          setState(() => _loading = false);
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  title: const Text("Import Complete"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("✅ Inserted: ${state.inserted}"),
                      Text("⏭ Skipped: ${state.skipped}"),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        context.read<CustomerBloc>().add(FetchCustomers());
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
          );
        }

        if (state is CustomerError) {
          setState(() => _loading = false);
          _showSnack(state.error);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Bulk Import Customers",
            style: TextStyle(color: whiteColor),
          ),
          backgroundColor: const Color(0xFF2E7D32),
        ),

        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Select CSV File"),
                    onPressed: _loading ? null : _pickCSV,
                  ),

                  if (_fileName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Selected: $_fileName",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],

                  const SizedBox(height: 16),

                  if (_csvData.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns:
                            _csvData.first
                                .map(
                                  (e) => DataColumn(label: Text(e.toString())),
                                )
                                .toList(),
                        rows:
                            _csvData
                                .skip(1)
                                .map(
                                  (row) => DataRow(
                                    cells:
                                        row
                                            .map(
                                              (c) =>
                                                  DataCell(Text(c.toString())),
                                            )
                                            .toList(),
                                  ),
                                )
                                .toList(),
                      ),
                    )
                  else
                    const SizedBox(
                      height: 200,
                      child: Center(child: Text("No file selected")),
                    ),
                ],
              ),
            ),

            if (_loading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        floatingActionButton:
            _csvData.isEmpty
                ? null
                : FloatingActionButton.extended(
                  backgroundColor: const Color(0xFF2E7D32),
                  icon: const Icon(Icons.cloud_upload, color: Colors.white),
                  label: const Text(
                    "IMPORT CUSTOMERS",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: _loading ? null : _importCSV,
                ),
      ),
    );
  }
}
