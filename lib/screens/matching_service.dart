import 'package:cloud_firestore/cloud_firestore.dart';

class MatchingService {
  /// Get top 5 recommended applicants for a given jobId
  static Future<List<Map<String, dynamic>>> getTopApplicantsForJob(String jobId) async {
    final jobDoc = await FirebaseFirestore.instance.collection('jobs').doc(jobId).get();
    if (!jobDoc.exists) return [];

    final jobData = jobDoc.data()!;
    final jobRole = jobData['role'] as String;
    final employerId = jobData['createdBy'] as String;

    final employerDoc = await FirebaseFirestore.instance.collection('users').doc(employerId).get();
    final employerTraits = List<String>.from(employerDoc.data()?['employerData']?['interviewTraits'] ?? []);

    final userQuery = await FirebaseFirestore.instance.collection('users').get();
    final applicants = <Map<String, dynamic>>[];

    for (final doc in userQuery.docs) {
      final data = doc.data();
      if (data['role'] != 'applicant') continue;

      final applicantData = data['applicantData'] ?? {};
      final applicantTraits = List<String>.from(applicantData['interviewTraits'] ?? []);
      final category = applicantData['preferredCategory'] ?? '';

      // Trait matching: Jaccard similarity
      final traitSet1 = employerTraits.toSet();
      final traitSet2 = applicantTraits.toSet();
      final intersection = traitSet1.intersection(traitSet2).length;
      final union = traitSet1.union(traitSet2).length;
      final traitScore = union == 0 ? 0.0 : intersection / union;

      // Role/category match
      final roleScore = (category == jobRole) ? 1.0 : 0.0;

      final matchScore = traitScore * 0.7 + roleScore * 0.3;

      applicants.add({
        'uid': doc.id,
        'fullName': data['fullName'] ?? '',
        'profilePhotoUrl': data['profilePhotoUrl'] ?? '',
        'interviewTraits': applicantTraits,
        'sentimentScore': applicantData['sentimentScore'] ?? 0.0,
        'matchScore': matchScore,
      });
    }

    applicants.sort((a, b) => b['matchScore'].compareTo(a['matchScore']));
    return applicants.take(5).toList();
  }

  /// Get top 5 recommended jobs for a given applicantId
  static Future<List<Map<String, dynamic>>> getTopJobsForApplicant(String applicantId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(applicantId).get();
    final applicantData = userDoc.data()?['applicantData'] ?? {};
    final applicantTraits = List<String>.from(applicantData['interviewTraits'] ?? []);
    final category = applicantData['preferredCategory'] ?? '';

    if (applicantTraits.isEmpty || category.isEmpty) return [];

    final jobsQuery = await FirebaseFirestore.instance.collection('jobs').get();
    final jobs = jobsQuery.docs;

    final results = <Map<String, dynamic>>[];

    for (final job in jobs) {
      final jobData = job.data();
      final jobId = job.id;
      final employerId = jobData['createdBy'];

      final employerDoc = await FirebaseFirestore.instance.collection('users').doc(employerId).get();
      final employerTraits = List<String>.from(employerDoc.data()?['employerData']?['interviewTraits'] ?? []);

      // Trait matching: Jaccard similarity
      final setA = applicantTraits.toSet();
      final setB = employerTraits.toSet();
      final intersection = setA.intersection(setB).length;
      final union = setA.union(setB).length;
      final traitScore = union == 0 ? 0.0 : intersection / union;

      // Category match
      final role = jobData['role'] ?? '';
      final categoryScore = (role == category) ? 1.0 : 0.0;

      final matchScore = traitScore * 0.7 + categoryScore * 0.3;

      results.add({
        'jobId': jobId,
        'matchScore': matchScore,
        ...jobData,
      });
    }

    results.sort((a, b) => b['matchScore'].compareTo(a['matchScore']));
    return results.take(5).toList();
  }
}
