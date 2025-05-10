import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:peoplejob_frontend/ui/pages/home/home_page.dart';
import 'package:peoplejob_frontend/ui/pages/user/user_home_page.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080')); // 백엔드 주소
  final _storage = const FlutterSecureStorage();

  Future<bool> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'];
      final role = response.data['role'];

      // 토큰과 role 저장
      await _storage.write(key: 'token', value: token);
      await _storage.write(key: 'role', value: role);

      // 로그인 성공 시 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
      return true;
    } on DioException catch (e) {
      print('로그인 실패: ${e.response?.data}');
      return false;
    } catch (e) {
      print('예외 발생: $e');
      return false;
    }
  }
}
