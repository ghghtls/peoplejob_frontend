import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/api_config.dart';

class InquiryService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  InquiryService({Dio? dio, FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: dotenv.env['API_URL'] ?? ApiConfig.apiUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await _storage.read(key: 'jwt');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {}
          handler.next(options);
        },
        onError: (error, handler) async {
          try {
            if (error.response?.statusCode == 401) {
              await _storage.delete(key: 'jwt');
            }
          } catch (_) {}
          handler.next(error);
        },
      ),
    );
  }

  Future<String?> _getUserNo() async {
    return await _storage.read(key: 'userNo');
  }

  // 문의 등록
  // InquiryEntity는 writer(이름), email, category(NOT NULL) 기반
  Future<bool> createInquiry(
    String title,
    String content, {
    String category = '일반',
  }) async {
    try {
      if (await _getUserNo() == null) throw Exception('로그인이 필요합니다.');

      final name = await _storage.read(key: 'name') ?? '';
      final email = await _storage.read(key: 'email') ?? '';

      await _dio.post(
        '/api/inquiry',
        data: {
          'title': title,
          'content': content,
          'writer': name,
          'email': email,
          'category': category,
        },
      );
      return true;
    } catch (e) {
      debugPrint('문의 등록 실패: $e');
      return false;
    }
  }

  // 내 문의 목록 조회
  // GET /api/inquiry/my?email=
  Future<List<Map<String, dynamic>>> getMyInquiries() async {
    try {
      final myEmail = await _storage.read(key: 'email');
      if (myEmail == null || myEmail.isEmpty) return [];

      final response = await _dio.get(
        '/api/inquiry/my',
        queryParameters: {'email': myEmail},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('문의 목록 조회 실패: $e');
      return [];
    }
  }

  // 문의 상세 조회
  Future<Map<String, dynamic>?> getInquiryDetail(int inquiryNo) async {
    try {
      final response = await _dio.get('/api/inquiry/$inquiryNo');
      if (response.statusCode == 200) return response.data;
      return null;
    } catch (e) {
      debugPrint('문의 상세 조회 실패: $e');
      return null;
    }
  }

  // 문의 수정
  Future<bool> updateInquiry(int inquiryNo, String title, String content) async {
    try {
      await _dio.put(
        '/api/inquiry/$inquiryNo',
        data: {'title': title, 'content': content},
      );
      return true;
    } catch (e) {
      debugPrint('문의 수정 실패: $e');
      return false;
    }
  }

  // 문의 삭제
  Future<bool> deleteInquiry(int inquiryNo) async {
    try {
      await _dio.delete('/api/inquiry/$inquiryNo');
      return true;
    } catch (e) {
      debugPrint('문의 삭제 실패: $e');
      return false;
    }
  }

  // 관리자 - 전체 문의 조회
  Future<List<Map<String, dynamic>>> getAllInquiries() async {
    try {
      final response = await _dio.get('/api/inquiry');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('전체 문의 조회 실패: $e');
      return [];
    }
  }

  // 관리자 - 답변 등록
  Future<bool> answerInquiry(int inquiryNo, String answer) async {
    try {
      await _dio.put(
        '/api/inquiry/$inquiryNo/answer',
        queryParameters: {'answer': answer},
      );
      return true;
    } catch (e) {
      debugPrint('답변 등록 실패: $e');
      return false;
    }
  }
}
