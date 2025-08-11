import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
      ),
    );
  }

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
}
