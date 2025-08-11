import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InquiryService {
  static const String baseUrl = 'http://localhost:8080/api/inquiry';
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  InquiryService() {
    // Dio 기본 설정
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
  }

  // JWT 토큰 가져오기
  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // 사용자 ID 가져오기
  Future<String?> _getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  // 인증 헤더 생성
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 문의 등록
  Future<bool> createInquiry(String title, String content) async {
    try {
      final userId = await _getUserId();

      if (userId == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final headers = await _getHeaders();

      final response = await _dio.post(
        baseUrl,
        options: Options(headers: headers),
        data: {'userNo': int.parse(userId), 'title': title, 'content': content},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('문의 등록 실패: $e');
      return false;
    }
  }

  // 내 문의 목록 조회
  Future<List<Map<String, dynamic>>> getMyInquiries() async {
    try {
      final userId = await _getUserId();

      if (userId == null) {
        return [];
      }

      final headers = await _getHeaders();

      final response = await _dio.get(
        '$baseUrl/user/$userId',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('문의 목록 조회 실패: $e');
      return [];
    }
  }

  // 문의 상세 조회
  Future<Map<String, dynamic>?> getInquiryDetail(int inquiryNo) async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.get(
        '$baseUrl/$inquiryNo',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('문의 상세 조회 실패: $e');
      return null;
    }
  }

  // 문의 수정
  Future<bool> updateInquiry(
    int inquiryNo,
    String title,
    String content,
  ) async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.put(
        '$baseUrl/$inquiryNo',
        options: Options(headers: headers),
        data: {'title': title, 'content': content},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('문의 수정 실패: $e');
      return false;
    }
  }

  // 문의 삭제
  Future<bool> deleteInquiry(int inquiryNo) async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.delete(
        '$baseUrl/$inquiryNo',
        options: Options(headers: headers),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('문의 삭제 실패: $e');
      return false;
    }
  }

  // 관리자 - 전체 문의 조회
  Future<List<Map<String, dynamic>>> getAllInquiries() async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.get(
        baseUrl,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('전체 문의 조회 실패: $e');
      return [];
    }
  }

  // 관리자 - 답변 등록
  Future<bool> answerInquiry(int inquiryNo, String answer) async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.put(
        '$baseUrl/$inquiryNo/answer',
        options: Options(headers: headers),
        queryParameters: {'answer': answer},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('답변 등록 실패: $e');
      return false;
    }
  }
}
