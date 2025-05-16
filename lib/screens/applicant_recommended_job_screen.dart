import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'matching_service.dart';

class ApplicantRecommendedJobsScreen extends StatefulWidget {
  const ApplicantRecommendedJobsScreen({super.key});

  @override
  State<ApplicantRecommendedJobsScreen> createState() => _ApplicantRecommendedJobsScreenState();
}

class _ApplicantRecommendedJobsScreenState extends State<ApplicantRecommendedJobsScreen> {
  late Future<List<Map<String, dynamic>>> _recommendedJobsFuture;
  final appliedJobIds = <String>{};

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _recommendedJobsFuture = MatchingService.getTopJobsForApplicant(uid);
      _loadAppliedJobs(uid);
    }
  }

  Future<void> _loadAppliedJobs(String uid) async {
    final apps = await FirebaseFirestore.instance
        .collection('applications')
        .where('applicantId', isEqualTo: uid)
        .get();

    setState(() {
      appliedJobIds.addAll(apps.docs.map((doc) => doc['jobId'] as String));
    });
  }

  Future<void> _applyToJob(BuildContext context, Map<String, dynamic> job) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Application'),
        content: const Text('Are you sure you want to apply to this job?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Apply')),
        ],
      ),
    );

    if (confirmed != true) return;

    final jobId = job['id'] as String;
    final jobRef = FirebaseFirestore.instance.collection('jobs').doc(jobId);

    await FirebaseFirestore.instance.collection('applications').add({
      'applicantId': user.uid,
      'jobId': jobId,
      'jobRef': jobRef,
      'status': 'pending',
      'appliedAt': FieldValue.serverTimestamp(),
    });

    setState(() => appliedJobIds.add(jobId));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Application submitted successfully!')),
    );
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
              Color(0xFFD9A89E),
              Color(0xFFDEB6AD),
              Color(0xFFEBD3CD),
              Color(0xFFF0E2DD),
              Color(0xFFFAF8F5),
              Color(0xFFF7F1EE),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommended for You',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Color(0xFF3E3E3E),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _recommendedJobsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final jobs = snapshot.data ?? [];
                      if (jobs.isEmpty) {
                        return const Center(child: Text('No suitable jobs found.', style: TextStyle(fontFamily: 'Poppins')));
                      }
                      return ListView.separated(
                        itemCount: jobs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final job = jobs[index];
                          final jobId = job['id'];
                          final alreadyApplied = appliedJobIds.contains(jobId);

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job['role'] ?? 'Unknown Role',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                    color: Color(0xFF3E3E3E),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  job['storeAddress']?['text'] ?? 'Unknown Location',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    fontFamily: 'Poppins',
                                    color: Color(0xFF3E3E3E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: alreadyApplied ? null : () => _applyToJob(context, job),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF50604D),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  child: Text(alreadyApplied ? 'Already Applied' : 'Apply'),
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
