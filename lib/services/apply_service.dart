import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApplyService {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  final String _baseUrl;

  ApplyService({Dio? dio, FlutterSecureStorage? storage, String? baseUrl})
    : _baseUrl = baseUrl ?? 'http://localhost:8888',
      _storage = storage ?? const FlutterSecureStorage(),
      _dio =
          dio ?? Dio(BaseOptions(baseUrl: baseUrl ?? 'http://localhost:8888')) {
    // JWT 토큰 자동 주입
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('이미 지원한 채용공고입니다');
      }
      throw Exception('지원에 실패했습니다: ${e.message}');
    } catch (e) {
      throw Exception('지원에 실패했습니다: $e');
    }
  }

  // 내 지원 내역 조회
  Future<List<dynamic>> getMyApplications() async {
    try {
      final res = await _dio.get('/api/apply/my');
      return res.data as List<dynamic>;
    } catch (e) {
      throw Exception('지원 내역을 불러오는데 실패했습니다: $e');
    }
  }

  // 특정 채용공고의 지원자 목록 조회 (기업용)
  Future<List<dynamic>> getJobApplications(int jobOpeningNo) async {
    try {
      final res = await _dio.get('/api/apply/job/$jobOpeningNo');
      return res.data as List<dynamic>;
    } catch (e) {
      throw Exception('지원자 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 모든 지원 내역 조회 (기업용)
  Future<List<dynamic>> getAllApplications() async {
    try {
      final res = await _dio.get('/api/apply');
      return res.data as List<dynamic>;
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

  // 지원 상태 확인 (공고+이력서)
  Future<bool> checkApplicationStatus({
    required int jobOpeningNo,
    required int resumeNo,
  }) async {
    try {
      final res = await _dio.get(
        '/api/apply/check',
        queryParameters: {'jobopeningNo': jobOpeningNo, 'resumeNo': resumeNo},
      );
      final data = res.data;
      return data is Map && data['applied'] == true;
    } catch (_) {
      return false;
    }
  }

  // 특정 채용공고에 지원했는지 확인
  Future<bool> hasAppliedToJob(int jobOpeningNo) async {
    try {
      final res = await _dio.get('/api/apply/check-job/$jobOpeningNo');
      final data = res.data;
      return data is Map && data['applied'] == true;
    } catch (_) {
      return false;
    }
  }

  // 지원 통계 (기업용)
  Future<Map<String, dynamic>> getApplicationStats() async {
    try {
      final res = await _dio.get('/api/apply/stats');
      return Map<String, dynamic>.from(res.data as Map);
    } catch (e) {
      throw Exception('지원 통계를 불러오는데 실패했습니다: $e');
    }
  }
}
