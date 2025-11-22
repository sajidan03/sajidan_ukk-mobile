import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skillpp_kelas12/models/products_model.dart';

class ProductService {
  static const String baseUrl = 'https://learncode.biz.id/api';

  // Get products
  static Future<Map<String, dynamic>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      
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

  // Get categories
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));
      
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

  // Add new product
  static Future<Map<String, dynamic>> addProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/save'),
        headers: {
          'Content-Type': 'application/json',
        },
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

  // Update product - menggunakan endpoint yang sama dengan add
  static Future<Map<String, dynamic>> updateProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/save'), // Menggunakan endpoint yang sama
        headers: {
          'Content-Type': 'application/json',
        },
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

  // Delete product
  static Future<Map<String, dynamic>> deleteProduct(int productId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/delete'),
        headers: {
          'Content-Type': 'application/json',
        },
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

  // Upload product images
  static Future<Map<String, dynamic>> uploadImages(
    int productId, 
    List<String> imagePaths
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('$baseUrl/products/images/upload')
      );

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

  // Get single product by ID
  static Future<Map<String, dynamic>> getProductById(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId'),
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
}