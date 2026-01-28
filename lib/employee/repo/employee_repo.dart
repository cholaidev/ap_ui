import 'dart:convert';
import 'package:ap_ui/auth/bloc/auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmployeeRepository {
  final String? baseUrl = dotenv.env['API_URL'];

  // ----------------------------------------------------------------
  // 🔐 GET TOKEN
  // ----------------------------------------------------------------
  String _getToken() {
    final token = AuthManager().session?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Session expired. Please login again.');
    }
    return token;
  }

  // ----------------------------------------------------------------
  // 🚨 COMMON ERROR HANDLER
  // ----------------------------------------------------------------
  Exception _handleError(http.Response response) {
    try {
      final body = jsonDecode(response.body);

      // 🔴 Laravel validation errors (422)
      if (response.statusCode == 422 && body['errors'] != null) {
        final Map<String, dynamic> errors = body['errors'];

        final messages = <String>[];

        errors.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            messages.add(value.first.toString());
          }
        });

        return Exception(
          messages.isNotEmpty ? messages.join('\n') : 'Validation error',
        );
      }

      // 🔴 Unauthorized
      if (response.statusCode == 401) {
        return Exception('Unauthorized. Please login again.');
      }

      // 🔴 Other backend errors
      if (body['message'] != null) {
        return Exception(body['message']);
      }

      return Exception('Something went wrong');
    } catch (e) {
      return Exception('Unexpected server error');
    }
  }

  // ----------------------------------------------------------------
  // 📌 GET ALL EMPLOYEES
  // ----------------------------------------------------------------
  Future<List<dynamic>> getEmployees(String status) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/employees',
        ).replace(queryParameters: {'status': status}),
        headers: {
          'Authorization': 'Bearer ${_getToken()}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'] ?? [];
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ----------------------------------------------------------------
  // 📌 GET SINGLE EMPLOYEE
  // ----------------------------------------------------------------
  Future<Map<String, dynamic>> getEmployeeDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/employees/$id'),
        headers: {
          'Authorization': 'Bearer ${_getToken()}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ----------------------------------------------------------------
  // 📌 CREATE EMPLOYEE
  // ----------------------------------------------------------------
  Future<bool> createEmployee(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/employees'),
        headers: {
          'Authorization': 'Bearer ${_getToken()}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) return true;

      throw _handleError(response);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ----------------------------------------------------------------
  // 📌 UPDATE EMPLOYEE
  // ----------------------------------------------------------------
  Future<bool> updateEmployee(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/employees/$id'),
        headers: {
          'Authorization': 'Bearer ${_getToken()}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) return true;

      throw _handleError(response);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ----------------------------------------------------------------
  // 📌 DELETE EMPLOYEE
  // ----------------------------------------------------------------
  Future<bool> deleteEmployee(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/employees/$id'),
        headers: {
          'Authorization': 'Bearer ${_getToken()}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) return true;

      throw _handleError(response);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
