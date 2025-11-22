import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skillpp_kelas12/models/store_model.dart';
import 'package:skillpp_kelas12/services/login_service.dart';

class StoreService {
  static const String baseUrl = 'https://learncode.biz.id/api';

  static Future<Map<String, dynamic>> getStore() async {
    try {
      final String? token = await LoginService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/stores'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('Store API Status: ${response.statusCode}');
      print('Store API Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        final storeResponse = StoreResponse.fromJson(data);
        return {
          'success': true,
          'data': storeResponse,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Token tidak valid. Silakan login kembali.',
        };
      } else {
        return {
          'success': false,
          'message': 'HTTP Error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Store API Error: $e');
      return {
        'success': false,
        'message': 'Network Error: $e',
      };
    }
  }

  // Update store data
  static Future<Map<String, dynamic>> updateStore({
    required String namaToko,
    required String deskripsi,
    required String kontakToko,
    required String alamat,
  }) async {
    try {
      final String? token = await LoginService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
        };
      }

      final Map<String, dynamic> requestBody = {
        'nama_toko': namaToko,
        'deskripsi': deskripsi,
        'kontak_toko': kontakToko,
        'alamat': alamat,
      };

      print('Update Store Request: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/stores/save'), // Adjust endpoint if different
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('Update Store Status: ${response.statusCode}');
      print('Update Store Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Toko berhasil diupdate',
          'data': data['data'] ?? data,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Token tidak valid. Silakan login kembali.',
        };
      } else {
        return {
          'success': false,
          'message': 'HTTP Error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Update Store Error: $e');
      return {
        'success': false,
        'message': 'Network Error: $e',
      };
    }
  }
}