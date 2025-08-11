import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _useridController = TextEditingController(); // email 대신 userid
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  String? _errorMessage;

  // 백엔드 URL
  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8888';

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userid': _useridController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // JWT 토큰 저장
        await _storage.write(key: 'jwt', value: data['token']);
        await _storage.write(key: 'userid', value: data['userid']);
        await _storage.write(key: 'role', value: data['role']);
        await _storage.write(key: 'userType', value: data['userType']);
        await _storage.write(key: 'name', value: data['name']);
        await _storage.write(key: 'email', value: data['email']);

        // 역할에 따라 페이지 이동
        if (data['role'] == 'ROLE_ADMIN') {
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
        } else if (data['userType'] == 'company') {
          Navigator.pushReplacementNamed(context, '/companymypage');
        } else {
          Navigator.pushReplacementNamed(context, '/mypage');
        }
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          _errorMessage = error['error'] ?? '로그인 실패';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '네트워크 오류: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _useridController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 아이디 입력
          TextFormField(
            controller: _useridController,
            decoration: InputDecoration(
              labelText: '아이디',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '아이디를 입력하세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 비밀번호 입력
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: '비밀번호',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력하세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),

          // 에러 메시지
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 14),
              ),
            ),
          const SizedBox(height: 24),

          // 로그인 버튼
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text(
                        '로그인',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 12),

          // 구분선
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '또는',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 12),

          // 구글 로그인 버튼 (옵션)
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              icon: Image.network(
                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                height: 20,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.g_mobiledata, size: 20),
              ),
              label: const Text('Google 계정으로 로그인'),
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Google 로그인 준비중')));
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
