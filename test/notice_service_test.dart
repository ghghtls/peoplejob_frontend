// lib/services/notice_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class NoticeService {
  // ------------------------ 테스트 전용 훅 ------------------------
  static http.Client? _testClient;
  static String? _testBaseUrl;

  /// 테스트에서 모의 http.Client/베이스 URL 주입
  /// 예) NoticeService.setTestOverrides(client: mockHttpClient);
  static void setTestOverrides({http.Client? client, String? baseUrl}) {
    _testClient = client;
    _testBaseUrl = baseUrl;
  }

  /// 테스트 훅 초기화
  static void clearTestOverrides() {
    _testClient = null;
    _testBaseUrl = null;
  }
  // -------------------------------------------------------------

  late final http.Client _client;
  late final String _baseUrl;

  /// 무인자 생성자 유지. (앱에서는 그냥 NoticeService() 사용)
  /// 테스트에서는 setTestOverrides로 클라이언트를 주입한 뒤 생성하세요.
  NoticeService({
    http.Client? client,
    String baseUrl = 'http://localhost:8888',
  }) {
    _client = client ?? _testClient ?? http.Client();
    _baseUrl = _testBaseUrl ?? baseUrl;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = Uri.parse('$_baseUrl$path');
    if (query == null || query.isEmpty) return base;
    return base.replace(queryParameters: {...base.queryParameters, ...query});
  }

  List<Map<String, dynamic>> _asListOfMap(String body) {
    final decoded = jsonDecode(body) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> _asMap(String body) {
    return (jsonDecode(body) as Map).cast<String, dynamic>();
  }

  // 모든 공지사항
  Future<List<Map<String, dynamic>>> getAllNotices() async {
    final res = await _client.get(_uri('/api/notice'));
    if (res.statusCode == 200) return _asListOfMap(res.body);
    throw Exception('공지사항 목록을 불러오는데 실패했습니다: ${res.statusCode}');
  }

  // 단건 조회 (404면 null)
  Future<Map<String, dynamic>?> getNoticeById(int noticeId) async {
    final res = await _client.get(_uri('/api/notice/$noticeId'));
    if (res.statusCode == 200) return _asMap(res.body);
    if (res.statusCode == 404) return null;
    throw Exception('공지사항 상세 조회 실패: ${res.statusCode}');
  }

  // 중요 공지
  Future<List<Map<String, dynamic>>> getImportantNotices() async {
    final res = await _client.get(_uri('/api/notice/important'));
    if (res.statusCode == 200) return _asListOfMap(res.body);
    throw Exception('중요 공지사항 조회 실패: ${res.statusCode}');
  }

  // 최신 공지 (limit 사용)
  Future<List<Map<String, dynamic>>> getRecentNotices({int limit = 10}) async {
    final res = await _client.get(
      _uri('/api/notice/recent', {'limit': '$limit'}),
    );
    if (res.statusCode == 200) return _asListOfMap(res.body);
    throw Exception('최신 공지사항 조회 실패: ${res.statusCode}');
  }

  // 검색 (빈 키워드는 네트워크 호출하지 않고 빈 배열 반환)
  Future<List<Map<String, dynamic>>> searchNotices(String keyword) async {
    if (keyword.trim().isEmpty) return <Map<String, dynamic>>[];
    final res = await _client.get(
      _uri('/api/notice/search', {'keyword': keyword}),
    );
    if (res.statusCode == 200) return _asListOfMap(res.body);
    throw Exception('공지사항 검색 실패: ${res.statusCode}');
  }

  // 조회수 증가 (200이면 true, 그 외 false)
  Future<bool> incrementViewCount(int noticeId) async {
    final res = await _client.patch(
      _uri('/api/notice/$noticeId/view'),
      headers: {'Content-Type': 'application/json'},
    );
    return res.statusCode == 200;
  }

  // 페이지네이션
  Future<Map<String, dynamic>?> getNoticesWithPagination({
    int page = 0,
    int size = 10,
  }) async {
    final res = await _client.get(
      _uri('/api/notice', {'page': '$page', 'size': '$size'}),
    );
    if (res.statusCode == 200) return _asMap(res.body);
    throw Exception('페이지별 공지사항 조회 실패: ${res.statusCode}');
  }
}
