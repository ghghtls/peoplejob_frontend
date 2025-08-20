import 'dart:convert';
import 'package:http/http.dart' as http;

/// Redis 캐시와 연동하는 클라이언트 사이드 캐시 서비스
/// 백엔드의 Redis 캐시 시스템과 협력하여 데이터 캐싱 최적화
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // 로컬 메모리 캐시 (앱 세션 동안 유지)
  final Map<String, CacheItem> _localCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  // 캐시 설정
  static const Duration defaultCacheDuration = Duration(minutes: 10);
  static const Duration shortCacheDuration = Duration(minutes: 5);
  static const Duration longCacheDuration = Duration(hours: 1);

  /// 캐시에서 데이터 조회
  T? get<T>(String key) {
    try {
      final cacheItem = _localCache[key];
      if (cacheItem == null) {
        return null;
      }

      // 만료 확인
      if (cacheItem.isExpired) {
        remove(key);
        return null;
      }

      return cacheItem.data as T?;
    } catch (e) {
      print('Cache get error for key $key: $e');
      return null;
    }
  }

  /// 캐시에 데이터 저장
  void set<T>(String key, T data, {Duration? duration}) {
    try {
      final cacheDuration = duration ?? defaultCacheDuration;
      final expiryTime = DateTime.now().add(cacheDuration);

      _localCache[key] = CacheItem(data: data, expiryTime: expiryTime);

      _cacheTimestamps[key] = DateTime.now();

      print('Cache set: $key (expires in ${cacheDuration.inMinutes} minutes)');
    } catch (e) {
      print('Cache set error for key $key: $e');
    }
  }

  /// 캐시에서 데이터 제거
  void remove(String key) {
    _localCache.remove(key);
    _cacheTimestamps.remove(key);
  }

  /// 모든 캐시 제거
  void clear() {
    _localCache.clear();
    _cacheTimestamps.clear();
  }

  /// 만료된 캐시 항목들 정리
  void cleanupExpired() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _localCache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      print('Cleaned up ${expiredKeys.length} expired cache items');
    }
  }

  /// 패턴으로 캐시 키 제거
  void removeByPattern(String pattern) {
    final keysToRemove =
        _localCache.keys.where((key) => key.contains(pattern)).toList();

    for (final key in keysToRemove) {
      remove(key);
    }
  }

  /// 캐시 상태 정보 조회
  CacheStats getStats() {
    cleanupExpired(); // 통계 조회 전 정리

    return CacheStats(
      totalItems: _localCache.length,
      totalSize: _calculateCacheSize(),
      oldestItem: _getOldestCacheTime(),
      newestItem: _getNewestCacheTime(),
    );
  }

  /// 캐시 크기 계산 (근사치)
  int _calculateCacheSize() {
    int size = 0;
    for (final item in _localCache.values) {
      try {
        // JSON으로 직렬화하여 크기 측정
        final jsonString = jsonEncode(item.data);
        size += jsonString.length;
      } catch (e) {
        size += 100; // 직렬화 불가능한 경우 기본 크기
      }
    }
    return size;
  }

  /// 가장 오래된 캐시 시간 조회
  DateTime? _getOldestCacheTime() {
    if (_cacheTimestamps.isEmpty) return null;

    return _cacheTimestamps.values.reduce((a, b) => a.isBefore(b) ? a : b);
  }

  /// 가장 최신 캐시 시간 조회
  DateTime? _getNewestCacheTime() {
    if (_cacheTimestamps.isEmpty) return null;

    return _cacheTimestamps.values.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// 사용자별 캐시 무효화
  void invalidateUserCache(int userId) {
    removeByPattern('user:$userId');
    removeByPattern('profile:$userId');
    removeByPattern('resume:$userId');
    removeByPattern('apply:$userId');
    removeByPattern('scrap:$userId');
  }

  /// 공지사항 캐시 무효화
  void invalidateNoticeCache() {
    removeByPattern('notice:');
  }

  /// 채용공고 캐시 무효화
  void invalidateJobCache() {
    removeByPattern('job:');
    removeByPattern('joblist:');
  }

  /// 게시판 캐시 무효화
  void invalidateBoardCache() {
    removeByPattern('board:');
  }
}

/// 캐시 아이템 클래스
class CacheItem {
  final dynamic data;
  final DateTime expiryTime;

  CacheItem({required this.data, required this.expiryTime});

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

/// 캐시 통계 클래스
class CacheStats {
  final int totalItems;
  final int totalSize;
  final DateTime? oldestItem;
  final DateTime? newestItem;

  CacheStats({
    required this.totalItems,
    required this.totalSize,
    this.oldestItem,
    this.newestItem,
  });

  @override
  String toString() {
    return 'CacheStats(items: $totalItems, size: ${totalSize}B, '
        'oldest: $oldestItem, newest: $newestItem)';
  }
}

/// 캐시 키 생성 헬퍼 클래스
class CacheKeys {
  static String userProfile(int userId) => 'user:profile:$userId';
  static String userResumes(int userId) => 'user:resumes:$userId';
  static String userApplies(int userId) => 'user:applies:$userId';
  static String userScraps(int userId) => 'user:scraps:$userId';

  static String jobDetail(int jobId) => 'job:detail:$jobId';
  static String jobList(String filter) => 'job:list:$filter';
  static String jobSearch(String query) => 'job:search:$query';

  static String noticeList() => 'notice:list';
  static String noticeDetail(int noticeId) => 'notice:detail:$noticeId';

  static String boardList(String category) => 'board:list:$category';
  static String boardDetail(int boardId) => 'board:detail:$boardId';

  static String companyInfo(int companyId) => 'company:info:$companyId';
}

/// 캐시 데코레이터 - API 호출을 캐시로 래핑
class CachedApiCall {
  static final CacheService _cache = CacheService();

  /// GET 요청에 캐시 적용
  static Future<T?> get<T>({
    required String cacheKey,
    required Future<T> Function() apiCall,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    // 강제 새로고침이 아닌 경우 캐시 확인
    if (!forceRefresh) {
      final cachedData = _cache.get<T>(cacheKey);
      if (cachedData != null) {
        print('Cache hit: $cacheKey');
        return cachedData;
      }
    }

    try {
      // API 호출
      print('Cache miss, calling API: $cacheKey');
      final data = await apiCall();

      // 캐시에 저장
      _cache.set(cacheKey, data, duration: cacheDuration);

      return data;
    } catch (e) {
      print('API call failed for $cacheKey: $e');
      rethrow;
    }
  }

  /// POST/PUT/DELETE 후 관련 캐시 무효화
  static Future<T> mutate<T>({
    required Future<T> Function() apiCall,
    required List<String> invalidatePatterns,
  }) async {
    try {
      // API 호출
      final result = await apiCall();

      // 관련 캐시 무효화
      for (final pattern in invalidatePatterns) {
        _cache.removeByPattern(pattern);
      }

      return result;
    } catch (e) {
      print('Mutate API call failed: $e');
      rethrow;
    }
  }
}
