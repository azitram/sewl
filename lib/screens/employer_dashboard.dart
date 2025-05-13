import 'package:flutter/material.dart';

class EmployerDashboard extends StatelessWidget {
  const EmployerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        title: const Text('Employer Dashboard'),
        backgroundColor: const Color(0xFF7C746D),
      ),
      body: const Center(
        child: Text(
          'Welcome, Employer! 👋',
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
