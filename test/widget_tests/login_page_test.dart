import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart' as m;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:peoplejob_frontend/ui/pages/login/login_page.dart';

// ---- Mocks ----
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// 공용 빌더: Riverpod ProviderScope + (옵션) NavigatorObserver
Widget _buildApp({NavigatorObserver? observer}) {
  return ProviderScope(
    child: MaterialApp(
      home: const LoginPage(),
      navigatorObservers: observer != null ? [observer] : const [],
    ),
  );
}

void main() {
  group('LoginPage + LoginForm (existing) Widget Tests', () {
    testWidgets('기본 UI 렌더링', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      // AppBar의 '로그인'
      expect(find.widgetWithText(AppBar, '로그인'), findsOneWidget);

      // 로그인 버튼의 '로그인'
      expect(find.widgetWithText(ElevatedButton, '로그인'), findsOneWidget);

      // 입력 필드 (Key가 없으므로 라벨 텍스트로 탐색)
      expect(find.widgetWithText(TextFormField, '아이디'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '비밀번호'), findsOneWidget);

      // 하단 링크 버튼
      expect(find.text('아이디 찾기'), findsOneWidget);
      expect(find.text('비밀번호 찾기'), findsOneWidget);
    });

    testWidgets('아이디/비밀번호 입력 동작', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      final useridField = find.widgetWithText(TextFormField, '아이디');
      final passwordField = find.widgetWithText(TextFormField, '비밀번호');

      await tester.enterText(useridField, 'testuser');
      await tester.enterText(passwordField, 'password123');

      expect(find.text('testuser'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('빈 필드로 로그인 시 검증 에러 노출', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      final loginBtn = find.widgetWithText(ElevatedButton, '로그인');
      await tester.tap(loginBtn);
      await tester.pump(); // validation 반영

      expect(find.text('아이디를 입력하세요'), findsOneWidget);
      expect(find.text('비밀번호를 입력하세요'), findsOneWidget);
    });

    testWidgets('로그인 버튼 탭 시 로딩 인디케이터 표시', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      // 유효 입력
      await tester.enterText(
        find.widgetWithText(TextFormField, '아이디'),
        'testuser',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '비밀번호'),
        'password123',
      );

      // 탭 → 한 프레임 후 로딩표시
      await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, '로그인'), findsNothing);

      // (네트워크 실패로 에러가 표시될 때까지 대기)
      await tester.pumpAndSettle();
    });

    testWidgets('로그인 실패 시 에러 메시지(네트워크 오류) 노출', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      // 유효 입력
      await tester.enterText(
        find.widgetWithText(TextFormField, '아이디'),
        'wronguser',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '비밀번호'),
        'wrongpassword',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
      await tester.pump(); // setState(_isLoading)
      await tester.pumpAndSettle(); // http.post 시도 → catch → 에러 메시지 세팅

      // 실제 네트워크를 모킹하지 않으므로, 실패시 코드가 '네트워크 오류: ...'로 세팅
      expect(find.textContaining('네트워크 오류'), findsOneWidget);
    });

    testWidgets('아이디 찾기 버튼 탭 시 네비게이션 push', (WidgetTester tester) async {
      final navObserver = MockNavigatorObserver();
      await tester.pumpWidget(_buildApp(observer: navObserver));
      await tester.pump(); // 첫 라우트 알림
      reset(navObserver);

      await tester.tap(find.text('아이디 찾기'));
      await tester.pumpAndSettle();
    });

    testWidgets('비밀번호 찾기 버튼 탭 시 네비게이션 push', (WidgetTester tester) async {
      final navObserver = MockNavigatorObserver();
      await tester.pumpWidget(_buildApp(observer: navObserver));
      await tester.pump();
      reset(navObserver);

      await tester.tap(find.text('비밀번호 찾기'));
      await tester.pumpAndSettle();
    });
  });
}
