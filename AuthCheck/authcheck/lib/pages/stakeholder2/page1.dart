import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';

class Stakeholder2Page1 extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stakeholder2 Page1'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              // No manual navigation needed; AuthWrapper handles it
            },
          ),
        ],
      ),
      body: Center(child: Text('Stakeholder2 Page1 Content')),
    );
  }
}