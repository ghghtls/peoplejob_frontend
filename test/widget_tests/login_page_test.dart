import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:peoplejob_frontend/ui/pages/login/login_page.dart';
import 'package:peoplejob_frontend/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  group('LoginPage Widget Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    testWidgets('로그인 페이지 기본 UI 렌더링 테스트', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const LoginPage(),
          ),
        ),
      );

      // Then
      expect(find.text('로그인'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // 아이디, 비밀번호 필드
      expect(find.text('아이디 찾기'), findsOneWidget);
      expect(find.text('비밀번호 찾기'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
    });

    testWidgets('아이디 입력 필드 테스트', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const LoginPage(),
          ),
        ),
      );

      // When
      final useridField = find.byKey(const Key('userid_field'));
      await tester.enterText(useridField, 'testuser');

      // Then
      expect(find.text('testuser'), findsOneWidget);
    });

    testWidgets('비밀번호 입력 필드 테스트', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const LoginPage(),
          ),
        ),
      );

      // When
      final passwordField = find.byKey(const Key('password_field'));
      await tester.enterText(passwordField, 'password123');

      // Then
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('로그인 버튼 탭 테스트', (WidgetTester tester) async {
      // Given
      when(
        mockAuthService.login(
          userid: anyNamed('userid'),
          password: anyNamed('password'),
        ),
      ).thenAnswer(
        (_) async => {
          'token': 'mock-token',
          'userid': 'testuser',
          'name': '테스트 사용자',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const LoginPage(),
          ),
        ),
      );

      // When
      final useridField = find.byKey(const Key('userid_field'));
      final passwordField = find.byKey(const Key('password_field'));
      final loginButton = find.byKey(const Key('login_button'));

      await tester.enterText(useridField, 'testuser');
      await tester.enterText(passwordField, 'password123');
      await tester.tap(loginButton);
      await tester.pump();

      // Then
      verify(
        mockAuthService.login(userid: 'testuser', password: 'password123'),
      ).called(1);
    });

    testWidgets('빈 필드로 로그인 시도 시 오류 메시지 표시 테스트', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const LoginPage(),
          ),
        ),
      );

      // When
      final loginButton = find.byKey(const Key('login_button'));
      await tester.tap(loginButton);
      await tester.pump();

      // Then
      expect(find.text('아이디를 입력해주세요.'), findsOneWidget);
    });

    testWidgets('로그인 실패 시 오류 메시지 표시 테스트', (WidgetTester tester) async {
      // Given
      when(
        mockAuthService.login(
          userid: anyNamed('userid'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const LoginPage(),
          ),
        ),
      );

      // When
      final useridField = find.byKey(const Key('userid_field'));
      final passwordField = find.byKey(const Key('password_field'));
      final loginButton = find.byKey(const Key('login_button'));

      await tester.enterText(useridField, 'wronguser');
      await tester.enterText(passwordField, 'wrongpassword');
      await tester.tap(loginButton);
      await tester.pump();

      // Then
      expect(find.text('로그인에 실패했습니다.'), findsOneWidget);
    });

    testWidgets('아이디 찾기 버튼 탭 테스트', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const LoginPage(),
          ),
        ),
      );

      // When
      final findIdButton = find.text('아이디 찾기');
      await tester.tap(findIdButton);
      await tester.pumpAndSettle();

      // Then
      expect(find.byType(MaterialPageRoute), findsOneWidget);
    });

    testWidgets('비밀번호 찾기 버튼 탭 테스트', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const LoginPage(),
          ),
        ),
      );

      // When
      final findPasswordButton = find.text('비밀번호 찾기');
      await tester.tap(findPasswordButton);
      await tester.pumpAndSettle();

      // Then
      expect(find.byType(MaterialPageRoute), findsOneWidget);
    });

    testWidgets('로그인 로딩 상태 테스트', (WidgetTester tester) async {
      // Given
      when(
        mockAuthService.login(
          userid: anyNamed('userid'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 2));
        return {'token': 'mock-token', 'userid': 'testuser'};
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>(
            create: (_) => mockAuthService,
            child: const LoginPage(),
          ),
        ),
      );

      // When
      final useridField = find.byKey(const Key('userid_field'));
      final passwordField = find.byKey(const Key('password_field'));
      final loginButton = find.byKey(const Key('login_button'));

      await tester.enterText(useridField, 'testuser');
      await tester.enterText(passwordField, 'password123');
      await tester.tap(loginButton);
      await tester.pump();

      // Then
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('로그인'), findsNothing);
    });
  });
}
