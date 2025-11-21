import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skillpp_kelas12/models/register_model.dart';

class RegisterService {
  static const String baseUrl = 'https://learncode.biz.id/api';

  Future<RegisterResponseModel> register(RegisterModel user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(user.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return RegisterResponseModel.fromJson(data);
      } else {
        return RegisterResponseModel(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return RegisterResponseModel(
        success: false,
        message: 'Network Error: $e',
      );
    }
  }
}