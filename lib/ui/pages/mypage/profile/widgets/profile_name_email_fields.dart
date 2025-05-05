import 'package:flutter/material.dart';

class ProfileNameEmailFields extends StatelessWidget {
  const ProfileNameEmailFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: '이름',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: '이메일',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: true,
          decoration: const InputDecoration(
            labelText: '비밀번호 변경 (선택)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
