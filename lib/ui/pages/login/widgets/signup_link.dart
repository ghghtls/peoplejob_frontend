import 'package:flutter/material.dart';

class SignUpLink extends StatelessWidget {
  const SignUpLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('아직 회원이 아니신가요?'),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          child: const Text(
            '회원가입하기',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
