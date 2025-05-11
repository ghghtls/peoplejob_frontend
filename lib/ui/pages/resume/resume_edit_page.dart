import 'package:flutter/material.dart';
import 'package:peoplejob_frontend/ui/pages/resume/widgets/resume_address_field.dart';
import 'package:peoplejob_frontend/ui/pages/resume/widgets/resume_image_picker.dart';
import 'widgets/resume_title_field.dart';
import 'widgets/resume_description_field.dart';
import 'widgets/resume_file_upload.dart';
import 'widgets/resume_save_button.dart';

class ResumeEditPage extends StatelessWidget {
  const ResumeEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이력서 작성')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            ResumeTitleField(),
            SizedBox(height: 16),
            ResumeDescriptionField(),
            SizedBox(height: 16),
            ResumeAddressField(),
            SizedBox(height: 16),
            ResumeImagePicker(),
            SizedBox(height: 16),
            ResumeFileUpload(),
            SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: const ResumeSaveButton(),
    );
  }
}
