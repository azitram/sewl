import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String role;
  final String jobType;
  final Map<String, String> workingHours;
  final bool includesWeekend;
  final bool weekendHoursDifferent;
  final Map<String, String>? weekendWorkingHours;
  final Timestamp preferredStartDate;
  final String description;
  final Map<String, dynamic> storeAddress;
  final List<String> languagePreference;
  final bool mealsProvided;
  final bool transportReimbursed;
  final bool housingIncluded;
  final Map<String, dynamic> salary;
  final Map<String, String> contactInfo;

  JobModel({
    required this.id,
    required this.role,
    required this.jobType,
    required this.workingHours,
    required this.includesWeekend,
    required this.weekendHoursDifferent,
    this.weekendWorkingHours,
    required this.preferredStartDate,
    required this.description,
    required this.storeAddress,
    required this.languagePreference,
    required this.mealsProvided,
    required this.transportReimbursed,
    required this.housingIncluded,
    required this.salary,
    required this.contactInfo,
  });

  factory JobModel.fromJson(Map<String, dynamic> json, String id) {
    return JobModel(
      id: id,
      role: json['role'],
      jobType: json['jobType'],
      workingHours: Map<String, String>.from(json['workingHours']),
      includesWeekend: json['includesWeekend'],
      weekendHoursDifferent: json['weekendHoursDifferent'],
      weekendWorkingHours: json['weekendWorkingHours'] != null
          ? Map<String, String>.from(json['weekendWorkingHours'])
          : null,
      preferredStartDate: json['preferredStartDate'],
      description: json['description'],
      storeAddress: Map<String, dynamic>.from(json['storeAddress']),
      languagePreference: List<String>.from(json['languagePreference']),
      mealsProvided: json['mealsProvided'],
      transportReimbursed: json['transportReimbursed'],
      housingIncluded: json['housingIncluded'],
      salary: Map<String, dynamic>.from(json['salary']),
      contactInfo: Map<String, String>.from(json['contactInfo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'jobType': jobType,
      'workingHours': workingHours,
      'includesWeekend': includesWeekend,
      'weekendHoursDifferent': weekendHoursDifferent,
      if (weekendWorkingHours != null)
        'weekendWorkingHours': weekendWorkingHours,
      'preferredStartDate': preferredStartDate,
      'description': description,
      'storeAddress': storeAddress,
      'languagePreference': languagePreference,
      'mealsProvided': mealsProvided,
      'transportReimbursed': transportReimbursed,
      'housingIncluded': housingIncluded,
      'salary': salary,
      'contactInfo': contactInfo,
    };
  }
}