import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployerDashboard extends StatelessWidget {
  const EmployerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find the right person, the right way',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Color(0xFF3E3E3E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Let ',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF3E3E3E),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        TextSpan(
                          text: 'sewl',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF3E3E3E),
                          ),
                        ),
                        TextSpan(
                          text: ' help you match with someone who truly fits your needs.',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF3E3E3E),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/job-post');
                      },
                      icon: const Icon(Icons.add, color: Color(0xFF3E3E3E)),
                      label: const Text(
                        'Create Job Listing',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF3E3E3E),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF4D38E),
                        foregroundColor: const Color(0xFF3E3E3E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(28, 20, 28, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Posted Jobs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Color(0xFF3E3E3E),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('jobs')
                    .where('createdBy', isEqualTo: uid)
                    .orderBy('preferredStartDate')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final jobs = docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

                  if (jobs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No jobs posted yet.',
                        style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                    itemCount: jobs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return _buildJobCard(context, job);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job) {
    final role = job['role'] ?? 'Unknown Role';
    final shop = job['storeAddress']?['text'] ?? 'Unknown Location';
    final salary = job['salary']?['amount'] ?? 0;
    final jobType = job['jobType'] ?? 'Unknown Type';
    final status = job['status'] ?? 'active';

    final isClosed = status.toLowerCase() == 'closed';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFD9D9D9), Color(0xFF737373)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(role,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Color(0xFF3E3E3E),
              )),
          const SizedBox(height: 4),
          Text(shop,
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                fontFamily: 'Poppins',
                color: Color(0xFF3E3E3E),
              )),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.money, size: 18, color: Color(0xFF3E3E3E)),
              const SizedBox(width: 4),
              Text(
                'Rp ${salary.toString()},-',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Poppins',
                  color: Color(0xFF3E3E3E),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 18, color: Color(0xFF3E3E3E)),
              const SizedBox(width: 4),
              Text(
                jobType,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Poppins',
                  color: Color(0xFF3E3E3E),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isClosed ? const Color(0xFFD9A89E) : const Color(0xFFB4D4AD),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  isClosed ? 'Closed' : 'Active',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: isClosed ? const Color(0xFF815349) : const Color(0xFF50604C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              // TODO: Navigate to review submissions screen
              // Navigator.pushNamed(context, '/review-submissions', arguments: jobId);
            },
            child: const Text(
              'review submissions',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                color: Color(0xFF3E3E3E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
