import 'dart:convert';
import 'package:ap_ui/auth/bloc/auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CustomerRepository {
  final String? baseUrl = dotenv.env['API_URL'];

  // 🔐 GET TOKEN
  String _getToken() {
    final token = AuthManager().session?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Session expired. Please login again.');
    }
    return token;
  }

  // 🚨 COMMON ERROR HANDLER
  Exception _handleError(http.Response response) {
    try {
      final body = jsonDecode(response.body);

      // 🔴 VALIDATION ERROR (422)
      if (response.statusCode == 422 && body['errors'] != null) {
        final Map<String, dynamic> errors = body['errors'];
        final messages = <String>[];

        errors.forEach((_, value) {
          if (value is List && value.isNotEmpty) {
            messages.add(value.first.toString());
          }
        });

        return Exception(
          messages.isNotEmpty ? messages.join('\n') : 'Validation error',
        );
      }

      // 🔴 UNAUTHORIZED
      if (response.statusCode == 401) {
        return Exception('Unauthorized. Please login again.');
      }

      // 🔴 OTHER ERRORS
      if (body['message'] != null) {
        return Exception(body['message']);
      }

      return Exception('Something went wrong');
    } catch (_) {
      return Exception('Unexpected server error');
    }
  }

  // ----------------------------------------------------------------
  // 📌 GET ALL CUSTOMERS
  // ----------------------------------------------------------------
  Future<List<dynamic>> fetchCustomers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customers'),
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
  // 📌 GET CUSTOMER DETAILS
  // ----------------------------------------------------------------
  Future<Map<String, dynamic>> getCustomerDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customers/$id'),
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
  // 📌 ADD CUSTOMER
  // ----------------------------------------------------------------
  Future<void> addCustomer(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customers'),
        headers: {
          'Authorization': 'Bearer ${_getToken()}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) return;

      throw _handleError(response);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ----------------------------------------------------------------
  // 📌 UPDATE CUSTOMER
  // ----------------------------------------------------------------
  Future<void> updateCustomer(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/customers/$id'),
        headers: {
          'Authorization': 'Bearer ${_getToken()}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) return;

      throw _handleError(response);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ----------------------------------------------------------------
  // 📌 DELETE CUSTOMER
  // ----------------------------------------------------------------
  Future<void> deleteCustomer(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/customers/$id'),
        headers: {
          'Authorization': 'Bearer ${_getToken()}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) return;

      throw _handleError(response);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ----------------------------------------------------------------
  // 📌 CUSTOMER DELIVERY HISTORY
  // ----------------------------------------------------------------
  Future<List<dynamic>> customerHistory({
    required int customerId,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (from != null) queryParams['from_date'] = from.toIso8601String();
      if (to != null) queryParams['to_date'] = to.toIso8601String();

      final uri = Uri.parse(
        '$baseUrl/customer-history/$customerId',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
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

  Future<Map<String, dynamic>> bulkImportCustomers(
    List<Map<String, dynamic>> customers,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customers/bulk-import'),
        headers: {
          'Authorization': 'Bearer ${_getToken()}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },

        // ✅ FIXED PAYLOAD
        body: jsonEncode({"customers": customers}),
      );

      final decoded = jsonDecode(response.body);

      // ✅ SUCCESS
      if (response.statusCode == 200 && decoded['status'] == true) {
        return decoded;
      }

      // ❌ VALIDATION ERROR (422)
      if (response.statusCode == 422) {
        throw Exception(
          decoded['message'] ?? 'Validation failed during bulk import',
        );
      }

      // ❌ OTHER SERVER ERRORS
      throw Exception(decoded['message'] ?? 'Bulk import failed');
    } catch (e, stackTrace) {
      print('Bulk import error: $e');
      print(stackTrace);

      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
