import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String id;
  final String applicantId;
  final String employerId;
  final String jobId;
  final String message;
  final String status;
  final DateTime submittedAt;

  ApplicationModel({
    required this.id,
    required this.applicantId,
    required this.employerId,
    required this.jobId,
    required this.message,
    required this.status,
    required this.submittedAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json, String id) {
    return ApplicationModel(
      id: id,
      applicantId: json['applicantId'],
      employerId: json['employerId'],
      jobId: json['jobId'],
      message: json['message'],
      status: json['status'],
      submittedAt: (json['submittedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicantId': applicantId,
      'employerId': employerId,
      'jobId': jobId,
      'message': message,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }
}