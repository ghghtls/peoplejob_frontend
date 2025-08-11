import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BoardService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8888'));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  BoardService() {
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

  // 게시글 전체 조회
  Future<List<dynamic>> getAllBoards() async {
    try {
      final response = await _dio.get('/api/board');
      return response.data;
    } catch (e) {
      throw Exception('게시글 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 카테고리별 게시글 조회
  Future<List<dynamic>> getBoardsByCategory(String category) async {
    try {
      final response = await _dio.get('/api/board/category/$category');
      return response.data;
    } catch (e) {
      throw Exception('게시글 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 게시글 상세 조회
  Future<Map<String, dynamic>> getBoardDetail(int boardNo) async {
    try {
      final response = await _dio.get('/api/board/$boardNo');
      return response.data;
    } catch (e) {
      throw Exception('게시글 상세 정보를 불러오는데 실패했습니다: $e');
    }
  }

  // 게시글 등록
  Future<bool> createBoard(Map<String, dynamic> boardData) async {
    try {
      await _dio.post('/api/board', data: boardData);
      return true;
    } catch (e) {
      throw Exception('게시글 등록에 실패했습니다: $e');
    }
  }

  // 게시글 수정
  Future<bool> updateBoard(int boardNo, Map<String, dynamic> boardData) async {
    try {
      await _dio.put('/api/board/$boardNo', data: boardData);
      return true;
    } catch (e) {
      throw Exception('게시글 수정에 실패했습니다: $e');
    }
  }

  // 게시글 삭제
  Future<bool> deleteBoard(int boardNo) async {
    try {
      await _dio.delete('/api/board/$boardNo');
      return true;
    } catch (e) {
      throw Exception('게시글 삭제에 실패했습니다: $e');
    }
  }

  // 게시글 검색
  Future<List<dynamic>> searchBoards(String keyword) async {
    try {
      final response = await _dio.get('/api/board/search?keyword=$keyword');
      return response.data;
    } catch (e) {
      throw Exception('게시글 검색에 실패했습니다: $e');
    }
  }

  // 조회수 증가
  Future<void> increaseViewCount(int boardNo) async {
    try {
      await _dio.patch('/api/board/$boardNo/view');
    } catch (e) {
      // 조회수 증가 실패는 무시
    }
  }
}
