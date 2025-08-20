/// API 설정 클래스
/// 백엔드 Redis 캐시 시스템과 연동하는 설정들
class ApiConfig {
  // 기본 API URL
  static const String baseUrl = 'http://localhost:9000';
  static const String productionUrl = 'https://api.peoplejob.com';

  // 개발/운영 환경 구분
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  // 현재 사용할 API URL
  static String get apiUrl => isProduction ? productionUrl : baseUrl;

  // API 엔드포인트
  static const String authEndpoint = '/api/auth';
  static const String userEndpoint = '/api/users';
  static const String jobEndpoint = '/api/jobs';
  static const String resumeEndpoint = '/api/resumes';
  static const String applyEndpoint = '/api/applies';
  static const String noticeEndpoint = '/api/notices';
  static const String boardEndpoint = '/api/boards';
  static const String inquiryEndpoint = '/api/inquiries';
  static const String fileEndpoint = '/api/files';
  static const String adminEndpoint = '/api/admin';
  static const String paymentEndpoint = '/api/payments';
  static const String scrapEndpoint = '/api/scraps';
  static const String emailEndpoint = '/api/email';

  // 헬스체크 및 모니터링
  static const String healthEndpoint = '/actuator/health';
  static const String metricsEndpoint = '/actuator/metrics';

  // 캐시 설정
  static const Duration defaultCacheTimeout = Duration(minutes: 10);
  static const Duration shortCacheTimeout = Duration(minutes: 5);
  static const Duration longCacheTimeout = Duration(hours: 1);

  // Rate Limiting 설정 (클라이언트 사이드)
  static const int maxApiCallsPerMinute = 60;
  static const int maxLoginAttemptsPerHour = 5;
  static const Duration loginCooldownPeriod = Duration(minutes: 15);

  // 토큰 관련 설정
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  static const Duration sessionTimeout = Duration(hours: 24);

  // 파일 업로드 설정
  static const int maxFileSize = 20 * 1024 * 1024; // 20MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = [
    'pdf',
    'doc',
    'docx',
    'hwp',
  ];

  // 페이징 설정
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // 검색 설정
  static const int minSearchLength = 2;
  static const Duration searchDebounceDelay = Duration(milliseconds: 500);

  // 네트워크 타임아웃 설정
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // 재시도 설정
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Redis 캐시 키 패턴
  static const Map<String, String> cacheKeyPatterns = {
    'user_profile': 'user:profile:',
    'user_resumes': 'user:resumes:',
    'user_applies': 'user:applies:',
    'user_scraps': 'user:scraps:',
    'job_detail': 'job:detail:',
    'job_list': 'job:list:',
    'job_search': 'job:search:',
    'notice_list': 'notice:list',
    'notice_detail': 'notice:detail:',
    'board_list': 'board:list:',
    'board_detail': 'board:detail:',
    'company_info': 'company:info:',
  };

  // 에러 메시지
  static const Map<String, String> errorMessages = {
    'network_error': '네트워크 연결을 확인해주세요.',
    'server_error': '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
    'unauthorized': '로그인이 필요합니다.',
    'forbidden': '접근 권한이 없습니다.',
    'not_found': '요청하신 정보를 찾을 수 없습니다.',
    'rate_limit': '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.',
    'token_expired': '로그인이 만료되었습니다. 다시 로그인해주세요.',
    'cache_error': '캐시 오류가 발생했습니다.',
    'validation_error': '입력 정보를 확인해주세요.',
  };

  // HTTP 헤더
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'PeopleJob-Flutter/${getAppVersion()}',
  };

  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };

  // 앱 버전 정보 (실제로는 package_info_plus에서 가져와야 함)
  static String getAppVersion() {
    return '1.0.0'; // 실제 구현에서는 PackageInfo.fromPlatform() 사용
  }

  // 환경별 설정
  static Map<String, dynamic> get environmentConfig => {
    'isDevelopment': !isProduction,
    'isProduction': isProduction,
    'apiUrl': apiUrl,
    'enableLogging': !isProduction,
    'enableAnalytics': isProduction,
    'enableCrashReporting': isProduction,
  };

  // Redis 연동 관련 설정
  static const Map<String, Duration> redisCacheDurations = {
    'user_session': Duration(hours: 24),
    'email_verification': Duration(minutes: 30),
    'password_reset': Duration(minutes: 15),
    'job_list': Duration(minutes: 10),
    'notice_list': Duration(minutes: 30),
    'company_info': Duration(hours: 2),
  };

  // API 응답 상태 코드
  static const Map<int, String> statusCodeMessages = {
    200: 'Success',
    201: 'Created',
    400: 'Bad Request',
    401: 'Unauthorized',
    403: 'Forbidden',
    404: 'Not Found',
    409: 'Conflict',
    422: 'Unprocessable Entity',
    429: 'Too Many Requests',
    500: 'Internal Server Error',
    502: 'Bad Gateway',
    503: 'Service Unavailable',
  };
}

/// 앱 환경 설정
enum AppEnvironment { development, staging, production }

/// 현재 앱 환경
class EnvironmentConfig {
  static AppEnvironment get current {
    if (ApiConfig.isProduction) {
      return AppEnvironment.production;
    }
    return AppEnvironment.development;
  }

  static bool get isDevelopment => current == AppEnvironment.development;
  static bool get isStaging => current == AppEnvironment.staging;
  static bool get isProduction => current == AppEnvironment.production;
}
