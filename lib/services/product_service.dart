import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skillpp_kelas12/models/products_model.dart';
import 'package:skillpp_kelas12/services/login_service.dart';

class ProductService {
  static const String baseUrl = 'https://learncode.biz.id/api';

  // Get products dengan token
  static Future<Map<String, dynamic>> getProducts() async {
    try {
      final String? token = await LoginService.getToken();
      
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      // Tambahkan token jika ada
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final productResponse = ProductResponse.fromJson(data);
        return {
          'success': true,
          'data': productResponse,
        };
      } else {
        return {
          'success': false,
          'message': 'HTTP Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network Error: $e',
      };
    }
  }

  // Get categories dengan token
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final String? token = await LoginService.getToken();
      
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Categories API Response: $data');
        
        final categoryResponse = CategoryResponse.fromJson(data);
        return {
          'success': true,
          'data': categoryResponse,
        };
      } else {
        return {
          'success': false,
          'message': 'HTTP Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Categories API Error: $e');
      return {
        'success': false,
        'message': 'Network Error: $e',
      };
    }
  }

  // Add new product dengan token
  static Future<Map<String, dynamic>> addProduct(Product product) async {
    try {
      final String? token = await LoginService.getToken();
      
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('$baseUrl/products/save'),
        headers: headers,
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Produk berhasil ditambahkan',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'HTTP Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network Error: $e',
      };
    }
  }

  // Update product dengan token
  static Future<Map<String, dynamic>> updateProduct(Product product) async {
    try {
      final String? token = await LoginService.getToken();
      
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('$baseUrl/products/save'),
        headers: headers,
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Produk berhasil diupdate',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'HTTP Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network Error: $e',
      };
    }
  }

  // Delete product dengan token
  static Future<Map<String, dynamic>> deleteProduct(int productId) async {
    try {
      final String? token = await LoginService.getToken();
      
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('$baseUrl/products/delete'),
        headers: headers,
        body: json.encode({
          'id': productId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Produk berhasil dihapus',
        };
      } else {
        return {
          'success': false,
          'message': 'HTTP Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network Error: $e',
      };
    }
  }

  // Upload product images dengan token
  static Future<Map<String, dynamic>> uploadImages(
    int productId, 
    List<String> imagePaths
  ) async {
    try {
      final String? token = await LoginService.getToken();
      
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('$baseUrl/products/images/upload')
      );

      // Add headers dengan token
      request.headers['Content-Type'] = 'multipart/form-data';
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add product ID
      request.fields['id_produk'] = productId.toString();

      // Add images
      for (var imagePath in imagePaths) {
        request.files.add(await http.MultipartFile.fromPath(
          'images[]', 
          imagePath
        ));
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final Map<String, dynamic> data = json.decode(responseData);

      if (response.statusCode == 200) {
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Gambar berhasil diupload',
        };
      } else {
        return {
          'success': false,
          'message': 'HTTP Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network Error: $e',
      };
    }
  }

  // Get single product by ID dengan token
  static Future<Map<String, dynamic>> getProductById(int productId) async {
    try {
      final String? token = await LoginService.getToken();
      
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final product = Product.fromJson(data['data']);
          return {
            'success': true,
            'data': product,
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Produk tidak ditemukan',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'HTTP Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network Error: $e',
      };
    }
  }
  
  // Get product detail by ID dengan token - endpoint yang benar
static Future<Map<String, dynamic>> getProductDetail(int productId) async {
  try {
    final String? token = await LoginService.getToken();
    
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    print('Fetching product detail for ID: $productId');
    print('Endpoint: $baseUrl/products/$productId/show');
    
    final response = await http.get(
      Uri.parse('$baseUrl/products/$productId/show'), // Endpoint yang benar
      headers: headers,
    );

    print('Product Detail Status: ${response.statusCode}');
    print('Product Detail Response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        final productDetailResponse = ProductDetailResponse.fromJson(data);
        return {
          'success': true,
          'data': productDetailResponse,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Produk tidak ditemukan',
        };
      }
    } else if (response.statusCode == 404) {
      return {
        'success': false,
        'message': 'Produk tidak ditemukan (404)',
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
    print('Product Detail Error: $e');
    return {
      'success': false,
      'message': 'Network Error: $e',
    };
  }
}
}