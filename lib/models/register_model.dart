class RegisterModel {
  final String nama;
  final String kontak;
  final String username;
  final String password;

  RegisterModel({
    required this.nama,
    required this.kontak,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'kontak': kontak,
      'username': username,
      'password': password,
    };
  }
}

class RegisterResponseModel {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  RegisterResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}