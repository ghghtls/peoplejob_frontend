import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

final isSubmittingProvider = StateProvider<bool>((ref) => false);

class CompanyRegisterForm extends ConsumerStatefulWidget {
  const CompanyRegisterForm({super.key});

  @override
  ConsumerState<CompanyRegisterForm> createState() => _CompanyState();
}

class _CompanyState extends ConsumerState<CompanyRegisterForm> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _labelColor = Color(0xFF1C1C1E);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _fieldBg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);
  static const Color _green = Color(0xFF0FA958);

  final _formKey = GlobalKey<FormState>();
  final _userid = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();
  final _companyName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _businessNumber = TextEditingController();
  final _ceoName = TextEditingController();
  final _companyType = TextEditingController();
  final _employeeCount = TextEditingController();
  final _establishedYear = TextEditingController();
  final _website = TextEditingController();
  final _companyDescription = TextEditingController();

  String _baseUrl = '';
  bool? _idAvailable;
  bool _isCheckingId = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8888';
  }

  @override
  void dispose() {
    _userid.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    _companyName.dispose();
    _email.dispose();
    _phone.dispose();
    _businessNumber.dispose();
    _ceoName.dispose();
    _companyType.dispose();
    _employeeCount.dispose();
    _establishedYear.dispose();
    _website.dispose();
    _companyDescription.dispose();
    super.dispose();
  }

  Future<void> _checkId() async {
    final id = _userid.text.trim();
    if (id.isEmpty) {
      _showSnack('아이디를 먼저 입력해주세요');
      return;
    }
    if (id.length < 4 || id.length > 20) {
      _showSnack('아이디는 4-20자로 입력해주세요');
      return;
    }

    setState(() => _isCheckingId = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/users/check/$id'));
      debugPrint('중복확인 응답: ${response.statusCode} | ${response.body}');
      bool available;
      if (response.statusCode == 200) {
        available = _parseAvailable(response.body);
      } else if (response.statusCode == 409) {
        available = false;
      } else if (response.statusCode == 404) {
        available = true;
      } else if (response.statusCode == 403) {
        if (mounted) _showSnack('서버 설정 오류 - 관리자에게 문의해주세요 (403)', color: _red);
        return;
      } else {
        if (mounted) _showSnack('서버 오류 (${response.statusCode})', color: _red);
        return;
      }
      setState(() => _idAvailable = available);
      if (!mounted) return;
      _showSnack(
        available ? '사용 가능한 아이디입니다' : '이미 사용중인 아이디입니다',
        color: available ? _green : _red,
      );
    } catch (e) {
      debugPrint('중복확인 오류: $e');
      if (mounted) _showSnack('서버에 연결할 수 없습니다', color: _red);
    } finally {
      if (mounted) setState(() => _isCheckingId = false);
    }
  }

  bool _parseAvailable(String body) {
    try {
      final data = jsonDecode(body);
      if (data is bool) return data;
      if (data is Map) {
        for (final key in ['available', 'isAvailable']) {
          if (data.containsKey(key)) {
            final v = data[key];
            return v == true || v == 'true';
          }
        }
        for (final key in ['duplicate', 'isDuplicate', 'exists']) {
          if (data.containsKey(key)) {
            final v = data[key];
            return v == false || v == 'false';
          }
        }
      }
    } catch (_) {
      final trimmed = body.trim().toLowerCase();
      if (trimmed == 'true') return true;
      if (trimmed == 'false') return false;
    }
    return false;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_idAvailable != true) {
      _showSnack('아이디 중복 확인을 해주세요');
      return;
    }

    if (_password.text != _passwordConfirm.text) {
      _showSnack('비밀번호가 일치하지 않습니다');
      return;
    }

    ref.read(isSubmittingProvider.notifier).state = true;

    try {
      final payload = <String, dynamic>{
        "userid": _userid.text.trim(),
        "password": _password.text,
        "username": _companyName.text.trim(),
        "email": _email.text.trim(),
        "userType": "COMPANY",
        "companyName": _companyName.text.trim(),
        "businessNumber": _businessNumber.text.trim(),
        "ceoName": _ceoName.text.trim(),
        if (_phone.text.trim().isNotEmpty) "phone": _phone.text.trim(),
        if (_companyType.text.trim().isNotEmpty) "companyType": _companyType.text.trim(),
        if (_employeeCount.text.trim().isNotEmpty)
          "employeeCount": int.tryParse(_employeeCount.text.trim()),
        if (_establishedYear.text.trim().isNotEmpty) "establishedYear": _establishedYear.text.trim(),
        if (_website.text.trim().isNotEmpty) "website": _website.text.trim(),
        if (_companyDescription.text.trim().isNotEmpty)
          "companyDescription": _companyDescription.text.trim(),
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['verifyCode'] != null) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('이메일 인증코드', style: TextStyle(fontWeight: FontWeight.w700)),
              content: Text(
                '인증코드: ${data['verifyCode']}\n(개발용 — 실제 서비스에서는 이메일로 발송됩니다)',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('확인', style: TextStyle(color: _blue, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        } else {
          _showSnack('기업회원 가입 완료! 로그인해주세요', color: _green);
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        String errorMsg = '회원가입 실패';
        try {
          final error = jsonDecode(response.body);
          errorMsg = error['error'] ?? error['message'] ?? errorMsg;
        } catch (_) {}
        _showSnack(errorMsg, color: _red);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('네트워크 오류: $e', color: _red);
    } finally {
      if (mounted) ref.read(isSubmittingProvider.notifier).state = false;
    }
  }

  void _showSnack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(isSubmittingProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이디
          _buildLabel('아이디'),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildField(
                  controller: _userid,
                  hint: '영문, 숫자 4-20자',
                  icon: Icons.person_outline_rounded,
                  suffixIcon: _idAvailable == true
                      ? const Icon(Icons.check_circle_rounded, color: _green, size: 20)
                      : _idAvailable == false
                          ? const Icon(Icons.cancel_rounded, color: _red, size: 20)
                          : null,
                  onChanged: (_) => setState(() => _idAvailable = null),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '아이디를 입력해주세요';
                    if (v.length < 4 || v.length > 20) return '4-20자로 입력해주세요';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _isCheckingId ? null : _checkId,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _blue,
                    side: const BorderSide(color: _blue, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: _isCheckingId
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: _blue),
                        )
                      : const Text('중복확인', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 비밀번호
          _buildLabel('비밀번호'),
          const SizedBox(height: 8),
          _buildField(
            controller: _password,
            hint: '8자 이상',
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: _secondary,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return '비밀번호를 입력해주세요';
              if (v.length < 8) return '비밀번호는 8자 이상이어야 합니다';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 비밀번호 확인
          _buildLabel('비밀번호 확인'),
          const SizedBox(height: 8),
          _buildField(
            controller: _passwordConfirm,
            hint: '비밀번호를 다시 입력하세요',
            icon: Icons.lock_outline_rounded,
            obscure: _obscureConfirm,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: _secondary,
                size: 20,
              ),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return '비밀번호 확인을 입력해주세요';
              if (v != _password.text) return '비밀번호가 일치하지 않습니다';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 회사명
          _buildLabel('회사명'),
          const SizedBox(height: 8),
          _buildField(
            controller: _companyName,
            hint: '회사명을 입력하세요',
            icon: Icons.business_rounded,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return '회사명을 입력해주세요';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 사업자번호
          _buildLabel('사업자번호'),
          const SizedBox(height: 8),
          _buildField(
            controller: _businessNumber,
            hint: '000-00-00000',
            icon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return '사업자번호를 입력해주세요';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 대표자명
          _buildLabel('대표자명'),
          const SizedBox(height: 8),
          _buildField(
            controller: _ceoName,
            hint: '대표자 이름을 입력하세요',
            icon: Icons.person_rounded,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return '대표자명을 입력해주세요';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 담당자 이메일
          _buildLabel('담당자 이메일'),
          const SizedBox(height: 8),
          _buildField(
            controller: _email,
            hint: 'hr@company.com',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return '이메일을 입력해주세요';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                return '올바른 이메일 형식이 아닙니다';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 대표 전화번호 (선택)
          _buildLabel('대표 전화번호 (선택)'),
          const SizedBox(height: 8),
          _buildField(
            controller: _phone,
            hint: '02-1234-5678',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),

          // 추가 정보 구분선
          Row(
            children: [
              const Expanded(child: Divider(color: Color(0xFFE5E5EA))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '추가 정보 (선택)',
                  style: TextStyle(
                    fontSize: 13,
                    color: _secondary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Color(0xFFE5E5EA))),
            ],
          ),
          const SizedBox(height: 16),

          // 회사 유형
          _buildLabel('회사 유형'),
          const SizedBox(height: 8),
          _buildField(
            controller: _companyType,
            hint: '예: 주식회사, 유한회사',
            icon: Icons.category_outlined,
          ),
          const SizedBox(height: 16),

          // 직원 수
          _buildLabel('직원 수'),
          const SizedBox(height: 8),
          _buildField(
            controller: _employeeCount,
            hint: '예: 50',
            icon: Icons.group_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // 설립연도
          _buildLabel('설립연도'),
          const SizedBox(height: 8),
          _buildField(
            controller: _establishedYear,
            hint: '예: 2020',
            icon: Icons.calendar_today_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // 웹사이트
          _buildLabel('웹사이트'),
          const SizedBox(height: 8),
          _buildField(
            controller: _website,
            hint: 'https://company.com',
            icon: Icons.language_outlined,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),

          // 회사 소개
          _buildLabel('회사 소개'),
          const SizedBox(height: 8),
          _buildMultilineField(
            controller: _companyDescription,
            hint: '회사에 대해 간단히 소개해주세요',
          ),
          const SizedBox(height: 32),

          // 가입 버튼
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                disabledBackgroundColor: _blue.withValues(alpha: 0.4),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '기업회원 가입',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: Colors.white,
                      ),
                    ),
            ),
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
        color: _labelColor,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 16, color: _labelColor, letterSpacing: -0.3),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _secondary, fontSize: 15),
        prefixIcon: Icon(icon, color: _secondary, size: 20),
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

  Widget _buildMultilineField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      style: const TextStyle(fontSize: 16, color: _labelColor, letterSpacing: -0.3),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _secondary, fontSize: 15),
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.all(16),
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
      ),
    );
  }
}
