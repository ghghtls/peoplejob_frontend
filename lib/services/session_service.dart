import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'cache_service.dart';

/// 사용자 세션 관리 서비스
/// 로컬 저장소와 Redis 세션을 연동하여 사용자 상태 관리
class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final CacheService _cache = CacheService();

  // 세션 키 상수
  static const String _userIdKey = 'user_id';
  static const String _sessionIdKey = 'session_id';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userTypeKey = 'user_type';
  static const String _userInfoKey = 'user_info';
  static const String _lastActivityKey = 'last_activity';

  /// 현재 사용자 정보 캐시
  UserSession? _currentSession;

  /// 세션 생성
  Future<void> createSession({
    required int userId,
    required String sessionId,
    required String accessToken,
    required String refreshToken,
    required String userType,
    Map<String, dynamic>? userInfo,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 로컬 저장소에 세션 정보 저장
      await prefs.setInt(_userIdKey, userId);
      await prefs.setString(_sessionIdKey, sessionId);
      await prefs.setString(_accessTokenKey, accessToken);
      await prefs.setString(_refreshTokenKey, refreshToken);
      await prefs.setString(_userTypeKey, userType);
      await prefs.setString(_lastActivityKey, DateTime.now().toIso8601String());

      if (userInfo != null) {
        await prefs.setString(_userInfoKey, jsonEncode(userInfo));
      }

      // 메모리 캐시에 세션 정보 저장
      _currentSession = UserSession(
        userId: userId,
        sessionId: sessionId,
        accessToken: accessToken,
        refreshToken: refreshToken,
        userType: userType,
        userInfo: userInfo,
        lastActivity: DateTime.now(),
      );

      // 앱 캐시에도 저장
      _cache.set(
        'current_session',
        _currentSession,
        duration: const Duration(hours: 24),
      );

      print('Session created for user: $userId');
    } catch (e) {
      print('Failed to create session: $e');
      rethrow;
    }
  }

  /// 현재 세션 정보 조회
  Future<UserSession?> getCurrentSession() async {
    // 메모리 캐시에서 먼저 확인
    if (_currentSession != null && !_currentSession!.isExpired) {
      return _currentSession;
    }

    // 캐시에서 확인
    final cachedSession = _cache.get<UserSession>('current_session');
    if (cachedSession != null && !cachedSession.isExpired) {
      _currentSession = cachedSession;
      return cachedSession;
    }

    // 로컬 저장소에서 복원
    try {
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt(_userIdKey);
      final sessionId = prefs.getString(_sessionIdKey);
      final accessToken = prefs.getString(_accessTokenKey);
      final refreshToken = prefs.getString(_refreshTokenKey);
      final userType = prefs.getString(_userTypeKey);
      final userInfoJson = prefs.getString(_userInfoKey);
      final lastActivityStr = prefs.getString(_lastActivityKey);

      if (userId == null || sessionId == null || accessToken == null) {
        return null;
      }

      Map<String, dynamic>? userInfo;
      if (userInfoJson != null) {
        userInfo = jsonDecode(userInfoJson);
      }

      DateTime? lastActivity;
      if (lastActivityStr != null) {
        lastActivity = DateTime.parse(lastActivityStr);
      }

      _currentSession = UserSession(
        userId: userId,
        sessionId: sessionId,
        accessToken: accessToken,
        refreshToken: refreshToken ?? '',
        userType: userType ?? 'individual',
        userInfo: userInfo,
        lastActivity: lastActivity ?? DateTime.now(),
      );

      return _currentSession;
    } catch (e) {
      print('Failed to get current session: $e');
      return null;
    }
  }

  /// 세션 업데이트
  Future<void> updateSession({
    String? accessToken,
    String? refreshToken,
    Map<String, dynamic>? userInfo,
  }) async {
    final currentSession = await getCurrentSession();
    if (currentSession == null) {
      throw Exception('No active session to update');
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      if (accessToken != null) {
        await prefs.setString(_accessTokenKey, accessToken);
        currentSession.accessToken = accessToken;
      }

      if (refreshToken != null) {
        await prefs.setString(_refreshTokenKey, refreshToken);
        currentSession.refreshToken = refreshToken;
      }

      if (userInfo != null) {
        await prefs.setString(_userInfoKey, jsonEncode(userInfo));
        currentSession.userInfo = userInfo;
      }

      // 마지막 활동 시간 업데이트
      final now = DateTime.now();
      await prefs.setString(_lastActivityKey, now.toIso8601String());
      currentSession.lastActivity = now;

      // 캐시 업데이트
      _cache.set(
        'current_session',
        currentSession,
        duration: const Duration(hours: 24),
      );

      print('Session updated for user: ${currentSession.userId}');
    } catch (e) {
      print('Failed to update session: $e');
      rethrow;
    }
  }

  /// 세션 삭제 (로그아웃)
  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 로컬 저장소에서 세션 정보 삭제
      await prefs.remove(_userIdKey);
      await prefs.remove(_sessionIdKey);
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userTypeKey);
      await prefs.remove(_userInfoKey);
      await prefs.remove(_lastActivityKey);

      // 메모리 캐시 클리어
      _currentSession = null;

      // 앱 캐시에서 세션 관련 데이터 삭제
      _cache.remove('current_session');

      // 사용자 관련 캐시 무효화
      if (_currentSession?.userId != null) {
        _cache.invalidateUserCache(_currentSession!.userId);
      }

      print('Session cleared');
    } catch (e) {
      print('Failed to clear session: $e');
      rethrow;
    }
  }

  /// 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    final session = await getCurrentSession();
    return session != null && !session.isExpired;
  }

  /// 현재 사용자 ID 조회
  Future<int?> getCurrentUserId() async {
    final session = await getCurrentSession();
    return session?.userId;
  }

  /// 현재 사용자 타입 조회
  Future<String?> getCurrentUserType() async {
    final session = await getCurrentSession();
    return session?.userType;
  }

  /// 액세스 토큰 조회
  Future<String?> getAccessToken() async {
    final session = await getCurrentSession();
    return session?.accessToken;
  }

  /// 리프레시 토큰 조회
  Future<String?> getRefreshToken() async {
    final session = await getCurrentSession();
    return session?.refreshToken;
  }

  /// 세션 만료 확인
  Future<bool> isSessionExpired() async {
    final session = await getCurrentSession();
    return session?.isExpired ?? true;
  }

  /// 마지막 활동 시간 업데이트
  Future<void> updateLastActivity() async {
    await updateSession();
  }

  /// 사용자 정보 업데이트
  Future<void> updateUserInfo(Map<String, dynamic> userInfo) async {
    await updateSession(userInfo: userInfo);
  }

  /// 토큰 갱신
  Future<void> refreshTokens(
    String newAccessToken,
    String newRefreshToken,
  ) async {
    await updateSession(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    );
  }
}

/// 사용자 세션 클래스
class UserSession {
  final int userId;
  final String sessionId;
  String accessToken;
  String refreshToken;
  final String userType;
  Map<String, dynamic>? userInfo;
  DateTime lastActivity;

  UserSession({
    required this.userId,
    required this.sessionId,
    required this.accessToken,
    required this.refreshToken,
    required this.userType,
    this.userInfo,
    required this.lastActivity,
  });

  /// 세션 만료 확인 (24시간)
  bool get isExpired {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);
    return difference.inHours >= 24;
  }

  /// 토큰 만료 임박 확인 (1시간 이내)
  bool get isTokenExpiringSoon {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);
    return difference.inHours >= 23;
  }

  /// 사용자가 개인 사용자인지 확인
  bool get isIndividual => userType == 'individual';

  /// 사용자가 기업 사용자인지 확인
  bool get isCompany => userType == 'company';

  /// 사용자가 관리자인지 확인
  bool get isAdmin => userType == 'admin';

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'sessionId': sessionId,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'userType': userType,
      'userInfo': userInfo,
      'lastActivity': lastActivity.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      userId: json['userId'],
      sessionId: json['sessionId'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      userType: json['userType'],
      userInfo: json['userInfo'],
      lastActivity: DateTime.parse(json['lastActivity']),
    );
  }

  @override
  String toString() {
    return 'UserSession(userId: $userId, userType: $userType, '
        'lastActivity: $lastActivity, expired: $isExpired)';
  }
}
