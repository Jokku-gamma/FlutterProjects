import 'package:flutter/material.dart';
import 'auth_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  int? stakeholder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (val) => setState(() => email = val),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (val) => setState(() => password = val),
            ),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Stakeholder'),
              items: [1, 2, 3].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('Stakeholder $value'),
                );
              }).toList(),
              onChanged: (val) => setState(() => stakeholder = val),
            ),
            ElevatedButton(
              child: Text('Register'),
              onPressed: () async {
                if (_formKey.currentState!.validate() && stakeholder != null) {
                  dynamic result = await _auth.registerWithEmailAndPassword(email, password, stakeholder!);
                  if (result == null) {
                    // Show error
                  } else {
                    // Registration successful, AuthWrapper will handle navigation
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}