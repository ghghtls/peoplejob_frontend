import 'package:flutter/material.dart';
import 'widgets/profile_image_picker.dart';
import 'widgets/profile_name_email_fields.dart';
import 'widgets/profile_save_button.dart';

class ProfileEditPage extends StatelessWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필 편집')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            ProfileImagePicker(),
            SizedBox(height: 20),
            ProfileNameEmailFields(),
            SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: const ProfileSaveButton(),
    );
  }
}
