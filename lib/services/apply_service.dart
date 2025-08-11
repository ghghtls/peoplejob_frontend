import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApplyService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8888'));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApplyService() {
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

  // 지원하기
  Future<bool> applyToJob({
    required int jobOpeningNo,
    required int resumeNo,
  }) async {
    try {
      await _dio.post(
        '/api/apply',
        data: {
          'jobopeningNo': jobOpeningNo,
          'resumeNo': resumeNo,
          'regdate': DateTime.now().toIso8601String().split('T')[0],
        },
      );
      return true;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        throw Exception('이미 지원한 채용공고입니다');
      }
      throw Exception('지원에 실패했습니다: $e');
    }
  }

  // 내 지원 내역 조회
  Future<List<dynamic>> getMyApplications() async {
    try {
      final response = await _dio.get('/api/apply/my');
      return response.data;
    } catch (e) {
      throw Exception('지원 내역을 불러오는데 실패했습니다: $e');
    }
  }

  // 특정 채용공고의 지원자 목록 조회 (기업용)
  Future<List<dynamic>> getJobApplications(int jobOpeningNo) async {
    try {
      final response = await _dio.get('/api/apply/job/$jobOpeningNo');
      return response.data;
    } catch (e) {
      throw Exception('지원자 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 모든 지원 내역 조회 (기업용)
  Future<List<dynamic>> getAllApplications() async {
    try {
      final response = await _dio.get('/api/apply');
      return response.data;
    } catch (e) {
      throw Exception('지원 내역을 불러오는데 실패했습니다: $e');
    }
  }

  // 지원 취소
  Future<bool> cancelApplication(int applyNo) async {
    try {
      await _dio.delete('/api/apply/$applyNo');
      return true;
    } catch (e) {
      throw Exception('지원 취소에 실패했습니다: $e');
    }
  }

  // 지원 상태 확인
  Future<bool> checkApplicationStatus({
    required int jobOpeningNo,
    required int resumeNo,
  }) async {
    try {
      final response = await _dio.get(
        '/api/apply/check',
        queryParameters: {'jobopeningNo': jobOpeningNo, 'resumeNo': resumeNo},
      );
      return response.data['applied'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // 특정 채용공고에 지원했는지 확인
  Future<bool> hasAppliedToJob(int jobOpeningNo) async {
    try {
      final response = await _dio.get('/api/apply/check-job/$jobOpeningNo');
      return response.data['applied'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // 지원 통계 (기업용)
  Future<Map<String, dynamic>> getApplicationStats() async {
    try {
      final response = await _dio.get('/api/apply/stats');
      return response.data;
    } catch (e) {
      throw Exception('지원 통계를 불러오는데 실패했습니다: $e');
    }
  }
}
