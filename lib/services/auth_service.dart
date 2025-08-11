import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8888';

  // JWT 로그인
  Future<Map<String, dynamic>?> login({
    required String userid,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userid': userid, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 토큰 및 사용자 정보 저장
        await _storage.write(key: 'jwt', value: data['token']);
        await _storage.write(key: 'userid', value: data['userid']);
        await _storage.write(key: 'role', value: data['role']);
        await _storage.write(key: 'userType', value: data['userType']);
        await _storage.write(key: 'name', value: data['name']);
        await _storage.write(key: 'email', value: data['email']);

        return data;
      }
      return null;
    } catch (e) {
      debugPrint('로그인 오류: $e');
      return null;
    }
  }

  // 로그아웃
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  // 토큰 가져오기
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt');
  }

  // 사용자 정보 가져오기
  Future<Map<String, String?>> getUserInfo() async {
    return {
      'userid': await _storage.read(key: 'userid'),
      'role': await _storage.read(key: 'role'),
      'userType': await _storage.read(key: 'userType'),
      'name': await _storage.read(key: 'name'),
      'email': await _storage.read(key: 'email'),
    };
  }

  // 역할 가져오기
  Future<String?> getRole() async {
    return await _storage.read(key: 'role');
  }

  // 사용자 타입 가져오기
  Future<String?> getUserType() async {
    return await _storage.read(key: 'userType');
  }

  // 인증된 요청 보내기
  Future<http.Response> authenticatedGet(String endpoint) async {
    final token = await getToken();
    return http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<http.Response> authenticatedPost(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await getToken();
    return http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }
}
