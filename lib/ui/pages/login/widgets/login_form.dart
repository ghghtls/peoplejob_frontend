import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../main.dart' show isAdminProvider;

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _useridController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  static const Color _blue      = Color(0xFF0B5FFF); // sapphire-500
  static const Color _label     = Color(0xFF0B1220); // ink-900
  static const Color _secondary = Color(0xFF8E8E93); // ink-300
  static const Color _fieldBg   = Color(0xFFF2F2F7); // ink-50
  static const Color _red       = Color(0xFFE5342F); // danger

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _errorMessage;

  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8090';

  @override
  void dispose() {
    _useridController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

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
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final role = data['role'] as String? ?? '';
        final isAdmin = role == 'ADMIN' || role == 'ROLE_ADMIN';
        // role이 ROLE_ADMIN이면 userType을 항상 'admin'으로 강제 설정
        final userType = isAdmin ? 'admin' : (data['userType'] as String? ?? '').toLowerCase();
        await _storage.write(key: 'jwt', value: data['token']);
        await _storage.write(key: 'userid', value: data['userid']);
        await _storage.write(key: 'userNo', value: data['userNo'].toString());
        await _storage.write(key: 'role', value: role);
        await _storage.write(key: 'userType', value: userType);
        await _storage.write(key: 'name', value: data['name']);
        await _storage.write(key: 'email', value: data['email']);

        if (!mounted) return;
        if (isAdmin) {
          ref.read(isAdminProvider.notifier).state = true;
          Navigator.pushReplacementNamed(context, '/admin');
        } else if (userType == 'company') {
          Navigator.pushReplacementNamed(context, '/companymypage');
        } else {
          Navigator.pushReplacementNamed(context, '/mypage');
        }
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() => _errorMessage = error['error'] ?? '아이디 또는 비밀번호가 올바르지 않습니다');
      }
    } catch (e) {
      setState(() => _errorMessage = '네트워크 오류가 발생했습니다');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 아이디
          _buildLabel('아이디'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _useridController,
            hint: '아이디를 입력하세요',
            prefixIcon: Icons.person_outline_rounded,
            validator: (v) => (v == null || v.trim().isEmpty) ? '아이디를 입력하세요' : null,
          ),
          const SizedBox(height: 16),

          // 비밀번호
          _buildLabel('비밀번호'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _passwordController,
            hint: '비밀번호를 입력하세요',
            prefixIcon: Icons.lock_outline_rounded,
            obscure: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: _secondary,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) => (v == null || v.isEmpty) ? '비밀번호를 입력하세요' : null,
          ),
          const SizedBox(height: 8),

          // 에러 메시지
          if (_errorMessage != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: _red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: _red, fontSize: 14, letterSpacing: -0.2),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // 로그인 유지 + 비밀번호 찾기
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (v) => setState(() => _rememberMe = v ?? false),
                        activeColor: _blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        side: const BorderSide(color: Color(0xFFD1D1D6), width: 1.5),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '로그인 유지',
                      style: TextStyle(fontSize: 14, color: _secondary, letterSpacing: -0.2),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/find-password'),
                style: TextButton.styleFrom(
                  foregroundColor: _secondary,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                ),
                child: const Text(
                  '비밀번호 찾기',
                  style: TextStyle(fontSize: 14, letterSpacing: -0.2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 로그인 버튼
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                disabledBackgroundColor: _blue.withValues(alpha: 0.4),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // 또는 구분선
          Row(
            children: [
              const Expanded(child: Divider(color: Color(0xFFE5E5EA))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '또는',
                  style: const TextStyle(fontSize: 13, color: _secondary, letterSpacing: -0.2),
                ),
              ),
              const Expanded(child: Divider(color: Color(0xFFE5E5EA))),
            ],
          ),
          const SizedBox(height: 20),

          // 카카오 로그인 버튼
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEE500),
                foregroundColor: const Color(0xFF1A1A1A),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_rounded, size: 20, color: Color(0xFF1A1A1A)),
                  SizedBox(width: 8),
                  Text(
                    '카카오로 시작하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 아이디 찾기 | 회원가입
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _linkButton('아이디 찾기', () => Navigator.pushNamed(context, '/find-id')),
              _divider(),
              _linkButton('회원가입', () => Navigator.pushNamed(context, '/register'), bold: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _label,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(fontSize: 16, color: _label, letterSpacing: -0.3),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _secondary, fontSize: 15),
        prefixIcon: Icon(prefixIcon, color: _secondary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _blue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _red, width: 1.5),
        ),
        errorStyle: const TextStyle(color: _red, fontSize: 12),
      ),
    );
  }

  Widget _linkButton(String label, VoidCallback onTap, {bool bold = false}) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: bold ? _blue : _secondary,
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _divider() {
    return const Text(
      '|',
      style: TextStyle(color: Color(0xFFD1D1D6), fontSize: 14),
    );
  }
}
