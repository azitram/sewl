import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'choose_role_screen.dart';
import 'applicant_dashboard.dart';
import 'applicant_setup_screen.dart';
import 'employer_dashboard.dart';
import 'employer_setup_screen.dart';
import 'sewlmate_interview_screen.dart';

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
          final applicantData = data['applicantData'] ?? {};
          final hasSetup = applicantData['ktpPhotoUrl'] != null && applicantData['profilePhotoUrl'] != null;
          final hasInterviewed = applicantData['interviewSummary'] != null &&
              (applicantData['interviewSummary'] as String).trim().isNotEmpty;

          if (!hasSetup) return const ApplicantSetupScreen();
          if (!hasInterviewed) return const SewlMateInterviewScreen();
          return const ApplicantDashboard();
        }

        if (role == 'employer') {
          final employerData = data['employerData'] ?? {};
          final hasSetup = employerData['companyName'] != null;
          final hasInterviewed = employerData['interviewSummary'] != null &&
              (employerData['interviewSummary'] as String).trim().isNotEmpty;

          if (!hasSetup) return const EmployerSetupScreen();
          if (!hasInterviewed) return const SewlMateInterviewScreen();
          return const EmployerDashboard();
        }

        return const ChooseRoleScreen(); // fallback
      },
    );
  }
}
