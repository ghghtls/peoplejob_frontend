import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peoplejob_frontend/data/provider/resume_providers.dart';

class ResumeSaveButton extends ConsumerWidget {
  const ResumeSaveButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          final title = ref.read(resumeTitleProvider);
          final description = ref.read(resumeDescriptionProvider);
          final file = ref.read(resumeFileProvider);

          // 저장 처리
          debugPrint('저장된 제목: $title');
          debugPrint('저장된 자기소개: $description');
          debugPrint('첨부파일 경로: ${file?.path}');

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('이력서가 저장되었습니다.')));

          Navigator.pop(context);
        },
        child: const Text('저장하기'),
      ),
    );
  }
}
