import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChooseRoleScreen extends StatelessWidget {
  const ChooseRoleScreen({super.key});

  Future<void> _setRoleAndNavigate(BuildContext context, String role) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'role': role},
        SetOptions(merge: true), // Prevents overwriting other fields
      );

      if (role == 'employer') {
        Navigator.pushReplacementNamed(context, '/employer-dashboard');
      } else if (role == 'applicant') {
        Navigator.pushReplacementNamed(context, '/applicant-dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'You are..',
                  style: TextStyle(
                    color: Color(0xFF3E3E3E),
                    fontSize: 25,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Employer Card
                    GestureDetector(
                      onTap: () => _setRoleAndNavigate(context, 'employer'),
                      child: Container(
                        width: 150,
                        height: 150,
                        padding: const EdgeInsets.all(10),
                        decoration: ShapeDecoration(
                          gradient: const RadialGradient(
                            center: Alignment(0.5, 0.4),
                            radius: 0.74,
                            colors: [Color(0xFFB4A89D), Color(0xFF7C746D)],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/employer_icon.png',
                              width: 75,
                              height: 75,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'employer',
                              style: TextStyle(
                                color: Color(0xFF3E3E3E),
                                fontSize: 18,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Applicant Card
                    GestureDetector(
                      onTap: () => _setRoleAndNavigate(context, 'applicant'),
                      child: Container(
                        width: 150,
                        height: 150,
                        padding: const EdgeInsets.all(10),
                        decoration: ShapeDecoration(
                          gradient: const RadialGradient(
                            center: Alignment(0.5, 0.4),
                            radius: 0.74,
                            colors: [Color(0xFFB4A89D), Color(0xFF7C746D)],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/job_icon.png',
                              width: 75,
                              height: 75,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'applicant',
                              style: TextStyle(
                                color: Color(0xFF3E3E3E),
                                fontSize: 18,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
