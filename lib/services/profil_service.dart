import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skillpp_kelas12/models/profil_model.dart';

class ProfileService {
  static const String baseUrl = 'https://learncode.biz.id/api';

  // Get profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/profile'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final profileResponse = ProfileResponse.fromJson(data);
        return {
          'success': true,
          'data': profileResponse,
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

  // Update profile (jika diperlukan)
  static Future<Map<String, dynamic>> updateProfile(Profile profile) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile/update'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(profile.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Profil berhasil diupdate',
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