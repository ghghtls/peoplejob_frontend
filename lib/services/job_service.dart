// lib/services/job_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/model/job.dart';

class JobService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8888'));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  JobService() {
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
        onError: (error, handler) async {
          // 401 에러 시 토큰 갱신 또는 로그아웃 처리
          if (error.response?.statusCode == 401) {
            await _storage.delete(key: 'jwt');
          }
          handler.next(error);
        },
      ),
    );
  }

  // ============ 기존 메서드들 ============

  // 채용공고 전체 조회
  Future<List<dynamic>> getAllJobs() async {
    try {
      final response = await _dio.get('/api/jobopening');
      return response.data;
    } catch (e) {
      throw Exception('채용공고 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 채용공고 상세 조회
  Future<Map<String, dynamic>> getJobDetail(int jobId) async {
    try {
      final response = await _dio.get('/api/jobopening/$jobId');
      return response.data;
    } catch (e) {
      throw Exception('채용공고 상세 정보를 불러오는데 실패했습니다: $e');
    }
  }

  // 채용공고 등록
  Future<bool> createJob(Map<String, dynamic> jobData) async {
    try {
      await _dio.post('/api/jobopening', data: jobData);
      return true;
    } catch (e) {
      throw Exception('채용공고 등록에 실패했습니다: $e');
    }
  }

  // 채용공고 수정
  Future<bool> updateJob(int jobId, Map<String, dynamic> jobData) async {
    try {
      await _dio.put('/api/jobopening/$jobId', data: jobData);
      return true;
    } catch (e) {
      throw Exception('채용공고 수정에 실패했습니다: $e');
    }
  }

  // 채용공고 삭제
  Future<bool> deleteJob(int jobId) async {
    try {
      await _dio.delete('/api/jobopening/$jobId');
      return true;
    } catch (e) {
      throw Exception('채용공고 삭제에 실패했습니다: $e');
    }
  }

  // 채용공고 검색
  Future<List<dynamic>> searchJobs(String keyword) async {
    try {
      final response = await _dio.get(
        '/api/jobopening/search?keyword=$keyword',
      );
      return response.data;
    } catch (e) {
      throw Exception('채용공고 검색에 실패했습니다: $e');
    }
  }

  // ============ 새로 추가: 상태 관리 메서드들 ============

  // 임시저장
  Future<Map<String, dynamic>> saveDraft(Map<String, dynamic> jobData) async {
    try {
      final response = await _dio.post('/api/jobs/draft', data: jobData);
      return {
        'success': true,
        'job': response.data['job'],
        'message': response.data['message'],
      };
    } catch (e) {
      throw Exception('임시저장에 실패했습니다: $e');
    }
  }

  // 임시저장 목록 조회
  Future<Map<String, dynamic>> getUserDrafts(
    int userNo, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/jobs/user/$userNo/drafts',
        queryParameters: {'page': page, 'size': size},
      );
      return {
        'success': true,
        'jobs': response.data['content'],
        'totalElements': response.data['totalElements'],
        'totalPages': response.data['totalPages'],
        'currentPage': response.data['number'],
        'hasNext': !response.data['last'],
      };
    } catch (e) {
      throw Exception('임시저장 목록 조회에 실패했습니다: $e');
    }
  }

  // 게시하기 (임시저장 -> 게시중)
  Future<Map<String, dynamic>> publishJob(int jobNo, int userNo) async {
    try {
      final response = await _dio.post(
        '/api/jobs/$jobNo/publish',
        queryParameters: {'userNo': userNo},
      );
      return {
        'success': true,
        'job': response.data['job'],
        'message': response.data['message'],
      };
    } catch (e) {
      throw Exception('게시에 실패했습니다: $e');
    }
  }

  // 게시중인 채용공고만 조회 (일반 사용자용)
  Future<Map<String, dynamic>> getPublishedJobs({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/jobs',
        queryParameters: {'status': 'published', 'page': page, 'size': size},
      );
      return {
        'success': true,
        'jobs': response.data['content'],
        'totalElements': response.data['totalElements'],
        'totalPages': response.data['totalPages'],
        'currentPage': response.data['number'],
        'hasNext': !response.data['last'],
      };
    } catch (e) {
      throw Exception('채용공고 목록 조회에 실패했습니다: $e');
    }
  }

  // 사용자별 상태별 채용공고 조회
  Future<Map<String, dynamic>> getUserJobsByStatus(
    int userNo,
    String? status, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      Map<String, dynamic> queryParams = {'page': page, 'size': size};

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        '/api/jobs/user/$userNo',
        queryParameters: queryParams,
      );

      return {
        'success': true,
        'jobs': response.data['content'],
        'totalElements': response.data['totalElements'],
        'totalPages': response.data['totalPages'],
        'currentPage': response.data['number'],
        'hasNext': !response.data['last'],
      };
    } catch (e) {
      throw Exception('사용자 채용공고 조회에 실패했습니다: $e');
    }
  }

  // 사용자의 채용공고 상태별 개수 조회
  Future<Map<String, dynamic>> getUserJobStatusCounts(int userNo) async {
    try {
      final response = await _dio.get('/api/jobs/user/$userNo/status-counts');
      return {'success': true, 'counts': response.data};
    } catch (e) {
      throw Exception('상태별 개수 조회에 실패했습니다: $e');
    }
  }

  // 상태 변경
  Future<Map<String, dynamic>> changeJobStatus(
    int jobNo,
    String status,
    int userNo,
  ) async {
    try {
      final response = await _dio.put(
        '/api/jobs/$jobNo/status',
        queryParameters: {'status': status, 'userNo': userNo},
      );
      return {
        'success': true,
        'job': response.data['job'],
        'message': response.data['message'],
      };
    } catch (e) {
      throw Exception('상태 변경에 실패했습니다: $e');
    }
  }

  // 검색 (게시중인 것만)
  Future<Map<String, dynamic>> searchPublishedJobs(
    String keyword, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/jobs/search',
        queryParameters: {'keyword': keyword, 'page': page, 'size': size},
      );
      return {
        'success': true,
        'jobs': response.data['content'],
        'totalElements': response.data['totalElements'],
        'totalPages': response.data['totalPages'],
        'currentPage': response.data['number'],
        'hasNext': !response.data['last'],
      };
    } catch (e) {
      throw Exception('검색에 실패했습니다: $e');
    }
  }

  // 카테고리별 조회 (게시중인 것만)
  Future<Map<String, dynamic>> getJobsByCategory(
    String? jobType,
    String? location, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      Map<String, dynamic> queryParams = {'page': page, 'size': size};

      if (jobType != null && jobType.isNotEmpty) {
        queryParams['jobType'] = jobType;
      }

      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }

      final response = await _dio.get(
        '/api/jobs/category',
        queryParameters: queryParams,
      );

      return {
        'success': true,
        'jobs': response.data['content'],
        'totalElements': response.data['totalElements'],
        'totalPages': response.data['totalPages'],
        'currentPage': response.data['number'],
        'hasNext': !response.data['last'],
      };
    } catch (e) {
      throw Exception('카테고리별 조회에 실패했습니다: $e');
    }
  }

  // ============ 채용공고 작성/수정 관련 (새로운 API 엔드포인트 사용) ============

  // 새 채용공고 생성 (기본 임시저장 상태)
  Future<Map<String, dynamic>> createJobPosting(Job job) async {
    try {
      final response = await _dio.post('/api/jobs', data: job.toJson());
      return {
        'success': true,
        'job': Job.fromJson(response.data['job']),
        'message': response.data['message'],
      };
    } catch (e) {
      throw Exception('채용공고 생성에 실패했습니다: $e');
    }
  }

  // 채용공고 수정 (새로운 API)
  Future<Map<String, dynamic>> updateJobPosting(int jobNo, Job job) async {
    try {
      final response = await _dio.put('/api/jobs/$jobNo', data: job.toJson());
      return {
        'success': true,
        'job': Job.fromJson(response.data['job']),
        'message': response.data['message'],
      };
    } catch (e) {
      throw Exception('채용공고 수정에 실패했습니다: $e');
    }
  }

  // 채용공고 삭제 (새로운 API)
  Future<Map<String, dynamic>> deleteJobPosting(int jobNo) async {
    try {
      final response = await _dio.delete('/api/jobs/$jobNo');
      return {'success': true, 'message': response.data['message']};
    } catch (e) {
      throw Exception('채용공고 삭제에 실패했습니다: $e');
    }
  }

  // 채용공고 상세 조회 (새로운 API)
  Future<Job> getJobPosting(int jobNo) async {
    try {
      final response = await _dio.get('/api/jobs/$jobNo');
      return Job.fromJson(response.data);
    } catch (e) {
      throw Exception('채용공고 조회에 실패했습니다: $e');
    }
  }

  // ============ 관리자용 메서드들 ============

  // 마감일 지난 채용공고 자동 마감 처리 (관리자용)
  Future<Map<String, dynamic>> expireOverdueJobs() async {
    try {
      final response = await _dio.post('/api/jobs/expire-overdue');
      return {'success': true, 'message': response.data['message']};
    } catch (e) {
      throw Exception('자동 마감 처리에 실패했습니다: $e');
    }
  }

  // 특정 채용공고 마감 처리 (관리자용)
  Future<Map<String, dynamic>> expireJob(int jobNo) async {
    try {
      final response = await _dio.post('/api/jobs/$jobNo/expire');
      return {
        'success': true,
        'job': Job.fromJson(response.data['job']),
        'message': response.data['message'],
      };
    } catch (e) {
      throw Exception('채용공고 마감 처리에 실패했습니다: $e');
    }
  }

  // 승인 대기중인 채용공고 목록 (관리자용)
  Future<Map<String, dynamic>> getPendingJobs({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/admin/jobs/pending',
        queryParameters: {'page': page, 'size': size},
      );
      return {
        'success': true,
        'jobs': response.data['content'],
        'totalElements': response.data['totalElements'],
        'totalPages': response.data['totalPages'],
        'currentPage': response.data['number'],
        'hasNext': !response.data['last'],
      };
    } catch (e) {
      throw Exception('승인 대기 목록 조회에 실패했습니다: $e');
    }
  }

  // ============ 헬퍼 메서드들 ============

  // 사용자 정보 가져오기
  Future<int?> getCurrentUserNo() async {
    try {
      final userNoStr = await _storage.read(key: 'userNo');
      return userNoStr != null ? int.tryParse(userNoStr) : null;
    } catch (e) {
      return null;
    }
  }

  // 토큰 유효성 확인
  Future<bool> isTokenValid() async {
    try {
      final token = await _storage.read(key: 'jwt');
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // 에러 메시지 파싱
  String parseErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null) {
        if (error.response!.data is Map &&
            error.response!.data['error'] != null) {
          return error.response!.data['error'];
        }
      }

      switch (error.response?.statusCode) {
        case 400:
          return '잘못된 요청입니다.';
        case 401:
          return '인증이 필요합니다.';
        case 403:
          return '권한이 없습니다.';
        case 404:
          return '요청한 데이터를 찾을 수 없습니다.';
        case 500:
          return '서버 오류가 발생했습니다.';
        default:
          return '네트워크 오류가 발생했습니다.';
      }
    }

    return error.toString();
  }

  // Response 데이터 안전하게 파싱
  T? safeGet<T>(Map<String, dynamic>? data, String key, [T? defaultValue]) {
    try {
      return data?[key] as T? ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  // 페이징 정보 파싱
  Map<String, dynamic> parsePagingInfo(Map<String, dynamic> response) {
    return {
      'totalElements': safeGet<int>(response, 'totalElements', 0),
      'totalPages': safeGet<int>(response, 'totalPages', 0),
      'currentPage': safeGet<int>(response, 'number', 0),
      'size': safeGet<int>(response, 'size', 10),
      'hasNext': safeGet<bool>(response, 'last', true) == false,
      'hasPrevious': safeGet<bool>(response, 'first', true) == false,
    };
  }

  // ============ 배치 작업용 메서드들 ============

  // 여러 채용공고 상태 일괄 변경
  Future<Map<String, dynamic>> batchChangeStatus(
    List<int> jobNos,
    String status,
    int userNo,
  ) async {
    try {
      final results = <Map<String, dynamic>>[];

      for (final jobNo in jobNos) {
        try {
          final result = await changeJobStatus(jobNo, status, userNo);
          results.add({'jobNo': jobNo, 'success': true, 'job': result['job']});
        } catch (e) {
          results.add({
            'jobNo': jobNo,
            'success': false,
            'error': parseErrorMessage(e),
          });
        }
      }

      return {
        'success': true,
        'results': results,
        'totalCount': jobNos.length,
        'successCount': results.where((r) => r['success']).length,
        'failCount': results.where((r) => !r['success']).length,
      };
    } catch (e) {
      throw Exception('일괄 상태 변경에 실패했습니다: $e');
    }
  }

  // 여러 채용공고 일괄 삭제
  Future<Map<String, dynamic>> batchDeleteJobs(List<int> jobNos) async {
    try {
      final results = <Map<String, dynamic>>[];

      for (final jobNo in jobNos) {
        try {
          await deleteJobPosting(jobNo);
          results.add({'jobNo': jobNo, 'success': true});
        } catch (e) {
          results.add({
            'jobNo': jobNo,
            'success': false,
            'error': parseErrorMessage(e),
          });
        }
      }

      return {
        'success': true,
        'results': results,
        'totalCount': jobNos.length,
        'successCount': results.where((r) => r['success']).length,
        'failCount': results.where((r) => !r['success']).length,
      };
    } catch (e) {
      throw Exception('일괄 삭제에 실패했습니다: $e');
    }
  }
}
