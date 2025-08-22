import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

import 'package:peoplejob_frontend/services/auth_service.dart';
import 'package:peoplejob_frontend/services/job_service.dart';
import 'package:peoplejob_frontend/services/resume_service.dart';
import 'package:peoplejob_frontend/services/board_service.dart';
import 'package:peoplejob_frontend/services/apply_service.dart';
import 'package:peoplejob_frontend/services/notice_service.dart';

class MockAuthService extends Mock implements AuthService {}

class MockJobService extends Mock implements JobService {}

class MockResumeService extends Mock implements ResumeService {}

class MockBoardService extends Mock implements BoardService {}

class MockApplyService extends Mock implements ApplyService {}

class MockNoticeService extends Mock implements NoticeService {}

class TestHelpers {
  // 테스트용 MaterialApp 생성
  static Widget createTestApp(
    Widget child, {
    MockAuthService? authService,
    MockJobService? jobService,
    MockResumeService? resumeService,
    MockBoardService? boardService,
    MockApplyService? applyService,
    MockNoticeService? noticeService,
  }) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          if (authService != null)
            Provider<AuthService>(create: (_) => authService),
          if (jobService != null)
            Provider<JobService>(create: (_) => jobService),
          if (resumeService != null)
            Provider<ResumeService>(create: (_) => resumeService),
          if (boardService != null)
            Provider<BoardService>(create: (_) => boardService),
          if (applyService != null)
            Provider<ApplyService>(create: (_) => applyService),
          if (noticeService != null)
            Provider<NoticeService>(create: (_) => noticeService),
        ],
        child: child,
      ),
    );
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
    final textField = find.byKey(key);
    await tester.enterText(textField, text);
    await tester.pump();
  }

  // 버튼 탭 헬퍼
  static Future<void> tapButtonByKey(WidgetTester tester, Key key) async {
    final button = find.byKey(key);
    await tester.tap(button);
    await tester.pump();
  }

  // 버튼 탭 (텍스트로 찾기)
  static Future<void> tapButtonByText(WidgetTester tester, String text) async {
    final button = find.text(text);
    await tester.tap(button);
    await tester.pump();
  }

  // 드롭다운 선택 헬퍼
  static Future<void> selectDropdownItem(
    WidgetTester tester,
    String dropdownText,
    String itemText,
  ) async {
    // 드롭다운 버튼 찾기
    final dropdown = find.text(dropdownText);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    // 드롭다운 아이템 선택
    final item = find.text(itemText).last;
    await tester.tap(item);
    await tester.pumpAndSettle();
  }

  // 스크롤 헬퍼
  static Future<void> scrollToBottom(WidgetTester tester) async {
    final listView = find.byType(Scrollable);
    await tester.drag(listView, const Offset(0, -500));
    await tester.pumpAndSettle();
  }

  static Future<void> scrollToTop(WidgetTester tester) async {
    final listView = find.byType(Scrollable);
    await tester.drag(listView, const Offset(0, 500));
    await tester.pumpAndSettle();
  }

  // 로딩 완료까지 대기
  static Future<void> waitForLoading(WidgetTester tester) async {
    while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  // 다이얼로그 대기 및 처리
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

  // 스낵바 메시지 확인
  static void expectSnackBar(String message) {
    expect(find.text(message), findsOneWidget);
  }

  // 에러 메시지 확인
  static void expectErrorMessage(String message) {
    expect(find.text(message), findsOneWidget);
  }

  // 폼 유효성 검사 메시지 확인
  static void expectValidationError(String message) {
    expect(find.text(message), findsOneWidget);
  }

  // 네비게이션 확인
  static void expectNavigatedTo(String routeName) {
    // 실제 구현에서는 Navigator observer 등을 사용
    expect(find.byType(MaterialPageRoute), findsOneWidget);
  }

  // 위젯 존재 확인
  static void expectWidgetExists<T>() {
    expect(find.byType(T), findsOneWidget);
  }

  static void expectWidgetNotExists<T>() {
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

  // 여러 텍스트 확인
  static void expectTexts(List<String> texts) {
    for (String text in texts) {
      expect(find.text(text), findsOneWidget);
    }
  }

  // Mock 서비스 설정 헬퍼들
  static void setupMockJobService(MockJobService mockJobService) {
    when(mockJobService.getAllJobs()).thenAnswer((_) async => []);
    when(mockJobService.getJobById(any)).thenAnswer((_) async => null);
    when(mockJobService.searchJobs(any)).thenAnswer((_) async => []);
  }

  static void setupMockResumeService(MockResumeService mockResumeService) {
    when(mockResumeService.getAllResumes()).thenAnswer((_) async => []);
    when(mockResumeService.getUserResumes(any)).thenAnswer((_) async => []);
    when(mockResumeService.getResumeById(any)).thenAnswer((_) async => null);
  }

  static void setupMockBoardService(MockBoardService mockBoardService) {
    when(mockBoardService.getAllBoards()).thenAnswer((_) async => []);
    when(mockBoardService.getBoardById(any)).thenAnswer((_) async => null);
    when(mockBoardService.searchBoards(any)).thenAnswer((_) async => []);
  }

  static void setupMockApplyService(MockApplyService mockApplyService) {
    when(mockApplyService.getUserApplications(any)).thenAnswer((_) async => []);
    when(
      mockApplyService.getApplicationById(any),
    ).thenAnswer((_) async => null);
    when(mockApplyService.getApplicationStats(any)).thenAnswer(
      (_) async => {
        'totalApplications': 0,
        'pendingApplications': 0,
        'acceptedApplications': 0,
        'rejectedApplications': 0,
      },
    );
  }

  static void setupMockNoticeService(MockNoticeService mockNoticeService) {
    when(mockNoticeService.getAllNotices()).thenAnswer((_) async => []);
    when(mockNoticeService.getNoticeById(any)).thenAnswer((_) async => null);
    when(mockNoticeService.getImportantNotices()).thenAnswer((_) async => []);
    when(mockNoticeService.getRecentNotices()).thenAnswer((_) async => []);
  }

  // 테스트 데이터 생성 헬퍼
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

  // 네트워크 오류 시뮬레이션
  static void simulateNetworkError(Mock mockService) {
    when(mockService.noSuchMethod(any)).thenThrow(Exception('Network error'));
  }

  // 서버 오류 시뮬레이션
  static void simulateServerError(Mock mockService) {
    when(mockService.noSuchMethod(any)).thenThrow(Exception('Server error'));
  }

  // 인증 오류 시뮬레이션
  static void simulateAuthError(MockAuthService mockAuthService) {
    when(mockAuthService.getToken()).thenAnswer((_) async => null);
    when(mockAuthService.getUserInfo()).thenAnswer((_) async => {});
  }

  // 커스텀 매처들
  static Matcher hasTextStyle(TextStyle expectedStyle) {
    return _HasTextStyle(expectedStyle);
  }

  static Matcher isEnabled() {
    return _IsEnabled();
  }

  static Matcher isDisabled() {
    return _IsDisabled();
  }
}

// 커스텀 매처 구현
class _HasTextStyle extends Matcher {
  final TextStyle expectedStyle;

  _HasTextStyle(this.expectedStyle);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Text) return false;
    return item.style == expectedStyle;
  }

  @override
  Description describe(Description description) {
    return description.add('has text style $expectedStyle');
  }
}

class _IsEnabled extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is ElevatedButton) return item.onPressed != null;
    if (item is TextButton) return item.onPressed != null;
    if (item is OutlinedButton) return item.onPressed != null;
    if (item is IconButton) return item.onPressed != null;
    return false;
  }

  @override
  Description describe(Description description) {
    return description.add('is enabled');
  }
}

class _IsDisabled extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is ElevatedButton) return item.onPressed == null;
    if (item is TextButton) return item.onPressed == null;
    if (item is OutlinedButton) return item.onPressed == null;
    if (item is IconButton) return item.onPressed == null;
    return false;
  }

  @override
  Description describe(Description description) {
    return description.add('is disabled');
  }
}
