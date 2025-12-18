import 'dart:convert';

import 'package:ap_ui/auth/bloc/auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SupplyRepository {
  final String? baseUrl = dotenv.env['API_URL'];

  /// 🔐 Get auth token
  String _getToken() {
    final token = AuthManager().session?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('No access token found — user may not be logged in.');
    }
    return token;
  }

  /// 📦 Fetch all supplies
  Future<List<dynamic>> fetchSupplies() async {
    try {
      final token = _getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/supplies'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 fetchSupplies → Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print('📦 fetchSupplies → Body: $body');
        return body['data'] ?? [];
      } else {
        throw Exception(
          'Failed to load supplies — status: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      print('❌ fetchSupplies ERROR: $e');
      print('📌 STACK TRACE:\n$stackTrace');
      throw Exception('fetchSupplies failed: $e');
    }
  }

  /// 📄 Fetch single supply details
  Future<Map<String, dynamic>> getSupplyDetails(int id) async {
    try {
      final token = _getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/supplies/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 getSupplyDetails → Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print('📦 getSupplyDetails → Body: $body');
        return body;
      } else {
        throw Exception(
          'Failed to load supply details (id: $id) — status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("❌ getSupplyDetails Error (id=$id): $e");
      throw Exception("Unable to fetch supply details. Error: $e");
    }
  }

  /// ➕ Create supply
  Future<void> createSupply(Map<String, dynamic> data) async {
    try {
      final token = _getToken();
      print('create supply payload $data');
      final response = await http.post(
        Uri.parse('$baseUrl/supplies'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      print("📤 Create Supply Payload: $data");
      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'Failed to create supply — status: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      print("❌ createSupply error: $e");
      print("🧵 StackTrace:\n$stackTrace");
      throw Exception("Unable to create supply: $e");
    }
  }

  /// ✏️ Update supply
  Future<void> updateSupply(int id, Map<String, dynamic> data) async {
    try {
      final token = _getToken();

      final response = await http.put(
        Uri.parse('$baseUrl/supplies/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      print("📤 Update Supply Payload: $data");
      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update supply (id: $id) — status: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      print("❌ updateSupply error: $e");
      print("🧵 StackTrace:\n$stackTrace");
      throw Exception("Unable to update supply: $e");
    }
  }

  /// 🗑️ Delete supply
  Future<void> deleteSupply(int id) async {
    try {
      final token = _getToken();

      final response = await http.delete(
        Uri.parse('$baseUrl/supplies/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("🗑️ Delete Supply Status: ${response.statusCode}");

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to delete supply (id: $id) — status: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      print("❌ deleteSupply error: $e");
      print("🧵 StackTrace:\n$stackTrace");
      throw Exception("Unable to delete supply: $e");
    }
  }
}
