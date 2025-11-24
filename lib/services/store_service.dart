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

      // Status code success: 200, 201, 204
      if (response.statusCode >= 200 && response.statusCode < 300) {
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
        final Map<String, dynamic> errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Terjadi kesalahan: ${response.statusCode}',
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
        Uri.parse('$baseUrl/stores/save'), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('Update Store Status: ${response.statusCode}');
      print('Update Store Response: ${response.body}');

      // Status code success: 200, 201
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
        final Map<String, dynamic> errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Terjadi kesalahan: ${response.statusCode}',
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

  static Future<bool> hasStore() async {
    try {
      final result = await getStore();
      return result['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Tambahkan method untuk daftar toko
  static Future<Map<String, dynamic>> registerStore(Map<String, dynamic> storeData) async {
    try {
      final String? token = await LoginService.getToken();
      
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('$baseUrl/stores/save'),
        headers: headers,
        body: json.encode(storeData),
      );

      print('Register Store Status: ${response.statusCode}');
      print('Register Store Response: ${response.body}');

      // Status code success: 200, 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Toko berhasil didaftarkan',
          'data': data['data'],
        };
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Terjadi kesalahan: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network Error: $e',
      };
    }
  }
  // Method untuk menghapus toko
static Future<Map<String, dynamic>> deleteStore(int storeId) async {
  try {
    final String? token = await LoginService.getToken();
    
    if (token == null) {
      return {
        'success': false,
        'message': 'Token tidak ditemukan. Silakan login kembali.',
      };
    }

    print('Deleting store with ID: $storeId');

    final response = await http.post(
      Uri.parse('$baseUrl/stores/$storeId/delete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Delete Store Status: ${response.statusCode}');
    print('Delete Store Response: ${response.body}');

    // Status code success: 200, 201, 204
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = json.decode(response.body);
      return {
        'success': data['success'] ?? true,
        'message': data['message'] ?? 'Toko berhasil dihapus',
        'data': data['data'] ?? data,
      };
    } else if (response.statusCode == 401) {
      return {
        'success': false,
        'message': 'Token tidak valid. Silakan login kembali.',
      };
    } else if (response.statusCode == 404) {
      return {
        'success': false,
        'message': 'Toko tidak ditemukan.',
      };
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      return {
        'success': false,
        'message': errorData['message'] ?? 'Terjadi kesalahan: ${response.statusCode}',
      };
    }
  } catch (e) {
    print('Delete Store Error: $e');
    return {
      'success': false,
      'message': 'Network Error: $e',
    };
  }
}
}