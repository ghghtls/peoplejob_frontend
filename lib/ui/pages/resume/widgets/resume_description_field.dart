import 'package:flutter/material.dart';

class ResumeDescriptionField extends StatelessWidget {
  const ResumeDescriptionField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: 8,
      decoration: const InputDecoration(
        labelText: '자기소개 및 경력 요약',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
    );
  }
}
