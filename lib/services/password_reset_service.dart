import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/api_config.dart';

class PasswordResetService {
  final Dio _dio;

  PasswordResetService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: dotenv.env['API_URL'] ?? ApiConfig.apiUrl,
            ));

  Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        '/api/password-reset/request',
        data: {'email': email},
      );
      return {
        'success': true,
        'data': response.data,
        'message': response.data['message'] ?? '비밀번호 재설정 이메일을 발송했습니다.',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data?['message'] ?? '요청 처리에 실패했습니다.',
      };
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> validateToken({required String token}) async {
    try {
      final response = await _dio.get(
        '/api/password-reset/validate-token',
        queryParameters: {'token': token},
      );
      return {
        'success': true,
        'valid': response.data['valid'] ?? false,
        'data': response.data,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'valid': false,
        'error': e.response?.data?['message'] ?? '토큰 검증에 실패했습니다.',
      };
    } catch (e) {
      return {
        'success': false,
        'valid': false,
        'error': '네트워크 오류: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/api/password-reset/reset',
        data: {
          'token': token,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      return {
        'success': true,
        'data': response.data,
        'message': response.data['message'] ?? '비밀번호가 성공적으로 재설정되었습니다.',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data?['message'] ?? '비밀번호 재설정에 실패했습니다.',
      };
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: ${e.toString()}'};
    }
  }

  static Map<String, dynamic> validatePassword(String password) {
    if (password.isEmpty) return {'valid': false, 'message': '비밀번호를 입력해주세요.'};
    if (password.length < 8) return {'valid': false, 'message': '비밀번호는 8자 이상이어야 합니다.'};
    if (!password.contains(RegExp(r'[A-Za-z]'))) {
      return {'valid': false, 'message': '비밀번호는 영문자를 포함해야 합니다.'};
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return {'valid': false, 'message': '비밀번호는 숫자를 포함해야 합니다.'};
    }
    return {'valid': true, 'message': '유효한 비밀번호입니다.'};
  }

  static bool passwordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}
