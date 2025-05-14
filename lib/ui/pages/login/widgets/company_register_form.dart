import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 전역 Provider 재사용
final profileImageProvider = StateProvider<XFile?>((ref) => null);

class CompanyRegisterForm extends ConsumerWidget {
  const CompanyRegisterForm({super.key});

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final image = ref.read(profileImageProvider);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("로그인이 필요합니다.")));
      return;
    }

    String profileUrl = '';
    if (image != null) {
      final file = File(image.path);
      final refPath = FirebaseStorage.instance.ref().child(
        'company_logos/${user.uid}',
      );
      await refPath.putFile(file);
      profileUrl = await refPath.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'email': user.email,
      'nickname': '기업회원', // 필요 시 회사명 입력값 저장 가능
      'profileImage': profileUrl,
      'userType': 'company',
      'createdAt': DateTime.now().toIso8601String(),
      'lastLoginAt': DateTime.now().toIso8601String(),
    });

    Navigator.pushReplacementNamed(context, '/companymypage');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(profileImageProvider);

    return Column(
      children: [
        // 회사 로고 업로드
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
            child: image == null ? const Icon(Icons.business) : null,
          ),
        ),
        const SizedBox(height: 16),

        // 회사명, 사업자번호 등 기본 폼
        const _CompanyRegisterFormFields(),

        const SizedBox(height: 16),

        // 가입 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _submit(context, ref),
            child: const Text('기업회원 가입하기'),
          ),
        ),
      ],
    );
  }
}

class _CompanyRegisterFormFields extends StatelessWidget {
  const _CompanyRegisterFormFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        TextField(
          decoration: InputDecoration(
            labelText: '회사명',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: '사업자등록번호',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: '담당자 이메일',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: '비밀번호',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
      ],
    );
  }
}
