import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peoplejob_frontend/data/provider/resume_providers.dart';

class ResumeDescriptionField extends ConsumerWidget {
  final String initialValue;

  const ResumeDescriptionField({super.key, required this.initialValue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: initialValue);

    controller.addListener(() {
      ref.read(resumeDescriptionProvider.notifier).state = controller.text;
    });

    return TextFormField(
      controller: controller,
      maxLines: 5,
      decoration: const InputDecoration(
        labelText: '자기소개',
        border: OutlineInputBorder(),
      ),
    );
  }
}
