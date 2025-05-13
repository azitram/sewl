import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'choose_role_screen.dart';
import 'applicant_dashboard.dart';
import 'employer_dashboard.dart';

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // User is not signed in
      return const LoginScreen();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          // User doc doesn't exist yet
          return const ChooseRoleScreen();
        }

        final role = snapshot.data!.get('role');

        if (role == 'employer') {
          return const EmployerDashboard();
        } else if (role == 'applicant') {
          return const ApplicantDashboard();
        } else {
          return const ChooseRoleScreen(); // Fallback if role is invalid
        }
      },
    );
  }
}