
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skillpp_kelas12/models/products_model.dart';

class ProductService {
  static const String baseUrl = 'https://learncode.biz.id/api';

  // Get products (existing)
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

  // Add new product
  static Future<Map<String, dynamic>> addProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/save'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id_kategori': product.idKategori,
          'nama_produk': product.namaProduk,
          'harga': product.harga,
          'stok': product.stok,
          'deskripsi': product.deskripsi,
        }),
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

  // Update product
  static Future<Map<String, dynamic>> updateProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/update'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id': product.id,
          'id_kategori': product.idKategori,
          'nama_produk': product.namaProduk,
          'harga': product.harga,
          'stok': product.stok,
          'deskripsi': product.deskripsi,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Produk berhasil diupdate',
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

  static Future<Map<String, dynamic>> uploadImages(
    int productId, 
    List<String> imagePaths
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('$baseUrl/products/images/upload')
      );

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
}