import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static const String baseUrl = 'http://localhost:9000/api/email';

  /// 테스트 이메일 발송
  static Future<Map<String, dynamic>> sendTestEmail({
    required String to,
    String? subject,
    String? content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/test'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': to,
          'subject': subject ?? '테스트 이메일',
          'content': content ?? '안녕하세요, 피플잡에서 보내는 테스트 이메일입니다.',
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': response.body};
      }
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: ${e.toString()}'};
    }
  }

  /// 회원가입 인증 이메일 발송
  static Future<Map<String, dynamic>> sendVerificationEmail({
    required String to,
    required String username,
    required String verificationCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': to,
          'username': username,
          'verificationCode': verificationCode,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': response.body};
      }
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: ${e.toString()}'};
    }
  }

  /// 비밀번호 재설정 이메일 발송
  static Future<Map<String, dynamic>> sendPasswordResetEmail({
    required String to,
    required String username,
    required String resetToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': to,
          'username': username,
          'resetToken': resetToken,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': response.body};
      }
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: ${e.toString()}'};
    }
  }

  /// 이메일 유효성 검사
  static Future<Map<String, dynamic>> validateEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/validate?email=${Uri.encodeComponent(email)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': response.body};
      }
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: ${e.toString()}'};
    }
  }

  /// 클라이언트 측 이메일 유효성 검사
  static bool isValidEmailFormat(String email) {
    final emailRegex = RegExp(
      r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// 인증 코드 생성 (6자리 숫자)
  static String generateVerificationCode() {
    final now = DateTime.now();
    final random = (now.millisecondsSinceEpoch % 900000) + 100000;
    return random.toString();
  }

  /// UUID 기반 리셋 토큰 생성
  static String generateResetToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = (DateTime.now().microsecondsSinceEpoch % 10000).toString();
    return '$timestamp-$random';
  }
}
