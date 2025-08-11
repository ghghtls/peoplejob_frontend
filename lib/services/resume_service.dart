import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ResumeService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8888'));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ResumeService() {
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

  // 이력서 전체 조회
  Future<List<dynamic>> getAllResumes() async {
    try {
      final response = await _dio.get('/api/resume');
      return response.data;
    } catch (e) {
      throw Exception('이력서 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 특정 사용자의 이력서 조회
  Future<List<dynamic>> getUserResumes(int userNo) async {
    try {
      final response = await _dio.get('/api/resume/user/$userNo');
      return response.data;
    } catch (e) {
      throw Exception('사용자 이력서 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 이력서 상세 조회
  Future<Map<String, dynamic>> getResumeDetail(int resumeId) async {
    try {
      final response = await _dio.get('/api/resume/$resumeId');
      return response.data;
    } catch (e) {
      throw Exception('이력서 상세 정보를 불러오는데 실패했습니다: $e');
    }
  }

  // 이력서 등록
  Future<bool> createResume(Map<String, dynamic> resumeData) async {
    try {
      await _dio.post('/api/resume', data: resumeData);
      return true;
    } catch (e) {
      throw Exception('이력서 등록에 실패했습니다: $e');
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

  // 이력서 검색
  Future<List<dynamic>> searchResumes(String keyword) async {
    try {
      final response = await _dio.get('/api/resume/search?keyword=$keyword');
      return response.data;
    } catch (e) {
      throw Exception('이력서 검색에 실패했습니다: $e');
    }
  }

  // 희망 직종별 이력서 조회
  Future<List<dynamic>> getResumesByJobType(String jobType) async {
    try {
      final response = await _dio.get('/api/resume/jobtype/$jobType');
      return response.data;
    } catch (e) {
      throw Exception('직종별 이력서 조회에 실패했습니다: $e');
    }
  }

  // 희망 지역별 이력서 조회
  Future<List<dynamic>> getResumesByLocation(String location) async {
    try {
      final response = await _dio.get('/api/resume/location/$location');
      return response.data;
    } catch (e) {
      throw Exception('지역별 이력서 조회에 실패했습니다: $e');
    }
  }
}
