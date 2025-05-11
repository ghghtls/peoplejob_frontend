import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ResumeImagePicker extends StatefulWidget {
  const ResumeImagePicker({super.key});

  @override
  State<ResumeImagePicker> createState() => _ResumeImagePickerState();
}

class _ResumeImagePickerState extends State<ResumeImagePicker> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _selectedImage == null
            ? const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_placeholder.png'),
            )
            : CircleAvatar(
              radius: 50,
              backgroundImage: FileImage(_selectedImage!),
            ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: _pickImage, child: const Text('이미지 선택')),
            const SizedBox(width: 16),
            if (_selectedImage != null)
              TextButton(onPressed: _removeImage, child: const Text('제거')),
          ],
        ),
      ],
    );
  }
}
