import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/api_config.dart';

/// 마이페이지 전용 서비스
/// 백엔드 MypageController와 연동
class MypageService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  MypageService({Dio? dio, FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: dotenv.env['API_URL'] ?? ApiConfig.apiUrl,
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

  /// 내 이력서 목록 조회
  /// GET /api/mypage/resumes/{userNo}
  Future<List<dynamic>> getMyResumes() async {
    try {
      final userNo = await _getUserNo();
      if (userNo == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final res = await _dio.get('/api/mypage/resumes/$userNo');
      return res.data is List ? res.data : [];
    } catch (e) {
      throw Exception('내 이력서 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 내 지원 내역 조회
  /// GET /api/mypage/applies/{userNo}
  Future<List<dynamic>> getMyApplications() async {
    try {
      final userNo = await _getUserNo();
      if (userNo == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final res = await _dio.get('/api/mypage/applies/$userNo');
      return res.data is List ? res.data : [];
    } catch (e) {
      throw Exception('내 지원 내역을 불러오는데 실패했습니다: $e');
    }
  }

  /// 내 채용공고 목록 (기업회원용)
  /// GET /api/mypage/jobopenings/{companyNo}
  Future<List<dynamic>> getMyJobPostings() async {
    try {
      final userNo = await _getUserNo();
      if (userNo == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final res = await _dio.get('/api/mypage/jobopenings/$userNo');
      return res.data is List ? res.data : [];
    } catch (e) {
      throw Exception('내 채용공고 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 특정 채용공고의 지원자 목록 조회
  /// GET /api/mypage/applies/job/{jobopeningNo}
  Future<List<dynamic>> getJobApplicants(int jobopeningNo) async {
    try {
      final res = await _dio.get('/api/mypage/applies/job/$jobopeningNo');
      return res.data is List ? res.data : [];
    } catch (e) {
      throw Exception('지원자 목록을 불러오는데 실패했습니다: $e');
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
