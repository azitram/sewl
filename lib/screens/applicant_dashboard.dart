import 'package:flutter/material.dart';

class ApplicantDashboard extends StatelessWidget {
  const ApplicantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        title: const Text('Applicant Dashboard'),
        backgroundColor: const Color(0xFFB4A89D),
      ),
      body: const Center(
        child: Text(
          'Welcome, Applicant! 🎉',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Color(0xFF3E3E3E),
          ),
        ),
      ),
    );
  }
}