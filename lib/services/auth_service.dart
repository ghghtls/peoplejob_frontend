import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// 로그인 요청
  Future<bool> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final response = await _dio.post(
        '/api/member/login', // ✅ 실제 백엔드 기준 경로
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'];
      final role = response.data['role'];
      final userEmail = response.data['email'];

      // ✅ 토큰 및 사용자 정보 안전하게 저장
      await _storage.write(key: 'jwt', value: token);
      await _storage.write(key: 'role', value: role);
      await _storage.write(key: 'email', value: userEmail);

      // ✅ 역할 기반 분기 처리
      if (role == 'user') {
        Navigator.pushReplacementNamed(context, '/mypage');
      } else if (role == 'company') {
        Navigator.pushReplacementNamed(context, '/companymypage');
      } else {
        Navigator.pushReplacementNamed(context, '/'); // fallback
      }

      return true;
    } on DioException catch (e) {
      final errorData = e.response?.data;
      print('로그인 실패: ${errorData ?? e.message}');
      _showSnackbar(context, '로그인 실패: 아이디 또는 비밀번호를 확인해주세요.');
      return false;
    } catch (e) {
      print('예외 발생: $e');
      _showSnackbar(context, '알 수 없는 오류가 발생했습니다.');
      return false;
    }
  }

  /// 로그아웃 시 저장된 토큰 제거
  Future<void> logout(BuildContext context) async {
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'role');
    await _storage.delete(key: 'email');

    Navigator.pushReplacementNamed(context, '/login');
  }

  /// 현재 저장된 토큰 반환
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt');
  }

  /// 현재 사용자 역할 반환
  Future<String?> getRole() async {
    return await _storage.read(key: 'role');
  }

  /// 스낵바 알림 유틸
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
