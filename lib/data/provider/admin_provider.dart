import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:peoplejob_frontend/services/auth_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../model/inquiry.dart';
import '../model/job.dart';

// AuthService Provider 추가
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// 관리자 상태 클래스
class AdminState {
  final List<Inquiry> inquiries;
  final List<Job> jobs;
  final List<dynamic> users;
  final List<dynamic> payments;
  final Map<String, dynamic> dashboard;
  final bool isLoading;
  final String? error;

  AdminState({
    this.inquiries = const [],
    this.jobs = const [],
    this.users = const [],
    this.payments = const [],
    this.dashboard = const {},
    this.isLoading = false,
    this.error,
  });

  AdminState copyWith({
    List<Inquiry>? inquiries,
    List<Job>? jobs,
    List<dynamic>? users,
    List<dynamic>? payments,
    Map<String, dynamic>? dashboard,
    bool? isLoading,
    String? error,
  }) {
    return AdminState(
      inquiries: inquiries ?? this.inquiries,
      jobs: jobs ?? this.jobs,
      users: users ?? this.users,
      payments: payments ?? this.payments,
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

  String get _baseUrl => 'http://localhost:8080/api/admin';

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

  // 공통 Excel 다운로드 메서드
  Future<String?> _downloadExcel(String endpoint, String fileName) async {
    try {
      // 권한 확인
      if (Platform.isAndroid) {
        final permission = await Permission.storage.request();
        if (!permission.isGranted) {
          state = state.copyWith(error: '저장소 권한이 필요합니다.');
          return null;
        }
      }

      // 다운로드 디렉토리 가져오기
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        final downloadPath = '/storage/emulated/0/Download';
        directory = Directory(downloadPath);
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        state = state.copyWith(error: '다운로드 폴더를 찾을 수 없습니다.');
        return null;
      }

      final headers = await _headers;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final downloadFileName = '${fileName}_$timestamp.xlsx';
      final filePath = '${directory.path}/$downloadFileName';

      // Excel 파일 다운로드
      final response = await _dio.get(
        '$_baseUrl/$endpoint',
        options: Options(headers: headers, responseType: ResponseType.bytes),
      );

      // 파일 저장
      final file = File(filePath);
      await file.writeAsBytes(response.data);

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
