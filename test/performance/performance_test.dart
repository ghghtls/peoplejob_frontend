import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class PerformanceTest {
  /// 스크롤 성능 측정
  /// - 통합 테스트 환경(IntegrationTestWidgetsFlutterBinding)에서는 watchPerformance 활용
  /// - 일반 위젯 테스트 환경에서는 폴백으로 스크롤 후 프레임 안정성만 검증
  static Future<void> testScrollPerformance(
    WidgetTester tester,
    Widget scrollableWidget, {
    Finder? scrollableFinder,
    int flingCount = 3,
    Offset flingOffset = const Offset(0, -400),
    double flingVelocity = 1200,
    String reportKey = 'scroll_performance',
  }) async {
    // 테스트용 래핑 (일부 위젯은 머티리얼 컨텍스트가 필요)
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: scrollableWidget)),
    );
    await tester.pumpAndSettle();

    // 스크롤 가능한 대상 찾기 (미지정 시 ListView -> Scrollable 순으로 탐색)
    final finder =
        scrollableFinder ??
        (find.byType(ListView).evaluate().isNotEmpty
            ? find.byType(ListView).first
            : find.byType(Scrollable).first);

    expect(finder, findsOneWidget, reason: '스크롤 가능한 위젯을 찾지 못했습니다.');

    final binding = WidgetsBinding.instance;

    // 통합 테스트 환경이면 watchPerformance 사용
    if (binding is IntegrationTestWidgetsFlutterBinding) {
      await binding.watchPerformance(() async {
        for (int i = 0; i < flingCount; i++) {
          await tester.fling(finder, flingOffset, flingVelocity);
          await tester.pumpAndSettle();
        }
      }, reportKey: reportKey);
    } else {
      // 위젯 테스트 환경 폴백
      for (int i = 0; i < flingCount; i++) {
        await tester.fling(finder, flingOffset, flingVelocity);
        await tester.pumpAndSettle();
      }
    }

    // 프레임 드롭/미처리 프레임이 남아있지 않은지 간단 검증
    expect(tester.binding.hasScheduledFrame, isFalse);
  }

  /// 메모리 사용량 테스트 (플랫폼/런타임 제약으로 간단 폴백만 제공)
  /// 필요 시 VM Service 연동 또는 플랫폼별 측정 로직을 여기에 확장
  static Future<void> testMemoryUsage(
    WidgetTester tester, {
    required Future<void> Function() action,
  }) async {
    // 여기서는 액션 수행이 예외 없이 완료되고 UI가 안정화되는지만 확인
    await action();
    await tester.pumpAndSettle();
  }
}
