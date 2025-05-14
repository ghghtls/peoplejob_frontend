import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peoplejob_frontend/data/provider/resume_providers.dart';

class ResumeFileUpload extends ConsumerWidget {
  const ResumeFileUpload({super.key});

  Future<void> _pickFile(WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);
      ref.read(resumeFileProvider.notifier).state = file;
    }
  }

  void _removeFile(WidgetRef ref) {
    ref.read(resumeFileProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = ref.watch(resumeFileProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('첨부파일', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _pickFile(ref),
              child: const Text('파일 선택'),
            ),
            const SizedBox(width: 16),
            if (file != null) Expanded(child: Text(file.path.split('/').last)),
            if (file != null)
              TextButton(
                onPressed: () => _removeFile(ref),
                child: const Text('제거'),
              ),
          ],
        ),
      ],
    );
  }
}
