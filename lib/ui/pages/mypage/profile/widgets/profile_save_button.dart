import 'package:flutter/material.dart';

class ProfileSaveButton extends StatelessWidget {
  const ProfileSaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: 저장 API 연동
          print("프로필 저장");
        },
        child: const Text('저장하기'),
      ),
    );
  }
}
