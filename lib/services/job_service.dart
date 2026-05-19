// lib/services/job_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/model/job.dart';
import 'config/api_config.dart';

class JobService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  JobService() {
    _dio = Dio(BaseOptions(
      baseUrl: dotenv.env['API_URL'] ?? ApiConfig.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ));
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await _storage.read(key: 'jwt');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {
            // storage unavailable — proceed without token
          }
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


  Future<List<dynamic>> getAllJobs({int size = 50}) async {
    try {
      final response = await _dio.get('/api/jobs',
          queryParameters: {'status': 'published', 'size': size});
      if (response.data is Map) {
        return response.data['content'] ?? [];
      }
      return response.data is List ? response.data : [];
    } catch (e) {
      throw Exception('채용공고 목록을 불러오는데 실패했습니다: $e');
    }
  }

  Future<Map<String, dynamic>> getJobDetail(int jobId) async {
    try {
      final response = await _dio.get('/api/jobs/$jobId');
      return response.data;
    } catch (e) {
      throw Exception('채용공고 상세 정보를 불러오는데 실패했습니다: $e');
    }
  }

  Future<bool> createJob(Map<String, dynamic> jobData) async {
    try {
      await _dio.post('/api/jobs', data: jobData);
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.message ?? '알 수 없는 오류';
      throw Exception('채용공고 등록 실패: $msg');
    } catch (e) {
      throw Exception('채용공고 등록 실패: $e');
    }
  }

  Future<bool> updateJob(int jobId, Map<String, dynamic> jobData) async {
    try {
      await _dio.put('/api/jobs/$jobId', data: jobData);
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.message ?? '알 수 없는 오류';
      throw Exception('채용공고 수정 실패: $msg');
    } catch (e) {
      throw Exception('채용공고 수정 실패: $e');
    }
  }

  Future<bool> deleteJob(int jobId) async {
    try {
      await _dio.delete('/api/jobs/$jobId');
      return true;
    } catch (e) {
      throw Exception('채용공고 삭제에 실패했습니다: $e');
    }
  }

  Future<List<dynamic>> searchJobs(String keyword) async {
    try {
      final response = await _dio.get(
        '/api/jobs/search',
        queryParameters: {'keyword': keyword},
      );
      // 백엔드가 Page<JobopeningDTO> 반환 → content 추출
      if (response.data is Map) {
        return response.data['content'] ?? [];
      }
      return response.data is List ? response.data : [];
    } catch (e) {
      throw Exception('채용공고 검색에 실패했습니다: $e');
    }
  }


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

  Future<Map<String, dynamic>> getPublishedJobs({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/jobs',
        queryParameters: {'status': 'published', 'page': page, 'size': size},
      );

      // 응답 데이터가 null이거나 예상 형식이 아닌 경우 처리
      if (response.data == null) {
        return {
          'success': true,
          'jobs': [],
          'totalElements': 0,
          'totalPages': 0,
          'currentPage': 0,
          'hasNext': false,
        };
      }

      return {
        'success': true,
        'jobs': response.data['content'] ?? [],
        'totalElements': response.data['totalElements'] ?? 0,
        'totalPages': response.data['totalPages'] ?? 0,
        'currentPage': response.data['number'] ?? 0,
        'hasNext': response.data['last'] != null ? !response.data['last'] : false,
      };
    } on DioException catch (e) {
      // 네트워크 오류는 로그만 남기고 빈 결과 반환
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        debugPrint('채용공고 목록 조회 실패 - 연결 오류: ${e.message}');
        return {
          'success': false,
          'jobs': [],
          'totalElements': 0,
          'totalPages': 0,
          'currentPage': 0,
          'hasNext': false,
        };
      }
      throw Exception('채용공고 목록 조회에 실패했습니다: $e');
    } catch (e) {
      throw Exception('채용공고 목록 조회에 실패했습니다: $e');
    }
  }

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

  Future<Map<String, dynamic>> getUserJobStatusCounts(int userNo) async {
    try {
      final response = await _dio.get('/api/jobs/user/$userNo/status-counts');
      return {'success': true, 'counts': response.data};
    } catch (e) {
      throw Exception('상태별 개수 조회에 실패했습니다: $e');
    }
  }

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

  Future<Map<String, dynamic>> deleteJobPosting(int jobNo) async {
    try {
      final response = await _dio.delete('/api/jobs/$jobNo');
      return {'success': true, 'message': response.data['message']};
    } catch (e) {
      throw Exception('채용공고 삭제에 실패했습니다: $e');
    }
  }

  Future<Job> getJobPosting(int jobNo) async {
    try {
      final response = await _dio.get('/api/jobs/$jobNo');
      return Job.fromJson(response.data);
    } catch (e) {
      throw Exception('채용공고 조회에 실패했습니다: $e');
    }
  }


  Future<void> increaseViewCount(int jobId) async {
    try {
      await _dio.post('/api/jobs/$jobId/view');
    } catch (e) {
      debugPrint('조회수 증가 실패: $e');
    }
  }

  Future<Map<String, dynamic>> expireOverdueJobs() async {
    try {
      final response = await _dio.post('/api/jobs/expire-overdue');
      return {'success': true, 'message': response.data['message']};
    } catch (e) {
      throw Exception('자동 마감 처리에 실패했습니다: $e');
    }
  }

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


  Future<int?> getCurrentUserNo() async {
    try {
      final userNoStr = await _storage.read(key: 'userNo');
      return userNoStr != null ? int.tryParse(userNoStr) : null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isTokenValid() async {
    try {
      final token = await _storage.read(key: 'jwt');
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

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

  T? safeGet<T>(Map<String, dynamic>? data, String key, [T? defaultValue]) {
    try {
      return data?[key] as T? ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

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



