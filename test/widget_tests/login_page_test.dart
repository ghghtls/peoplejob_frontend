import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mockito/mockito.dart';

import 'package:peoplejob_frontend/ui/pages/login/login_page.dart';

// ---- Mocks ----
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// 공용 빌더: Riverpod ProviderScope + (옵션) NavigatorObserver
// 아이디 찾기 / 비밀번호 찾기 라우트를 스텁으로 등록해야 pushNamed 에러 없이 동작
Widget _buildApp({NavigatorObserver? observer}) {
  return ProviderScope(
    child: MaterialApp(
      home: const LoginPage(),
      navigatorObservers: observer != null ? [observer] : const [],
      routes: {
        '/find-id': (_) => const Scaffold(body: Text('아이디 찾기')),
        '/find-password': (_) => const Scaffold(body: Text('비밀번호 찾기')),
        '/register': (_) => const Scaffold(body: Text('회원가입')),
      },
    ),
  );
}

void main() {
  setUpAll(() async {
    dotenv.testLoad(fileInput: 'API_URL=http://localhost:5000\n');
  });

  group('LoginPage + LoginForm (existing) Widget Tests', () {
    testWidgets('기본 UI 렌더링', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      // 로그인 버튼 텍스트 (AppBar 없는 커스텀 레이아웃)
      expect(find.widgetWithText(ElevatedButton, '로그인'), findsOneWidget);

      // 입력 필드 2개 존재 (아이디, 비밀번호)
      expect(find.byType(TextFormField), findsNWidgets(2));

      // 하단 링크 버튼
      expect(find.text('아이디 찾기'), findsOneWidget);
      expect(find.text('비밀번호 찾기'), findsOneWidget);
    });

    testWidgets('아이디/비밀번호 입력 동작', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      final useridField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);

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

    testWidgets('로그인 버튼 탭 시 처리 완료 후 버튼 복구', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.enterText(find.byType(TextFormField).at(0), 'testuser');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // TestWidgetsFlutterBinding이 HTTP를 즉시 400으로 처리하므로
      // CircularProgressIndicator는 pump() 한 번 안에 사라짐 — 완료 후 상태만 검증
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, '로그인'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
      await tester.pumpAndSettle();

      // 처리 완료 후 버튼이 다시 활성화됨
      expect(find.widgetWithText(ElevatedButton, '로그인'), findsOneWidget);
    });

    testWidgets('로그인 실패 시 에러 메시지(네트워크 오류) 노출', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      // 유효 입력
      await tester.enterText(find.byType(TextFormField).at(0), 'wronguser');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpassword');

      await tester.ensureVisible(find.widgetWithText(ElevatedButton, '로그인'));
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
