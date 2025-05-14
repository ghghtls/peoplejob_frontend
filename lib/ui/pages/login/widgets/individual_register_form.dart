import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peoplejob_frontend/ui/pages/login/register_page.dart';

class IndividualRegisterForm extends ConsumerWidget {
  const IndividualRegisterForm({super.key});

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final nickname = ref.read(nicknameProvider).trim();
    final image = ref.read(profileImageProvider);
    final user = FirebaseAuth.instance.currentUser;
    final isLoading = ref.read(isRegisteringProvider);

    if (nickname.isEmpty || isLoading) return;

    final validNickname = RegExp(r'^[a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가-힣]+$');
    if (!validNickname.hasMatch(nickname)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('닉네임에 특수문자는 사용할 수 없습니다.')));
      return;
    }

    ref.read(isRegisteringProvider.notifier).state = true;

    String profileUrl = '';
    if (image != null) {
      final file = File(image.path);
      final refPath = FirebaseStorage.instance.ref().child(
        'profile_images/${user!.uid}',
      );
      await refPath.putFile(file);
      profileUrl = await refPath.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'email': user!.email,
      'nickname': nickname,
      'profileImage': profileUrl,
      'createdAt': DateTime.now().toIso8601String(),
      'lastLoginAt': DateTime.now().toIso8601String(),
    });

    ref.read(isRegisteringProvider.notifier).state = false;
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nickname = ref.watch(nicknameProvider);
    final image = ref.watch(profileImageProvider);
    final isLoading = ref.watch(isRegisteringProvider);

    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            final picker = ImagePicker();
            final picked = await picker.pickImage(source: ImageSource.gallery);
            if (picked != null) {
              ref.read(profileImageProvider.notifier).state = picked;
            }
          },
          child: CircleAvatar(
            radius: 40,
            backgroundImage: image != null ? FileImage(File(image.path)) : null,
            child: image == null ? const Icon(Icons.add_a_photo) : null,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: (val) => ref.read(nicknameProvider.notifier).state = val,
          decoration: const InputDecoration(
            labelText: '닉네임',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _submit(context, ref),
            child:
                isLoading
                    ? const CircularProgressIndicator()
                    : const Text('가입하기'),
          ),
        ),
      ],
    );
  }
}
