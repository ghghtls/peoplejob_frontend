import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/auth_service.dart';

class EmailVerificationPage extends StatefulWidget {
  final String userid;
  final String email;

  const EmailVerificationPage({
    super.key,
    required this.userid,
    required this.email,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);
  static const Color _green = Color(0xFF0FA958);

  final AuthService _authService = AuthService();
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  int _resendCooldown = 0;

  @override
  void dispose() {
    for (var c in _controllers) { c.dispose(); }
    for (var n in _focusNodes) { n.dispose(); }
    super.dispose();
  }

  String get _verificationCode => _controllers.map((c) => c.text).join();

  Future<void> _verifyCode() async {
    final code = _verificationCode;
    if (code.length != 6) {
      setState(() => _errorMessage = '6자리 인증코드를 모두 입력해주세요');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final success = await _authService.verifyEmail(userid: widget.userid, code: code);
      if (mounted) {
        if (success) {
          _showSuccessDialog();
        } else {
          setState(() { _errorMessage = '인증코드가 올바르지 않습니다. 다시 확인해주세요.'; _isLoading = false; });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() { _errorMessage = '인증 처리 중 오류가 발생했습니다: ${e.toString()}'; _isLoading = false; });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.check_circle_rounded, color: _green, size: 28),
          const SizedBox(width: 10),
          const Text('인증 완료', style: TextStyle(fontWeight: FontWeight.w700)),
        ]),
        content: const Text('이메일 인증이 완료되었습니다.\n로그인 페이지로 이동합니다.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('로그인하러 가기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _resendCode() async {
    if (_resendCooldown > 0) return;
    setState(() { _isResending = true; _errorMessage = null; });

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${widget.email}로 인증코드가 재발송되었습니다'),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        setState(() => _resendCooldown = 60);
        _startCooldownTimer();
      }
    } catch (e) {
      if (mounted) { setState(() => _errorMessage = '인증코드 재발송에 실패했습니다'); }
    } finally {
      if (mounted) { setState(() => _isResending = false); }
    }
  }

  void _startCooldownTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCooldown > 0) {
        setState(() => _resendCooldown--);
        _startCooldownTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: _blue),
                    style: IconButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.all(8)),
                  ),
                  const Expanded(
                    child: Text('이메일 인증',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _label, letterSpacing: -0.4)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),

                    // 아이콘
                    Container(
                      width: 88, height: 88,
                      decoration: BoxDecoration(
                        color: _blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.mark_email_read_rounded, size: 44, color: _blue),
                    ),

                    const SizedBox(height: 28),

                    const Text('이메일을 확인해주세요',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _label, letterSpacing: -0.5)),

                    const SizedBox(height: 10),

                    Text('${widget.email}로\n6자리 인증코드를 발송했습니다',
                        style: const TextStyle(fontSize: 15, color: _secondary, height: 1.6),
                        textAlign: TextAlign.center),

                    const SizedBox(height: 40),

                    // 인증코드 입력
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 48,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _label),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: _blue, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                              if (index == 5 && value.isNotEmpty) { _verifyCode(); }
                            },
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // 에러 메시지
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _red.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: _red, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_errorMessage!,
                                style: const TextStyle(color: _red, fontSize: 13))),
                          ],
                        ),
                      ),

                    const SizedBox(height: 28),

                    // 인증 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _blue, elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          disabledBackgroundColor: _blue.withValues(alpha: 0.5),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : const Text('인증하기',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 재발송 버튼
                    TextButton.icon(
                      onPressed: _isResending || _resendCooldown > 0 ? null : _resendCode,
                      icon: Icon(Icons.refresh_rounded, size: 18,
                          color: _resendCooldown > 0 ? _secondary : _blue),
                      label: Text(
                        _resendCooldown > 0 ? '$_resendCooldown초 후 재발송 가능' : '인증코드 재발송',
                        style: TextStyle(
                          color: _resendCooldown > 0 ? _secondary : _blue,
                          fontWeight: FontWeight.w600, fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 나중에 하기
                    TextButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Text('나중에 인증하시겠습니까?',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          content: const Text('이메일 인증을 완료하지 않으면\n일부 서비스 이용에 제한이 있을 수 있습니다.',
                              style: TextStyle(height: 1.5)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx),
                                child: const Text('계속 인증하기', style: TextStyle(color: _blue, fontWeight: FontWeight.w600))),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                              },
                              child: const Text('나중에 하기', style: TextStyle(color: _secondary)),
                            ),
                          ],
                        ),
                      ),
                      child: const Text('나중에 인증하기', style: TextStyle(color: _secondary, fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
