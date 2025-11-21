import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillpp_kelas12/models/products_model.dart';

class ProductService {
  static const String URL = 'http://learncode.biz.id/api';
  
  static Future<Map<String, dynamic>> getProducts() async {
    try {
      final String? token = await _getToken();
      
      if (token == null) {
        return {
          'success': false, 
          'message': 'Token tidak ditemukan. Silakan login kembali.'
        };
      }

      final response = await http.get(
        Uri.parse('$URL/products'), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Parse data ke model ProductResponse
        final productResponse = ProductResponse.fromJson(data);
        
        return {
          'success': true, 
          'message': 'Data produk berhasil diambil', 
          'data': productResponse
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false, 
          'message': 'Gagal mengambil data produk: ${error['message'] ?? 'Unknown error'}'
        };
      }
    } catch (e) {
      return {
        'success': false, 
        'message': 'Connection error: $e'
      };
    }
  }

  // Method untuk mengambil produk by kategori
  static Future<Map<String, dynamic>> getProductsByCategory(String categoryId) async {
    try {
      final String? token = await _getToken();
      
      if (token == null) {
        return {
          'success': false, 
          'message': 'Token tidak ditemukan. Silakan login kembali.'
        };
      }

      final response = await http.get(
        Uri.parse('$URL/produk?kategori=$categoryId'), // Sesuaikan endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final productResponse = ProductResponse.fromJson(data);
        
        return {
          'success': true, 
          'message': 'Data produk berhasil diambil', 
          'data': productResponse
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false, 
          'message': 'Gagal mengambil data produk: ${error['message'] ?? 'Unknown error'}'
        };
      }
    } catch (e) {
      return {
        'success': false, 
        'message': 'Connection error: $e'
      };
    }
  }

  // Method untuk mengambil detail produk
  static Future<Map<String, dynamic>> getProductDetail(int productId) async {
    try {
      final String? token = await _getToken();
      
      if (token == null) {
        return {
          'success': false, 
          'message': 'Token tidak ditemukan. Silakan login kembali.'
        };
      }

      final response = await http.get(
        Uri.parse('$URL/produk/$productId'), // Sesuaikan endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final product = Product.fromJson(data['data']);
          return {
            'success': true, 
            'message': 'Detail produk berhasil diambil', 
            'data': product
          };
        } else {
          return {
            'success': false, 
            'message': data['message'] ?? 'Gagal mengambil detail produk'
          };
        }
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false, 
          'message': 'Gagal mengambil detail produk: ${error['message'] ?? 'Unknown error'}'
        };
      }
    } catch (e) {
      return {
        'success': false, 
        'message': 'Connection error: $e'
      };
    }
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}