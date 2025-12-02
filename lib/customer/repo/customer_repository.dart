import 'dart:convert';
import 'package:ap_ui/auth/bloc/auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CustomerRepository {
  final String? baseUrl = dotenv.env['API_URL'];

  /// ✅ Get auth token or throw if not available
  String _getToken() {
    final token = AuthManager().session?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('No access token found — user may not be logged in.');
    }
    return token;
  }

  /// 🧾 Fetch all customers
  Future<List<dynamic>> fetchCustomers() async {
    try {
      final token = _getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/customers'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 fetchCustomers → Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print('📦 fetchCustomers → Body: $body');
        return body['data'] ?? [];
      } else {
        throw Exception(
          'Failed to load customers — status: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      print('❌ fetchCustomers ERROR: $e');
      print('📌 STACK TRACE:\n$stackTrace');
      throw Exception('fetchCustomers failed: $e');
    }
  }

  /// 👤 Get details of one customer
  Future<Map<String, dynamic>> getCustomerDetails(int id) async {
    try {
      final token = _getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/customers/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('customerdetails${jsonDecode(response.body)}');
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to load customer details (id: $id) — Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Log error for debugging
      print("❌ getCustomerDetails Error (id=$id): $e");

      // Re-throw error so UI can handle it (show popup/snackbar)
      throw Exception("Unable to fetch customer details. Error: $e");
    }
  }

  /// ➕ Add new customer
  Future<void> addCustomer(Map<String, dynamic> data) async {
    try {
      final token = _getToken();
      if (token == null || token.isEmpty) {
        throw Exception("Auth token missing");
      }

      final response = await http.post(
        Uri.parse('$baseUrl/customers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      print("📤 Add Customer Request: $data");
      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'Failed to add customer — status: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      print("❌ addCustomer error: $e");
      print("🧵 StackTrace:");
      print(stackTrace);
      throw Exception("Unable to add customer: $e");
    }
  }

  /// ✏️ Update existing customer
  Future<void> updateCustomer(int id, Map<String, dynamic> data) async {
    final token = _getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/customers/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update customer (id: $id) — status: ${response.statusCode}',
      );
    }
  }

  Future<void> deleteCustomer(int id) async {
    final token = _getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/customers/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update customer (id: $id) — status: ${response.statusCode}',
      );
    }
  }
}
