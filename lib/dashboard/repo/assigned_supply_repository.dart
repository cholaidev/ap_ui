import 'dart:convert';

import 'package:ap_ui/auth/bloc/auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AssignedSupplyRepository {
  final String? baseUrl = dotenv.env['API_URL'];

  /// 🔐 Get auth token
  String _getToken() {
    final token = AuthManager().session?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('No access token found — user may not be logged in.');
    }
    return token;
  }

  Future<void> assignSupplyDate(DateTime date) async {
    final token = _getToken();
    final uri = Uri.parse('$baseUrl/supplies/assign-date');

    final payload = {'supply_date': date.toIso8601String()};

    try {
      // 🔵 REQUEST LOG
      print('📤 AssignSupplyDate REQUEST');
      print('URL: $uri');
      print('Payload: $payload');

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      // 🟢 RESPONSE LOG
      print('📥 AssignSupplyDate RESPONSE');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      // ❌ API ERROR
      if (response.statusCode != 200) {
        final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

        final message =
            body['message'] ?? body['error'] ?? 'Failed to generate supply';

        throw Exception(message);
      }

      // ✅ SUCCESS
      print('✅ Supply generated successfully for ${payload['supply_date']}');
    } catch (e, stack) {
      // 🔴 EXCEPTION LOG
      print('🔥 AssignSupplyDate ERROR');
      print('Error: $e');
      print('StackTrace: $stack');

      // rethrow clean message for Bloc/UI
      throw Exception(
        e is Exception
            ? e.toString().replaceAll('Exception: ', '')
            : 'Unexpected error while generating supply',
      );
    }
  }

  Future<void> assignMultipleSupplyDates(List<DateTime> dates) async {
    final token = _getToken();
    final uri = Uri.parse('$baseUrl/supplies/assign-date');

    final payload = {
      'supply_dates': dates.map((date) => date.toIso8601String()).toList(),
    };

    try {
      // 🔵 REQUEST LOG
      print('📤 AssignMultipleSupplyDates REQUEST');
      print('URL: $uri');
      print('Payload: $payload');

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      // 🟢 RESPONSE LOG
      print('📥 AssignMultipleSupplyDates RESPONSE');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      // ❌ API ERROR
      if (response.statusCode != 200) {
        final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

        final message =
            body['message'] ?? body['error'] ?? 'Failed to generate supply';

        throw Exception(message);
      }

      // ✅ SUCCESS
      print('✅ Supply generated successfully');
    } catch (e, stack) {
      // 🔴 ERROR LOG
      print('🔥 AssignMultipleSupplyDates ERROR');
      print('Error: $e');
      print('StackTrace: $stack');

      throw Exception(
        e is Exception
            ? e.toString().replaceAll('Exception: ', '')
            : 'Unexpected error while generating supply',
      );
    }
  }

  /// 📦 Fetch all supplies
}
