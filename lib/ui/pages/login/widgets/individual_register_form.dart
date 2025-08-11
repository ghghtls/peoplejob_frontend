import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

final profileImageProvider = StateProvider<XFile?>((ref) => null);
final isRegisteringProvider = StateProvider<bool>((ref) => false);

class IndividualRegisterForm extends ConsumerStatefulWidget {
  const IndividualRegisterForm({super.key});

  @override
  ConsumerState<IndividualRegisterForm> createState() => _FormState();
}

class _FormState extends ConsumerState<IndividualRegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _userid = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _zipcode = TextEditingController();
  final _address = TextEditingController();
  final _addressDetail = TextEditingController();

  // 백엔드 URL (Docker 환경)
  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8888';

  @override
  void dispose() {
    _userid.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _zipcode.dispose();
    _address.dispose();
    _addressDetail.dispose();
    super.dispose();
  }

  // 아이디 중복 체크
  Future<bool> _checkUseridAvailable() async {
    if (_userid.text.trim().isEmpty) return false;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/users/check/${_userid.text.trim()}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['available'] == true;
      }
    } catch (e) {
      debugPrint('ID 중복 체크 실패: $e');
    }
    return false;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // 비밀번호 확인
    if (_password.text != _passwordConfirm.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')));
      return;
    }

    ref.read(isRegisteringProvider.notifier).state = true;

    try {
      // 아이디 중복 체크
      final isAvailable = await _checkUseridAvailable();
      if (!isAvailable) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('이미 사용중인 아이디입니다.')));
        return;
      }

      // 회원가입 요청
      final payload = {
        "userid": _userid.text.trim(),
        "password": _password.text,
        "name": _name.text.trim(),
        "email": _email.text.trim(),
        "phone": _phone.text.trim(),
        "zipcode": _zipcode.text.trim(),
        "address": _address.text.trim(),
        "addressDetail": _addressDetail.text.trim(),
        "userType": "user", // 개인회원
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 개발 환경: 인증코드 표시
        if (data['verifyCode'] != null) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('이메일 인증코드'),
                  content: Text(
                    '인증코드: ${data['verifyCode']}\n(개발용 - 실제로는 이메일로 발송됩니다)',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('확인'),
                    ),
                  ],
                ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('회원가입 완료! 로그인해주세요.')));
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error['error'] ?? '회원가입 실패')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('네트워크 오류: $e')));
    } finally {
      if (mounted) {
        ref.read(isRegisteringProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = ref.watch(profileImageProvider);
    final isLoading = ref.watch(isRegisteringProvider);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 프로필 이미지 (선택)
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
              backgroundImage:
                  image != null ? FileImage(File(image.path)) : null,
              child: image == null ? const Icon(Icons.add_a_photo) : null,
            ),
          ),
          const SizedBox(height: 16),

          // 아이디
          TextFormField(
            controller: _userid,
            decoration: const InputDecoration(
              labelText: '아이디 *',
              hintText: '영문, 숫자 조합 4-20자',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '아이디를 입력해주세요';
              }
              if (value.length < 4 || value.length > 20) {
                return '아이디는 4-20자로 입력해주세요';
              }
              return null;
            },
          ),

          // 비밀번호
          TextFormField(
            controller: _password,
            decoration: const InputDecoration(
              labelText: '비밀번호 *',
              hintText: '8자 이상',
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력해주세요';
              }
              if (value.length < 8) {
                return '비밀번호는 8자 이상이어야 합니다';
              }
              return null;
            },
          ),

          // 비밀번호 확인
          TextFormField(
            controller: _passwordConfirm,
            decoration: const InputDecoration(labelText: '비밀번호 확인 *'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호 확인을 입력해주세요';
              }
              return null;
            },
          ),

          // 이름
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: '이름 *'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '이름을 입력해주세요';
              }
              return null;
            },
          ),

          // 이메일
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(
              labelText: '이메일 *',
              hintText: 'example@email.com',
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '이메일을 입력해주세요';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return '올바른 이메일 형식이 아닙니다';
              }
              return null;
            },
          ),

          // 전화번호
          TextFormField(
            controller: _phone,
            decoration: const InputDecoration(
              labelText: '전화번호',
              hintText: '010-1234-5678',
            ),
            keyboardType: TextInputType.phone,
          ),

          // 우편번호
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _zipcode,
                  decoration: const InputDecoration(labelText: '우편번호'),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // TODO: 주소 검색 API 연동
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('주소 검색 기능 준비중')));
                },
                child: const Text('주소검색'),
              ),
            ],
          ),

          // 주소
          TextFormField(
            controller: _address,
            decoration: const InputDecoration(labelText: '주소'),
            readOnly: true,
          ),

          // 상세주소
          TextFormField(
            controller: _addressDetail,
            decoration: const InputDecoration(labelText: '상세주소'),
          ),

          const SizedBox(height: 24),

          // 가입 버튼
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child:
                  isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('가입하기', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
