import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skillpp_kelas12/models/costumer_product_model.dart';

class CustomerProductService {
  static const String baseUrl = 'https://learncode.biz.id/api';

  // Get semua produk untuk pembeli (tanpa token)
  static Future<CustomerProductResponse> getProducts({
    int page = 1,
    int perPage = 20,
    String? search,
    String? kategori,
    String sortBy = 'terbaru',
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (kategori != null && kategori.isNotEmpty) {
        queryParams['kategori'] = kategori;
      }
      if (sortBy.isNotEmpty) {
        queryParams['sort'] = sortBy;
      }

      final uri = Uri.parse('$baseUrl/products/customer').replace(
        queryParameters: queryParams,
      );

      print('Fetching customer products: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Customer Products Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CustomerProductResponse.fromJson(data);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Customer Products Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get produk populer
  static Future<CustomerProductResponse> getPopularProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/popular'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CustomerProductResponse.fromJson(data);
      } else {
        throw Exception('Failed to load popular products');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get produk by kategori
  static Future<CustomerProductResponse> getProductsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/category/$category'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CustomerProductResponse.fromJson(data);
      } else {
        throw Exception('Failed to load category products');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get detail produk untuk pembeli
  static Future<CustomerProduct> getProductDetail(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId/customer'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Customer Product Detail Status: ${response.statusCode}');
      print('Customer Product Detail Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return CustomerProduct.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Product not found');
        }
      } else {
        throw Exception('Failed to load product detail: ${response.statusCode}');
      }
    } catch (e) {
      print('Customer Product Detail Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get rekomendasi produk
  static Future<CustomerProductResponse> getRecommendedProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/recommended'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CustomerProductResponse.fromJson(data);
      } else {
        throw Exception('Failed to load recommended products');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}