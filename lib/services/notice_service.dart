import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/model/notice.dart';

class NoticeService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8888'));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  NoticeService() {
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

  // 공지사항 전체 목록 조회
  Future<List<Notice>> getAllNotices() async {
    try {
      final response = await _dio.get('/api/notice');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Notice.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('공지사항 목록 조회 실패: $e');
      throw Exception('공지사항 목록을 불러오는데 실패했습니다.');
    }
  }

  // 공지사항 페이징 조회
  Future<Map<String, dynamic>> getNoticesWithPaging({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/notice/page',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'notices':
              (data['content'] as List)
                  .map((json) => Notice.fromJson(json))
                  .toList(),
          'totalElements': data['totalElements'],
          'totalPages': data['totalPages'],
          'currentPage': data['number'],
          'hasNext': !data['last'],
          'hasPrevious': !data['first'],
        };
      }
      return {'notices': [], 'totalElements': 0, 'totalPages': 0};
    } catch (e) {
      print('공지사항 페이징 조회 실패: $e');
      throw Exception('공지사항 목록을 불러오는데 실패했습니다.');
    }
  }

  // 공지사항 상세 조회
  Future<Notice?> getNoticeDetail(int noticeId) async {
    try {
      final response = await _dio.get('/api/notice/$noticeId');
      if (response.statusCode == 200) {
        return Notice.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('공지사항 상세 조회 실패: $e');
      throw Exception('공지사항 상세 정보를 불러오는데 실패했습니다.');
    }
  }

  // 중요 공지사항 조회
  Future<List<Notice>> getImportantNotices() async {
    try {
      final response = await _dio.get('/api/notice/important');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Notice.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('중요 공지사항 조회 실패: $e');
      throw Exception('중요 공지사항을 불러오는데 실패했습니다.');
    }
  }

  // 공지사항 검색
  Future<Map<String, dynamic>> searchNotices({
    required String keyword,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/notice/search',
        queryParameters: {'keyword': keyword, 'page': page, 'size': size},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'notices':
              (data['content'] as List)
                  .map((json) => Notice.fromJson(json))
                  .toList(),
          'totalElements': data['totalElements'],
          'totalPages': data['totalPages'],
          'currentPage': data['number'],
          'hasNext': !data['last'],
          'hasPrevious': !data['first'],
        };
      }
      return {'notices': [], 'totalElements': 0, 'totalPages': 0};
    } catch (e) {
      print('공지사항 검색 실패: $e');
      throw Exception('공지사항 검색에 실패했습니다.');
    }
  }

  // 최근 공지사항 조회 (메인 페이지용)
  Future<List<Notice>> getRecentNotices({int limit = 5}) async {
    try {
      final response = await _dio.get(
        '/api/notice/recent',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Notice.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('최근 공지사항 조회 실패: $e');
      throw Exception('최근 공지사항을 불러오는데 실패했습니다.');
    }
  }

  // === 관리자용 기능 ===

  // 공지사항 등록 (관리자용)
  Future<int?> createNotice(Notice notice) async {
    try {
      final response = await _dio.post('/api/notice', data: notice.toJson());

      if (response.statusCode == 200) {
        return response.data['noticeId'] as int?;
      }
      return null;
    } catch (e) {
      print('공지사항 등록 실패: $e');
      throw Exception('공지사항 등록에 실패했습니다.');
    }
  }

  // 공지사항 수정 (관리자용)
  Future<bool> updateNotice(Notice notice) async {
    try {
      final response = await _dio.put(
        '/api/notice/${notice.noticeNo}',
        data: notice.toJson(),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('공지사항 수정 실패: $e');
      throw Exception('공지사항 수정에 실패했습니다.');
    }
  }

  // 공지사항 삭제 (관리자용)
  Future<bool> deleteNotice(int noticeId) async {
    try {
      final response = await _dio.delete('/api/notice/$noticeId');
      return response.statusCode == 200;
    } catch (e) {
      print('공지사항 삭제 실패: $e');
      throw Exception('공지사항 삭제에 실패했습니다.');
    }
  }

  // 관리자용: 모든 공지사항 조회 (비활성화 포함)
  Future<Map<String, dynamic>> getAllNoticesForAdmin({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/notice/admin/all',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'notices':
              (data['content'] as List)
                  .map((json) => Notice.fromJson(json))
                  .toList(),
          'totalElements': data['totalElements'],
          'totalPages': data['totalPages'],
          'currentPage': data['number'],
          'hasNext': !data['last'],
          'hasPrevious': !data['first'],
        };
      }
      return {'notices': [], 'totalElements': 0, 'totalPages': 0};
    } catch (e) {
      print('관리자용 공지사항 조회 실패: $e');
      throw Exception('관리자용 공지사항 목록을 불러오는데 실패했습니다.');
    }
  }

  // 공지사항 활성화/비활성화 토글 (관리자용)
  Future<bool> toggleNoticeStatus(int noticeId) async {
    try {
      final response = await _dio.put('/api/notice/$noticeId/toggle-status');
      return response.statusCode == 200;
    } catch (e) {
      print('공지사항 상태 변경 실패: $e');
      throw Exception('공지사항 상태 변경에 실패했습니다.');
    }
  }

  // 중요 공지 설정/해제 토글 (관리자용)
  Future<bool> toggleImportantStatus(int noticeId) async {
    try {
      final response = await _dio.put('/api/notice/$noticeId/toggle-important');
      return response.statusCode == 200;
    } catch (e) {
      print('공지사항 중요도 변경 실패: $e');
      throw Exception('공지사항 중요도 변경에 실패했습니다.');
    }
  }

  // 공지사항 물리 삭제 (관리자용)
  Future<bool> permanentDeleteNotice(int noticeId) async {
    try {
      final response = await _dio.delete(
        '/api/notice/admin/$noticeId/permanent',
      );
      return response.statusCode == 200;
    } catch (e) {
      print('공지사항 완전 삭제 실패: $e');
      throw Exception('공지사항 완전 삭제에 실패했습니다.');
    }
  }

  // 공지사항 통계 조회 (관리자용)
  Future<Map<String, dynamic>?> getNoticeStatistics() async {
    try {
      final response = await _dio.get('/api/notice/admin/statistics');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('공지사항 통계 조회 실패: $e');
      throw Exception('공지사항 통계 조회에 실패했습니다.');
    }
  }
}
