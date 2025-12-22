import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthRepository {
  final String? baseUrl = dotenv.env['API_URL'];

  // 🚨 COMMON AUTH ERROR HANDLER
  Exception _handleError(http.Response response) {
    try {
      final body = jsonDecode(response.body);

      // 🔴 Validation errors (Laravel 422)
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

      // 🔴 Unauthorized
      if (response.statusCode == 401) {
        return Exception(body['message'] ?? 'Invalid credentials');
      }

      // 🔴 Other backend errors
      if (body['message'] != null) {
        return Exception(body['message']);
      }

      return Exception('Authentication failed');
    } catch (_) {
      return Exception('Unexpected server error');
    }
  }

  // ----------------------------------------------------------------
  // 🔐 LOGIN
  // ----------------------------------------------------------------
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Accept': 'application/json'},
        body: {'phone': phone, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'message': data['message'],
          'token': data['token'],
          'user': data['user'],
        };
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ----------------------------------------------------------------
  // 🧾 REGISTER
  // ----------------------------------------------------------------
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String phone,
    String role,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Accept': 'application/json'},
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'phone': phone,
          'role': role,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'message': data['message'] ?? 'Registration successful',
          'token': data['token'],
          'user': data['user'],
        };
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
