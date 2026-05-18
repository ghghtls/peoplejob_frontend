import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:peoplejob_frontend/services/auth_service.dart';
import 'package:peoplejob_frontend/services/job_service.dart';
import 'package:peoplejob_frontend/services/resume_service.dart';
import 'package:peoplejob_frontend/services/board_service.dart';
import 'package:peoplejob_frontend/services/apply_service.dart';
import 'package:peoplejob_frontend/services/notice_service.dart';

// ---- Mocks ----
class MockAuthService extends Mock implements AuthService {}

class MockJobService extends Mock implements JobService {}

class MockResumeService extends Mock implements ResumeService {}

class MockBoardService extends Mock implements BoardService {}

class MockApplyService extends Mock implements ApplyService {}

class MockNoticeService extends Mock implements NoticeService {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class TestHelpers {
  static Widget createTestApp(
    Widget child, {
    MockAuthService? authService,
    MockJobService? jobService,
    MockResumeService? resumeService,
    MockBoardService? boardService,
    MockApplyService? applyService,
    MockNoticeService? noticeService,
    Map<String, WidgetBuilder>? routes,
    List<NavigatorObserver>? observers,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: child,
        routes: routes ?? const {},
        navigatorObservers: observers ?? const <NavigatorObserver>[],
      ),
    );
  }

  static (Widget app, MockNavigatorObserver observer) buildAppWithObserver(
    Widget child, {
    MockAuthService? authService,
    MockJobService? jobService,
    MockResumeService? resumeService,
    MockBoardService? boardService,
    MockApplyService? applyService,
    MockNoticeService? noticeService,
    Map<String, WidgetBuilder>? routes,
  }) {
    final observer = MockNavigatorObserver();
    final app = createTestApp(
      child,
      authService: authService,
      jobService: jobService,
      resumeService: resumeService,
      boardService: boardService,
      applyService: applyService,
      noticeService: noticeService,
      routes: routes,
      observers: [observer],
    );
    return (app, observer);
  }

  static void setupMockAuthService(MockAuthService mockAuthService) {
    when(mockAuthService.getToken()).thenAnswer((_) async => 'mock-token');
    when(mockAuthService.getUserNo()).thenAnswer((_) async => 1);
    when(mockAuthService.getUserInfo()).thenAnswer(
      (_) async => {
        'userid': 'testuser',
        'userNo': '1',
        'name': '테스트 사용자',
        'email': 'test@example.com',
        'userType': 'INDIVIDUAL',
        'role': 'USER',
      },
    );
  }

  static Future<void> enterTextByKey(
    WidgetTester tester,
    Key key,
    String text,
  ) async {
    await tester.enterText(find.byKey(key), text);
    await tester.pumpAndSettle();
  }

  static Future<void> tapButtonByKey(WidgetTester tester, Key key) async {
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
  }

  static Future<void> tapButtonByText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  static Future<void> selectDropdownItem(
    WidgetTester tester,
    String dropdownText,
    String itemText,
  ) async {
    await tester.tap(find.text(dropdownText));
    await tester.pumpAndSettle();
    await tester.tap(find.text(itemText).last);
    await tester.pumpAndSettle();
  }

  static Future<void> scrollToBottom(WidgetTester tester) async {
    final scrollable = find.byType(Scrollable);
    await tester.drag(scrollable, const Offset(0, -500));
    await tester.pumpAndSettle();
  }

  static Future<void> scrollToTop(WidgetTester tester) async {
    final scrollable = find.byType(Scrollable);
    await tester.drag(scrollable, const Offset(0, 500));
    await tester.pumpAndSettle();
  }

  static Future<void> waitForLoading(
    WidgetTester tester, {
    Duration step = const Duration(milliseconds: 100),
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final end = DateTime.now().add(timeout);
    while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
      if (DateTime.now().isAfter(end)) break;
      await tester.pump(step);
    }
    await tester.pumpAndSettle();
  }

  static Future<void> handleDialog(
    WidgetTester tester,
    String buttonText,
  ) async {
    await tester.pumpAndSettle();
    final button = find.text(buttonText);
    if (button.evaluate().isNotEmpty) {
      await tester.tap(button);
      await tester.pumpAndSettle();
    }
  }

  static void expectSnackBar(String message) {
    expect(find.text(message), findsOneWidget);
  }

  static void expectErrorMessage(String message) {
    expect(find.text(message), findsOneWidget);
  }

  static void expectValidationError(String message) {
    expect(find.text(message), findsOneWidget);
  }

  static void expectPushed(MockNavigatorObserver observer, {int times = 1}) {}

  static void expectNavigatedToPageText(String textOnNewPage) {
    expect(find.text(textOnNewPage), findsOneWidget);
  }

  static void expectWidgetExists<T extends Widget>() {
    expect(find.byType(T), findsOneWidget);
  }

  static void expectWidgetNotExists<T extends Widget>() {
    expect(find.byType(T), findsNothing);
  }

  static void expectListLength(Type widgetType, int expectedLength) {
    expect(find.byType(widgetType), findsNWidgets(expectedLength));
  }

  static void expectTextContains(String partialText) {
    expect(find.textContaining(partialText), findsOneWidget);
  }

  static void expectTexts(List<String> texts) {
    for (final text in texts) {
      expect(find.text(text), findsOneWidget);
    }
  }

  static void setupMockJobService(MockJobService mockJobService) {}

  static void setupMockResumeService(MockResumeService mockResumeService) {}

  static void setupMockBoardService(MockBoardService mockBoardService) {}

  static void setupMockApplyService(MockApplyService mockApplyService) {
    when(mockApplyService.getMyApplications()).thenAnswer((_) async => []);
    when(mockApplyService.getAllApplications()).thenAnswer((_) async => []);
  }

  static void setupMockNoticeService(MockNoticeService mockNoticeService) {}

  static Map<String, dynamic> createTestJob({
    int id = 1,
    String title = '테스트 채용공고',
    String company = '테스트 회사',
  }) {
    return {
      'jobopeningNo': id,
      'title': title,
      'company': company,
      'content': '채용공고 내용',
      'location': '서울',
      'jobtype': '정규직',
      'salary': '협의',
      'education': '대졸',
      'career': '경력무관',
      'deadline': '2024-12-31',
      'regdate': '2024-01-01T00:00:00',
    };
  }

  static Map<String, dynamic> createTestResume({
    int id = 1,
    String title = '테스트 이력서',
    String name = '홍길동',
  }) {
    return {
      'resumeNo': id,
      'title': title,
      'name': name,
      'content': '이력서 내용',
      'email': 'test@example.com',
      'phone': '010-1234-5678',
      'education': '대졸',
      'career': '3년',
      'skills': 'Java, Spring',
      'hopeJobtype': '개발자',
      'hopeLocation': '서울',
      'regdate': '2024-01-01T00:00:00',
    };
  }

  static Map<String, dynamic> createTestBoard({
    int id = 1,
    String title = '테스트 게시글',
    String category = '자유게시판',
  }) {
    return {
      'boardNo': id,
      'title': title,
      'category': category,
      'content': '게시글 내용',
      'writer': '홍길동',
      'regdate': '2024-01-01',
      'viewCount': 10,
    };
  }

  @Deprecated('특정 메서드에 대해 when(...).thenThrow(...)를 직접 사용하세요.')
  static void simulateNetworkError(Mock mockService) {}

  @Deprecated('특정 메서드에 대해 when(...).thenThrow(...)를 직접 사용하세요.')
  static void simulateServerError(Mock mockService) {}

  static void simulateAuthError(MockAuthService mockAuthService) {
    when(mockAuthService.getToken()).thenAnswer((_) async => null);
    when(mockAuthService.getUserInfo()).thenAnswer((_) async => {});
  }

  static Matcher hasTextStyle(TextStyle expectedStyle) =>
      _HasTextStyle(expectedStyle);
  static Matcher isEnabled() => const _IsEnabled();
  static Matcher isDisabled() => const _IsDisabled();
}

class _HasTextStyle extends Matcher {
  final TextStyle expected;
  _HasTextStyle(this.expected);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Text) return false;
    final s = item.style;
    if (s == null) return false;
    bool ok = true;
    if (expected.fontSize != null) ok &= s.fontSize == expected.fontSize;
    if (expected.fontWeight != null) ok &= s.fontWeight == expected.fontWeight;
    if (expected.color != null) ok &= s.color == expected.color;
    if (expected.decoration != null) ok &= s.decoration == expected.decoration;
    if (expected.fontStyle != null) ok &= s.fontStyle == expected.fontStyle;
    return ok;
  }

  @override
  Description describe(Description description) =>
      description.add('has partial TextStyle match: $expected');
}

class _IsEnabled extends Matcher {
  const _IsEnabled();
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is ElevatedButton) return item.onPressed != null;
    if (item is TextButton) return item.onPressed != null;
    if (item is OutlinedButton) return item.onPressed != null;
    if (item is IconButton) return item.onPressed != null;
    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('is enabled');
}

class _IsDisabled extends Matcher {
  const _IsDisabled();
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is ElevatedButton) return item.onPressed == null;
    if (item is TextButton) return item.onPressed == null;
    if (item is OutlinedButton) return item.onPressed == null;
    if (item is IconButton) return item.onPressed == null;
    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('is disabled');
}
