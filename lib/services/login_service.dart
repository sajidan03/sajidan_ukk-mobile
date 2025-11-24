import 'dart:convert';
import 'package:skillpp_kelas12/models/login_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  static const String baseUrl = 'https://learncode.biz.id/api';
  
  static Future<Map<String, dynamic>> login(LoginModel logindata) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(logindata.toJson()),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        if (data['token'] != null) {
          await _saveToken(data['token']);
        }
        
        return {
          'success': true, 
          'message': 'Login Berhasil', 
          'data': data
        };
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': 'Username atau password salah : $error'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error : $e'};
    }
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      return null;
    }
  }

  static Future<void> logout() async {
    try {
      await _clearToken();
      
      final String? token = await getToken();
      if (token != null && token.isNotEmpty) {
        try {
          await http.post(
            Uri.parse('$baseUrl/logout'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ).timeout(Duration(seconds: 5));
        } catch (e) {
        }
      }
    } catch (e) {
      await _clearToken();
    }
  }

  static Future<void> _clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } catch (e) {
    }
  }
}