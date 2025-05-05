import 'package:flutter/material.dart';

class ResumeTitleField extends StatelessWidget {
  const ResumeTitleField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        labelText: '이력서 제목',
        border: OutlineInputBorder(),
      ),
    );
  }
}
