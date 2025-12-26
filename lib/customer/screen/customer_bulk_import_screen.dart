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

  void _showWarning(String message) {
    setState(() {
      _csvData = [];
      _fileName = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }

  // ================= CSV PICK =================
  Future<void> _pickCSV() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result == null) return;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;

    // 🔴 CHECK FILE EXTENSION
    if (!fileName.toLowerCase().endsWith('.csv')) {
      _showWarning("Please select a valid CSV file");
      return;
    }

    try {
      final content = await file.readAsString();

      // 🔴 TRY PARSING CSV
      final csvTable = const CsvToListConverter().convert(content);

      // 🔴 CHECK IF CSV HAS AT LEAST HEADER + 1 ROW
      if (csvTable.length < 2) {
        _showWarning("CSV file is empty or invalid");
        return;
      }

      setState(() {
        _csvData = csvTable;
        _fileName = fileName;
      });
    } catch (e) {
      _showWarning("Unable to read CSV file. Please check the format.");
    }
  }

  // ================= VALIDATION HELPERS =================
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
      final qty = double.parse(value.toString());
      return qty > 0 ? qty : null;
    } catch (_) {
      return null;
    }
  }

  // ================= IMPORT CSV =================
  Future<void> _importCSV() async {
    if (_csvData.length < 2) return;

    setState(() => _loading = true);

    final List<Map<String, dynamic>> validCustomers = [];
    final List<String> errors = [];

    final rows = _csvData.skip(1).toList();

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];

      final house = row[0].toString().trim();
      final name = row[1].toString().trim();
      final phone = row[2].toString().trim();
      final milk = row[3].toString().trim();
      final quantity = row.length > 4 ? row[4] : null;

      if (name.isEmpty) {
        errors.add("Row ${i + 2}: Name is empty");
        continue;
      }

      if (!_isValidPhone(phone)) {
        errors.add("Row ${i + 2}: Phone must be 10 digits");
        continue;
      }

      if (!_isValidMilk(milk)) {
        errors.add("Row ${i + 2}: Milk must be Cow or Buffalo");
        continue;
      }

      final qty = _parseQuantity(quantity);
      if (qty == null) {
        errors.add("Row ${i + 2}: Quantity must be > 0");
        continue;
      }

      validCustomers.add({
        "house": house,
        "name": name,
        "phone": phone.replaceAll(RegExp(r'\D'), ''),
        "milk": milk,
        "quantity": qty,
      });
    }

    setState(() => _loading = false);

    // ❌ No valid rows
    if (validCustomers.isEmpty) {
      _showErrorDialog(errors);
      return;
    }

    // ⚠️ Some invalid rows → ask user
    if (errors.isNotEmpty) {
      _showContinueDialog(errors: errors, validCustomers: validCustomers);
      return;
    }

    // ✅ All valid
    _submitValidCustomers(validCustomers);
  }

  // ================= SUBMIT =================
  void _submitValidCustomers(List<Map<String, dynamic>> customers) {
    setState(() => _loading = true);
    context.read<CustomerBloc>().add(BulkCustomer(customers));
  }

  // ================= ERROR DIALOG =================
  void _showErrorDialog(List<String> errors) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("CSV Validation Errors"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: errors.length,
                itemBuilder: (_, i) => Text("• ${errors[i]}"),
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

  // ================= CONTINUE DIALOG =================
  void _showContinueDialog({
    required List<String> errors,
    required List<Map<String, dynamic>> validCustomers,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text("Validation Issues Found"),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Valid customers: ${validCustomers.length}"),
                  Text(
                    "Invalid rows: ${errors.length}",
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Errors:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      itemCount: errors.length,
                      itemBuilder: (_, i) => Text("• ${errors[i]}"),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _submitValidCustomers(validCustomers);
                },
                child: const Text("Continue with Valid"),
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
                  title: const Text("Bulk Import Completed"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("✅ Inserted: ${state.inserted}"),
                      Text("⏭ Skipped: ${state.skipped}"),
                      if (state.skippedPhones.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          "Skipped Phone Numbers:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 120,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  state.skippedPhones
                                      .map<Widget>((p) => Text("• $p"))
                                      .toList(),
                            ),
                          ),
                        ),
                      ],
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading:
              _loading
                  ? null
                  : BackButton(
                    color: whiteColor,
                    onPressed: () {
                      context.read<CustomerBloc>().add(FetchCustomers());
                      Navigator.pop(context);
                    },
                  ),
          title: const Text(
            "Bulk Import Customers",
            style: TextStyle(color: whiteColor),
          ),
          backgroundColor: const Color(0xFF2E7D32),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                    SizedBox(
                      height: 350,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns:
                              _csvData.first
                                  .map(
                                    (e) =>
                                        DataColumn(label: Text(e.toString())),
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
                                                (cell) => DataCell(
                                                  Text(cell.toString()),
                                                ),
                                              )
                                              .toList(),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    )
                  else
                    const SizedBox(
                      height: 200,
                      child: Center(child: Text("No file selected")),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _csvData.isEmpty || _loading ? null : _importCSV,
                    child: const Text("Import Customers"),
                  ),
                ],
              ),
            ),
            if (_loading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text(
                          "Validating & syncing...",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
