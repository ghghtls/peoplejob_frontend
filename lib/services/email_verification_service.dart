import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/api_config.dart';

/// 이메일 인증 서비스
/// 백엔드 EmailVerificationController와 연동
class EmailVerificationService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  EmailVerificationService({Dio? dio, FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: dotenv.env['API_URL'] ?? ApiConfig.apiUrl,
            )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'jwt');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _storage.delete(key: 'jwt');
          }
          handler.next(error);
        },
      ),
    );
  }

  /// 이메일 인증코드 발송
  /// POST /api/email/send-verification
  Future<Map<String, dynamic>> sendVerificationEmail({
    required String email,
  }) async {
    try {
      final res = await _dio.post(
        '/api/email/send-verification',
        data: {'email': email},
      );

      if (res.statusCode == 200) {
        return {
          'success': true,
          'message': res.data['message'] ?? '인증코드가 발송되었습니다.',
        };
      } else {
        return {
          'success': false,
          'message': res.data['message'] ?? '인증코드 발송에 실패했습니다.',
        };
      }
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? '인증코드 발송에 실패했습니다.',
        };
      }
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '인증코드 발송 중 오류가 발생했습니다: $e',
      };
    }
  }

  /// 이메일 인증 확인 (POST)
  /// POST /api/email/verify
  Future<Map<String, dynamic>> verifyEmail({
    required String code,
  }) async {
    try {
      final res = await _dio.post(
        '/api/email/verify',
        data: {'code': code},
      );

      if (res.statusCode == 200) {
        return {
          'success': true,
          'message': res.data['message'] ?? '이메일 인증이 완료되었습니다.',
        };
      } else {
        return {
          'success': false,
          'message': res.data['message'] ?? '유효하지 않거나 만료된 인증코드입니다.',
        };
      }
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        return {
          'success': false,
          'message':
              e.response?.data['message'] ?? '유효하지 않거나 만료된 인증코드입니다.',
        };
      }
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '이메일 인증 중 오류가 발생했습니다: $e',
      };
    }
  }

  /// 이메일 인증 확인 (GET - 이메일 링크 클릭)
  /// GET /api/email/verify?code={code}
  Future<Map<String, dynamic>> verifyEmailByLink({
    required String code,
  }) async {
    try {
      final res = await _dio.get(
        '/api/email/verify',
        queryParameters: {'code': code},
      );

      if (res.statusCode == 200) {
        return {
          'success': true,
          'message': res.data['message'] ?? '이메일 인증이 완료되었습니다.',
        };
      } else {
        return {
          'success': false,
          'message': res.data['message'] ?? '유효하지 않거나 만료된 인증 링크입니다.',
        };
      }
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        return {
          'success': false,
          'message':
              e.response?.data['message'] ?? '유효하지 않거나 만료된 인증 링크입니다.',
        };
      }
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '이메일 인증 중 오류가 발생했습니다: $e',
      };
    }
  }

  /// 비밀번호 재설정 이메일 발송
  /// POST /api/email/send-reset-password
  Future<Map<String, dynamic>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      final res = await _dio.post(
        '/api/email/send-reset-password',
        data: {'email': email},
      );

      if (res.statusCode == 200) {
        return {
          'success': true,
          'message': res.data['message'] ?? '비밀번호 재설정 링크가 발송되었습니다.',
        };
      } else {
        return {
          'success': false,
          'message': res.data['message'] ?? '비밀번호 재설정 링크 발송에 실패했습니다.',
        };
      }
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        return {
          'success': false,
          'message':
              e.response?.data['message'] ?? '비밀번호 재설정 링크 발송에 실패했습니다.',
        };
      }
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '비밀번호 재설정 링크 발송 중 오류가 발생했습니다: $e',
      };
    }
  }

  /// 비밀번호 재설정
  /// POST /api/email/reset-password
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final res = await _dio.post(
        '/api/email/reset-password',
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );

      if (res.statusCode == 200) {
        return {
          'success': true,
          'message': res.data['message'] ?? '비밀번호가 성공적으로 변경되었습니다.',
        };
      } else {
        return {
          'success': false,
          'message': res.data['message'] ?? '유효하지 않거나 만료된 토큰입니다.',
        };
      }
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? '유효하지 않거나 만료된 토큰입니다.',
        };
      }
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '비밀번호 재설정 중 오류가 발생했습니다: $e',
      };
    }
  }

  /// 인증 코드 재발송
  Future<Map<String, dynamic>> resendVerificationEmail({
    required String email,
  }) async {
    return await sendVerificationEmail(email: email);
  }

  /// 이메일 인증 상태 확인
  Future<bool> isEmailVerified({required String email}) async {
    try {
      final res = await _dio.get(
        '/api/email/verify-status',
        queryParameters: {'email': email},
      );

      if (res.statusCode == 200 && res.data is Map) {
        return res.data['verified'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
