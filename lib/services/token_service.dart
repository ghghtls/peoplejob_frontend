import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'cache_service.dart';
import 'session_service.dart';

/// 토큰 관리 서비스
/// JWT 토큰 관리, 이메일 인증, 비밀번호 재설정 토큰 등을 처리
class TokenService {
  static final TokenService _instance = TokenService._internal();
  factory TokenService() => _instance;
  TokenService._internal();

  final CacheService _cache = CacheService();
  final SessionService _session = SessionService();

  static const String baseUrl = 'http://localhost:9000'; // API 서버 URL

  /// 이메일 인증 토큰 요청
  Future<bool> requestEmailVerification(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/request-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        print('Email verification token sent to: $email');

        // 로컬에서 요청 시간 기록 (Rate Limiting 체크용)
        _cache.set(
          'email_verification_request:$email',
          DateTime.now(),
          duration: const Duration(minutes: 30),
        );

        return true;
      } else {
        print('Failed to send verification email: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error requesting email verification: $e');
      return false;
    }
  }

  /// 이메일 인증 토큰 검증
  Future<bool> verifyEmailToken(String email, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/verify-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'token': token}),
      );

      if (response.statusCode == 200) {
        print('Email verification successful for: $email');

        // 인증 완료 후 관련 캐시 삭제
        _cache.remove('email_verification_request:$email');

        return true;
      } else {
        print('Email verification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error verifying email token: $e');
      return false;
    }
  }

  /// 비밀번호 재설정 토큰 요청
  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/request-password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        print('Password reset token sent to: $email');

        // 로컬에서 요청 시간 기록
        _cache.set(
          'password_reset_request:$email',
          DateTime.now(),
          duration: const Duration(minutes: 15),
        );

        return true;
      } else {
        print('Failed to send password reset email: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error requesting password reset: $e');
      return false;
    }
  }

  /// 비밀번호 재설정 토큰 검증
  Future<bool> verifyPasswordResetToken(String email, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/verify-password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'token': token}),
      );

      if (response.statusCode == 200) {
        print('Password reset token verification successful for: $email');
        return true;
      } else {
        print('Password reset token verification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error verifying password reset token: $e');
      return false;
    }
  }

  /// 새 비밀번호 설정
  Future<bool> resetPassword(
    String email,
    String token,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'token': token,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        print('Password reset successful for: $email');

        // 비밀번호 재설정 완료 후 관련 캐시 삭제
        _cache.remove('password_reset_request:$email');

        return true;
      } else {
        print('Password reset failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }

  /// 액세스 토큰 갱신
  Future<TokenRefreshResult> refreshAccessToken() async {
    try {
      final refreshToken = await _session.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return TokenRefreshResult(
          success: false,
          error: 'No refresh token available',
        );
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];

        // 세션에 새 토큰 저장
        await _session.refreshTokens(newAccessToken, newRefreshToken);

        print('Token refresh successful');
        return TokenRefreshResult(
          success: true,
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
      } else {
        print('Token refresh failed: ${response.body}');
        return TokenRefreshResult(
          success: false,
          error: 'Token refresh failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return TokenRefreshResult(success: false, error: 'Network error: $e');
    }
  }

  /// JWT 토큰 만료 시간 확인
  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      // Base64 디코딩 (URL-safe)
      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);
      final payloadMap = jsonDecode(decodedString);

      final exp = payloadMap['exp'];
      if (exp == null) return true;

      final expDateTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expDateTime);
    } catch (e) {
      print('Error checking token expiration: $e');
      return true;
    }
  }

  /// JWT 토큰에서 사용자 ID 추출
  int? getUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);
      final payloadMap = jsonDecode(decodedString);

      return payloadMap['userId'];
    } catch (e) {
      print('Error extracting user ID from token: $e');
      return null;
    }
  }

  /// 인증 토큰 생성 (로컬 용도)
  String generateVerificationToken() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(
      6,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Rate Limiting 체크
  bool canRequestToken(String type, String identifier) {
    final key = '${type}_request:$identifier';
    final lastRequest = _cache.get<DateTime>(key);

    if (lastRequest == null) return true;

    final Duration cooldown = switch (type) {
      'email_verification' => const Duration(minutes: 1),
      'password_reset' => const Duration(minutes: 1),
      _ => const Duration(minutes: 1),
    };

    return DateTime.now().difference(lastRequest) >= cooldown;
  }

  /// 토큰 요청 기록
  void recordTokenRequest(String type, String identifier) {
    final key = '${type}_request:$identifier';
    _cache.set(key, DateTime.now(), duration: const Duration(hours: 1));
  }

  /// 모든 토큰 무효화 (로그아웃 시)
  Future<void> invalidateAllTokens() async {
    try {
      final accessToken = await _session.getAccessToken();
      if (accessToken != null) {
        // 서버에 토큰 무효화 요청
        await http.post(
          Uri.parse('$baseUrl/api/auth/invalidate'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );
      }
    } catch (e) {
      print('Error invalidating tokens on server: $e');
    }

    // 로컬 세션 클리어
    await _session.clearSession();

    // 토큰 관련 로컬 캐시 클리어
    _cache.removeByPattern('token:');
    _cache.removeByPattern('email_verification:');
    _cache.removeByPattern('password_reset:');
  }

  /// 토큰 상태 확인
  Future<TokenStatus> getTokenStatus() async {
    final session = await _session.getCurrentSession();
    if (session == null) {
      return TokenStatus(isValid: false, isExpired: true, needsRefresh: false);
    }

    final isExpired = isTokenExpired(session.accessToken);
    final needsRefresh = session.isTokenExpiringSoon;

    return TokenStatus(
      isValid: !isExpired,
      isExpired: isExpired,
      needsRefresh: needsRefresh,
      userId: session.userId,
      userType: session.userType,
    );
  }
}

/// 토큰 갱신 결과 클래스
class TokenRefreshResult {
  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final String? error;

  TokenRefreshResult({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.error,
  });
}

/// 토큰 상태 클래스
class TokenStatus {
  final bool isValid;
  final bool isExpired;
  final bool needsRefresh;
  final int? userId;
  final String? userType;

  TokenStatus({
    required this.isValid,
    required this.isExpired,
    required this.needsRefresh,
    this.userId,
    this.userType,
  });

  @override
  String toString() {
    return 'TokenStatus(valid: $isValid, expired: $isExpired, '
        'needsRefresh: $needsRefresh, userId: $userId)';
  }
}
