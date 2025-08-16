import 'dart:convert';
import 'package:http/http.dart' as http;

class PasswordResetService {
  static const String baseUrl = 'http://localhost:9000/api/password-reset';

  /// 비밀번호 재설정 요청
  static Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? '비밀번호 재설정 이메일을 발송했습니다.',
        };
      } else {
        return {
          'success': false,
          'error': responseData['message'] ?? '요청 처리에 실패했습니다.',
        };
      }
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: ${e.toString()}'};
    }
  }

  /// 토큰 유효성 검증
  static Future<Map<String, dynamic>> validateToken({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/validate-token?token=${Uri.encodeComponent(token)}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'valid': responseData['valid'] ?? false,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'valid': false,
          'error': responseData['message'] ?? '토큰 검증에 실패했습니다.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'valid': false,
        'error': '네트워크 오류: ${e.toString()}',
      };
    }
  }

  /// 비밀번호 재설정 실행
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? '비밀번호가 성공적으로 재설정되었습니다.',
        };
      } else {
        return {
          'success': false,
          'error': responseData['message'] ?? '비밀번호 재설정에 실패했습니다.',
        };
      }
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: ${e.toString()}'};
    }
  }

  /// 클라이언트 측 비밀번호 유효성 검사
  static Map<String, dynamic> validatePassword(String password) {
    if (password.isEmpty) {
      return {'valid': false, 'message': '비밀번호를 입력해주세요.'};
    }

    if (password.length < 8) {
      return {'valid': false, 'message': '비밀번호는 8자 이상이어야 합니다.'};
    }

    if (!password.contains(RegExp(r'[A-Za-z]'))) {
      return {'valid': false, 'message': '비밀번호는 영문자를 포함해야 합니다.'};
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return {'valid': false, 'message': '비밀번호는 숫자를 포함해야 합니다.'};
    }

    return {'valid': true, 'message': '유효한 비밀번호입니다.'};
  }

  /// 비밀번호 확인 검사
  static bool passwordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}
