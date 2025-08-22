import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class TestConfig {
  static void setupTestEnvironment() {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    // 테스트 타임아웃 설정
    TestWidgetsFlutterBinding.ensureInitialized()
        .binding
        .defaultTestTimeout = const Timeout(Duration(minutes: 5));
  }

  static const Map<String, String> testEnvVars = {
    'API_URL': 'http://localhost:8080',
    'TEST_MODE': 'true',
  };
}
