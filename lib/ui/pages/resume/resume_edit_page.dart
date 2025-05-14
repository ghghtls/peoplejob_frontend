import 'package:flutter/material.dart';
import 'package:peoplejob_frontend/ui/pages/resume/widgets/resume_address_field.dart';
import 'package:peoplejob_frontend/ui/pages/resume/widgets/resume_image_picker.dart';
import 'widgets/resume_title_field.dart';
import 'widgets/resume_description_field.dart';
import 'widgets/resume_file_upload.dart';
import 'widgets/resume_save_button.dart';

class ResumeEditPage extends StatelessWidget {
  final String? initialTitle;
  final String? initialDescription;

  const ResumeEditPage({super.key, this.initialTitle, this.initialDescription});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이력서 작성')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ResumeTitleField(initialValue: initialTitle ?? ''),
            const SizedBox(height: 16),
            ResumeDescriptionField(initialValue: initialDescription ?? ''),
            const SizedBox(height: 16),
            const ResumeAddressField(),
            const SizedBox(height: 16),
            const ResumeImagePicker(),
            const SizedBox(height: 16),
            const ResumeFileUpload(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: const ResumeSaveButton(),
    );
  }
}
