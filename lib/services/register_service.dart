import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skillpp_kelas12/models/register_model.dart';

class RegisterService {
  static const String baseUrl = 'https://learncode.biz.id/api';

  Future<RegisterResponseModel> register(RegisterModel user) async {
    try {
      print('Register Request: ${user.toJson()}');

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(user.toJson()),
      );

      print('Register Status: ${response.statusCode}');
      print('Register Response: ${response.body}');

      // Status code success: 200, 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return RegisterResponseModel.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return RegisterResponseModel(
          success: false,
          message: errorData['message'] ?? 'Terjadi kesalahan: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Register Error: $e');
      return RegisterResponseModel(
        success: false,
        message: 'Network Error: $e',
      );
    }
  }
}