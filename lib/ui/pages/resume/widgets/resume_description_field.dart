import 'package:flutter/material.dart';

class ResumeDescriptionField extends StatelessWidget {
  final String initialValue;

  const ResumeDescriptionField({super.key, required this.initialValue});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);

    return TextFormField(
      controller: controller,
      maxLines: 5,
      decoration: const InputDecoration(labelText: '자기소개'),
    );
  }
}
