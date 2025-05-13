import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'choose_role_screen.dart';
import 'applicant_dashboard.dart';
import 'applicant_setup_screen.dart';
import 'employer_dashboard.dart';
import 'employer_setup_screen.dart'; // Create this next

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const ChooseRoleScreen();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        if (data == null || !data.containsKey('role')) {
          return const ChooseRoleScreen();
        }

        final role = data['role'];

        if (role == 'applicant') {
          final isSetupDone = data.containsKey('applicantData') &&
              data['ktpPhotoUrl'] != null &&
              data['profilePhotoUrl'] != null;

          return isSetupDone ? const ApplicantDashboard() : const ApplicantSetupScreen();
        }

        if (role == 'employer') {
          final isSetupDone = data.containsKey('employerData') &&
              data['employerData'] != null &&
              data['employerData']['companyName'] != null;

          return isSetupDone ? const EmployerDashboard() : const EmployerSetupScreen();
        }

        return const ChooseRoleScreen(); // fallback
      },
    );
  }
}