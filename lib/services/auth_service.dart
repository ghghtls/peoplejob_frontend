import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8080';
  final Dio _dio = Dio();

  // 기존 메서드들 (login, logout, getToken 등)

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
        await _storage.write(key: 'userNo', value: data['userNo'].toString());
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

  // 사용자 번호 가져오기
  Future<int?> getUserNo() async {
    final userNoStr = await _storage.read(key: 'userNo');
    return userNoStr != null ? int.tryParse(userNoStr) : null;
  }

  // 사용자 정보 가져오기
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

  // ============ 새로 추가: 회원 정보 관리 메서드들 ============

  // 회원 정보 조회
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userNo = await getUserNo();
      if (userNo == null) throw Exception('사용자 정보를 찾을 수 없습니다.');

      final token = await getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/users/profile/$userNo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('회원 정보 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('회원 정보 조회 오류: $e');
      rethrow;
    }
  }

  // 회원 정보 수정
  Future<Map<String, dynamic>?> updateUserProfile({
    required String name,
    required String email,
    String? phone,
    String? address,
    String? detailAddress,
    String? zipcode,
    // 기업회원 전용 필드들
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
      if (userNo == null) throw Exception('사용자 정보를 찾을 수 없습니다.');

      final token = await getToken();
      final body = {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'detailAddress': detailAddress,
        'zipcode': zipcode,
        // 기업회원 정보
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

      final response = await http.put(
        Uri.parse('$_baseUrl/api/users/profile/$userNo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 로컬 저장소 업데이트
        if (data['user'] != null) {
          await _storage.write(key: 'name', value: data['user']['name']);
          await _storage.write(key: 'email', value: data['user']['email']);
        }

        return data;
      } else {
        throw Exception('회원 정보 수정 실패: ${response.statusCode}');
      }
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
      if (userNo == null) throw Exception('사용자 정보를 찾을 수 없습니다.');

      final token = await getToken();
      final response = await http.put(
        Uri.parse('$_baseUrl/api/users/password/$userNo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? '비밀번호 변경 실패');
      }
    } catch (e) {
      debugPrint('비밀번호 변경 오류: $e');
      rethrow;
    }
  }

  // 프로필 이미지 업로드
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final userNo = await getUserNo();
      if (userNo == null) throw Exception('사용자 정보를 찾을 수 없습니다.');

      final token = await getToken();

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '$_baseUrl/api/users/profile/$userNo/image',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data['imageUrl'];
      } else {
        throw Exception('프로필 이미지 업로드 실패');
      }
    } catch (e) {
      debugPrint('프로필 이미지 업로드 오류: $e');
      rethrow;
    }
  }

  // 프로필 이미지 삭제
  Future<bool> deleteProfileImage() async {
    try {
      final userNo = await getUserNo();
      if (userNo == null) throw Exception('사용자 정보를 찾을 수 없습니다.');

      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/users/profile/$userNo/image'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('프로필 이미지 삭제 오류: $e');
      return false;
    }
  }

  // 회원 탈퇴
  Future<bool> deleteAccount() async {
    try {
      final userNo = await getUserNo();
      if (userNo == null) throw Exception('사용자 정보를 찾을 수 없습니다.');

      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/users/profile/$userNo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await logout(); // 로컬 저장소 정리
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('회원 탈퇴 오류: $e');
      return false;
    }
  }

  // 인증된 요청 보내기 (기존 메서드들)
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
