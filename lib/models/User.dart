class User {
  final String name;
  final String email;
  final String username;
  final String password;

  User({
    required this.name,
    required this.email,
    required this.username,
    required this.password,
  });
  Map<String, dynamic> toJson() {
    return {
      "message": "User created successfully",
      "user": {
        "name": name,
        'email' : email,
        'username' : username,
        'password' : password,
    }
    };
  }
  factory User.fromJson(Map<String, dynamic> json){
     return User(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
