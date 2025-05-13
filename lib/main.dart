import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sewl/screens/login_screen.dart';
import 'package:sewl/screens/choose_role_screen.dart';
import 'package:sewl/screens/applicant_dashboard.dart';
import 'package:sewl/screens/employer_dashboard.dart';
import 'package:sewl/screens/role_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sewl',
      debugShowCheckedModeBanner: false,
      home: const RoleRouter(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/choose-role': (context) => const ChooseRoleScreen(),
        '/applicant-dashboard': (context) => const ApplicantDashboard(),
        '/employer-dashboard': (context) => const EmployerDashboard(),
      },
    );
  }
}