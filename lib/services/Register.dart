import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skillpp_kelas12/models/User.dart';

class Register{
  static const String baseUrl = 'http://192.168.130.178:8000/api';

  static Future<Map<String, dynamic>> createUser(User user) async {
    try {
      print('=== DEBUG CREATE USER ===');
      print('URL: $baseUrl/users/create');
      print('User Data: ${user.toJson()}');
      print('JSON Encoded: ${jsonEncode(user.toJson())}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/users/create'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(user.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      print('=== RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      // Handle different status codes
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Success Response: $jsonResponse');

        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'User created successfully',
          'data': jsonResponse['user'] ?? jsonResponse,
        };
      } else if (response.statusCode == 422) {
        // Validation errors (Laravel typical)
        final errors = json.decode(response.body);
        print('Validation Errors: $errors');
        return {
          'success': false,
          'message':
              'Validation error: ${errors['errors']?.toString() ?? 'Unknown validation error'}',
          'errors': errors['errors'],
        };
      } else if (response.statusCode == 400) {
        // Bad request
        final error = json.decode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Bad request'};
      } else if (response.statusCode == 500) {
        // Server error
        return {'success': false, 'message': 'Server error (500)'};
      } else {
        // Other status codes
        final error = json.decode(response.body);
        return {
          'success': false,
          'message':
              error['message'] ??
              'Failed to create user. Status: ${response.statusCode}',
        };
      }
    } on FormatException catch (e) {
      print('Format Exception: $e');
      return {
        'success': false,
        'message': 'Invalid response format from server',
      };
    } on http.ClientException catch (e) {
      print('Client Exception: $e');
      return {
        'success': false,
        'message': 'Network error. Check your connection and server URL',
      };
    } catch (e) {
      print('General Exception: $e');
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }
}
