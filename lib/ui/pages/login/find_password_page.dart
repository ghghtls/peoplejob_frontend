import 'package:flutter/material.dart';
import '../../../services/password_reset_service.dart';

class FindPasswordPage extends StatefulWidget {
  const FindPasswordPage({super.key});

  @override
  State<FindPasswordPage> createState() => _FindPasswordPageState();
}

class _FindPasswordPageState extends State<FindPasswordPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _fieldBg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);
  static const Color _green = Color(0xFF0FA958);

  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSent = false;
  String _resultMessage = '';
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestPasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _isSent = false;
      _resultMessage = '';
    });

    try {
      final result = await PasswordResetService().requestPasswordReset(
        email: _emailController.text.trim(),
      );

      setState(() {
        _isLoading = false;
        _isSent = true;
        _isSuccess = result['success'] ?? false;
        _resultMessage = result['success']
            ? result['message'] ?? '비밀번호 재설정 이메일이 발송되었습니다.'
            : result['error'] ?? '요청 처리에 실패했습니다.';
      });

      if (_isSuccess) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSent = true;
        _isSuccess = false;
        _resultMessage = '오류가 발생했습니다: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 뒤로가기
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 0, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 20, color: _blue),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ),

            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0B5FFF), Color(0xFF5A99FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _blue.withValues(alpha: 0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '비밀번호 찾기',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.7,
                      color: _label,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '가입한 이메일로 재설정 링크를 보내드립니다',
                    style: TextStyle(fontSize: 15, color: _secondary, letterSpacing: -0.3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 폼 카드
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 안내 박스
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _blue.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded, color: _blue, size: 18),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  '가입 시 사용한 이메일 주소를 입력하시면 비밀번호 재설정 링크를 보내드립니다.',
                                  style: TextStyle(
                                    color: _blue,
                                    fontSize: 13,
                                    height: 1.5,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // 이메일 라벨
                        const Text(
                          '이메일 주소',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _label,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 이메일 필드
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 16, color: _label, letterSpacing: -0.3),
                          decoration: InputDecoration(
                            hintText: 'example@email.com',
                            hintStyle: const TextStyle(color: _secondary, fontSize: 15),
                            prefixIcon: const Icon(Icons.mail_outline_rounded, color: _secondary, size: 20),
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
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return '이메일을 입력해주세요';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return '올바른 이메일 형식이 아닙니다';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // 결과 메시지
                        if (_isSent) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _isSuccess
                                  ? _green.withValues(alpha: 0.1)
                                  : _red.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  _isSuccess
                                      ? Icons.check_circle_rounded
                                      : Icons.error_outline_rounded,
                                  color: _isSuccess ? _green : _red,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _resultMessage,
                                    style: TextStyle(
                                      color: _isSuccess ? _green : _red,
                                      fontSize: 14,
                                      height: 1.5,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // 재설정 링크 버튼
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _requestPasswordReset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue,
                              disabledBackgroundColor: _blue.withValues(alpha: 0.4),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
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
                                    '재설정 링크 보내기',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.3,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 로그인 돌아가기
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: _secondary,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_back_ios_rounded, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  '로그인 페이지로 돌아가기',
                                  style: TextStyle(fontSize: 14, letterSpacing: -0.2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
