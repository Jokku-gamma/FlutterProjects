import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../dashboards/stakeholder1_dash.dart';
import '../dashboards/stakeholder2_dash.dart';
import '../dashboards/stakeholder3_dash.dart';
import 'login_page.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).get(),
            builder: (context, fsSnapshot) {
              if (fsSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (fsSnapshot.hasData && fsSnapshot.data!.exists) {
                int stakeholder = fsSnapshot.data!['stakeholder'];
                switch (stakeholder) {
                  case 1:
                    return Stakeholder1Dashboard();
                  case 2:
                    return Stakeholder2Dashboard();
                  case 3:
                    return Stakeholder3Dashboard();
                  default:
                    return Text('Invalid stakeholder');
                }
              } else {
                return Text('Error: User document not found');
              }
            },
          );
        } else {
          return LoginPage();
        }
      },
    );
  }
}