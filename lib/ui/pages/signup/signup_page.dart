import 'package:flutter/material.dart';
import 'widgets/signup_form.dart';
import 'widgets/login_link.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [SignUpForm(), SizedBox(height: 20), LoginLink()],
        ),
      ),
    );
  }
}
