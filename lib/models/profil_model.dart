class ProfileResponse {
  final bool success;
  final String message;
  final Profile data;

  ProfileResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'],
      message: json['message'],
      data: Profile.fromJson(json['data']),
    );
  }
}

class Profile {
  final int idUser;
  final String nama;
  final String username;
  final String kontak;
  final String role;
  final String createdAt;

  Profile({
    required this.idUser,
    required this.nama,
    required this.username,
    required this.kontak,
    required this.role,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      idUser: json['id_user'],
      nama: json['nama'],
      username: json['username'],
      kontak: json['kontak'],
      role: json['role'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'nama': nama,
      'username': username,
      'kontak': kontak,
      'role': role,
      'created_at': createdAt,
    };
  }

  String get formattedDate {
    try {
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return createdAt;
    }
  }
}