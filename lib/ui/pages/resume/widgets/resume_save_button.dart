import 'package:flutter/material.dart';

class ResumeSaveButton extends StatelessWidget {
  const ResumeSaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: 저장 API 연결
          print("이력서 저장");
        },
        child: const Text('저장하기'),
      ),
    );
  }
}
