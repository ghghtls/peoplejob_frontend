import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final profileImageProvider = StateProvider<XFile?>((ref) => null);
final isRegisteringProvider = StateProvider<bool>((ref) => false);

class IndividualRegisterForm extends ConsumerStatefulWidget {
  const IndividualRegisterForm({super.key});

  @override
  ConsumerState<IndividualRegisterForm> createState() => _FormState();
}

class _FormState extends ConsumerState<IndividualRegisterForm> {
  final _userid = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _zipcode = TextEditingController();
  final _address = TextEditingController();
  final _addressDetail = TextEditingController();

  Future<void> _submit() async {
    final image = ref.read(profileImageProvider);
    final isLoading = ref.read(isRegisteringProvider);
    if (isLoading) return;

    ref.read(isRegisteringProvider.notifier).state = true;

    String profileUrl = '';
    if (image != null) {
      final file = File(image.path);
      final refPath = FirebaseStorage.instance.ref().child(
        'profile_images/${_userid.text}',
      );
      await refPath.putFile(file);
      profileUrl = await refPath.getDownloadURL();
    }

    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _email.text,
      password: _password.text,
    );

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'userid': _userid.text,
      'password': _password.text,
      'name': _name.text,
      'email': _email.text,
      'phone': _phone.text,
      'zipcode': _zipcode.text,
      'address': _address.text,
      'addressDetail': _addressDetail.text,
      'userType': 'user',
      'emailVerified': false,
      'emailVerifyCode': '',
      'role': 'ROLE_USER',
      'regdate': DateTime.now().toIso8601String(),
      'profileImage': profileUrl,
    });

    ref.read(isRegisteringProvider.notifier).state = false;
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final image = ref.watch(profileImageProvider);
    final isLoading = ref.watch(isRegisteringProvider);

    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            final picked = await ImagePicker().pickImage(
              source: ImageSource.gallery,
            );
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
          controller: _userid,
          decoration: const InputDecoration(labelText: '아이디'),
        ),
        TextField(
          controller: _password,
          decoration: const InputDecoration(labelText: '비밀번호'),
          obscureText: true,
        ),
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: '이름'),
        ),
        TextField(
          controller: _email,
          decoration: const InputDecoration(labelText: '이메일'),
        ),
        TextField(
          controller: _phone,
          decoration: const InputDecoration(labelText: '전화번호'),
        ),
        TextField(
          controller: _zipcode,
          decoration: const InputDecoration(labelText: '우편번호'),
        ),
        TextField(
          controller: _address,
          decoration: const InputDecoration(labelText: '주소'),
        ),
        TextField(
          controller: _addressDetail,
          decoration: const InputDecoration(labelText: '상세주소'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: isLoading ? null : _submit,
          child:
              isLoading
                  ? const CircularProgressIndicator()
                  : const Text('가입하기'),
        ),
      ],
    );
  }
}
