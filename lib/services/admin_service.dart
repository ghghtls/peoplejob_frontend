import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/api_config.dart';

/// 관리자 전용 서비스
/// 백엔드 AdminController와 연동
class AdminService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AdminService({Dio? dio, FlutterSecureStorage? storage})
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

  /// 전체 사용자 조회
  Future<List<dynamic>> getAllUsers({
    int page = 0,
    int size = 20,
    String? userType,
    String? searchKeyword,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
        if (userType != null) 'userType': userType,
        if (searchKeyword != null) 'search': searchKeyword,
      };

      final res = await _dio.get('/api/admin/users', queryParameters: queryParams);
      
      if (res.data is Map && res.data['content'] is List) {
        return res.data['content'];
      }
      return res.data is List ? res.data : [];
    } catch (e) {
      throw Exception('사용자 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 사용자 삭제
  Future<bool> deleteUser(int userNo) async {
    try {
      await _dio.delete('/api/admin/users/$userNo');
      return true;
    } catch (e) {
      throw Exception('사용자 삭제에 실패했습니다: $e');
    }
  }

  /// 전체 채용공고 조회
  Future<List<dynamic>> getAllJobs({
    int page = 0,
    int size = 20,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
        if (status != null) 'status': status,
      };

      final res = await _dio.get('/api/admin/jobs', queryParameters: queryParams);
      
      if (res.data is Map && res.data['content'] is List) {
        return res.data['content'];
      }
      return res.data is List ? res.data : [];
    } catch (e) {
      throw Exception('채용공고 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 채용공고 삭제
  Future<bool> deleteJob(int jobopeningNo) async {
    try {
      await _dio.delete('/api/admin/jobs/$jobopeningNo');
      return true;
    } catch (e) {
      throw Exception('채용공고 삭제에 실패했습니다: $e');
    }
  }

  /// 전체 문의 조회
  Future<List<dynamic>> getAllInquiries({
    int page = 0,
    int size = 20,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
        if (status != null) 'status': status,
      };

      final res = await _dio.get('/api/admin/inquiries', queryParameters: queryParams);
      
      if (res.data is Map && res.data['content'] is List) {
        return res.data['content'];
      }
      return res.data is List ? res.data : [];
    } catch (e) {
      throw Exception('문의 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 문의 삭제
  Future<bool> deleteInquiry(int inquiryNo) async {
    try {
      await _dio.delete('/api/admin/inquiries/$inquiryNo');
      return true;
    } catch (e) {
      throw Exception('문의 삭제에 실패했습니다: $e');
    }
  }

  /// 문의 답변 등록
  Future<Map<String, dynamic>> answerInquiry(
    int inquiryNo,
    String answer,
    String answerBy,
  ) async {
    try {
      final res = await _dio.put(
        '/api/admin/inquiries/$inquiryNo/answer',
        queryParameters: {
          'answer': answer,
          'answerBy': answerBy,
        },
      );
      return res.data is Map ? res.data as Map<String, dynamic> : {};
    } catch (e) {
      throw Exception('답변 등록에 실패했습니다: $e');
    }
  }

  /// 전체 결제 내역 조회
  Future<List<dynamic>> getAllPayments({
    int page = 0,
    int size = 20,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
        if (status != null) 'status': status,
      };

      final res = await _dio.get('/api/admin/payments', queryParameters: queryParams);
      
      if (res.data is Map && res.data['content'] is List) {
        return res.data['content'];
      }
      return res.data is List ? res.data : [];
    } catch (e) {
      throw Exception('결제 내역을 불러오는데 실패했습니다: $e');
    }
  }

  /// 대시보드 통계 조회
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final res = await _dio.get('/api/admin/dashboard');
      return res.data is Map ? res.data as Map<String, dynamic> : {};
    } catch (e) {
      throw Exception('대시보드 통계를 불러오는데 실패했습니다: $e');
    }
  }

  /// 사용자 엑셀 다운로드
  Future<List<int>> downloadUsersExcel() async {
    try {
      final res = await _dio.get(
        '/api/admin/excel/users',
        options: Options(responseType: ResponseType.bytes),
      );
      return res.data as List<int>;
    } catch (e) {
      throw Exception('사용자 엑셀 다운로드에 실패했습니다: $e');
    }
  }

  /// 채용공고 엑셀 다운로드
  Future<List<int>> downloadJobsExcel() async {
    try {
      final res = await _dio.get(
        '/api/admin/excel/jobs',
        options: Options(responseType: ResponseType.bytes),
      );
      return res.data as List<int>;
    } catch (e) {
      throw Exception('채용공고 엑셀 다운로드에 실패했습니다: $e');
    }
  }

  /// 문의 엑셀 다운로드
  Future<List<int>> downloadInquiriesExcel() async {
    try {
      final res = await _dio.get(
        '/api/admin/excel/inquiries',
        options: Options(responseType: ResponseType.bytes),
      );
      return res.data as List<int>;
    } catch (e) {
      throw Exception('문의 엑셀 다운로드에 실패했습니다: $e');
    }
  }

  /// 지원자 엑셀 다운로드
  Future<List<int>> downloadApplicantsExcel(int jobNo) async {
    try {
      final res = await _dio.get(
        '/api/admin/excel/applicants/$jobNo',
        options: Options(responseType: ResponseType.bytes),
      );
      return res.data as List<int>;
    } catch (e) {
      throw Exception('지원자 엑셀 다운로드에 실패했습니다: $e');
    }
  }

  /// 결제 엑셀 다운로드
  Future<List<int>> downloadPaymentsExcel() async {
    try {
      final res = await _dio.get(
        '/api/admin/excel/payments',
        options: Options(responseType: ResponseType.bytes),
      );
      return res.data as List<int>;
    } catch (e) {
      throw Exception('결제 엑셀 다운로드에 실패했습니다: $e');
    }
  }

  /// 관리자 권한 확인
  Future<bool> isAdmin() async {
    try {
      final role = await _storage.read(key: 'role');
      return role == 'ADMIN';
    } catch (e) {
      return false;
    }
  }
}
