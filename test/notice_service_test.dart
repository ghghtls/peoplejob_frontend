import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:peoplejob_frontend/services/notice_service.dart';

class MockClient extends Mock implements http.Client {}

@GenerateMocks([http.Client])
void main() {
  group('NoticeService Tests', () {
    late NoticeService noticeService;
    late MockClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockClient();
      noticeService = NoticeService();
    });

    group('공지사항 조회 테스트', () {
      test('모든 공지사항 조회 성공 테스트', () async {
        // Given
        final noticesData = [
          {
            'noticeNo': 1,
            'title': '서비스 업데이트 안내',
            'content': '새로운 기능이 추가되었습니다.',
            'author': '관리자',
            'createdAt': '2024-01-01T10:00:00',
            'isImportant': true,
            'isPublished': true,
            'viewCount': 150,
          },
          {
            'noticeNo': 2,
            'title': '이용약관 변경 안내',
            'content': '이용약관이 일부 변경되었습니다.',
            'author': '관리자',
            'createdAt': '2024-01-02T14:00:00',
            'isImportant': false,
            'isPublished': true,
            'viewCount': 80,
          },
        ];

        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response(jsonEncode(noticesData), 200));

        // When
        final result = await noticeService.getAllNotices();

        // Then
        expect(result, hasLength(2));
        expect(result.first['title'], '서비스 업데이트 안내');
        expect(result.first['isImportant'], true);
        expect(result.last['title'], '이용약관 변경 안내');
        expect(result.last['isImportant'], false);
      });

      test('특정 공지사항 조회 성공 테스트', () async {
        // Given
        const noticeId = 1;
        final noticeData = {
          'noticeNo': 1,
          'title': '서비스 업데이트 안내',
          'content': '새로운 기능이 추가되었습니다. 자세한 내용은 다음과 같습니다...',
          'author': '관리자',
          'createdAt': '2024-01-01T10:00:00',
          'updatedAt': '2024-01-01T10:00:00',
          'isImportant': true,
          'isPublished': true,
          'viewCount': 150,
        };

        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response(jsonEncode(noticeData), 200));

        // When
        final result = await noticeService.getNoticeById(noticeId);

        // Then
        expect(result, isNotNull);
        expect(result!['noticeNo'], 1);
        expect(result['title'], '서비스 업데이트 안내');
        expect(result['isImportant'], true);
      });

      test('존재하지 않는 공지사항 조회 시 null 반환 테스트', () async {
        // Given
        const noticeId = 999;

        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response('Not Found', 404));

        // When
        final result = await noticeService.getNoticeById(noticeId);

        // Then
        expect(result, isNull);
      });
    });

    group('중요 공지사항 테스트', () {
      test('중요 공지사항만 조회 성공 테스트', () async {
        // Given
        final importantNotices = [
          {
            'noticeNo': 1,
            'title': '긴급 서비스 점검 안내',
            'isImportant': true,
            'isPublished': true,
          },
          {
            'noticeNo': 3,
            'title': '보안 업데이트 필수 안내',
            'isImportant': true,
            'isPublished': true,
          },
        ];

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(jsonEncode(importantNotices), 200),
        );

        // When
        final result = await noticeService.getImportantNotices();

        // Then
        expect(result, hasLength(2));
        expect(result.every((notice) => notice['isImportant'] == true), true);
      });
    });

    group('최신 공지사항 테스트', () {
      test('최신 공지사항 조회 성공 테스트', () async {
        // Given
        final recentNotices = [
          {
            'noticeNo': 3,
            'title': '최신 공지사항',
            'createdAt': '2024-01-03T10:00:00',
          },
          {
            'noticeNo': 2,
            'title': '어제 공지사항',
            'createdAt': '2024-01-02T10:00:00',
          },
        ];

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(jsonEncode(recentNotices), 200),
        );

        // When
        final result = await noticeService.getRecentNotices(limit: 5);

        // Then
        expect(result, hasLength(2));
        expect(result.first['noticeNo'], 3);
        expect(result.last['noticeNo'], 2);
      });
    });

    group('공지사항 검색 테스트', () {
      test('제목으로 공지사항 검색 성공 테스트', () async {
        // Given
        const keyword = '업데이트';
        final searchResults = [
          {'noticeNo': 1, 'title': '서비스 업데이트 안내', 'content': '업데이트 내용입니다.'},
        ];

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(jsonEncode(searchResults), 200),
        );

        // When
        final result = await noticeService.searchNotices(keyword);

        // Then
        expect(result, isNotEmpty);
        expect(result.first['title'], contains('업데이트'));
      });

      test('내용으로 공지사항 검색 성공 테스트', () async {
        // Given
        const keyword = '점검';
        final searchResults = [
          {'noticeNo': 2, 'title': '서비스 안내', 'content': '시스템 점검으로 인한 서비스 중단'},
        ];

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(jsonEncode(searchResults), 200),
        );

        // When
        final result = await noticeService.searchNotices(keyword);

        // Then
        expect(result, isNotEmpty);
        expect(result.first['content'], contains('점검'));
      });

      test('빈 키워드로 검색 시 빈 배열 반환 테스트', () async {
        // Given
        const keyword = '';

        // When
        final result = await noticeService.searchNotices(keyword);

        // Then
        expect(result, isEmpty);
      });
    });

    group('조회수 증가 테스트', () {
      test('공지사항 조회수 증가 성공 테스트', () async {
        // Given
        const noticeId = 1;

        when(
          mockHttpClient.patch(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('{"success": true}', 200));

        // When
        final result = await noticeService.incrementViewCount(noticeId);

        // Then
        expect(result, isTrue);
      });

      test('존재하지 않는 공지사항 조회수 증가 시 실패 테스트', () async {
        // Given
        const noticeId = 999;

        when(
          mockHttpClient.patch(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('Not Found', 404));

        // When
        final result = await noticeService.incrementViewCount(noticeId);

        // Then
        expect(result, isFalse);
      });
    });

    group('페이지네이션 테스트', () {
      test('페이지별 공지사항 조회 성공 테스트', () async {
        // Given
        const page = 1;
        const size = 10;
        final pageData = {
          'content': [
            {'noticeNo': 1, 'title': '공지사항 1'},
            {'noticeNo': 2, 'title': '공지사항 2'},
          ],
          'totalElements': 25,
          'totalPages': 3,
          'size': 10,
          'number': 1,
        };

        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response(jsonEncode(pageData), 200));

        // When
        final result = await noticeService.getNoticesWithPagination(
          page: page,
          size: size,
        );

        // Then
        expect(result, isNotNull);
        expect(result!['content'], hasLength(2));
        expect(result['totalElements'], 25);
        expect(result['totalPages'], 3);
      });
    });

    group('에러 처리 테스트', () {
      test('네트워크 오류 시 예외 발생 테스트', () async {
        // Given
        when(mockHttpClient.get(any)).thenThrow(Exception('Network error'));

        // When & Then
        expect(() => noticeService.getAllNotices(), throwsException);
      });

      test('서버 오류 시 예외 발생 테스트', () async {
        // Given
        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response('Server Error', 500));

        // When & Then
        expect(() => noticeService.getAllNotices(), throwsException);
      });

      test('잘못된 JSON 응답 시 예외 발생 테스트', () async {
        // Given
        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response('Invalid JSON', 200));

        // When & Then
        expect(() => noticeService.getAllNotices(), throwsException);
      });
    });
  });
}
