import 'package:flutter/material.dart';

class LoginLink extends StatelessWidget {
  const LoginLink({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        // TODO: 로그인 페이지로 이동
        print('로그인 페이지 이동');
      },
      child: const Text('로그인하기'),
    );
  }
}
