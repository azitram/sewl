import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

const List<String> jobRoles = [
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

class EmployerJobPostScreen extends StatefulWidget {
  const EmployerJobPostScreen({super.key});

  @override
  State<EmployerJobPostScreen> createState() => _EmployerJobPostScreenState();
}

class _EmployerJobPostScreenState extends State<EmployerJobPostScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Fields
  String role = jobRoles[0];
  String description = '';
  String jobType = 'full-time';
  String workingStart = '';
  String workingEnd = '';
  bool includesWeekend = false;
  bool weekendHoursDifferent = false;
  String weekendStart = '';
  String weekendEnd = '';
  DateTime? preferredStartDate;

  // Address
  String storeText = '';
  double? storeLat;
  double? storeLng;

  // Language
  List<String> languagePreference = [];
  final _languageController = TextEditingController();

  // Benefits
  bool mealsProvided = false;
  bool transportReimbursed = false;
  bool housingIncluded = false;

  // Salary
  double? salaryAmount;
  String salaryCurrency = 'IDR';
  String salaryUnit = 'per_day';

  // Contact
  String contactName = '';
  String contactPhone = '';
  String contactEmail = '';
  String contactDesc = '';

  void _submit() async {
    if (!_formKey.currentState!.validate() || preferredStartDate == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final jobData = {
      'role': role,
      'description': description,
      'jobType': jobType,
      'workingHours': {'start': workingStart, 'end': workingEnd},
      'includesWeekend': includesWeekend,
      'weekendHoursDifferent': weekendHoursDifferent,
      'weekendWorkingHours': {
        'start': weekendStart,
        'end': weekendEnd,
      },
      'preferredStartDate': Timestamp.fromDate(preferredStartDate!),
      'storeAddress': {'text': storeText, 'lat': storeLat, 'lng': storeLng},
      'languagePreference': languagePreference,
      'mealsProvided': mealsProvided,
      'transportReimbursed': transportReimbursed,
      'housingIncluded': housingIncluded,
      'salary': {
        'amount': salaryAmount,
        'currency': salaryCurrency,
        'unit': salaryUnit,
      },
      'contactInfo': {
        'name': contactName,
        'phone': contactPhone,
        'email': contactEmail,
        'description': contactDesc,
      },
      'createdBy': uid,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('jobs').add(jobData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job posted successfully!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  void _addLanguage() {
    final input = _languageController.text.trim();
    if (input.isNotEmpty && !languagePreference.contains(input)) {
      setState(() {
        languagePreference.add(input);
        _languageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Set up your job post',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: const Color(0xFFD9A89E),
        foregroundColor: const Color(0xFF3E3E3E),
      ),
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
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildDropdownField('Job Role', jobRoles, role, (val) => setState(() => role = val!)),
                  _buildTextField('Job Description', (val) => description = val, maxLines: 3),
                  _buildDropdownField('Job Type', ['full-time', 'part-time', 'one-time'], jobType, (val) => setState(() => jobType = val!)),

                  const SizedBox(height: 20),
                  const Text('Working Hour'),
                  _buildTextField('Start Time (e.g. 08:00)', (val) => workingStart = val),
                  _buildTextField('End Time (e.g. 16:00)', (val) => workingEnd = val),

                  _buildSwitch('Includes Weekend?', includesWeekend, (val) => setState(() => includesWeekend = val)),
                  _buildSwitch('Different Weekend Hours?', weekendHoursDifferent, (val) => setState(() => weekendHoursDifferent = val)),

                  if (weekendHoursDifferent) ...[
                    _buildTextField('Weekend Start Time (e.g. 08:00)', (val) => weekendStart = val),
                    _buildTextField('Weekend End Time (e.g. 16:00)', (val) => weekendEnd = val),
                  ],

                  const SizedBox(height: 12),
                  ListTile(
                    title: const Text('Preferred Start Date'),
                    subtitle: Text(preferredStartDate != null
                        ? DateFormat('dd MMM yyyy').format(preferredStartDate!)
                        : 'Choose a date'),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) setState(() => preferredStartDate = date);
                    },
                  ),

                  const SizedBox(height: 12),
                  _buildTextField('Store Address (text)', (val) => storeText = val),
                  _buildTextField('Latitude', (val) => storeLat = double.tryParse(val), keyboard: TextInputType.number),
                  _buildTextField('Longitude', (val) => storeLng = double.tryParse(val), keyboard: TextInputType.number),

                  const SizedBox(height: 12),
                  const Text('Language Preference'),
                  Row(children: [
                    Expanded(child: TextField(controller: _languageController)),
                    IconButton(icon: const Icon(Icons.add), onPressed: _addLanguage),
                  ]),
                  Wrap(
                    spacing: 6,
                    children: languagePreference
                        .map((lang) => Chip(label: Text(lang), onDeleted: () => setState(() => languagePreference.remove(lang))))
                        .toList(),
                  ),

                  _buildSwitch('Meals Provided?', mealsProvided, (val) => setState(() => mealsProvided = val)),
                  _buildSwitch('Transport Reimbursed?', transportReimbursed, (val) => setState(() => transportReimbursed = val)),
                  _buildSwitch('Housing Included?', housingIncluded, (val) => setState(() => housingIncluded = val)),

                  const SizedBox(height: 12),
                  _buildTextField('Salary Amount (e.g. 3000000)', (val) => salaryAmount = double.tryParse(val), keyboard: TextInputType.number),
                  _buildTextField('Currency (e.g. IDR)', (val) => salaryCurrency = val),
                  _buildDropdownField('Salary Unit', ['per_hour', 'per_day', 'per_week', 'per_month'], salaryUnit, (val) => setState(() => salaryUnit = val!)),

                  const SizedBox(height: 12),
                  _buildTextField('Contact Name', (val) => contactName = val),
                  _buildTextField('Contact Phone', (val) => contactPhone = val),
                  _buildTextField('Contact Email', (val) => contactEmail = val),
                  _buildTextField('Contact Description', (val) => contactDesc = val, maxLines: 2),

                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E3E3E),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    child: const Text('Post Job', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged,
      {int maxLines = 1, TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label, border: const UnderlineInputBorder()),
        validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String current, void Function(String?)? onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: current,
        items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        decoration: InputDecoration(labelText: label),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}
