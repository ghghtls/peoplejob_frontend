import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:peoplejob_frontend/services/board_service.dart';

class MockClient extends Mock implements http.Client {}

@GenerateMocks([http.Client])
void main() {
  group('BoardService Tests', () {
    late BoardService boardService;
    late MockClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockClient();
      boardService = BoardService();
    });

    group('게시글 조회 테스트', () {
      test('모든 게시글 조회 성공 테스트', () async {
        // Given
        final boardsData = [
          {
            'boardNo': 1,
            'category': '공지사항',
            'title': '서비스 점검 안내',
            'content': '서버 점검으로 인한 서비스 일시 중단 안내입니다.',
            'writer': '관리자',
            'regdate': '2024-01-01',
            'viewCount': 100,
          },
          {
            'boardNo': 2,
            'category': '자유게시판',
            'title': '취업 후기 공유',
            'content': '면접 후기를 공유합니다.',
            'writer': '홍길동',
            'regdate': '2024-01-02',
            'viewCount': 50,
          },
        ];

        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response(jsonEncode(boardsData), 200));

        // When
        final result = await boardService.getAllBoards();

        // Then
        expect(result, hasLength(2));
        expect(result.first['title'], '서비스 점검 안내');
        expect(result.last['title'], '취업 후기 공유');
      });

      test('특정 게시글 조회 성공 테스트', () async {
        // Given
        const boardId = 1;
        final boardData = {
          'boardNo': 1,
          'category': '공지사항',
          'title': '서비스 점검 안내',
          'content': '서버 점검으로 인한 서비스 일시 중단 안내입니다.',
          'writer': '관리자',
          'regdate': '2024-01-01',
          'viewCount': 100,
        };

        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response(jsonEncode(boardData), 200));

        // When
        final result = await boardService.getBoardById(boardId);

        // Then
        expect(result, isNotNull);
        expect(result!['boardNo'], 1);
        expect(result['title'], '서비스 점검 안내');
        expect(result['category'], '공지사항');
      });

      test('존재하지 않는 게시글 조회 시 null 반환 테스트', () async {
        // Given
        const boardId = 999;

        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response('Not Found', 404));

        // When
        final result = await boardService.getBoardById(boardId);

        // Then
        expect(result, isNull);
      });
    });

    group('게시글 등록/수정 테스트', () {
      test('게시글 등록 성공 테스트', () async {
        // Given
        final boardData = {
          'category': '자유게시판',
          'title': '새로운 게시글',
          'content': '게시글 내용입니다.',
          'writer': '홍길동',
        };

        final createdBoard = {
          'boardNo': 1,
          ...boardData,
          'regdate': '2024-01-01',
          'viewCount': 0,
        };

        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(createdBoard), 201));

        // When
        final result = await boardService.createBoard(boardData);

        // Then
        expect(result, isNotNull);
        expect(result!['boardNo'], 1);
        expect(result['title'], '새로운 게시글');
        expect(result['writer'], '홍길동');
      });

      test('게시글 수정 성공 테스트', () async {
        // Given
        const boardId = 1;
        final updateData = {'title': '수정된 제목', 'content': '수정된 내용'};

        final updatedBoard = {
          'boardNo': 1,
          'category': '자유게시판',
          'title': '수정된 제목',
          'content': '수정된 내용',
          'writer': '홍길동',
          'regdate': '2024-01-01',
          'viewCount': 10,
        };

        when(
          mockHttpClient.put(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(updatedBoard), 200));

        // When
        final result = await boardService.updateBoard(boardId, updateData);

        // Then
        expect(result, isNotNull);
        expect(result!['title'], '수정된 제목');
        expect(result['content'], '수정된 내용');
      });

      test('게시글 삭제 성공 테스트', () async {
        // Given
        const boardId = 1;

        when(
          mockHttpClient.delete(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('', 204));

        // When
        final result = await boardService.deleteBoard(boardId);

        // Then
        expect(result, isTrue);
      });
    });

    group('게시글 검색 테스트', () {
      test('제목으로 게시글 검색 성공 테스트', () async {
        // Given
        const keyword = '점검';
        final searchResults = [
          {
            'boardNo': 1,
            'title': '서비스 점검 안내',
            'content': '점검 내용',
            'writer': '관리자',
          },
        ];

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(jsonEncode(searchResults), 200),
        );

        // When
        final result = await boardService.searchBoards(keyword);

        // Then
        expect(result, isNotEmpty);
        expect(result.first['title'], contains('점검'));
      });

      test('내용으로 게시글 검색 성공 테스트', () async {
        // Given
        const keyword = '면접';
        final searchResults = [
          {
            'boardNo': 2,
            'title': '취업 후기',
            'content': '면접 경험을 공유합니다',
            'writer': '홍길동',
          },
        ];

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(jsonEncode(searchResults), 200),
        );

        // When
        final result = await boardService.searchBoards(keyword);

        // Then
        expect(result, isNotEmpty);
        expect(result.first['content'], contains('면접'));
      });
    });

    group('카테고리별 게시글 조회 테스트', () {
      test('공지사항 카테고리 조회 성공 테스트', () async {
        // Given
        const category = '공지사항';
        final noticeBoards = [
          {
            'boardNo': 1,
            'category': '공지사항',
            'title': '서비스 점검 안내',
            'writer': '관리자',
          },
        ];

        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response(jsonEncode(noticeBoards), 200));

        // When
        final result = await boardService.getBoardsByCategory(category);

        // Then
        expect(result, isNotEmpty);
        expect(result.first['category'], '공지사항');
      });

      test('자유게시판 카테고리 조회 성공 테스트', () async {
        // Given
        const category = '자유게시판';
        final freeBoards = [
          {
            'boardNo': 2,
            'category': '자유게시판',
            'title': '취업 후기',
            'writer': '홍길동',
          },
        ];

        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response(jsonEncode(freeBoards), 200));

        // When
        final result = await boardService.getBoardsByCategory(category);

        // Then
        expect(result, isNotEmpty);
        expect(result.first['category'], '자유게시판');
      });
    });

    group('조회수 증가 테스트', () {
      test('게시글 조회수 증가 성공 테스트', () async {
        // Given
        const boardId = 1;

        when(
          mockHttpClient.patch(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('{"success": true}', 200));

        // When
        final result = await boardService.incrementViewCount(boardId);

        // Then
        expect(result, isTrue);
      });

      test('존재하지 않는 게시글 조회수 증가 시 실패 테스트', () async {
        // Given
        const boardId = 999;

        when(
          mockHttpClient.patch(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('Not Found', 404));

        // When
        final result = await boardService.incrementViewCount(boardId);

        // Then
        expect(result, isFalse);
      });
    });

    group('에러 처리 테스트', () {
      test('네트워크 오류 시 예외 발생 테스트', () async {
        // Given
        when(mockHttpClient.get(any)).thenThrow(Exception('Network error'));

        // When & Then
        expect(() => boardService.getAllBoards(), throwsException);
      });

      test('서버 오류 시 예외 발생 테스트', () async {
        // Given
        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response('Server Error', 500));

        // When & Then
        expect(() => boardService.getAllBoards(), throwsException);
      });

      test('잘못된 JSON 응답 시 예외 발생 테스트', () async {
        // Given
        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response('Invalid JSON', 200));

        // When & Then
        expect(() => boardService.getAllBoards(), throwsException);
      });
    });
  });
}
