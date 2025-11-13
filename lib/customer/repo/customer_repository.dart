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
    final token = _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/customers'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] ?? [];
    } else {
      throw Exception(
        'Failed to load customers — status: ${response.statusCode}',
      );
    }
  }

  /// 👤 Get details of one customer
  Future<Map<String, dynamic>> getCustomerDetails(int id) async {
    final token = _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/customers/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to load customer details (id: $id) — ${response.statusCode}',
      );
    }
  }

  /// ➕ Add new customer
  Future<void> addCustomer(Map<String, dynamic> data) async {
    final token = _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/customers'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Failed to add customer — status: ${response.statusCode}',
      );
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
}
