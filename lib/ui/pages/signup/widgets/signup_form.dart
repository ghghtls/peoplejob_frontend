import 'package:flutter/material.dart';
import 'signup_button.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  String userType = '개인';

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
        const SizedBox(height: 16),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: '이름'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text("회원유형: "),
            Radio(
              value: '개인',
              groupValue: userType,
              onChanged: (value) {
                setState(() {
                  userType = value!;
                });
              },
            ),
            const Text('개인'),
            Radio(
              value: '기업',
              groupValue: userType,
              onChanged: (value) {
                setState(() {
                  userType = value!;
                });
              },
            ),
            const Text('기업'),
          ],
        ),
        const SizedBox(height: 20),
        SignUpButton(
          email: emailController.text,
          password: passwordController.text,
          name: nameController.text,
          userType: userType,
        ),
      ],
    );
  }
}
