import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:peoplejob_frontend/services/auth_service.dart';
import 'package:peoplejob_frontend/services/job_service.dart';
import 'package:peoplejob_frontend/services/resume_service.dart';
import 'package:peoplejob_frontend/services/board_service.dart';
import 'package:peoplejob_frontend/services/apply_service.dart';
import 'package:peoplejob_frontend/services/notice_service.dart';

// Mock 클래스 생성을 위한 어노테이션
@GenerateMocks([
  AuthService,
  JobService,
  ResumeService,
  BoardService,
  ApplyService,
  NoticeService,
])
void main() {}

class TestSetup {
  // 테스트 환경 초기 설정
  static Future<void> setupTestEnvironment() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // SharedPreferences 모의 설정
    SharedPreferences.setMockInitialValues({});

    // 플랫폼 채널 모의 설정
    _setupPlatformChannels();

    // 환경 변수 설정
    _setupEnvironmentVariables();
  }

  // 플랫폼 채널 모의 설정
  static void _setupPlatformChannels() {
    // SystemChrome 채널 모의
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/system_chrome'),
          (MethodCall methodCall) async {
            if (methodCall.method ==
                'SystemChrome.setApplicationSwitcherDescription') {
              return null;
            }
            if (methodCall.method == 'SystemChrome.setSystemUIOverlayStyle') {
              return null;
            }
            return null;
          },
        );

    // 파일 피커 채널 모의
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('miguelruivo.flutter.plugins.filepicker'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'any') {
              return null;
            }
            return null;
          },
        );

    // 이미지 피커 채널 모의
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/image_picker'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'pickImage') {
              return null; // 또는 테스트용 이미지 경로
            }
            return null;
          },
        );

    // URL 런처 채널 모의
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/url_launcher'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'launch') {
              return true;
            }
            return false;
          },
        );

    // 보안 저장소 채널 모의
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'read':
                return null;
              case 'write':
                return null;
              case 'delete':
                return null;
              case 'deleteAll':
                return null;
              default:
                return null;
            }
          },
        );

    // 연결성 플러스 채널 모의
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/connectivity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'check') {
              return 'wifi'; // 또는 'mobile', 'none'
            }
            return null;
          },
        );

    // 권한 핸들러 채널 모의
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'checkPermissionStatus') {
              return 1; // granted
            }
            if (methodCall.method == 'requestPermissions') {
              return {0: 1}; // granted
            }
            return null;
          },
        );
  }

  // 환경 변수 설정
  static void _setupEnvironmentVariables() {
    // 테스트 환경 변수들
    const testEnvVars = {
      'API_URL': 'http://localhost:8080',
      'FIREBASE_API_KEY': 'test-api-key',
      'FIREBASE_AUTH_DOMAIN': 'test-project.firebaseapp.com',
      'FIREBASE_PROJECT_ID': 'test-project',
      'FIREBASE_STORAGE_BUCKET': 'test-project.appspot.com',
      'FIREBASE_MESSAGING_SENDER_ID': '123456789',
      'FIREBASE_APP_ID': '1:123456789:web:abcdef',
    };

    // 환경 변수를 실제로 설정하는 것은 불가능하므로
    // 테스트에서 직접 mock 값을 사용해야 함
  }

  // 테스트용 HTTP 클라이언트 설정
  static void setupMockHttpClient() {
    // HTTP 클라이언트 모의 설정은 각 테스트에서 개별적으로 처리
  }

  // 테스트 정리
  static Future<void> tearDown() async {
    // 모든 모의 설정 정리
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(null, null);
  }

  // 특정 테스트를 위한 설정 리셋
  static void resetForTest() {
    // SharedPreferences 리셋
    SharedPreferences.setMockInitialValues({});
  }

  // Firebase 테스트 설정
  static Future<void> setupFirebaseForTest() async {
    // Firebase 테스트 설정은 실제 Firebase 없이 모의로 처리
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/firebase_core'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'Firebase#initializeCore') {
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
          },
        );
  }

  // 네트워크 상태 모의 설정
  static void setupNetworkMock({bool isConnected = true}) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/connectivity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'check') {
              return isConnected ? 'wifi' : 'none';
            }
            return null;
          },
        );
  }

  // 권한 상태 모의 설정
  static void setupPermissionMock({bool isGranted = true}) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'checkPermissionStatus') {
              return isGranted ? 1 : 0; // 1: granted, 0: denied
            }
            if (methodCall.method == 'requestPermissions') {
              return {0: isGranted ? 1 : 0};
            }
            return null;
          },
        );
  }

  // 파일 시스템 모의 설정
  static void setupFileSystemMock() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'getTemporaryDirectory':
                return '/tmp';
              case 'getDocumentsDirectory':
                return '/documents';
              case 'getExternalStorageDirectory':
                return '/external';
              default:
                return null;
            }
          },
        );
  }

  // 디바이스 정보 모의 설정
  static void setupDeviceInfoMock() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/device_info'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getAndroidDeviceInfo') {
              return {
                'version': {'sdkInt': 29},
                'brand': 'TestBrand',
                'model': 'TestModel',
              };
            }
            if (methodCall.method == 'getIosDeviceInfo') {
              return {
                'systemVersion': '14.0',
                'model': 'iPhone',
                'name': 'Test iPhone',
              };
            }
            return null;
          },
        );
  }

  // 테스트 데이터베이스 설정
  static Future<void> setupTestDatabase() async {
    // 테스트용 SQLite 데이터베이스 설정
    // 실제 구현에서는 sqflite_common_ffi 등을 사용
  }

  // 테스트 완료 후 정리
  static Future<void> cleanup() async {
    // 모든 리소스 정리
    await tearDown();
    resetForTest();
  }
}
