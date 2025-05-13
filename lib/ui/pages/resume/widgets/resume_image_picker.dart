import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peoplejob_frontend/data/provider/resume_providers.dart';

class ResumeImagePicker extends ConsumerWidget {
  const ResumeImagePicker({super.key});

  Future<void> _pickImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      ref.read(resumeImageProvider.notifier).state = File(picked.path);
    }
  }

  void _removeImage(WidgetRef ref) {
    ref.read(resumeImageProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedImage = ref.watch(resumeImageProvider);

    return Column(
      children: [
        selectedImage == null
            ? const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_placeholder.png'),
            )
            : CircleAvatar(
              radius: 50,
              backgroundImage: FileImage(selectedImage),
            ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _pickImage(ref),
              child: const Text('이미지 선택'),
            ),
            const SizedBox(width: 16),
            if (selectedImage != null)
              TextButton(
                onPressed: () => _removeImage(ref),
                child: const Text('제거'),
              ),
          ],
        ),
      ],
    );
  }
}
