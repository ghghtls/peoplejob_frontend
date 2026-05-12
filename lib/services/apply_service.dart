import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/api_config.dart';

class ApplyService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApplyService({Dio? dio, FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: dotenv.env['API_URL'] ?? ApiConfig.apiUrl,
            )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'jwt');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _storage.delete(key: 'jwt');
          }
          handler.next(error);
        },
      ),
    );
  }

  /// 지원하기
  /// POST /api/apply
  Future<bool> applyToJob({
    required int jobopeningNo,
    required int resumeNo,
  }) async {
    try {
      await _dio.post(
        '/api/apply',
        data: {
          'jobNo': jobopeningNo,  // 백엔드 DTO의 jobNo 필드명 사용
          'resumeNo': resumeNo,
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

  /// 이력서별 지원 내역 조회
  /// GET /api/apply/resume/{resumeNo}
  Future<List<dynamic>> getApplicationsByResume(int resumeNo) async {
    try {
      final res = await _dio.get('/api/apply/resume/$resumeNo');
      return res.data is List ? res.data : [];
    } catch (e) {
      throw Exception('지원 내역을 불러오는데 실패했습니다: $e');
    }
  }

  /// 채용공고별 지원자 목록 조회
  /// GET /api/apply/job/{jobopeningNo}
  Future<List<dynamic>> getApplicationsByJob(int jobopeningNo) async {
    try {
      final res = await _dio.get('/api/apply/job/$jobopeningNo');
      return res.data is List ? res.data : [];
    } catch (e) {
      throw Exception('지원자 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 지원 취소
  /// DELETE /api/apply/{applyNo}
  Future<bool> cancelApplication(int applyNo) async {
    try {
      await _dio.delete('/api/apply/$applyNo');
      return true;
    } catch (e) {
      throw Exception('지원 취소에 실패했습니다: $e');
    }
  }

  /// 내 지원 목록 조회 (현재 로그인한 사용자)
  Future<List<dynamic>> getMyApplications() async {
    try {
      final userNo = await _getUserNo();
      if (userNo == null) {
        throw Exception('로그인이 필요합니다.');
      }
      final res = await _dio.get('/api/apply/user/$userNo');
      return res.data is List ? res.data : [];
    } catch (e) {
      throw Exception('내 지원 내역을 불러오는데 실패했습니다: $e');
    }
  }

  /// 채용공고별 지원자 목록 조회 (별칭)
  Future<List<dynamic>> getJobApplications(int jobOpeningNo) async {
    return getApplicationsByJob(jobOpeningNo);
  }

  /// 모든 지원 내역 조회 (관리자용)
  Future<List<dynamic>> getAllApplications() async {
    try {
      final res = await _dio.get('/api/apply');
      return res.data is List ? res.data : [];
    } catch (e) {
      throw Exception('지원 내역을 불러오는데 실패했습니다: $e');
    }
  }

  /// 지원 상태 확인
  Future<Map<String, dynamic>?> checkApplicationStatus(
    int jobOpeningNo,
    int resumeNo,
  ) async {
    try {
      final res = await _dio.get(
        '/api/apply/status',
        queryParameters: {
          'jobopeningNo': jobOpeningNo,
          'resumeNo': resumeNo,
        },
      );
      return res.data is Map ? res.data as Map<String, dynamic> : null;
    } catch (e) {
      return null;
    }
  }

  /// 특정 채용공고에 지원했는지 확인
  Future<bool> hasAppliedToJob(int jobOpeningNo) async {
    try {
      final userNo = await _getUserNo();
      if (userNo == null) return false;

      final res = await _dio.get(
        '/api/apply/check',
        queryParameters: {
          'jobopeningNo': jobOpeningNo,
          'userNo': userNo,
        },
      );
      return res.data == true || (res.data is Map && res.data['hasApplied'] == true);
    } catch (e) {
      return false;
    }
  }

  /// 내부 헬퍼: userNo 가져오기
  Future<int?> _getUserNo() async {
    try {
      final userNoStr = await _storage.read(key: 'userNo');
      return userNoStr != null ? int.tryParse(userNoStr) : null;
    } catch (e) {
      return null;
    }
  }
}
