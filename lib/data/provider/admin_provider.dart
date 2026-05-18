import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:peoplejob_frontend/services/auth_service.dart';
import 'package:peoplejob_frontend/services/config/api_config.dart';
import 'dart:io';
import '../model/inquiry.dart';
import '../model/job.dart';
import '../../utils/excel_download_helper.dart';

// AuthService Provider 추가
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// 관리자 상태 클래스
class AdminState {
  final List<Inquiry> inquiries;
  final List<Job> jobs;
  final List<dynamic> users;
  final List<dynamic> payments;
  final List<dynamic> applicants;
  final Map<String, dynamic> dashboard;
  final bool isLoading;
  final String? error;

  AdminState({
    this.inquiries = const [],
    this.jobs = const [],
    this.users = const [],
    this.payments = const [],
    this.applicants = const [],
    this.dashboard = const {},
    this.isLoading = false,
    this.error,
  });

  AdminState copyWith({
    List<Inquiry>? inquiries,
    List<Job>? jobs,
    List<dynamic>? users,
    List<dynamic>? payments,
    List<dynamic>? applicants,
    Map<String, dynamic>? dashboard,
    bool? isLoading,
    String? error,
  }) {
    return AdminState(
      inquiries: inquiries ?? this.inquiries,
      jobs: jobs ?? this.jobs,
      users: users ?? this.users,
      payments: payments ?? this.payments,
      applicants: applicants ?? this.applicants,
      dashboard: dashboard ?? this.dashboard,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// 관리자 노티파이어
class AdminNotifier extends StateNotifier<AdminState> {
  final Dio _dio;
  final AuthService _authService;

  AdminNotifier(this._dio, this._authService) : super(AdminState());

  String get _baseUrl => '${dotenv.env['API_URL'] ?? ApiConfig.apiUrl}/api/admin';

  // 헤더에 토큰 추가
  Future<Map<String, String>> get _headers async {
    final token = await _authService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // 대시보드 데이터 로드
  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final headers = await _headers;
      final response = await _dio.get(
        '$_baseUrl/dashboard',
        options: Options(headers: headers),
      );
      state = state.copyWith(dashboard: response.data, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: _handleError(e), isLoading: false);
    }
  }

  // 전체 문의사항 로드
  Future<void> loadInquiries() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final headers = await _headers;
      final response = await _dio.get(
        '$_baseUrl/inquiries',
        options: Options(headers: headers),
      );
      final inquiries =
          (response.data as List)
              .map((json) => Inquiry.fromJson(json))
              .toList();
      state = state.copyWith(inquiries: inquiries, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: _handleError(e), isLoading: false);
    }
  }

  // 문의사항 답변
  Future<bool> answerInquiry(int inquiryNo, String answer) async {
    try {
      final headers = await _headers;
      await _dio.put(
        '$_baseUrl/inquiries/$inquiryNo/answer',
        queryParameters: {'answer': answer, 'answerBy': 'admin'},
        options: Options(headers: headers),
      );
      await loadInquiries();
      return true;
    } catch (e) {
      state = state.copyWith(error: _handleError(e));
      return false;
    }
  }

  // 문의사항 삭제
  Future<bool> deleteInquiry(int inquiryNo) async {
    try {
      final headers = await _headers;
      await _dio.delete(
        '$_baseUrl/inquiries/$inquiryNo',
        options: Options(headers: headers),
      );
      await loadInquiries();
      return true;
    } catch (e) {
      state = state.copyWith(error: _handleError(e));
      return false;
    }
  }

  // 전체 지원자 로드
  Future<void> loadApplicants() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final headers = await _headers;
      final response = await _dio.get(
        '$_baseUrl/applicants',
        options: Options(headers: headers),
      );
      state = state.copyWith(applicants: response.data as List, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: _handleError(e), isLoading: false);
    }
  }

  // 전체 회원 로드
  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final headers = await _headers;
      final response = await _dio.get(
        '$_baseUrl/users',
        options: Options(headers: headers),
      );
      state = state.copyWith(users: response.data, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: _handleError(e), isLoading: false);
    }
  }

  // 회원 삭제
  Future<bool> deleteUser(int userNo) async {
    try {
      final headers = await _headers;
      await _dio.delete(
        '$_baseUrl/users/$userNo',
        options: Options(headers: headers),
      );
      await loadUsers();
      return true;
    } catch (e) {
      state = state.copyWith(error: _handleError(e));
      return false;
    }
  }

  // 전체 채용공고 로드
  Future<void> loadJobs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final headers = await _headers;
      final response = await _dio.get(
        '$_baseUrl/jobs',
        options: Options(headers: headers),
      );
      final jobs =
          (response.data as List).map((json) => Job.fromJson(json)).toList();
      state = state.copyWith(jobs: jobs, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: _handleError(e), isLoading: false);
    }
  }

  // 채용공고 삭제
  Future<bool> deleteJob(int jobNo) async {
    try {
      final headers = await _headers;
      await _dio.delete(
        '$_baseUrl/jobs/$jobNo',
        options: Options(headers: headers),
      );
      await loadJobs();
      return true;
    } catch (e) {
      state = state.copyWith(error: _handleError(e));
      return false;
    }
  }

  // 채용공고 승인 (PENDING → PUBLISHED)
  Future<bool> approveJob(int jobNo) async {
    try {
      final headers = await _headers;
      await _dio.put(
        '$_baseUrl/jobs/$jobNo/approve',
        options: Options(headers: headers),
      );
      await loadJobs();
      return true;
    } catch (e) {
      state = state.copyWith(error: _handleError(e));
      return false;
    }
  }

  // 채용공고 반려 (PENDING → DRAFT)
  Future<bool> rejectJob(int jobNo) async {
    try {
      final headers = await _headers;
      await _dio.put(
        '$_baseUrl/jobs/$jobNo/reject',
        options: Options(headers: headers),
      );
      await loadJobs();
      return true;
    } catch (e) {
      state = state.copyWith(error: _handleError(e));
      return false;
    }
  }

  // 채용공고 강제 마감
  Future<bool> expireJob(int jobNo) async {
    try {
      final headers = await _headers;
      await _dio.put(
        '$_baseUrl/jobs/$jobNo/expire',
        options: Options(headers: headers),
      );
      await loadJobs();
      return true;
    } catch (e) {
      state = state.copyWith(error: _handleError(e));
      return false;
    }
  }

  // 결제 내역 로드
  Future<void> loadPayments() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final headers = await _headers;
      final response = await _dio.get(
        '$_baseUrl/payments',
        options: Options(headers: headers),
      );
      state = state.copyWith(payments: response.data, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: _handleError(e), isLoading: false);
    }
  }

  // ============ Excel 다운로드 기능 ============

  // 회원 목록 Excel 다운로드
  Future<String?> downloadUsersExcel() async {
    return _downloadExcel('excel/users', '회원목록');
  }

  // 채용공고 Excel 다운로드
  Future<String?> downloadJobsExcel() async {
    return _downloadExcel('excel/jobs', '채용공고목록');
  }

  // 문의사항 Excel 다운로드
  Future<String?> downloadInquiriesExcel() async {
    return _downloadExcel('excel/inquiries', '문의사항목록');
  }

  // 지원자 목록 Excel 다운로드
  Future<String?> downloadApplicantsExcel(int jobNo) async {
    return _downloadExcel('excel/applicants/$jobNo', '지원자목록_$jobNo');
  }

  // 결제 내역 Excel 다운로드
  Future<String?> downloadPaymentsExcel() async {
    return _downloadExcel('excel/payments', '결제내역목록');
  }

  Future<String?> _downloadExcel(String endpoint, String fileName) async {
    try {
      final headers = await _headers;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final downloadFileName = '${fileName}_$timestamp.xlsx';

      final response = await _dio.get(
        '$_baseUrl/$endpoint',
        options: Options(headers: headers, responseType: ResponseType.bytes),
      );

      final bytes = response.data;
      final byteList = bytes is List<int> ? bytes : (bytes as List).cast<int>();

      if (kIsWeb) {
        await downloadExcelOnWeb(byteList, downloadFileName);
        return downloadFileName;
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        state = state.copyWith(error: '다운로드 폴더를 찾을 수 없습니다.');
        return null;
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final filePath = '${directory.path}/$downloadFileName';
      await File(filePath).writeAsBytes(byteList);
      return filePath;
    } catch (e) {
      state = state.copyWith(error: _handleError(e));
      return null;
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.statusCode == 403) {
        return '관리자 권한이 필요합니다.';
      }
      if (error.response?.statusCode == 401) {
        return '로그인이 필요합니다.';
      }
      return error.response?.data['message'] ?? '서버 오류가 발생했습니다.';
    }
    return '알 수 없는 오류가 발생했습니다.';
  }
}

// Provider 정의
final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final dio = Dio();
  final authService = ref.watch(authServiceProvider);
  return AdminNotifier(dio, authService);
});
