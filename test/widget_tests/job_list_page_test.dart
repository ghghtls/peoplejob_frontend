import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:peoplejob_frontend/ui/pages/job/job_list_page.dart';
import 'package:peoplejob_frontend/services/job_service.dart';

class MockJobService extends Mock implements JobService {}

void main() {
  group('JobListPage Widget Tests', () {
    late MockJobService mockJobService;

    setUp(() {
      mockJobService = MockJobService();
    });

    testWidgets('채용공고 목록 페이지 기본 UI 렌더링 테스트', (WidgetTester tester) async {
      // Given
      when(mockJobService.getAllJobs()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<JobService>(
            create: (_) => mockJobService,
            child: const JobListPage(),
          ),
        ),
      );

      // Then
      expect(find.text('채용공고'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget); // 검색창
      expect(find.byType(DropdownButtonFormField), findsNWidgets(2)); // 필터 드롭다운
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('채용공고 목록 로딩 상태 테스트', (WidgetTester tester) async {
      // Given
      when(mockJobService.getAllJobs()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return [];
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<JobService>(
            create: (_) => mockJobService,
            child: const JobListPage(),
          ),
        ),
      );

      // Then
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('채용공고 목록 표시 테스트', (WidgetTester tester) async {
      // Given
      final jobsData = [
        {
          'jobopeningNo': 1,
          'title': '백엔드 개발자 모집',
          'company': '테스트 회사',
          'location': '서울',
          'jobtype': '정규직',
          'salary': '협의',
          'education': '대졸',
          'career': '경력무관',
          'deadline': '2024-12-31',
          'regdate': '2024-01-01T00:00:00',
        },
        {
          'jobopeningNo': 2,
          'title': '프론트엔드 개발자 모집',
          'company': '테스트 회사2',
          'location': '부산',
          'jobtype': '계약직',
          'salary': '3000만원',
          'education': '대졸',
          'career': '2년 이상',
          'deadline': '2024-11-30',
          'regdate': '2024-01-02T00:00:00',
        }
      ];

      when(mockJobService.getAllJobs()).thenAnswer((_) async => jobsData);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<JobService>(
            create: (_) => mockJobService,
            child: const JobListPage(),
          ),
        ),
      );

      await tester.pump(); // 로딩 완료 대기

      // Then
      expect(find.text('백엔드 개발자 모집'), findsOneWidget);
      expect(find.text('프론트엔드 개발자 모집'), findsOneWidget);
      expect(find.text('테스트 회사'), findsOneWidget);
      expect(find.text('테스트 회사2'), findsOneWidget);
      expect(find.text('총 2개의 채용공고'), findsOneWidget);
    });

    testWidgets('채용공고 검색 테스트', (WidgetTester tester) async {
      // Given
      final jobsData = [
        {
          'jobopeningNo': 1,
          'title': '백엔드 개발자 모집',
          'content': 'Java Spring 개발자',
          'company': '테스트 회사',
        },
        {
          'jobopeningNo': 2,
          'title': '프론트엔드 개발자 모집',
          'content': 'React 개발자',
          'company': '테스트 회사2',
        }
      ];

      when(mockJobService.getAllJobs()).thenAnswer((_) async => jobsData);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<JobService>(
            create: (_) => mockJobService,
            child: const JobListPage(),
          ),
        ),
      );

      await tester.pump();

      // When
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, '백엔드');
      await tester.pump();

      // Then
      expect(find.text('백엔드 개발자 모집'), findsOneWidget);
      expect(find.text('프론트엔드 개발자 모집'), findsNothing);
      expect(find.text('총 1개의 채용공고'), findsOneWidget);
    });

    testWidgets('고용형태 필터링 테스트', (WidgetTester tester) async {
      // Given
      final jobsData = [
        {
          'jobopeningNo': 1,
          'title': '백엔드 개발자 모집',
          'jobtype': '정규직',
          'company': '테스트 회사',
        },
        {
          'jobopeningNo': 2,
          'title': '프론트엔드 개발자 모집',
          'jobtype': '계약직',
          'company': '테스트 회사2',
        }
      ];

      when(mockJobService.getAllJobs()).thenAnswer((_) async => jobsData);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<JobService>(
            create: (_) => mockJobService,
            child: const JobListPage(),
          ),
        ),
      );

      await tester.pump();

      // When
      final jobTypeDropdown = find.byType(DropdownButtonFormField).first;
      await tester.tap(jobTypeDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('정규직').last);
      await tester.pumpAndSettle();

      // Then
      expect(find.text('백엔드 개발자 모집'), findsOneWidget);
      expect(find.text('프론트엔드 개발자 모집'), findsNothing);
    });

    testWidgets('지역 필터링 테스트', (WidgetTester tester) async {
      // Given
      final jobsData = [
        {
          'jobopeningNo': 1,
          'title': '백엔드 개발자 모집',
          'location': '서울',
          'company': '테스트 회사',
        },
        {
          'jobopeningNo': 2,
          'title': '프론트엔드 개발자 모집',
          'location': '부산',
          'company': '테스트 회사2',
        }
      ];

      when(mockJobService.getAllJobs()).thenAnswer((_) async => jobsData);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<JobService>(
            create: (_) => mockJobService,
            child: const JobListPage(),
          ),
        ),
      );

      await tester.pump();

      // When
      final locationDropdown = find.byType(DropdownButtonFormField).last;
      await tester.tap(locationDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('서울').last);
      await tester.pumpAndSettle();

      // Then
      expect(find.text('백엔드 개발자 모집'), findsOneWidget);
      expect(find.text('프론트엔드 개발자 모집'), findsNothing);
    });

    testWidgets('채용공고 카드 탭 테스트', (WidgetTester tester) async {
      // Given
      final jobsData = [
        {
          'jobopeningNo': 1,
          'title': '백엔드 개발자 모집',
          'company': '테스트 회사',
        }
      ];

      when(mockJobService.getAllJobs()).thenAnswer((_)when(mockJobService.getAllJobs()).thenAnswer((_) async => jobsData);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<JobService>(
            create: (_) => mockJobService,
            child: const JobListPage(),
          ),
          routes: {
            '/job-detail': (context) => const Scaffold(
              body: Text('Job Detail Page'),
            ),
          },
        ),
      );

      await tester.pump();

      // When
      final jobCard = find.byType(Card).first;
      await tester.tap(jobCard);
      await tester.pumpAndSettle();

      // Then
      expect(find.text('Job Detail Page'), findsOneWidget);
    });

    testWidgets('빈 채용공고 목록 표시 테스트', (WidgetTester tester) async {
      // Given
      when(mockJobService.getAllJobs()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<JobService>(
            create: (_) => mockJobService,
            child: const JobListPage(),
          ),
        ),
      );

      await tester.pump();

      // Then
      expect(find.text('검색 결과가 없습니다'), findsOneWidget);
      expect(find.text('다른 키워드로 검색해보세요'), findsOneWidget);
      expect(find.byIcon(Icons.work_off), findsOneWidget);
    });

    testWidgets('새로고침 버튼 테스트', (WidgetTester tester) async {
      // Given
      when(mockJobService.getAllJobs()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<JobService>(
            create: (_) => mockJobService,
            child: const JobListPage(),
          ),
        ),
      );

      await tester.pump();

      // When
      final refreshButton = find.byIcon(Icons.refresh);
      await tester.tap(refreshButton);

      // Then
      verify(mockJobService.getAllJobs()).called(2); // 초기 로딩 + 새로고침
    });

    testWidgets('FloatingActionButton 테스트', (WidgetTester tester) async {
      // Given
      when(mockJobService.getAllJobs()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<JobService>(
            create: (_) => mockJobService,
            child: const JobListPage(),
          ),
          routes: {
            '/job-register': (context) => const Scaffold(
              body: Text('Job Register Page'),
            ),
          },
        ),
      );

      await tester.pump();

      // When
      final fab = find.byType(FloatingActionButton);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Then
      expect(find.text('Job Register Page'), findsOneWidget);
    });

    testWidgets('마감된 채용공고 표시 테스트', (WidgetTester tester) async {
      // Given
      final expiredJob = {
        'jobopeningNo': 1,
        'title': '만료된 채용공고',
        'company': '테스트 회사',
        'deadline': '2023-12-31', // 과거 날짜
      };

      when(mockJobService.getAllJobs()).thenAnswer((_) async => [expiredJob]);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<JobService>(
            create: (_) => mockJobService,
            child: const JobListPage(),
          ),
        ),
      );

      await tester.pump();

      // Then
      expect(find.text('마감'), findsOneWidget);
      // 마감된 공고는 취소선이 그어져 있어야 함
    });

    testWidgets('RefreshIndicator 테스트', (WidgetTester tester) async {
      // Given
      when(mockJobService.getAllJobs()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<JobService>(
            create: (_) => mockJobService,
            child: const JobListPage(),
          ),
        ),
      );

      await tester.pump();

      // When
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();

      // Then
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}