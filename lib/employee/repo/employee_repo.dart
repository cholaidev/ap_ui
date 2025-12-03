import 'dart:convert';
import 'package:ap_ui/auth/bloc/auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmployeeRepository {
  final String? baseUrl = dotenv.env['API_URL'];

  // EmployeeRepository({required this.baseUrl});

  String? _getToken() {
    final token = AuthManager().session?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('No access token found — user may not be logged in.');
    }
    return token;
  }

  // ----------------------------------------------------------------
  // 📌 GET ALL EMPLOYEES
  // ----------------------------------------------------------------
  Future<List<dynamic>> getEmployees() async {
    try {
      final token = _getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/employees'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] ?? [];
      } else {
        throw Exception(
          "Failed to fetch employees — Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error loading employees: $e");
    }
  }

  // ----------------------------------------------------------------
  // 📌 GET SINGLE EMPLOYEE DETAILS
  // ----------------------------------------------------------------
  Future<Map<String, dynamic>> getEmployeeDetails(int id) async {
    try {
      final token = _getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/employees/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        throw Exception(
          "Failed to fetch details for employee $id — ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error fetching employee details: $e");
    }
  }

  // ----------------------------------------------------------------
  // 📌 CREATE EMPLOYEE
  // ----------------------------------------------------------------
  Future<bool> createEmployee(Map<String, dynamic> data) async {
    try {
      final token = _getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/employees'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? "Failed to create employee");
      }
    } catch (e) {
      throw Exception("Error creating employee: $e");
    }
  }

  // ----------------------------------------------------------------
  // 📌 UPDATE EMPLOYEE
  // ----------------------------------------------------------------
  Future<bool> updateEmployee(int id, Map<String, dynamic> data) async {
    try {
      final token = _getToken();

      final response = await http.put(
        Uri.parse('$baseUrl/employees/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          "Failed to update employee $id — ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error updating employee: $e");
    }
  }

  // ----------------------------------------------------------------
  // 📌 DELETE EMPLOYEE
  // ----------------------------------------------------------------
  Future<bool> deleteEmployee(int id) async {
    try {
      final token = _getToken();

      final response = await http.delete(
        Uri.parse('$baseUrl/employees/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          "Failed to delete employee $id — ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error deleting employee: $e");
    }
  }
}
