// lib/services/resume_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 내부에서 식별 가능한 인증 인터셉터 (중복 추가 방지용)
class _AuthTokenInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  _AuthTokenInterceptor(this.storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await storage.read(key: 'jwt');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // 테스트/런타임에서 스토리지 접근 실패 시 토큰 미첨부(무시)
    }
    handler.next(options);
  }
}

class ResumeService {
  // ------------------------ 테스트 훅 (선택) ------------------------
  static Dio? _testDio;
  static FlutterSecureStorage? _testStorage;

  /// 테스트에서 모의 Dio/Storage 주입할 때 사용하세요.
  /// 예) ResumeService.setTestOverrides(dio: mockDio, storage: mockStorage);
  static void setTestOverrides({Dio? dio, FlutterSecureStorage? storage}) {
    _testDio = dio;
    _testStorage = storage;
  }

  /// 테스트 훅 초기화 해제
  static void clearTestOverrides() {
    _testDio = null;
    _testStorage = null;
  }
  // ---------------------------------------------------------------

  late final Dio _dio;
  late final FlutterSecureStorage _storage;

  /// 기본 생성자(무인자). 필요시 외부에서 직접 주입도 가능.
  /// - 일반 앱 코드: `ResumeService()` 그대로 사용
  /// - 테스트: `ResumeService.setTestOverrides(...)` 호출 후 `ResumeService()` 생성
  ResumeService({Dio? dio, FlutterSecureStorage? storage}) {
    _dio =
        dio ?? _testDio ?? Dio(BaseOptions(baseUrl: 'http://localhost:8888'));
    _storage = storage ?? _testStorage ?? const FlutterSecureStorage();

    // 동일한 인터셉터가 중복으로 붙지 않도록 정리 후 추가
    _dio.interceptors.removeWhere((i) => i is _AuthTokenInterceptor);
    _dio.interceptors.add(_AuthTokenInterceptor(_storage));
  }

  // 이력서 전체 조회
  Future<List<Map<String, dynamic>>> getAllResumes() async {
    try {
      final response = await _dio.get('/api/resume');
      final data = response.data as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('이력서 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 특정 사용자의 이력서 조회
  Future<List<Map<String, dynamic>>> getUserResumes(int userNo) async {
    try {
      final response = await _dio.get('/api/resume/user/$userNo');
      final data = response.data as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('사용자 이력서 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 이력서 상세 조회
  Future<Map<String, dynamic>> getResumeDetail(int resumeId) async {
    try {
      final response = await _dio.get('/api/resume/$resumeId');
      return (response.data as Map).cast<String, dynamic>();
    } catch (e) {
      throw Exception('이력서 상세 정보를 불러오는데 실패했습니다: $e');
    }
  }

  // 이력서 등록
  Future<int?> createResume(Map<String, dynamic> resumeData) async {
    try {
      final response = await _dio.post('/api/resume', data: resumeData);

      if (response.statusCode == 200) {
        final body = response.data;
        if (body is Map<String, dynamic> && body.containsKey('resumeId')) {
          return body['resumeId'] as int?;
        }
        // 응답 구조가 다를 경우 null 반환
        // print('예상과 다른 응답 구조: $body');
        return null;
      }
      return null;
    } catch (e) {
      // print('이력서 등록 실패: $e');
      return null;
    }
  }

  // 이력서 수정
  Future<bool> updateResume(
    int resumeId,
    Map<String, dynamic> resumeData,
  ) async {
    try {
      await _dio.put('/api/resume/$resumeId', data: resumeData);
      return true;
    } catch (e) {
      throw Exception('이력서 수정에 실패했습니다: $e');
    }
  }

  // 이력서 삭제
  Future<bool> deleteResume(int resumeId) async {
    try {
      await _dio.delete('/api/resume/$resumeId');
      return true;
    } catch (e) {
      throw Exception('이력서 삭제에 실패했습니다: $e');
    }
  }

  // 이력서 검색 (빈 키워드는 즉시 빈 배열 반환하여 네트워크 호출 방지)
  Future<List<Map<String, dynamic>>> searchResumes(String keyword) async {
    try {
      if (keyword.trim().isEmpty) return <Map<String, dynamic>>[];
      final response = await _dio.get('/api/resume/search?keyword=$keyword');
      final data = response.data as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('이력서 검색에 실패했습니다: $e');
    }
  }

  // 희망 직종별 이력서 조회
  Future<List<Map<String, dynamic>>> getResumesByJobType(String jobType) async {
    try {
      final response = await _dio.get('/api/resume/jobtype/$jobType');
      final data = response.data as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('직종별 이력서 조회에 실패했습니다: $e');
    }
  }

  // 희망 지역별 이력서 조회
  Future<List<Map<String, dynamic>>> getResumesByLocation(
    String location,
  ) async {
    try {
      final response = await _dio.get('/api/resume/location/$location');
      final data = response.data as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('지역별 이력서 조회에 실패했습니다: $e');
    }
  }
}
