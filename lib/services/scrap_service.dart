import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ScrapService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8888'));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ScrapService() {
    // JWT 토큰을 자동으로 헤더에 추가하는 인터셉터
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'jwt');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  // 스크랩 추가
  Future<bool> addScrap(int jobOpeningNo) async {
    try {
      await _dio.post(
        '/api/scrap',
        data: {
          'jobopeningNo': jobOpeningNo,
          'regdate': DateTime.now().toIso8601String().split('T')[0],
        },
      );
      return true;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        throw Exception('이미 스크랩한 채용공고입니다');
      }
      throw Exception('스크랩 추가에 실패했습니다: $e');
    }
  }

  // 스크랩 제거
  Future<bool> removeScrap(int jobOpeningNo) async {
    try {
      await _dio.delete('/api/scrap/job/$jobOpeningNo');
      return true;
    } catch (e) {
      throw Exception('스크랩 제거에 실패했습니다: $e');
    }
  }

  // 내 스크랩 목록 조회
  Future<List<dynamic>> getMyScrapList() async {
    try {
      final response = await _dio.get('/api/scrap/my');
      return response.data;
    } catch (e) {
      throw Exception('스크랩 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 스크랩 여부 확인
  Future<bool> isScraped(int jobOpeningNo) async {
    try {
      final response = await _dio.get('/api/scrap/check/$jobOpeningNo');
      return response.data['scraped'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // 특정 스크랩 삭제 (스크랩 ID로)
  Future<bool> deleteScrapById(int scrapNo) async {
    try {
      await _dio.delete('/api/scrap/$scrapNo');
      return true;
    } catch (e) {
      throw Exception('스크랩 삭제에 실패했습니다: $e');
    }
  }

  // 전체 스크랩 조회 (관리자용)
  Future<List<dynamic>> getAllScraps() async {
    try {
      final response = await _dio.get('/api/scrap');
      return response.data;
    } catch (e) {
      throw Exception('스크랩 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 스크랩 통계
  Future<Map<String, dynamic>> getScrapStats() async {
    try {
      final response = await _dio.get('/api/scrap/stats');
      return response.data;
    } catch (e) {
      throw Exception('스크랩 통계를 불러오는데 실패했습니다: $e');
    }
  }
}
