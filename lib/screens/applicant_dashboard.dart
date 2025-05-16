import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'applicant_job_category_accessibility.dart';
import 'applicant_recommended_job_screen.dart';

class ApplicantDashboard extends StatefulWidget {
  const ApplicantDashboard({super.key});

  @override
  State<ApplicantDashboard> createState() => _ApplicantDashboardState();
}

class _ApplicantDashboardState extends State<ApplicantDashboard> {
  Stream<List<Map<String, dynamic>>> _appliedJobsStream() async* {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      yield [];
      return;
    }

    await for (var apps in FirebaseFirestore.instance
        .collection('applications')
        .where('applicantId', isEqualTo: user.uid)
        .snapshots()) {
      List<Map<String, dynamic>> results = [];

      for (var app in apps.docs) {
        final jobRef = app['jobRef'] as DocumentReference;
        final jobSnap = await jobRef.get();
        if (!jobSnap.exists) continue;
        final jobData = jobSnap.data() as Map<String, dynamic>;
        results.add({
          'role': jobData['role'],
          'storeName': jobData['contactInfo']['name'],
          'salary': jobData['salary']['amount'],
          'jobType': jobData['jobType'],
          'status': app['status'],
        });
      }

      yield results;
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    String label = status;

    switch (status.toLowerCase()) {
      case 'accepted':
        bgColor = Colors.green.shade300;
        break;
      case 'rejected':
        bgColor = Colors.red.shade300;
        break;
      default:
        bgColor = Colors.grey.shade400;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFBE0B0),
              Color(0xFFFEF2DE),
              Color(0xFFFAF8F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Find the right job, the right way',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E3E3E),
                  ),
                ),
                const SizedBox(height: 10),
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Let '),
                      TextSpan(
                          text: 'sewl',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                          ' help you match with jobs that truly fit your needs.'),
                    ],
                  ),
                  style: TextStyle(fontSize: 14, color: Color(0xFF3E3E3E)),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ApplicantJobCategoryAccessibility(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFBE0B0), Color(0xFFE6B05C)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        '+ Apply to job',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E3E3E),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ApplicantRecommendedJobsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB4D4AD), Color(0xFF88B48B)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        '🔎 Job Recommendations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E3E3E),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Jobs Applied',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E3E3E),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _appliedJobsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No applications yet.'));
                      }
                      final jobs = snapshot.data!;
                      return ListView.builder(
                        itemCount: jobs.length,
                        itemBuilder: (context, index) {
                          final job = jobs[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEDEDED), Color(0xFFCBCBCB)],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job['role'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  job['storeName'],
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.money, size: 18),
                                    const SizedBox(width: 6),
                                    Text('Rp ${job['salary'].toStringAsFixed(0)},-'),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.access_time, size: 18),
                                    const SizedBox(width: 6),
                                    Text(job['jobType']),
                                    const Spacer(),
                                    _buildStatusBadge(job['status']),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
