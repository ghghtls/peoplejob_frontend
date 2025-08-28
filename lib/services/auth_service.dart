import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart'; // debugPrint
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

class AuthService {
  // 주입 가능한 의존성들
  final FlutterSecureStorage _storage;
  final http.Client _client;
  final Dio _dio;

  // 구성용
  final String _baseUrl;

  AuthService({
    http.Client? client,
    FlutterSecureStorage? storage,
    Dio? dio,
    String? baseUrl,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? (dotenv.env['API_URL'] ?? 'http://localhost:8888'),
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl:
                   baseUrl ??
                   (dotenv.env['API_URL'] ?? 'http://localhost:8888'),
             ),
           ) {
    // JWT 자동 첨부 인터셉터 (Dio 전용)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'jwt');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  /* ========================= 기본 인증/저장소 유틸 ========================= */

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<String?> getToken() async => _storage.read(key: 'jwt');

  Future<int?> getUserNo() async {
    final userNoStr = await _storage.read(key: 'userNo');
    return userNoStr != null ? int.tryParse(userNoStr) : null;
  }

  Future<Map<String, String?>> getUserInfo() async {
    return {
      'userid': await _storage.read(key: 'userid'),
      'userNo': await _storage.read(key: 'userNo'),
      'role': await _storage.read(key: 'role'),
      'userType': await _storage.read(key: 'userType'),
      'name': await _storage.read(key: 'name'),
      'email': await _storage.read(key: 'email'),
    };
  }

  Map<String, String> _jsonHeaders({String? token}) => {
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  /* ============================== 인증 로직 ============================== */

  // JWT 로그인
  Future<Map<String, dynamic>?> login({
    required String userid,
    required String password,
  }) async {
    try {
      final res = await _client.post(
        Uri.parse('$_baseUrl/api/users/login'),
        headers: _jsonHeaders(),
        body: jsonEncode({'userid': userid, 'password': password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // 토큰 및 사용자 정보 저장
        await _storage.write(key: 'jwt', value: data['token']);
        await _storage.write(key: 'userid', value: data['userid']);
        await _storage.write(key: 'userNo', value: data['userNo'].toString());
        await _storage.write(key: 'role', value: data['role']);
        await _storage.write(key: 'userType', value: data['userType']);
        await _storage.write(key: 'name', value: data['name']);
        await _storage.write(key: 'email', value: data['email']);

        return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (e) {
      debugPrint('로그인 오류: $e');
      return null;
    }
  }

  /* ============================= 회원 정보 ============================== */

  // 회원 정보 조회
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userNo = await getUserNo();
      if (userNo == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다');
      }

      final token = await getToken();
      final res = await _client.get(
        Uri.parse('$_baseUrl/api/users/profile/$userNo'),
        headers: _jsonHeaders(token: token),
      );

      if (res.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(res.body));
      }
      throw Exception('회원 정보 조회 실패: ${res.statusCode}');
    } catch (e) {
      debugPrint('회원 정보 조회 오류: $e');
      rethrow;
    }
  }

  // 회원 정보 수정 (개인/기업 공용)
  Future<Map<String, dynamic>?> updateUserProfile({
    required String name,
    required String email,
    String? phone,
    String? address,
    String? detailAddress,
    String? zipcode,
    // 기업회원 전용
    String? companyName,
    String? businessNumber,
    String? companyPhone,
    String? companyAddress,
    String? ceoName,
    String? companyType,
    int? employeeCount,
    String? establishedYear,
    String? website,
    String? companyDescription,
  }) async {
    try {
      final userNo = await getUserNo();
      if (userNo == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다');
      }

      final token = await getToken();
      final body = <String, dynamic>{
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (detailAddress != null) 'detailAddress': detailAddress,
        if (zipcode != null) 'zipcode': zipcode,
        if (companyName != null) 'companyName': companyName,
        if (businessNumber != null) 'businessNumber': businessNumber,
        if (companyPhone != null) 'companyPhone': companyPhone,
        if (companyAddress != null) 'companyAddress': companyAddress,
        if (ceoName != null) 'ceoName': ceoName,
        if (companyType != null) 'companyType': companyType,
        if (employeeCount != null) 'employeeCount': employeeCount,
        if (establishedYear != null) 'establishedYear': establishedYear,
        if (website != null) 'website': website,
        if (companyDescription != null)
          'companyDescription': companyDescription,
      };

      final res = await _client.put(
        Uri.parse('$_baseUrl/api/users/profile/$userNo'),
        headers: _jsonHeaders(token: token),
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final data = Map<String, dynamic>.from(jsonDecode(res.body));

        // 로컬 저장소 업데이트
        final user = data['user'];
        if (user is Map) {
          if (user['name'] != null) {
            await _storage.write(key: 'name', value: user['name'] as String);
          }
          if (user['email'] != null) {
            await _storage.write(key: 'email', value: user['email'] as String);
          }
        }
        return data;
      }
      throw Exception('회원 정보 수정 실패: ${res.statusCode}');
    } catch (e) {
      debugPrint('회원 정보 수정 오류: $e');
      rethrow;
    }
  }

  // 비밀번호 변경
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final userNo = await getUserNo();
      if (userNo == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다');
      }

      final token = await getToken();
      final res = await _client.put(
        Uri.parse('$_baseUrl/api/users/password/$userNo'),
        headers: _jsonHeaders(token: token),
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (res.statusCode == 200) return true;

      try {
        final err = jsonDecode(res.body);
        throw Exception(err['error'] ?? '비밀번호 변경 실패');
      } catch (_) {
        throw Exception('비밀번호 변경 실패: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('비밀번호 변경 오류: $e');
      rethrow;
    }
  }

  /* =========================== 프로필 이미지 ============================ */

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final userNo = await getUserNo();
      if (userNo == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다');
      }
      final token = await getToken();

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final res = await _dio.post(
        '/api/users/profile/$userNo/image',
        data: formData,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      if (res.statusCode == 200) {
        final data = res.data;
        if (data is Map && data['imageUrl'] is String) {
          return data['imageUrl'] as String;
        }
        return null;
      }
      throw Exception('프로필 이미지 업로드 실패');
    } catch (e) {
      debugPrint('프로필 이미지 업로드 오류: $e');
      rethrow;
    }
  }

  Future<bool> deleteProfileImage() async {
    try {
      final userNo = await getUserNo();
      if (userNo == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다');
      }

      final token = await getToken();
      final res = await _client.delete(
        Uri.parse('$_baseUrl/api/users/profile/$userNo/image'),
        headers: _jsonHeaders(token: token),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('프로필 이미지 삭제 오류: $e');
      return false;
    }
  }

  /* =============================== 기타 ================================ */

  Future<bool> deleteAccount() async {
    try {
      final userNo = await getUserNo();
      if (userNo == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다');
      }

      final token = await getToken();
      final res = await _client.delete(
        Uri.parse('$_baseUrl/api/users/profile/$userNo'),
        headers: _jsonHeaders(token: token),
      );

      if (res.statusCode == 200) {
        await logout(); // 로컬 저장소 정리
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('회원 탈퇴 오류: $e');
      return false;
    }
  }

  // 인증된 요청 헬퍼 (테스트에서 헤더 검증 용)
  Future<http.Response> authenticatedGet(String endpoint) async {
    final token = await getToken();
    return _client.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _jsonHeaders(token: token),
    );
  }

  Future<http.Response> authenticatedPost(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await getToken();
    return _client.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode(body),
    );
  }
}
