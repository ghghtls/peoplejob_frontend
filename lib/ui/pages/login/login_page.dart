import 'package:flutter/material.dart';
import 'widgets/login_form.dart';
import 'widgets/signup_link.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [LoginForm(), SizedBox(height: 20), SignUpLink()],
        ),
      ),
    );
  }
}
