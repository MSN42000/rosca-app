import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _authService.logout();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
          )
        ],
      ),
      body: Center(
        child: Text(user != null
            ? 'Bienvenue ${user.email}'
            : 'Aucun utilisateur connecté'),
      ),
    );
  }
}
