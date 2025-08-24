import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BoardService {
  // ---------- 테스트 훅 ----------
  static Dio? _testDio;
  static FlutterSecureStorage? _testStorage;

  /// 테스트에서 모의 의존성 주입용 훅
  static void setTestOverrides({Dio? dio, FlutterSecureStorage? storage}) {
    _testDio = dio;
    _testStorage = storage;
  }

  /// 테스트 훅 해제
  static void resetTestOverrides() {
    _testDio = null;
    _testStorage = null;
  }

  // 각 Dio 인스턴스에 인터셉터가 중복으로 붙는 걸 막기 위한 태그
  static final Expando<bool> _interceptorAdded = Expando<bool>(
    'board_dio_auth_interceptor',
  );

  // ---------- 실제 필드 ----------
  late final Dio _dio;
  late final FlutterSecureStorage _storage;

  BoardService() {
    _dio = _testDio ?? Dio(BaseOptions(baseUrl: 'http://localhost:8888'));
    _storage = _testStorage ?? const FlutterSecureStorage();

    // JWT 토큰을 자동으로 헤더에 추가하는 인터셉터(중복 추가 방지)
    if (_interceptorAdded[_dio] != true) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            try {
              final token = await _storage.read(key: 'jwt');
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            } catch (_) {
              // 스토리지 접근 실패 시에도 요청은 진행
            }
            handler.next(options);
          },
        ),
      );
      _interceptorAdded[_dio] = true;
    }
  }

  // 게시글 전체 조회
  Future<List<dynamic>> getAllBoards() async {
    try {
      final response = await _dio.get('/api/board');
      return (response.data as List).cast<dynamic>();
    } catch (e) {
      throw Exception('게시글 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 카테고리별 게시글 조회
  Future<List<dynamic>> getBoardsByCategory(String category) async {
    try {
      final response = await _dio.get('/api/board/category/$category');
      return (response.data as List).cast<dynamic>();
    } catch (e) {
      throw Exception('게시글 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 게시글 상세 조회
  Future<Map<String, dynamic>> getBoardDetail(int boardNo) async {
    try {
      final response = await _dio.get('/api/board/$boardNo');
      return (response.data as Map).cast<String, dynamic>();
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
      return (response.data as List).cast<dynamic>();
    } catch (e) {
      throw Exception('게시글 검색에 실패했습니다: $e');
    }
  }

  // 조회수 증가 (실패는 무시)
  Future<void> increaseViewCount(int boardNo) async {
    try {
      await _dio.patch('/api/board/$boardNo/view');
    } catch (_) {
      // 조회수 증가 실패는 무시
    }
  }
}
