import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'matching_service.dart';


class EmployerReviewSubmissionsScreen extends StatefulWidget {
  final String jobId;
  const EmployerReviewSubmissionsScreen({super.key, required this.jobId});

  @override
  State<EmployerReviewSubmissionsScreen> createState() => _EmployerReviewSubmissionsScreenState();
}

class _EmployerReviewSubmissionsScreenState extends State<EmployerReviewSubmissionsScreen> {
  late Future<List<Map<String, dynamic>>> _topApplicantsFuture;

  @override
  void initState() {
    super.initState();
    _topApplicantsFuture = MatchingService.getTopApplicantsForJob(widget.jobId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: 320,
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top 5 Recommended Applicants',
                    style: TextStyle(
                      color: Color(0xFF3E3E3E),
                      fontSize: 25,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'SewlMate',
                          style: TextStyle(
                            color: Color(0xFF3E3E3E),
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: ' has selected these candidates by matching skills and personality to your needs.',
                          style: TextStyle(
                            color: Color(0xFF3E3E3E),
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _topApplicantsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final applicants = snapshot.data ?? [];

                        if (applicants.isEmpty) {
                          return const Center(child: Text('No recommended applicants found.'));
                        }

                        return ListView.separated(
                          itemCount: applicants.length,
                          padding: const EdgeInsets.only(bottom: 40),
                          separatorBuilder: (_, __) => const SizedBox(height: 20),
                          itemBuilder: (context, index) {
                            final applicant = applicants[index];
                            return _buildApplicantCard(applicant);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicantCard(Map<String, dynamic> applicant) {
    final name = applicant['fullName'] ?? 'Unnamed';
    final traits = List<String>.from(applicant['interviewTraits'] ?? []);
    final sentiment = applicant['sentimentScore']?.toStringAsFixed(2) ?? '0.0';
    final image = applicant['profilePhotoUrl'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const RadialGradient(
          radius: 1.5,
          colors: [
            Color(0xFFF6EDE4),
            Color(0xFFE5DBD2),
            Color(0xFFE1D7CE),
            Color(0xFFDED3CA),
            Color(0xFFCCC1B7),
            Color(0xFFC3B7AD),
            Color(0xFFB4A89D),
            Color(0xFF7C746D),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(image, height: 150, width: double.infinity, fit: BoxFit.cover),
            ),
          const SizedBox(height: 12),
          Text(name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              )),
          const SizedBox(height: 8),
          Text('Traits: ${traits.join(', ')}',
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Poppins',
              )),
          const SizedBox(height: 4),
          Text('Sentiment Score: $sentiment',
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Poppins',
                fontStyle: FontStyle.italic,
              )),
          const SizedBox(height: 8),
          Transform.rotate(
            angle: -0.53,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              color: const Color(0xFFB4D4AD),
              child: const Text(
                'inclusive applicant',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF50604D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
