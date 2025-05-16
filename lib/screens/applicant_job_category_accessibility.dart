import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sewl/screens/sewlmate_interview_screen.dart';

class ApplicantJobCategoryAccessibility extends StatefulWidget {
  const ApplicantJobCategoryAccessibility({super.key});

  @override
  State<ApplicantJobCategoryAccessibility> createState() => _ApplicantJobCategoryAccessibilityState();
}

class _ApplicantJobCategoryAccessibilityState extends State<ApplicantJobCategoryAccessibility> {
  final List<String> jobCategories = [
    'Cook/Kitchen Helper',
    'Housekeeper/Cleaner',
    'Babysitter/Nanny',
    'Elderly Caregiver',
    'Shop Helper/Cashier',
    'Food Stall Worker',
    'Driver/Delivery',
    'Tailor/Seamstress',
    'Handyman/Repair',
    'Crafts',
  ];

  String? selectedCategory;
  bool needsAccessibility = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedCategory = jobCategories[5];
  }

  Future<void> _handleContinue() async {
    setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;

    // Save selectedCategory and accessibility to Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'applicantData': {
        'preferredCategory': selectedCategory,
        'needsAccessibility': needsAccessibility,
      }
    }, SetOptions(merge: true));

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = userDoc.data();

    final hasInterview = data != null &&
        data['applicantData'] != null &&
        data['applicantData']['interviewSummary'] != null &&
        (data['applicantData']['interviewSummary'] as String).trim().isNotEmpty;

    setState(() => isLoading = false);

    if (hasInterview) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ApplicantQuickApplyScreen(
            category: selectedCategory!,
            needsAccessibility: needsAccessibility,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SewlMateInterviewScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFECC57F),
              Color(0xFFFBE0B0),
              Color(0xFFFEF2DE),
              Color(0xFFFAF8F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'What kind of jobs are you looking for?',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Color(0xFF3E3E3E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select your preferred job types',
                      style: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: Color(0xFF3E3E3E),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2EAE4),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFFB4A89D),
                          width: 3,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          items: jobCategories
                              .map((job) => DropdownMenuItem(
                            value: job,
                            child: Text(
                              job,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: Color(0xFF3E3E3E),
                              ),
                            ),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                          icon: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Do you need accessibility assistance?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Color(0xFF3E3E3E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Sewl',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Poppins',
                              color: Color(0xFF3E3E3E),
                            ),
                          ),
                          TextSpan(
                            text: ' currently supports ',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3E3E3E),
                            ),
                          ),
                          TextSpan(
                            text: 'deaf or mute',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Poppins',
                              color: Color(0xFF3E3E3E),
                            ),
                          ),
                          TextSpan(
                            text:
                            ' applicants with AI tools like voice-to-text and interview adjustments. More accessibility options coming soon.',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3E3E3E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Switch(
                          value: needsAccessibility,
                          activeColor: const Color(0xFF50604D),
                          activeTrackColor: const Color(0xFFB4D4AD),
                          onChanged: (value) {
                            setState(() {
                              needsAccessibility = value;
                            });
                          },
                        ),
                        Text(
                          needsAccessibility ? 'Yes' : 'No',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Color(0xFF50604D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB4A89D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            'Continue',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ApplicantQuickApplyScreen extends StatelessWidget {
  final String category;
  final bool needsAccessibility;
  const ApplicantQuickApplyScreen({required this.category, required this.needsAccessibility, super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Quick Apply for $category')));
}
