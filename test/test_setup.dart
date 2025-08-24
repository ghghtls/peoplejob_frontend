import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 테스트 공용 초기화 유틸
class TestSetup {
  /// 등록된 채널(중복 등록 방지용)
  static final Map<String, MethodChannel> _channels = {};

  /// 중복 초기화 방지
  static bool _initialized = false;

  /// 공통: defaultBinaryMessenger
  static TestDefaultBinaryMessenger get _messenger =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  /// 헬퍼: 채널 등록(이미 있으면 핸들러만 교체)
  static void _mockChannel(
    String name,
    Future<dynamic> Function(MethodCall) fn,
  ) {
    final ch = _channels.putIfAbsent(name, () => MethodChannel(name));
    _messenger.setMockMethodCallHandler(ch, fn);
  }

  /// 테스트 환경 초기 설정 (각 test 파일의 setUpAll에서 1회 호출 권장)
  static Future<void> setupTestEnvironment() async {
    if (_initialized) return; // 여러 번 불려도 1회만 세팅
    _initialized = true;

    // 바인딩/메신저 초기화
    TestWidgetsFlutterBinding.ensureInitialized();

    // SharedPreferences 메모리 초기화
    SharedPreferences.setMockInitialValues({});

    // 플랫폼 채널 모의 설정
    _setupPlatformChannels();

    // (필요 시) 환경 변수/상수 세팅
    _setupEnvironmentVariables();
  }

  /* --------------------------- 플랫폼 채널 모의 --------------------------- */

  static void _setupPlatformChannels() {
    // SystemChrome
    _mockChannel('plugins.flutter.io/system_chrome', (call) async {
      switch (call.method) {
        case 'SystemChrome.setApplicationSwitcherDescription':
        case 'SystemChrome.setSystemUIOverlayStyle':
          return null;
        default:
          return null;
      }
    });

    // File Picker
    _mockChannel('miguelruivo.flutter.plugins.filepicker', (call) async {
      // 필요 시 메서드별 분기
      return null;
    });

    // Image Picker
    _mockChannel('plugins.flutter.io/image_picker', (call) async {
      if (call.method == 'pickImage') {
        // 실제론 경로(String) 또는 null을 반환. 테스트에선 null로 충분.
        return null;
      }
      return null;
    });

    // URL Launcher
    _mockChannel('plugins.flutter.io/url_launcher', (call) async {
      switch (call.method) {
        case 'canLaunch':
          return true;
        case 'launch':
          return true;
        default:
          return false;
      }
    });

    // Flutter Secure Storage
    _mockChannel('plugins.it_nomads.com/flutter_secure_storage', (call) async {
      // read/write/delete/deleteAll 등 모두 no-op
      return null;
    });

    // Connectivity Plus
    _mockChannel('dev.fluttercommunity.plus/connectivity', (call) async {
      if (call.method == 'check') return 'wifi'; // 'mobile' / 'none' 가능
      return null;
    });

    // Permission Handler
    _mockChannel('flutter.baseflow.com/permissions/methods', (call) async {
      switch (call.method) {
        case 'checkPermissionStatus':
          return 1; // granted
        case 'requestPermissions':
          return {0: 1}; // granted
        default:
          return null;
      }
    });

    // Path Provider
    _mockChannel('plugins.flutter.io/path_provider', (call) async {
      switch (call.method) {
        case 'getTemporaryDirectory':
          return '/tmp';
        case 'getApplicationDocumentsDirectory':
        case 'getDocumentsDirectory': // 일부 플러그인에서 사용
          return '/documents';
        case 'getExternalStorageDirectory':
          return '/external';
        case 'getApplicationSupportDirectory':
          return '/support';
        default:
          return null;
      }
    });

    // Device Info (device_info or device_info_plus 사용 시 대비)
    _mockChannel('plugins.flutter.io/device_info', (call) async {
      if (call.method == 'getAndroidDeviceInfo') {
        return {
          'version': {'sdkInt': 29},
          'brand': 'TestBrand',
          'model': 'TestModel',
        };
      }
      if (call.method == 'getIosDeviceInfo') {
        return {
          'systemVersion': '14.0',
          'model': 'iPhone',
          'name': 'Test iPhone',
        };
      }
      return null;
    });

    // Firebase Core (필요 시)
    _mockChannel('plugins.flutter.io/firebase_core', (call) async {
      if (call.method == 'Firebase#initializeCore') {
        return {
          'name': '[DEFAULT]',
          'options': {
            'apiKey': 'test-api-key',
            'appId': 'test-app-id',
            'messagingSenderId': '123456789',
            'projectId': 'test-project',
          },
        };
      }
      return null;
    });
  }

  /* --------------------------- 환경 변수(더미) ---------------------------- */

  static void _setupEnvironmentVariables() {
    // 실제 프로세스 환경변수는 변경 불가.
    // 필요 시 테스트에서 상수/Config를 통해 참조.
    const _testEnvVars = {
      'API_URL': 'http://localhost:8080',
      'FIREBASE_API_KEY': 'test-api-key',
      'FIREBASE_AUTH_DOMAIN': 'test-project.firebaseapp.com',
      'FIREBASE_PROJECT_ID': 'test-project',
      'FIREBASE_STORAGE_BUCKET': 'test-project.appspot.com',
      'FIREBASE_MESSAGING_SENDER_ID': '123456789',
      'FIREBASE_APP_ID': '1:123456789:web:abcdef',
    };
    // 필요하면 여기 값을 테스트에서 직접 사용하세요.
    _testEnvVars.toString(); // 사용 경고 회피
  }

  /* ---------------------------- 선택적 유틸들 ---------------------------- */

  /// 네트워크 상태 모의 업데이트
  static void setupNetworkMock({bool isConnected = true}) {
    _mockChannel(
      'dev.fluttercommunity.plus/connectivity',
      (call) async =>
          call.method == 'check' ? (isConnected ? 'wifi' : 'none') : null,
    );
  }

  /// 권한 상태 모의 업데이트
  static void setupPermissionMock({bool isGranted = true}) {
    _mockChannel('flutter.baseflow.com/permissions/methods', (call) async {
      switch (call.method) {
        case 'checkPermissionStatus':
          return isGranted ? 1 : 0;
        case 'requestPermissions':
          return {0: isGranted ? 1 : 0};
        default:
          return null;
      }
    });
  }

  /// 파일 시스템 모의(별도 호출형)
  static void setupFileSystemMock() {
    _mockChannel('plugins.flutter.io/path_provider', (call) async {
      switch (call.method) {
        case 'getTemporaryDirectory':
          return '/tmp';
        case 'getApplicationDocumentsDirectory':
        case 'getDocumentsDirectory':
          return '/documents';
        case 'getExternalStorageDirectory':
          return '/external';
        default:
          return null;
      }
    });
  }

  /// 테스트간 전역상태 초기화
  static void resetForTest() {
    SharedPreferences.setMockInitialValues({});
  }

  /// 테스트 정리(채널 핸들러 해제 포함)
  static Future<void> cleanup() async {
    for (final ch in _channels.values) {
      _messenger.setMockMethodCallHandler(ch, null);
    }
    _channels.clear();
    _initialized = false;
    resetForTest();
  }
}
