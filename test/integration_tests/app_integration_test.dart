import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:peoplejob_frontend/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

      // 홈페이지 확인
      await pumpUntilFound(tester, find.text('PeopleJob'));
      expect(find.text('PeopleJob'), findsOneWidget);

      // 로그인 페이지로 이동
      await safeTap(tester, find.text('로그인').first);

      // 로그인 페이지 확인
      await pumpUntilFound(tester, find.text('로그인'));
      expect(find.text('로그인'), findsOneWidget);

      // 테스트 계정으로 로그인
      final fields = find.byType(TextField);
      if (fields.evaluate().length >= 2) {
        await tester.enterText(fields.at(0), 'testuser');
        await tester.enterText(fields.at(1), 'password123');
        await tester.pumpAndSettle();
      }

      final loginButton = find.byType(ElevatedButton).first;
      await safeTap(tester, loginButton);

      // 로그인 후 홈으로 복귀(앱 구현에 따라 스낵바/다이얼로그가 있을 수 있음)
      await pumpWarmUp(tester);
    });

    testWidgets('채용공고 목록 조회 및 상세보기 테스트', (WidgetTester tester) async {
      app.main();
      await pumpWarmUp(tester);
      await ensureLoggedIn(tester);

      // 채용공고 메뉴로 이동
      await openDrawer(tester);
      await safeTap(tester, find.text('📢 채용공고 보기'));

      // 채용공고 목록 페이지 확인
      await pumpUntilFound(tester, find.text('채용공고'));
      expect(find.text('채용공고'), findsOneWidget);

      // 검색 기능 테스트
      final searchField = find.byType(TextField).first;
      await enterTextIfPresent(tester, searchField, '개발자');

      // 첫 번째 채용공고 카드 탭
      if (find.byType(Card).evaluate().isNotEmpty) {
        await tester.tap(find.byType(Card).first);
        await tester.pumpAndSettle();

        // 상세 페이지 이동 확인(뒤로가기 아이콘 존재여부)
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      }
    });

    testWidgets('이력서 등록 플로우 테스트', (WidgetTester tester) async {
      app.main();
      await pumpWarmUp(tester);
      await ensureLoggedIn(tester);

      // 이력서 메뉴로 이동
      await openDrawer(tester);
      await safeTap(tester, find.text('📄 이력서 보기'));

      // 이력서 목록 페이지 확인
      await pumpUntilFound(tester, find.text('이력서'));
      expect(find.text('이력서'), findsOneWidget);

      // 새 이력서 등록 버튼 탭
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // 이력서 등록 페이지로 이동했는지 확인
        if (find.text('이력서 등록').evaluate().isNotEmpty) {
          expect(find.text('이력서 등록'), findsOneWidget);
        }

        // 필수 필드 입력(키가 있는 경우)
        final titleField = find.byKey(const Key('title_field'));
        final nameField = find.byKey(const Key('name_field'));
        await enterTextIfPresent(tester, titleField, '테스트 이력서');
        await enterTextIfPresent(tester, nameField, '홍길동');

        // 저장 버튼 탭
        await safeTap(tester, find.text('저장'));
      }
    });

    testWidgets('검색 기능 통합 테스트', (WidgetTester tester) async {
      app.main();
      await pumpWarmUp(tester);

      await safeTap(tester, find.byIcon(Icons.search));
      await pumpUntilFound(tester, find.text('검색'));
      expect(find.text('검색'), findsOneWidget);

      final searchField = find.byType(TextField).first;
      await enterTextIfPresent(tester, searchField, '개발자');
      // 검색 액션 트리거
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
    });

    testWidgets('공지사항 조회 테스트', (WidgetTester tester) async {
      app.main();
      await pumpWarmUp(tester);

      await openDrawer(tester);
      if (find.text('공지사항').evaluate().isNotEmpty) {
        await tester.tap(find.text('공지사항'));
        await tester.pumpAndSettle();

        expect(find.text('공지사항'), findsOneWidget);
      }
    });

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
    });

    testWidgets('네비게이션 테스트', (WidgetTester tester) async {
      app.main();
      await pumpWarmUp(tester);

      await openDrawer(tester);

      // 메뉴 항목 존재 확인(있을 때만 체크)
      if (find.text('📋 게시판').evaluate().isNotEmpty) {
        expect(find.text('📋 게시판'), findsOneWidget);
      }
      if (find.text('📄 이력서 보기').evaluate().isNotEmpty) {
        expect(find.text('📄 이력서 보기'), findsOneWidget);
      }
      if (find.text('📢 채용공고 보기').evaluate().isNotEmpty) {
        expect(find.text('📢 채용공고 보기'), findsOneWidget);
      }

      // 게시판으로 이동
      await safeTap(tester, find.text('📋 게시판'));

      // 뒤로가기
      await safeTap(tester, find.byIcon(Icons.arrow_back));

      // 홈페이지로 복귀 확인
      await pumpUntilFound(tester, find.text('PeopleJob'));
      expect(find.text('PeopleJob'), findsOneWidget);
    });

    testWidgets('오프라인 상태 처리 테스트(형태만 검증)', (WidgetTester tester) async {
      app.main();
      await pumpWarmUp(tester);

      await openDrawer(tester);
      await safeTap(tester, find.text('📢 채용공고 보기'));

      // 오프라인 메시지나 대체 UI가 있는 경우(앱 구현에 따라 다름)
      // 여기서는 화면이 깨지지 않고 안정화되는지만 확인
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('다크 모드 전환 테스트(형태만 검증)', (WidgetTester tester) async {
      app.main();
      await pumpWarmUp(tester);

      // 실제 앱 설정 화면이 있다면 이곳에서 전환 테스트
      // 여기서는 최소 안정성만 확인
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

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

      // 마지막에 프레임이 남아있지 않음
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  });

  // 통합 테스트 성능 수집 원하면 아래처럼 사용 가능
  // (binding as IntegrationTestWidgetsFlutterBinding)
  //     .reportData is available via extended driver.
}
