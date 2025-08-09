import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

final profileImageProvider = StateProvider<XFile?>((ref) => null);
final _isSubmittingProvider = StateProvider<bool>((ref) => false);

class CompanyRegisterForm extends ConsumerStatefulWidget {
  const CompanyRegisterForm({super.key});

  @override
  ConsumerState<CompanyRegisterForm> createState() => _CompanyState();
}

class _CompanyState extends ConsumerState<CompanyRegisterForm> {
  final _userid = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _zipcode = TextEditingController();
  final _address = TextEditingController();
  final _addressDetail = TextEditingController();

  // TODO: 환경에 맞게 수정 (로컬/EC2 등)
  static const String _baseUrl = 'http://localhost:8080';

  @override
  void dispose() {
    _userid.dispose();
    _password.dispose();
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _zipcode.dispose();
    _address.dispose();
    _addressDetail.dispose();
    super.dispose();
  }

  bool _validateRequired() {
    if (_userid.text.trim().isEmpty ||
        _password.text.trim().isEmpty ||
        _name.text.trim().isEmpty ||
        _email.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('아이디/비밀번호/회사명/이메일은 필수입니다.')));
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_validateRequired()) return;

    // (선택) 이미지 업로드는 백엔드 API가 준비되면 멀티파트로 전송하도록 후처리
    final XFile? image = ref.read(profileImageProvider);
    if (image != null) {
      // TODO: /api/files/upload 같은 엔드포인트가 생기면 여기에서 업로드하고 URL을 받아와 users에 추가
      // 현재 users 테이블에는 프로필 이미지 컬럼이 없으므로 보류
    }

    final payload = {
      "userid": _userid.text.trim(),
      "password": _password.text, // 서버에서 BCrypt로 해시 저장됨
      "name": _name.text.trim(),
      "email": _email.text.trim(),
      "phone": _phone.text.trim(),
      "zipcode": _zipcode.text.trim(),
      "address": _address.text.trim(),
      "addressDetail": _addressDetail.text.trim(),
      "userType": "company", // 기업회원 고정
    };

    ref.read(_isSubmittingProvider.notifier).state = true;

    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/api/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (!mounted) return;

      if (resp.statusCode == 200) {
        // 백엔드가 현재 콘솔에 인증코드를 출력하므로, 안내 메시지만 보여줌
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('가입 완료! 이메일 인증 코드를 확인하세요.')),
        );
        // 가입 후 이동 (원하는 경로로 교체 가능)
        Navigator.pushReplacementNamed(context, '/companymypage');
      } else {
        // 서버에서 내려준 에러 메시지 표시
        final msg = resp.body.isNotEmpty ? resp.body : '회원가입에 실패했습니다.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('네트워크 오류: $e')));
    } finally {
      if (mounted) {
        ref.read(_isSubmittingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = ref.watch(profileImageProvider);
    final isSubmitting = ref.watch(_isSubmittingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 회사 로고(선택)
        Center(
          child: GestureDetector(
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
              backgroundImage:
                  image != null ? FileImage(File(image.path)) : null,
              child: image == null ? const Icon(Icons.business) : null,
            ),
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _userid,
          decoration: const InputDecoration(labelText: '아이디'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _password,
          decoration: const InputDecoration(labelText: '비밀번호'),
          obscureText: true,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: '회사명'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _email,
          decoration: const InputDecoration(labelText: '담당자 이메일'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phone,
          decoration: const InputDecoration(labelText: '전화번호'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _zipcode,
          decoration: const InputDecoration(labelText: '우편번호'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _address,
          decoration: const InputDecoration(labelText: '주소'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _addressDetail,
          decoration: const InputDecoration(labelText: '상세주소'),
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : _submit,
            child:
                isSubmitting
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('기업회원 가입'),
          ),
        ),
      ],
    );
  }
}
