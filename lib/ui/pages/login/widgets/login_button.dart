import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final String email;
  final String password;

  const LoginButton({super.key, required this.email, required this.password});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // TODO: 리버팟 상태 연결 시 로그인 로직 추가
        print('로그인 시도: $email / $password');
      },
      child: const Text('로그인'),
    );
  }
}
