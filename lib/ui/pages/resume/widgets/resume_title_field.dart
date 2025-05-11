import 'package:flutter/material.dart';

class ResumeTitleField extends StatelessWidget {
  final String initialValue;

  const ResumeTitleField({super.key, required this.initialValue});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);

    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(labelText: '이력서 제목'),
    );
  }
}
