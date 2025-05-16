import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SewlMateInterviewScreen extends StatefulWidget {
  const SewlMateInterviewScreen({super.key});

  @override
  State<SewlMateInterviewScreen> createState() => _SewlMateInterviewScreenState();
}

class _SewlMateInterviewScreenState extends State<SewlMateInterviewScreen> {
  bool isLoading = false;
  List<String> questions = [];
  List<String> answers = [];
  int currentQuestion = 0;
  String role = 'applicant';
  final answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data();
    setState(() {
      role = data?['role'] ?? 'applicant';
    });
  }

  Future<void> _startInterview() async {
    setState(() => isLoading = true);

    try {
      final prompt = role == 'applicant'
          ? "Generate 3 situational interview questions for a domestic worker to assess reliability, communication, and work ethic."
          : "Generate 3 situational interview questions for a household employer to assess expectations, communication style, and management preferences.";

      final response = await http.post(
        Uri.parse("https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=${dotenv.env['GEMINI_API_KEY']!}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      print('Gemini status: ${response.statusCode}');
      print('Gemini body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Gemini failed: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data['candidates'] == null || data['candidates'].isEmpty) {
        throw Exception('Gemini response missing candidates.');
      }

      final rawText = data['candidates'][0]['content']['parts'][0]['text'] as String;
      final parsed = rawText
          .split(RegExp(r"\n+|\d+[.)]"))
          .map((q) => q.trim())
          .where((q) => q.isNotEmpty)
          .toList();

      setState(() {
        questions = parsed.take(3).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Gemini error: $e");
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load questions: $e')),
      );
    }
  }

  Future<void> _submitInterview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final qnaText = List.generate(
      questions.length,
          (i) => 'Q: ${questions[i]}\nA: ${answers[i]}',
    ).join("\n\n");

    final analysisPrompt =
        "You are SewlMate. Analyze the following interview and summarize the applicant's or employer's personality traits, sentiment, and work style. Return a JSON with keys: summary, traits (list), sentimentScore (0 to 1). Interview:\n$qnaText";

    final response = await http.post(
      Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${dotenv.env['GEMINI_API_KEY']!}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": analysisPrompt}
            ]
          }
        ]
      }),
    );

    final content = jsonDecode(response.body)['candidates'][0]['content']['parts'][0]['text'];
    final result = jsonDecode(content);

    final summary = result['summary'];
    final traits = List<String>.from(result['traits']);
    final sentimentScore = result['sentimentScore'];

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      role == 'applicant' ? 'applicantData' : 'employerData': {
        'interviewSummary': summary,
        'interviewTraits': traits,
        'sentimentScore': sentimentScore,
      }
    }, SetOptions(merge: true));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Interview Completed'),
        content: Text('Summary: $summary\n\nTraits: ${traits.join(", ")}\nSentiment: $sentimentScore'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
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
            child: Stack(
              children: [
                Positioned(
                  left: 36,
                  top: 189,
                  child: SizedBox(
                    width: 322,
                    child: Text(
                      'Let’s get to know you',
                      style: TextStyle(
                        color: Color(0xFF3E3E3E),
                        fontSize: 25,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 36,
                  top: 249,
                  child: SizedBox(
                    width: 337,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Hi, I’m SewlMate — your AI interviewer.',
                            style: TextStyle(
                              color: Color(0xFF3E3E3E),
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: ' I’ll ask you a few questions to understand your personality and work style. Feel free to answer in your preferred language.',
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
                  ),
                ),
                Positioned(
                  bottom: 80,
                  left: 100,
                  right: 100,
                  child: ElevatedButton(
                    onPressed: _startInterview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      shape: StadiumBorder(),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Start Interview',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFAF8F5),
                          fontSize: 18,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = questions[currentQuestion];

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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Question ${currentQuestion + 1}',
                    style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Color(0xFF3E3E3E))),
                const SizedBox(height: 24),
                Text(question,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: Color(0xFF3E3E3E))),
                const SizedBox(height: 32),
                TextField(
                  controller: answerController,
                  style: const TextStyle(fontFamily: 'Poppins'),
                  decoration: InputDecoration(
                    hintText: 'Your answer...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (answerController.text.isEmpty) return;
                    answers.add(answerController.text);
                    answerController.clear();
                    if (currentQuestion + 1 < questions.length) {
                      setState(() => currentQuestion++);
                    } else {
                      _submitInterview();
                    }
                  },
                  child: Text(currentQuestion + 1 < questions.length ? 'Next' : 'Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
