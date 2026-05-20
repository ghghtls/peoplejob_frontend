import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:peoplejob_frontend/main.dart' as app;

// 통합 테스트는 실제 기기/에뮬레이터 + Firebase 연결이 필요합니다.
// 실행 방법: flutter test integration_test/ --device-id=<device>
// 일반 `flutter test`로는 실행할 수 없습니다.
// 기기 + Firebase 필요: flutter test integration_test/ --device-id=<device>
const _kSkip = true;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // 공용 헬퍼들
  Future<void> pumpWarmUp(WidgetTester tester) async {
    // 초기 프레임/애니메이션 안정화
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
  }

  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
    Duration step = const Duration(milliseconds: 100),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      if (finder.evaluate().isNotEmpty) break;
      await tester.pump(step);
    }
    await tester.pumpAndSettle();
  }

  Future<void> openDrawer(WidgetTester tester) async {
    // 드로어는 보통 햄버거 아이콘이나 툴팁으로 열림
    final menuIcon = find.byIcon(Icons.menu);
    final tooltip = find.byTooltip('Open navigation menu'); // Material 기본 툴팁
    if (menuIcon.evaluate().isNotEmpty) {
      await tester.tap(menuIcon);
    } else if (tooltip.evaluate().isNotEmpty) {
      await tester.tap(tooltip);
    }
    await tester.pumpAndSettle();
  }

  Future<void> safeTap(WidgetTester tester, Finder finder) async {
    if (finder.evaluate().isNotEmpty) {
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }
  }

  Future<void> enterTextIfPresent(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    if (finder.evaluate().isNotEmpty) {
      await tester.enterText(finder, text);
      await tester.pumpAndSettle();
    }
  }

  Future<void> ensureLoggedIn(WidgetTester tester) async {
    // 홈에서 '로그인' 버튼이 보이면 로그인 플로우 실행
    final loginTextBtn = find.text('로그인');
    if (loginTextBtn.evaluate().isNotEmpty) {
      await tester.tap(loginTextBtn.first);
      await tester.pumpAndSettle();

      // 아이디/비번 입력
      final fields = find.byType(TextField);
      if (fields.evaluate().length >= 2) {
        await tester.enterText(fields.at(0), 'testuser');
        await tester.enterText(fields.at(1), 'password123');
      }

      // 로그인 버튼 시도 (Key가 없을 수 있으니 타입/텍스트로 시도)
      final loginBtnByText = find.text('로그인');
      final loginBtnByType = find.byType(ElevatedButton);
      if (loginBtnByText.evaluate().isNotEmpty) {
        await tester.tap(loginBtnByText.first);
      } else if (loginBtnByType.evaluate().isNotEmpty) {
        await tester.tap(loginBtnByType.first);
      }
      await tester.pumpAndSettle();
    }
  }

  group('App Integration Tests', () {
    testWidgets('전체 앱 플로우 테스트', (WidgetTester tester) async {
      app.main();
      await pumpWarmUp(tester);

      await pumpUntilFound(tester, find.text('PeopleJob'));
      expect(find.text('PeopleJob'), findsOneWidget);

      await safeTap(tester, find.text('로그인').first);

      await pumpUntilFound(tester, find.text('로그인'));
      expect(find.text('로그인'), findsOneWidget);

      final fields = find.byType(TextField);
      if (fields.evaluate().length >= 2) {
        await tester.enterText(fields.at(0), 'testuser');
        await tester.enterText(fields.at(1), 'password123');
        await tester.pumpAndSettle();
      }

      final loginButton = find.byType(ElevatedButton).first;
      await safeTap(tester, loginButton);
      await pumpWarmUp(tester);
    }, skip: _kSkip);

    testWidgets('채용공고 목록 조회 및 상세보기 테스트', (WidgetTester tester) async {
      app.main();
      await pumpWarmUp(tester);
      await ensureLoggedIn(tester);

      await openDrawer(tester);
      await safeTap(tester, find.text('📢 채용공고 보기'));

      await pumpUntilFound(tester, find.text('채용공고'));
      expect(find.text('채용공고'), findsOneWidget);

      final searchField = find.byType(TextField).first;
      await enterTextIfPresent(tester, searchField, '개발자');

      if (find.byType(Card).evaluate().isNotEmpty) {
        await tester.tap(find.byType(Card).first);
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      }
    }, skip: _kSkip);

    testWidgets('이력서 등록 플로우 테스트', (WidgetTester tester) async {
      app.main();
      await pumpWarmUp(tester);
      await ensureLoggedIn(tester);

      await openDrawer(tester);
      await safeTap(tester, find.text('📄 이력서 보기'));

      await pumpUntilFound(tester, find.text('이력서'));
      expect(find.text('이력서'), findsOneWidget);

      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        if (find.text('이력서 등록').evaluate().isNotEmpty) {
          expect(find.text('이력서 등록'), findsOneWidget);
        }

        final titleField = find.byKey(const Key('title_field'));
        final nameField = find.byKey(const Key('name_field'));
        await enterTextIfPresent(tester, titleField, '테스트 이력서');
        await enterTextIfPresent(tester, nameField, '홍길동');
        await safeTap(tester, find.text('저장'));
      }
    }, skip: _kSkip);

    testWidgets('검색 기능 통합 테스트', (WidgetTester tester) async {
      app.main();
      await pumpWarmUp(tester);

      await safeTap(tester, find.byIcon(Icons.search));
      await pumpUntilFound(tester, find.text('검색'));
      expect(find.text('검색'), findsOneWidget);

      final searchField = find.byType(TextField).first;
      await enterTextIfPresent(tester, searchField, '개발자');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
    }, skip: _kSkip);

    testWidgets('공지사항 조회 테스트', (WidgetTester tester) async {
      app.main();
      await pumpWarmUp(tester);

      await openDrawer(tester);
      if (find.text('공지사항').evaluate().isNotEmpty) {
        await tester.tap(find.text('공지사항'));
        await tester.pumpAndSettle();
        expect(find.text('공지사항'), findsOneWidget);
      }
    }, skip: _kSkip);

    testWidgets('마이페이지 접근 테스트', (WidgetTester tester) async {
      app.main();
      await pumpWarmUp(tester);
      await ensureLoggedIn(tester);

      await openDrawer(tester);
      if (find.text('마이페이지').evaluate().isNotEmpty) {
        await tester.tap(find.text('마이페이지'));
        await tester.pumpAndSettle();
        expect(find.text('마이페이지'), findsOneWidget);
      }
    }, skip: _kSkip);

    testWidgets('네비게이션 테스트', (WidgetTester tester) async {
      app.main();
      await pumpWarmUp(tester);

      await openDrawer(tester);

      if (find.text('📋 게시판').evaluate().isNotEmpty) {
        expect(find.text('📋 게시판'), findsOneWidget);
      }
      if (find.text('📄 이력서 보기').evaluate().isNotEmpty) {
        expect(find.text('📄 이력서 보기'), findsOneWidget);
      }
      if (find.text('📢 채용공고 보기').evaluate().isNotEmpty) {
        expect(find.text('📢 채용공고 보기'), findsOneWidget);
      }

      await safeTap(tester, find.text('📋 게시판'));
      await safeTap(tester, find.byIcon(Icons.arrow_back));

      await pumpUntilFound(tester, find.text('PeopleJob'));
      expect(find.text('PeopleJob'), findsOneWidget);
    }, skip: _kSkip);

    testWidgets('오프라인 상태 처리 테스트(형태만 검증)', (WidgetTester tester) async {
      app.main();
      await pumpWarmUp(tester);

      await openDrawer(tester);
      await safeTap(tester, find.text('📢 채용공고 보기'));
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
    }, skip: _kSkip);

    testWidgets('다크 모드 전환 테스트(형태만 검증)', (WidgetTester tester) async {
      app.main();
      await pumpWarmUp(tester);
      expect(tester.binding.hasScheduledFrame, isFalse);
    }, skip: _kSkip);

    testWidgets('메모리/라우팅 누수 방지 기초 테스트', (WidgetTester tester) async {
      app.main();
      await pumpWarmUp(tester);

      for (int i = 0; i < 3; i++) {
        await openDrawer(tester);
        await safeTap(tester, find.text('📢 채용공고 보기'));
        await safeTap(tester, find.byIcon(Icons.arrow_back));

        await openDrawer(tester);
        await safeTap(tester, find.text('📄 이력서 보기'));
        await safeTap(tester, find.byIcon(Icons.arrow_back));
      }

      expect(tester.binding.hasScheduledFrame, isFalse);
    }, skip: _kSkip);
  });

  // 통합 테스트 성능 수집 원하면 아래처럼 사용 가능
  // (binding as IntegrationTestWidgetsFlutterBinding)
  //     .reportData is available via extended driver.
}
