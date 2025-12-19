import 'package:ap_ui/auth/bloc/auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class SettingRepository {
  final String? baseUrl = dotenv.env['API_URL'];

  String? _getToken() {
    final token = AuthManager().session?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('No access token found — user may not be logged in.');
    }
    return token;
  }

  Future<num?> getMilkPrice() async {
    final token = _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/settings'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final body = jsonDecode(response.body);
    return body['data']?['milk_price'];
  }

  Future<void> updateMilkPrice(num? price) async {
    final token = _getToken();

    await http.post(
      Uri.parse('$baseUrl/settings'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'milk_price': price}),
    );
  }
}
