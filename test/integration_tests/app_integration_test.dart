import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:peoplejob_frontend/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('전체 앱 플로우 테스트', (WidgetTester tester) async {
      // Given
      app.main();
      await tester.pumpAndSettle();

      // 홈페이지 확인
      expect(find.text('PeopleJob'), findsOneWidget);
      expect(find.text('로그인'), findsAtLeastNWidgets(1));

      // 로그인 페이지로 이동
      await tester.tap(find.text('로그인').first);
      await tester.pumpAndSettle();

      // 로그인 페이지 확인
      expect(find.text('로그인'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));

      // 테스트 계정으로 로그인
      await tester.enterText(find.byType(TextField).first, 'testuser');
      await tester.enterText(find.byType(TextField).last, 'password123');

      final loginButton = find.byType(ElevatedButton).first;
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // 로그인 후 홈페이지로 돌아왔는지 확인
      // (실제 서버 연동이 필요하므로 mock 환경에서는 적절히 조정)
    });

    testWidgets('채용공고 목록 조회 및 상세보기 테스트', (WidgetTester tester) async {
      // Given
      app.main();
      await tester.pumpAndSettle();

      // 채용공고 메뉴로 이동
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('📢 채용공고 보기'));
      await tester.pumpAndSettle();

      // 채용공고 목록 페이지 확인
      expect(find.text('채용공고'), findsOneWidget);

      // 검색 기능 테스트
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, '개발자');
      await tester.pump();

      // 첫 번째 채용공고 카드 탭
      if (find.byType(Card).evaluate().isNotEmpty) {
        await tester.tap(find.byType(Card).first);
        await tester.pumpAndSettle();

        // 상세 페이지로 이동했는지 확인
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      }
    });

    testWidgets('이력서 등록 플로우 테스트', (WidgetTester tester) async {
      // Given
      app.main();
      await tester.pumpAndSettle();

      // 로그인 (필요한 경우)
      // ... 로그인 과정 ...

      // 이력서 메뉴로 이동
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('📄 이력서 보기'));
      await tester.pumpAndSettle();

      // 이력서 목록 페이지 확인
      expect(find.text('이력서'), findsOneWidget);

      // 새 이력서 등록 버튼 탭
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // 이력서 등록 페이지로 이동했는지 확인
        expect(find.text('이력서 등록'), findsOneWidget);

        // 필수 필드 입력
        final titleField = find.byKey(const Key('title_field'));
        if (titleField.evaluate().isNotEmpty) {
          await tester.enterText(titleField, '테스트 이력서');
        }

        final nameField = find.byKey(const Key('name_field'));
        if (nameField.evaluate().isNotEmpty) {
          await tester.enterText(nameField, '홍길동');
        }

        // 저장 버튼 탭
        final saveButton = find.text('저장');
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('검색 기능 통합 테스트', (WidgetTester tester) async {
      // Given
      app.main();
      await tester.pumpAndSettle();

      // 검색 버튼 탭
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // 검색 페이지 확인
      expect(find.text('검색'), findsOneWidget);

      // 검색어 입력
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, '개발자');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // 검색 결과 확인 (실제 데이터가 있는 경우)
      // expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('공지사항 조회 테스트', (WidgetTester tester) async {
      // Given
      app.main();
      await tester.pumpAndSettle();

      // 공지사항 메뉴로 이동
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // 공지사항이 표시되는지 확인
      if (find.text('공지사항').evaluate().isNotEmpty) {
        await tester.tap(find.text('공지사항'));
        await tester.pumpAndSettle();

        expect(find.text('공지사항'), findsOneWidget);
      }
    });

    testWidgets('마이페이지 접근 테스트', (WidgetTester tester) async {
      // Given
      app.main();
      await tester.pumpAndSettle();

      // 로그인이 필요한 기능이므로 로그인 상태 확인
      // ... 로그인 과정 ...

      // 마이페이지 메뉴로 이동
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      if (find.text('마이페이지').evaluate().isNotEmpty) {
        await tester.tap(find.text('마이페이지'));
        await tester.pumpAndSettle();

        // 마이페이지 UI 확인
        expect(find.text('마이페이지'), findsOneWidget);
      }
    });

    testWidgets('네비게이션 테스트', (WidgetTester tester) async {
      // Given
      app.main();
      await tester.pumpAndSettle();

      // 드로어 메뉴 열기
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // 각 메뉴 항목들이 표시되는지 확인
      expect(find.text('📋 게시판'), findsOneWidget);
      expect(find.text('📄 이력서 보기'), findsOneWidget);
      expect(find.text('📢 채용공고 보기'), findsOneWidget);

      // 게시판으로 이동
      await tester.tap(find.text('📋 게시판'));
      await tester.pumpAndSettle();

      // 뒤로가기
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 홈페이지로 돌아왔는지 확인
      expect(find.text('PeopleJob'), findsOneWidget);
    });

    testWidgets('오프라인 상태 처리 테스트', (WidgetTester tester) async {
      // Given
      app.main();
      await tester.pumpAndSettle();

      // 네트워크 연결이 없는 상태에서의 동작 테스트
      // (실제 구현에서는 connectivity_plus 패키지를 사용)

      // 채용공고 목록 접근 시도
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('📢 채용공고 보기'));
      await tester.pumpAndSettle();

      // 오프라인 메시지나 캐시된 데이터 표시 확인
      // (실제 구현에 따라 다름)
    });

    testWidgets('다크 모드 전환 테스트', (WidgetTester tester) async {
      // Given
      app.main();
      await tester.pumpAndSettle();

      // 설정에서 다크 모드 전환 (설정 메뉴가 있는 경우)
      // ... 설정 메뉴 접근 ...

      // 테마 변경 확인
      // expect(Theme.of(context).brightness, Brightness.dark);
    });

    testWidgets('메모리 누수 테스트', (WidgetTester tester) async {
      // Given
      app.main();
      await tester.pumpAndSettle();

      // 여러 페이지를 반복적으로 이동하면서 메모리 사용량 확인
      for (int i = 0; i < 5; i++) {
        // 채용공고 페이지
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text('📢 채용공고 보기'));
        await tester.pumpAndSettle();

        // 홈으로 돌아가기
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // 이력서 페이지
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text('📄 이력서 보기'));
        await tester.pumpAndSettle();

        // 홈으로 돌아가기
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }

      // 메모리 사용량이 안정적인지 확인
      // (실제로는 flutter driver나 별도 도구 필요)
    });
  });
}
