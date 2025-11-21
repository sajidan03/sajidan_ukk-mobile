// class UserModel {
//   final String number_of_users;
//   final List<User> users;

//   UserModel({
//     required this.number_of_users,
//     required this.users,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       number_of_users: json['number_of_users'].toString(), // Convert to String
//       users: (json['users'] as List)
//           .map((userJson) => User.fromJson(userJson))
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'number_of_users': number_of_users,
//       'users': users.map((user) => user.toJson()).toList(),
//     };
//   }
// }

// class User {
//   final int id;
//   final String name;
//   final String email;
//   final String username;
//   final String? email_verified_at;
//   final String created_at;
//   final String updated_at;

//   User({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.username,
//     this.email_verified_at,
//     required this.created_at,
//     required this.updated_at,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'],
//       name: json['name'],
//       email: json['email'],
//       username: json['username'],
//       email_verified_at: json['email_verified_at'],
//       created_at: json['created_at'],
//       updated_at: json['updated_at'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       'username': username,
//       'email_verified_at': email_verified_at,
//       'created_at': created_at,
//       'updated_at': updated_at,
//     };
//   }
// }