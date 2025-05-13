import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ApplicantSetupScreen extends StatefulWidget {
  const ApplicantSetupScreen({super.key});

  @override
  State<ApplicantSetupScreen> createState() => _ApplicantSetupScreenState();
}

class _ApplicantSetupScreenState extends State<ApplicantSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '';
  String phoneNumber = '';
  String emergencyName = '';
  String emergencyPhone = '';
  List<Map<String, String>> pastJobs = [];
  List<Map<String, String>> endorsements = [];
  File? profilePhoto;
  File? ktpPhoto;

  void _pickImage(bool isKTP) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isKTP) {
          ktpPhoto = File(picked.path);
        } else {
          profilePhoto = File(picked.path);
        }
      });
    }
  }

  void _addPastJob() {
    setState(() {
      pastJobs.add({'role': '', 'companyName': '', 'duration': ''});
    });
  }

  void _addEndorsement() {
    setState(() {
      endorsements.add({'name': '', 'phone': '', 'relationship': ''});
    });
  }

  Future<String> _uploadImageToStorage(File imageFile, String path) async {
    final storageRef = FirebaseStorage.instance.ref().child(path);
    final uploadTask = await storageRef.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (ktpPhoto == null || profilePhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload both KTP and profile photos')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final uid = user.uid;

      String ktpUrl = await _uploadImageToStorage(ktpPhoto!, 'ktp_photos/$uid.jpg');
      String profileUrl = await _uploadImageToStorage(profilePhoto!, 'profile_photos/$uid.jpg');

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'ktpPhotoUrl': ktpUrl,
        'profilePhotoUrl': profileUrl,
        'verifiedKTP': false,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'applicant',
        'applicantData': {
          'pastJobs': pastJobs,
          'communityEndorsements': endorsements,
          'emergencyContact': {
            'name': emergencyName,
            'phone': emergencyPhone,
          },
          'interviewTraits': [],
          'sentimentScore': null,
          'interviewSummary': '',
        },
      }, SetOptions(merge: true));

      Navigator.pushReplacementNamed(context, '/applicant_dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
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
            colors: [
              Color(0xFFD9A89E),
              Color(0xFFDEB6AD),
              Color(0xFFEBD3CD),
              Color(0xFFF0E2DD),
              Color(0xFFFAF8F5),
              Color(0xFFF7F1EE),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Set up your profile',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Color(0xFF3E3E3E),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Full Name'),
                  _buildUnderlineTextField((value) => fullName = value),

                  _buildLabel('Phone Number'),
                  _buildUnderlineTextField((value) => phoneNumber = value, keyboardType: TextInputType.phone),

                  const SizedBox(height: 20),

                  _buildLabel('Upload Profile Photo'),
                  if (profilePhoto != null) Image.file(profilePhoto!, height: 100),
                  _buildSmallGradientButton('Pick Profile Photo', () => _pickImage(false)),

                  const SizedBox(height: 16),

                  _buildLabel('Upload KTP Photo'),
                  if (ktpPhoto != null) Image.file(ktpPhoto!, height: 100),
                  _buildSmallGradientButton('Pick KTP Photo', () => _pickImage(true)),

                  const SizedBox(height: 24),
                  _buildLabel('Past Jobs'),
                  ...pastJobs.asMap().entries.map((entry) {
                    int i = entry.key;
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel('Role (Job ${i + 1})'),
                            TextButton(
                              onPressed: () => setState(() => pastJobs.removeAt(i)),
                              child: const Text('Remove', style: TextStyle(color: Color(0xff3E3E3E))),
                            ),
                          ],
                        ),
                        _buildUnderlineTextField((val) => pastJobs[i]['role'] = val, required: false),
                        _buildLabel('Company Name'),
                        _buildUnderlineTextField((val) => pastJobs[i]['companyName'] = val, required: false),
                        _buildLabel('Duration'),
                        _buildUnderlineTextField((val) => pastJobs[i]['duration'] = val, required: false),
                        const SizedBox(height: 12),
                      ],
                    );
                  }),
                  _buildSmallGradientButton('Add Past Job', _addPastJob),

                  const SizedBox(height: 24),
                  _buildLabel('Community Endorsements'),
                  ...endorsements.asMap().entries.map((entry) {
                    int i = entry.key;
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel('Name (Endorsement ${i + 1})'),
                            TextButton(
                              onPressed: () => setState(() => endorsements.removeAt(i)),
                              child: const Text('Remove', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                        _buildUnderlineTextField((val) => endorsements[i]['name'] = val, required: false),
                        _buildLabel('Phone'),
                        _buildUnderlineTextField((val) => endorsements[i]['phone'] = val, required: false),
                        _buildLabel('Relationship'),
                        _buildUnderlineTextField((val) => endorsements[i]['relationship'] = val, required: false),
                        const SizedBox(height: 12),
                      ],
                    );
                  }),
                  _buildSmallGradientButton('Add Endorsement', _addEndorsement),

                  const SizedBox(height: 24),
                  _buildLabel('Emergency Contact'),
                  _buildUnderlineTextField((value) => emergencyName = value),
                  _buildLabel('Phone'),
                  _buildUnderlineTextField((value) => emergencyPhone = value),

                  const SizedBox(height: 32),
                  Center(
                    child: _buildGradientButton('Submit', _submit),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Poppins',
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w400,
          color: Color(0xFF3E3E3E),
        ),
      ),
    );
  }

  Widget _buildUnderlineTextField(Function(String) onChanged, {TextInputType keyboardType = TextInputType.text, bool required = true}) {
    return TextFormField(
      decoration: const InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF3E3E3E), width: 2),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF3E3E3E), width: 2),
        ),
        fillColor: Colors.transparent,
        filled: true,
      ),
      style: const TextStyle(fontFamily: 'Poppins', color: Color(0xFF3E3E3E)),
      keyboardType: keyboardType,
      validator: required ? (value) => value == null || value.isEmpty ? 'Required' : null : null,
      onChanged: onChanged,
    );
  }

  Widget _buildGradientButton(String label, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFA8A8A8), Color(0xFF3E3E3E)],
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallGradientButton(String label, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: 180,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFA8A8A8), Color(0xFF3E3E3E)],
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
