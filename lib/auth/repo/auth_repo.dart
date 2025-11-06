import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ap_ui/models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthRepository {
  final String? baseUrl = dotenv.env['API_URL'];

  /// 🧩 User login
  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Accept': 'application/json'},
      body: {'phone': phone, 'password': password},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        "message": data["message"],
        "token": data["token"],
        "user": data["user"],
      };
    } else {
      throw Exception(data["message"] ?? "Login failed");
    }
  }

  /// 🧾 User register
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String phone,
    String role,
  ) async {
    try {
      print('base url $baseUrl');

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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "message": data["message"] ?? "Registration successful",
          "token": data["token"],
          "user": data["user"],
        };
      } else {
        print('❌ Register error: ${data["message"]}');
        throw Exception(data["message"] ?? "Registration failed");
      }
    } catch (e) {
      print('⚠️ Exception in register(): $e');
      throw Exception("Something went wrong. Please try again later.");
    }
  }
}
