import 'package:flutter/material.dart';

class SignUpLink extends StatelessWidget {
  const SignUpLink({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        // TODO: 회원가입 페이지로 이동
        print('회원가입 페이지 이동');
      },
      child: const Text('회원가입하기'),
    );
  }
}
