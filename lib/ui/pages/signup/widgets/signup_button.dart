import 'package:flutter/material.dart';

class SignUpButton extends StatelessWidget {
  final String email;
  final String password;
  final String name;
  final String userType;

  const SignUpButton({
    super.key,
    required this.email,
    required this.password,
    required this.name,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // TODO: 회원가입 API 연결 예정
        print('회원가입 시도: $email / $password / $name / $userType');
      },
      child: const Text('회원가입'),
    );
  }
}
