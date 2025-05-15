import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peoplejob_frontend/data/provider/admin_provider.dart';
import 'package:peoplejob_frontend/data/provider/auth_provider.dart';
import 'package:peoplejob_frontend/services/auth_service.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final success = await AuthService().login(
        email: email,
        password: password,
        context: context,
      );

      if (success) {
        final role = await AuthService().getRole();

        final isAdmin = email == 'admin@admin.com';
        final userType = role == 'company' ? 'company' : 'user';

        ref.read(isAdminProvider.notifier).state = isAdmin;
        ref.read(userTypeProvider.notifier).state = userType;

        if (isAdmin) {
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
        } else if (userType == 'company') {
          Navigator.pushReplacementNamed(context, '/companymypage');
        } else {
          Navigator.pushReplacementNamed(context, '/mypage');
        }
      } else {
        setState(() {
          _errorMessage = '로그인 실패: 이메일 또는 비밀번호를 확인하세요.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '오류 발생: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: '이메일'),
            validator:
                (value) => value == null || value.isEmpty ? '이메일을 입력하세요' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: '비밀번호'),
            obscureText: true,
            validator:
                (value) =>
                    value == null || value.isEmpty ? '비밀번호를 입력하세요' : null,
          ),
          const SizedBox(height: 24),
          if (_errorMessage != null)
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),

          // ✅ 이메일(JWT) 로그인 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('이메일로 로그인'),
            ),
          ),
          const SizedBox(height: 12),

          // ✅ 구글 로그인 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Google 계정으로 로그인'),
              onPressed: () async {
                await AuthService().signInWithGoogle(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
