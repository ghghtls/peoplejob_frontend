import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart' as itest;

/// 공통 테스트 설정 유틸
class TestConfig {
  /// 위젯/단위 테스트 환경 세팅
  static void setupTestEnvironment({Duration? timeout}) {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    final t = Timeout(timeout ?? const Duration(minutes: 5));

    // SDK 버전에 따라 타입/세터 유무가 달라져서 동적으로 시도
    try {
      (binding as dynamic).defaultTestTimeout = t;
    } catch (_) {}
  }

  /// 통합 테스트(integration_test) 환경 설정
  /// - 통합 테스트 파일에서만 호출
  static itest.IntegrationTestWidgetsFlutterBinding
  setupIntegrationTestEnvironment({Duration? timeout}) {
    final iBinding =
        itest.IntegrationTestWidgetsFlutterBinding.ensureInitialized()
            as itest.IntegrationTestWidgetsFlutterBinding;

    final base = TestWidgetsFlutterBinding.instance;
    final t = Timeout(timeout ?? const Duration(minutes: 5));

    try {
      (base as dynamic).defaultTestTimeout = t;
    } catch (_) {}

    return iBinding;
  }

  /// pumpAndSettle 등에 쓰기 좋은 기본 딜레이
  static const pumpSettle = Duration(milliseconds: 250);

  /// 테스트용 환경 변수(실제 프로세스 env는 변경하지 않음)
  static const Map<String, String> testEnvVars = {
    'API_URL': 'http://localhost:8080',
    'TEST_MODE': 'true',
  };
}
