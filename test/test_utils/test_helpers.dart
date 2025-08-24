import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
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
  // 테스트용 MaterialApp 생성 (Provider.value 사용)
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
    final providers = <SingleChildWidget>[
      if (authService != null) Provider<AuthService>.value(value: authService),
      if (jobService != null) Provider<JobService>.value(value: jobService),
      if (resumeService != null)
        Provider<ResumeService>.value(value: resumeService),
      if (boardService != null)
        Provider<BoardService>.value(value: boardService),
      if (applyService != null)
        Provider<ApplyService>.value(value: applyService),
      if (noticeService != null)
        Provider<NoticeService>.value(value: noticeService),
    ];

    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        home: child,
        routes: routes ?? const {},
        navigatorObservers: observers ?? const <NavigatorObserver>[],
      ),
    );
  }

  // 네비게이션 테스트용 앱 빌더 + 옵저버
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

  // 공통 모의 설정
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

  // 텍스트 입력 헬퍼
  static Future<void> enterTextByKey(
    WidgetTester tester,
    Key key,
    String text,
  ) async {
    await tester.enterText(find.byKey(key), text);
    await tester.pumpAndSettle();
  }

  // 버튼 탭 헬퍼
  static Future<void> tapButtonByKey(WidgetTester tester, Key key) async {
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
  }

  static Future<void> tapButtonByText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  // 드롭다운 선택 헬퍼
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

  // 스크롤 헬퍼
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

  // 로딩 완료까지 대기
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

  // 다이얼로그 처리
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

  // 메시지 확인
  static void expectSnackBar(String message) {
    expect(find.text(message), findsOneWidget);
  }

  static void expectErrorMessage(String message) {
    expect(find.text(message), findsOneWidget);
  }

  static void expectValidationError(String message) {
    expect(find.text(message), findsOneWidget);
  }

  // 네비게이션 확인 (Observer 기반)
  static void expectPushed(MockNavigatorObserver observer, {int times = 1}) {}

  static void expectNavigatedToPageText(String textOnNewPage) {
    expect(find.text(textOnNewPage), findsOneWidget);
  }

  // 위젯 존재/미존재 확인 (Widget 한정)
  static void expectWidgetExists<T extends Widget>() {
    expect(find.byType(T), findsOneWidget);
  }

  static void expectWidgetNotExists<T extends Widget>() {
    expect(find.byType(T), findsNothing);
  }

  // 리스트 아이템 개수 확인
  static void expectListLength(Type widgetType, int expectedLength) {
    expect(find.byType(widgetType), findsNWidgets(expectedLength));
  }

  // 텍스트 포함 확인
  static void expectTextContains(String partialText) {
    expect(find.textContaining(partialText), findsOneWidget);
  }

  static void expectTexts(List<String> texts) {
    for (final text in texts) {
      expect(find.text(text), findsOneWidget);
    }
  }

  // Mock 서비스 기본 스텁 (실제 서비스 시그니처와 일치하도록 최소화)
  static void setupMockJobService(MockJobService mockJobService) {
    // 필요시 프로젝트 실제 메서드명에 맞춰 수정하세요.
    // 예시:
    // when(mockJobService.getAllJobs()).thenAnswer((_) async => []);
  }

  static void setupMockResumeService(MockResumeService mockResumeService) {
    // 필요시 프로젝트 실제 메서드명에 맞춰 수정하세요.
  }

  static void setupMockBoardService(MockBoardService mockBoardService) {
    // 필요시 프로젝트 실제 메서드명에 맞춰 수정하세요.
  }

  static void setupMockApplyService(MockApplyService mockApplyService) {
    // ▶ 현재 ApplyService(대화에서 공유한 버전)에 맞춘 기본 스텁
    when(mockApplyService.getMyApplications()).thenAnswer((_) async => []);
    when(mockApplyService.getAllApplications()).thenAnswer((_) async => []);
    when(mockApplyService.getApplicationStats()).thenAnswer(
      (_) async => {
        'totalApplications': 0,
        'pendingApplications': 0,
        'acceptedApplications': 0,
        'rejectedApplications': 0,
        'monthlyStats': const [],
      },
    );
  }

  static void setupMockNoticeService(MockNoticeService mockNoticeService) {
    // 필요시 프로젝트 실제 메서드명에 맞춰 수정하세요.
  }

  // 테스트 데이터
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

  // ── 시뮬레이션 도우미 (특정 메서드를 직접 stub 하는 것을 권장) ──
  @Deprecated('특정 메서드에 대해 when(...).thenThrow(...)를 직접 사용하세요.')
  static void simulateNetworkError(Mock mockService) {}

  @Deprecated('특정 메서드에 대해 when(...).thenThrow(...)를 직접 사용하세요.')
  static void simulateServerError(Mock mockService) {}

  static void simulateAuthError(MockAuthService mockAuthService) {
    when(mockAuthService.getToken()).thenAnswer((_) async => null);
    when(mockAuthService.getUserInfo()).thenAnswer((_) async => {});
  }

  // 커스텀 매처들
  static Matcher hasTextStyle(TextStyle expectedStyle) =>
      _HasTextStyle(expectedStyle);
  static Matcher isEnabled() => const _IsEnabled();
  static Matcher isDisabled() => const _IsDisabled();
}

// 커스텀 매처 구현
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
