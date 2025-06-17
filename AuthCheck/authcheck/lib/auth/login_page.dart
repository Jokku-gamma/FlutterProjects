import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
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
            ElevatedButton(
              child: Text('Login'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                  if (result == null) {
                    // Show error
                  } else {
                    // Login successful, AuthWrapper will handle navigation
                  }
                }
              },
            ),
            TextButton(
              child: Text('Don\'t have an account? Register'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage())),
            ),
          ],
        ),
      ),
    );
  }
}