import 'package:flutter/material.dart';
import 'package:skillpp_kelas12/models/UserModel.dart';
import 'package:skillpp_kelas12/services/user_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<UserModel> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = UserService.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users')),
      body: FutureBuilder<UserModel>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userModel = snapshot.data!;
            return Column(
              children: [
                Text('Total Users: ${userModel.number_of_users}'),
                Expanded(
                  child: ListView.builder(
                    itemCount: userModel.users.length,
                    itemBuilder: (context, index) {
                      final user = userModel.users[index];
                      return ListTile(
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        trailing: Text(user.username),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
