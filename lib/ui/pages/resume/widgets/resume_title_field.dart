import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peoplejob_frontend/data/provider/resume_providers.dart';

class ResumeTitleField extends ConsumerWidget {
  final String initialValue;

  const ResumeTitleField({super.key, required this.initialValue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: initialValue);

    controller.addListener(() {
      ref.read(resumeTitleProvider.notifier).state = controller.text;
    });

    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: '이력서 제목',
        border: OutlineInputBorder(),
      ),
    );
  }
}
