import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role; // 'applicant' or 'employer'
  final String profilePhotoUrl;
  final String? selfiePhotoUrl;
  final String? ktpPhotoUrl;
  final Timestamp createdAt;
  final bool? verifiedKTP;

  final Map<String, dynamic>? applicantData;
  final Map<String, dynamic>? employerData;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.profilePhotoUrl,
    required this.createdAt,
    this.selfiePhotoUrl,
    this.ktpPhotoUrl,
    this.verifiedKTP,
    this.applicantData,
    this.employerData,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String uid) {
    return UserModel(
      uid: uid,
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      profilePhotoUrl: json['profilePhotoUrl'],
      selfiePhotoUrl: json['selfiePhotoUrl'],
      ktpPhotoUrl: json['ktpPhotoUrl'],
      createdAt: json['createdAt'],
      verifiedKTP: json['verifiedKTP'],
      applicantData: json['applicantData'],
      employerData: json['employerData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'profilePhotoUrl': profilePhotoUrl,
      'selfiePhotoUrl': selfiePhotoUrl,
      'ktpPhotoUrl': ktpPhotoUrl,
      'createdAt': createdAt,
      'verifiedKTP': verifiedKTP,
      'applicantData': role == 'applicant' ? applicantData : null,
      'employerData': role == 'employer' ? employerData : null,
    };
  }
}