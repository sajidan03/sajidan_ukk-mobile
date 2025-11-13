import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skillpp_kelas12/models/UserModel.dart';

class UserService {
  static Future<UserModel> getUsers() async {
    final response = await http.get(
      Uri.parse('http://192.168.110.109:8000/api/users'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return UserModel.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load users');
    }
  }
}
