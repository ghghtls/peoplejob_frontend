import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peoplejob_frontend/ui/pages/login/widgets/company_register_form.dart';
import 'package:peoplejob_frontend/ui/pages/login/widgets/individual_register_form.dart';

final isCompanyUserProvider = StateProvider<bool>((ref) => false);

final nicknameProvider = StateProvider<String>((ref) => '');
final profileImageProvider = StateProvider<XFile?>((ref) => null);
final isRegisteringProvider = StateProvider<bool>((ref) => false);

class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompany = ref.watch(isCompanyUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('회원 유형 선택', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Radio<bool>(
                  value: false,
                  groupValue: isCompany,
                  onChanged:
                      (val) =>
                          ref.read(isCompanyUserProvider.notifier).state = val!,
                ),
                const Text('일반회원'),
                const SizedBox(width: 16),
                Radio<bool>(
                  value: true,
                  groupValue: isCompany,
                  onChanged:
                      (val) =>
                          ref.read(isCompanyUserProvider.notifier).state = val!,
                ),
                const Text('기업회원'),
              ],
            ),
            const SizedBox(height: 16),
            isCompany
                ? const CompanyRegisterForm()
                : const IndividualRegisterForm(),
          ],
        ),
      ),
    );
  }
}
