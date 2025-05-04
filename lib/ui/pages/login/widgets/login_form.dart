import 'package:flutter/material.dart';
import 'login_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool autoLogin = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: '이메일'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: '비밀번호'),
        ),
        CheckboxListTile(
          title: const Text("자동 로그인"),
          value: autoLogin,
          onChanged: (value) {
            setState(() {
              autoLogin = value ?? false;
            });
          },
        ),
        const SizedBox(height: 20),
        LoginButton(
          email: emailController.text,
          password: passwordController.text,
        ),
      ],
    );
  }
}
