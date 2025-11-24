import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skillpp_kelas12/models/products_model.dart';
import 'package:skillpp_kelas12/services/login_service.dart';

class ProductService {
  static const String baseUrl = 'https://learncode.biz.id/api';

  static Future<Map<String, dynamic>> getProducts() async {
    try {
      final String? token = await LoginService.getToken();
      
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: headers,
      );
      
      print('Products API Status: ${response.statusCode}');
      print('Products API Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        final productResponse = ProductResponse.fromJson(data);
        return {
          'success': true,
          'data': productResponse,
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
      print('Products API Error: $e');
      return {
        'success': false,
        'message': 'Network Error: $e',
      };
    }
  }

static Future<Map<String, dynamic>> getCategories() async {
  try {
    final response = await http.get(
      Uri.parse('https://learncode.biz.id/api/categories'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': true,
        'data': data['data'], // List kategori
      };
    } else {
      return {
        'success': false,
        'message': 'Failed to load categories: ${response.statusCode}',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Error: $e',
    };
  }
}
  static Future<Map<String, dynamic>> addProduct(Product product) async {
    try {
      final String? token = await LoginService.getToken();
      
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      print('Add Product Request: ${product.toJson()}');

      final response = await http.post(
        Uri.parse('$baseUrl/products/save'),
        headers: headers,
        body: json.encode(product.toJson()),
      );

      print('Add Product Status: ${response.statusCode}');
      print('Add Product Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Produk berhasil ditambahkan',
          'data': data['data'],
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
      print('Add Product Error: $e');
      return {
        'success': false,
        'message': 'Network Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateProduct(Product product) async {
    try {
      final String? token = await LoginService.getToken();
      
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      print('Update Product Request: ${product.toJson()}');

      final response = await http.post(
        Uri.parse('$baseUrl/products/save'),
        headers: headers,
        body: json.encode(product.toJson()),
      );

      print('Update Product Status: ${response.statusCode}');
      print('Update Product Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Produk berhasil diupdate',
          'data': data['data'],
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
      print('Update Product Error: $e');
      return {
        'success': false,
        'message': 'Network Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteProduct(int productId) async {
    try {
      final String? token = await LoginService.getToken();
      
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      print('Delete Product ID: $productId');
      print('Endpoint: $baseUrl/products/$productId/delete');

      final response = await http.post(
        Uri.parse('$baseUrl/products/$productId/delete'),
        headers: headers,
        body: json.encode({
          'id': productId,
        }),
      );

      print('Delete Product Status: ${response.statusCode}');
      print('Delete Product Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Produk berhasil dihapus',
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
      print('Delete Product Error: $e');
      return {
        'success': false,
        'message': 'Network Error: $e',
      };
    }
  }

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

      request.headers['Content-Type'] = 'multipart/form-data';
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['id_produk'] = productId.toString();

      for (var imagePath in imagePaths) {
        request.files.add(await http.MultipartFile.fromPath(
          'images[]', 
          imagePath
        ));
      }

      print('Upload Images for Product ID: $productId');
      print('Image Paths: $imagePaths');

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final Map<String, dynamic> data = json.decode(responseData);

      print('Upload Images Status: ${response.statusCode}');
      print('Upload Images Response: $responseData');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Gambar berhasil diupload',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Token tidak valid. Silakan login kembali.',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Terjadi kesalahan: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Upload Images Error: $e');
      return {
        'success': false,
        'message': 'Network Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getProductById(int productId) async {
    try {
      final String? token = await LoginService.getToken();
      
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      print('Get Product by ID: $productId');

      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: headers,
      );

      print('Get Product by ID Status: ${response.statusCode}');
      print('Get Product by ID Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
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
      print('Get Product by ID Error: $e');
      return {
        'success': false,
        'message': 'Network Error: $e',
      };
    }
  }
  
  // Get product detail by ID dengan endpoint yang benar
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
      print('Endpoint: $baseUrl/products/$productId/show'); // ENDPOINT YANG BENAR
      
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId/show'), // ENDPOINT YANG BENAR
        headers: headers,
      );

      print('Product Detail Status: ${response.statusCode}');
      print('Product Detail Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
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
      print('Product Detail Error: $e');
      return {
        'success': false,
        'message': 'Network Error: $e',
      };
    }
  }

  // Get product images by product ID
  static Future<Map<String, dynamic>> getProductImages(int productId) async {
    try {
      final String? token = await LoginService.getToken();
      
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      print('Fetching product images for ID: $productId');
      print('Endpoint: $baseUrl/products/$productId/images');
      
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId/images'),
        headers: headers,
      );

      print('Product Images Status: ${response.statusCode}');
      print('Product Images Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<ProductImage> images = (data['data'] as List)
              .map((imageJson) => ProductImage.fromJson(imageJson))
              .toList();
          
          return {
            'success': true,
            'data': images,
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Gambar tidak ditemukan',
          };
        }
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
      print('Product Images Error: $e');
      return {
        'success': false,
        'message': 'Network Error: $e',
      };
    }
  }
static Future<Map<String, dynamic>> getProductsByCategory(int categoryId) async {
  try {
    final response = await http.get(
      Uri.parse('https://learncode.biz.id/api/products/category/$categoryId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': true,
        'data': ProductResponse.fromJson(data),
      };
    } else {
      return {
        'success': false,
        'message': 'Failed to load products: ${response.statusCode}',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Error: $e',
    };
  }
}
}