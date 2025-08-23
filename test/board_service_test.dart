import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:peoplejob_frontend/services/board_service.dart';

// Mock 클래스들
class MockDio extends Mock implements Dio {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockResponse extends Mock implements Response {}

class MockRequestOptions extends Mock implements RequestOptions {}

@GenerateMocks([Dio, FlutterSecureStorage])
void main() {
  group('BoardService Tests', () {
    late BoardService boardService;
    late MockDio mockDio;
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      mockDio = MockDio();
      mockStorage = MockFlutterSecureStorage();

      // BoardService를 테스트용으로 초기화
      boardService = BoardService();

      // 기본 토큰 설정
      when(
        mockStorage.read(key: 'jwt'),
      ).thenAnswer((_) async => 'mock-jwt-token');
    });

    group('게시글 조회 테스트', () {
      test('모든 게시글 조회 성공 테스트', () async {
        // Given
        final mockBoards = [
          {
            'boardNo': 1,
            'category': '공지사항',
            'title': '서비스 점검 안내',
            'content': '서버 점검으로 인한 서비스 일시 중단 안내입니다.',
            'writer': '관리자',
            'userid': 'admin',
            'regdate': '2024-01-01',
            'viewCount': 150,
            'isNotice': true,
          },
          {
            'boardNo': 2,
            'category': '자유게시판',
            'title': '취업 후기 공유',
            'content': '면접 경험을 공유합니다.',
            'writer': '홍길동',
            'userid': 'hong123',
            'regdate': '2024-01-02',
            'viewCount': 85,
            'isNotice': false,
          },
          {
            'boardNo': 3,
            'category': 'QnA',
            'title': '이력서 작성 문의',
            'content': '이력서 작성 시 주의사항이 있나요?',
            'writer': '김철수',
            'userid': 'kim456',
            'regdate': '2024-01-03',
            'viewCount': 32,
            'isNotice': false,
          },
        ];

        final mockResponse = MockResponse();
        when(mockResponse.data).thenReturn(mockBoards);
        when(mockDio.get('/api/board')).thenAnswer((_) async => mockResponse);

        // When
        final result = await boardService.getAllBoards();

        // Then
        expect(result, hasLength(3));
        expect(result[0]['title'], '서비스 점검 안내');
        expect(result[0]['category'], '공지사항');
        expect(result[0]['isNotice'], true);
        expect(result[1]['title'], '취업 후기 공유');
        expect(result[1]['category'], '자유게시판');
        expect(result[2]['title'], '이력서 작성 문의');
        expect(result[2]['category'], 'QnA');

        verify(mockDio.get('/api/board')).called(1);
      });

      test('카테고리별 게시글 조회 성공 테스트', () async {
        // Given
        const category = '공지사항';
        final mockNoticeBoards = [
          {
            'boardNo': 1,
            'category': '공지사항',
            'title': '서비스 점검 안내',
            'content': '서버 점검 안내',
            'writer': '관리자',
            'isNotice': true,
            'viewCount': 150,
          },
          {
            'boardNo': 4,
            'category': '공지사항',
            'title': '새 기능 업데이트',
            'content': '새로운 기능이 추가되었습니다',
            'writer': '관리자',
            'isNotice': true,
            'viewCount': 95,
          },
        ];

        final mockResponse = MockResponse();
        when(mockResponse.data).thenReturn(mockNoticeBoards);
        when(
          mockDio.get('/api/board/category/$category'),
        ).thenAnswer((_) async => mockResponse);

        // When
        final result = await boardService.getBoardsByCategory(category);

        // Then
        expect(result, hasLength(2));
        expect(result.every((board) => board['category'] == '공지사항'), true);
        expect(result.every((board) => board['isNotice'] == true), true);

        verify(mockDio.get('/api/board/category/$category')).called(1);
      });

      test('게시글 상세 조회 성공 테스트', () async {
        // Given
        const boardNo = 1;
        final mockBoardDetail = {
          'boardNo': 1,
          'category': '공지사항',
          'title': '서비스 점검 안내',
          'content': '''
서버 점검으로 인한 서비스 일시 중단 안내입니다.

점검 일시: 2024년 1월 15일 02:00 ~ 06:00
점검 내용: 서버 성능 최적화 및 보안 업데이트

점검 시간 중에는 서비스 이용이 불가능합니다.
이용에 불편을 드려 죄송합니다.
          ''',
          'writer': '관리자',
          'userid': 'admin',
          'regdate': '2024-01-01T10:00:00',
          'viewCount': 150,
          'isNotice': true,
          'attachments': [
            {
              'fileNo': 1,
              'fileName': '점검_안내.pdf',
              'fileUrl': '/files/notice_1.pdf',
            },
          ],
        };

        final mockResponse = MockResponse();
        when(mockResponse.data).thenReturn(mockBoardDetail);
        when(
          mockDio.get('/api/board/$boardNo'),
        ).thenAnswer((_) async => mockResponse);

        // When
        final result = await boardService.getBoardDetail(boardNo);

        // Then
        expect(result['boardNo'], 1);
        expect(result['title'], '서비스 점검 안내');
        expect(result['content'], contains('점검 일시'));
        expect(result['writer'], '관리자');
        expect(result['viewCount'], 150);
        expect(result['attachments'], hasLength(1));

        verify(mockDio.get('/api/board/$boardNo')).called(1);
      });

      test('존재하지 않는 게시글 조회 시 예외 발생 테스트', () async {
        // Given
        const boardNo = 999;

        final dioException = DioException(
          requestOptions: MockRequestOptions(),
          response: MockResponse()..statusCode = 404,
          type: DioExceptionType.badResponse,
        );

        when(mockDio.get('/api/board/$boardNo')).thenThrow(dioException);

        // When & Then
        expect(
          () => boardService.getBoardDetail(boardNo),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('게시글 상세 정보를 불러오는데 실패했습니다'),
            ),
          ),
        );
      });
    });

    group('게시글 등록/수정/삭제 테스트', () {
      test('게시글 등록 성공 테스트', () async {
        // Given
        final boardData = {
          'category': '자유게시판',
          'title': '새로운 게시글 제목',
          'content': '게시글 내용입니다. 여러 줄로 작성된 내용입니다.',
          'writer': '홍길동',
          'userid': 'hong123',
          'isNotice': false,
        };

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(201);
        when(mockResponse.data).thenReturn({
          'boardNo': 5,
          'success': true,
          'message': '게시글이 성공적으로 등록되었습니다.',
        });

        when(
          mockDio.post('/api/board', data: anyNamed('data')),
        ).thenAnswer((_) async => mockResponse);

        // When
        final result = await boardService.createBoard(boardData);

        // Then
        expect(result, isTrue);

        verify(
          mockDio.post(
            '/api/board',
            data: argThat(
              allOf([
                containsPair('category', '자유게시판'),
                containsPair('title', '새로운 게시글 제목'),
                containsPair('content', contains('게시글 내용')),
                containsPair('writer', '홍길동'),
                containsPair('isNotice', false),
              ]),
              named: 'data',
            ),
          ),
        ).called(1);
      });

      test('필수 필드 누락으로 게시글 등록 실패 테스트', () async {
        // Given
        final invalidBoardData = {
          'category': '자유게시판',
          // title 누락
          'content': '내용만 있는 게시글',
          'writer': '홍길동',
        };

        final dioException = DioException(
          requestOptions: MockRequestOptions(),
          response: MockResponse()..statusCode = 400,
          type: DioExceptionType.badResponse,
        );

        when(
          mockDio.post('/api/board', data: anyNamed('data')),
        ).thenThrow(dioException);

        // When & Then
        expect(
          () => boardService.createBoard(invalidBoardData),
          throwsA(
            predicate(
              (e) => e is Exception && e.toString().contains('게시글 등록에 실패했습니다'),
            ),
          ),
        );
      });

      test('게시글 수정 성공 테스트', () async {
        // Given
        const boardNo = 1;
        final updateData = {
          'title': '수정된 게시글 제목',
          'content': '수정된 게시글 내용입니다.',
          'category': 'QnA',
        };

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(200);
        when(
          mockResponse.data,
        ).thenReturn({'success': true, 'message': '게시글이 성공적으로 수정되었습니다.'});

        when(
          mockDio.put('/api/board/$boardNo', data: anyNamed('data')),
        ).thenAnswer((_) async => mockResponse);

        // When
        final result = await boardService.updateBoard(boardNo, updateData);

        // Then
        expect(result, isTrue);

        verify(
          mockDio.put(
            '/api/board/$boardNo',
            data: argThat(
              allOf([
                containsPair('title', '수정된 게시글 제목'),
                containsPair('content', '수정된 게시글 내용입니다.'),
                containsPair('category', 'QnA'),
              ]),
              named: 'data',
            ),
          ),
        ).called(1);
      });

      test('권한 없는 사용자의 게시글 수정 실패 테스트', () async {
        // Given
        const boardNo = 1;
        final updateData = {'title': '수정하려는 제목', 'content': '수정하려는 내용'};

        final dioException = DioException(
          requestOptions: MockRequestOptions(),
          response: MockResponse()..statusCode = 403,
          type: DioExceptionType.badResponse,
        );

        when(
          mockDio.put('/api/board/$boardNo', data: anyNamed('data')),
        ).thenThrow(dioException);

        // When & Then
        expect(
          () => boardService.updateBoard(boardNo, updateData),
          throwsA(
            predicate(
              (e) => e is Exception && e.toString().contains('게시글 수정에 실패했습니다'),
            ),
          ),
        );
      });

      test('게시글 삭제 성공 테스트', () async {
        // Given
        const boardNo = 1;

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(200);
        when(
          mockResponse.data,
        ).thenReturn({'success': true, 'message': '게시글이 성공적으로 삭제되었습니다.'});

        when(
          mockDio.delete('/api/board/$boardNo'),
        ).thenAnswer((_) async => mockResponse);

        // When
        final result = await boardService.deleteBoard(boardNo);

        // Then
        expect(result, isTrue);
        verify(mockDio.delete('/api/board/$boardNo')).called(1);
      });

      test('존재하지 않는 게시글 삭제 실패 테스트', () async {
        // Given
        const boardNo = 999;

        final dioException = DioException(
          requestOptions: MockRequestOptions(),
          response: MockResponse()..statusCode = 404,
          type: DioExceptionType.badResponse,
        );

        when(mockDio.delete('/api/board/$boardNo')).thenThrow(dioException);

        // When & Then
        expect(
          () => boardService.deleteBoard(boardNo),
          throwsA(
            predicate(
              (e) => e is Exception && e.toString().contains('게시글 삭제에 실패했습니다'),
            ),
          ),
        );
      });
    });

    group('게시글 검색 테스트', () {
      test('제목으로 게시글 검색 성공 테스트', () async {
        // Given
        const keyword = '점검';
        final mockSearchResults = [
          {
            'boardNo': 1,
            'category': '공지사항',
            'title': '서비스 점검 안내',
            'content': '서버 점검으로 인한 서비스 중단',
            'writer': '관리자',
            'regdate': '2024-01-01',
            'viewCount': 150,
          },
          {
            'boardNo': 6,
            'category': '공지사항',
            'title': '정기 점검 일정 안내',
            'content': '월간 정기 점검 일정을 안내드립니다',
            'writer': '관리자',
            'regdate': '2024-01-05',
            'viewCount': 80,
          },
        ];

        final mockResponse = MockResponse();
        when(mockResponse.data).thenReturn(mockSearchResults);
        when(
          mockDio.get('/api/board/search?keyword=$keyword'),
        ).thenAnswer((_) async => mockResponse);

        // When
        final result = await boardService.searchBoards(keyword);

        // Then
        expect(result, hasLength(2));
        expect(result[0]['title'], contains('점검'));
        expect(result[1]['title'], contains('점검'));
        verify(mockDio.get('/api/board/search?keyword=$keyword')).called(1);
      });

      test('내용으로 게시글 검색 성공 테스트', () async {
        // Given
        const keyword = '면접';
        final mockSearchResults = [
          {
            'boardNo': 2,
            'category': '자유게시판',
            'title': '취업 후기 공유',
            'content': '면접 경험을 공유합니다. 준비 과정과 실제 면접 질문들을 정리했어요.',
            'writer': '홍길동',
            'regdate': '2024-01-02',
            'viewCount': 85,
          },
          {
            'boardNo': 7,
            'category': 'QnA',
            'title': '면접 준비 질문',
            'content': '면접에서 자주 나오는 질문들이 궁금합니다',
            'writer': '김철수',
            'regdate': '2024-01-06',
            'viewCount': 42,
          },
        ];

        final mockResponse = MockResponse();
        when(mockResponse.data).thenReturn(mockSearchResults);
        when(
          mockDio.get('/api/board/search?keyword=$keyword'),
        ).thenAnswer((_) async => mockResponse);

        // When
        final result = await boardService.searchBoards(keyword);

        // Then
        expect(result, hasLength(2));
        expect(result[0]['content'], contains('면접'));
        expect(result[1]['title'], contains('면접'));
        verify(mockDio.get('/api/board/search?keyword=$keyword')).called(1);
      });

      test('검색 결과가 없을 때 빈 배열 반환 테스트', () async {
        // Given
        const keyword = '존재하지않는키워드';

        final mockResponse = MockResponse();
        when(mockResponse.data).thenReturn([]);
        when(
          mockDio.get('/api/board/search?keyword=$keyword'),
        ).thenAnswer((_) async => mockResponse);

        // When
        final result = await boardService.searchBoards(keyword);

        // Then
        expect(result, isEmpty);
        verify(mockDio.get('/api/board/search?keyword=$keyword')).called(1);
      });

      test('빈 키워드로 검색 시 모든 게시글 반환 테스트', () async {
        // Given
        const keyword = '';
        final mockAllBoards = [
          {'boardNo': 1, 'title': '첫 번째 게시글', 'category': '공지사항'},
          {'boardNo': 2, 'title': '두 번째 게시글', 'category': '자유게시판'},
        ];

        final mockResponse = MockResponse();
        when(mockResponse.data).thenReturn(mockAllBoards);
        when(
          mockDio.get('/api/board/search?keyword=$keyword'),
        ).thenAnswer((_) async => mockResponse);

        // When
        final result = await boardService.searchBoards(keyword);

        // Then
        expect(result, hasLength(2));
      });
    });

    group('조회수 관리 테스트', () {
      test('조회수 증가 성공 테스트', () async {
        // Given
        const boardNo = 1;

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(200);
        when(
          mockResponse.data,
        ).thenReturn({'success': true, 'newViewCount': 151});

        when(
          mockDio.patch('/api/board/$boardNo/view'),
        ).thenAnswer((_) async => mockResponse);

        // When
        await boardService.increaseViewCount(boardNo);

        // Then
        verify(mockDio.patch('/api/board/$boardNo/view')).called(1);
      });

      test('존재하지 않는 게시글의 조회수 증가 시 무시 테스트', () async {
        // Given
        const boardNo = 999;

        final dioException = DioException(
          requestOptions: MockRequestOptions(),
          response: MockResponse()..statusCode = 404,
          type: DioExceptionType.badResponse,
        );

        when(mockDio.patch('/api/board/$boardNo/view')).thenThrow(dioException);

        // When & Then (예외가 발생하지 않아야 함)
        expect(() => boardService.increaseViewCount(boardNo), returnsNormally);
      });

      test('네트워크 오류 시 조회수 증가 무시 테스트', () async {
        // Given
        const boardNo = 1;

        when(
          mockDio.patch('/api/board/$boardNo/view'),
        ).thenThrow(Exception('Network error'));

        // When & Then (예외가 발생하지 않아야 함)
        expect(() => boardService.increaseViewCount(boardNo), returnsNormally);
      });
    });

    group('에러 처리 테스트', () {
      test('네트워크 연결 오류 시 예외 발생 테스트', () async {
        // Given
        final dioException = DioException(
          requestOptions: MockRequestOptions(),
          type: DioExceptionType.connectionTimeout,
        );

        when(mockDio.get('/api/board')).thenThrow(dioException);

        // When & Then
        expect(
          () => boardService.getAllBoards(),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('게시글 목록을 불러오는데 실패했습니다'),
            ),
          ),
        );
      });

      test('서버 내부 오류 시 예외 발생 테스트', () async {
        // Given
        final dioException = DioException(
          requestOptions: MockRequestOptions(),
          response: MockResponse()..statusCode = 500,
          type: DioExceptionType.badResponse,
        );

        when(mockDio.get('/api/board')).thenThrow(dioException);

        // When & Then
        expect(
          () => boardService.getAllBoards(),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('게시글 목록을 불러오는데 실패했습니다'),
            ),
          ),
        );
      });

      test('인증 실패 시 예외 발생 테스트', () async {
        // Given
        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => null);

        final dioException = DioException(
          requestOptions: MockRequestOptions(),
          response: MockResponse()..statusCode = 401,
          type: DioExceptionType.badResponse,
        );

        when(
          mockDio.post('/api/board', data: anyNamed('data')),
        ).thenThrow(dioException);

        // When & Then
        expect(
          () => boardService.createBoard({'title': '제목', 'content': '내용'}),
          throwsA(
            predicate(
              (e) => e is Exception && e.toString().contains('게시글 등록에 실패했습니다'),
            ),
          ),
        );
      });
    });

    group('실제 사용 시나리오 테스트', () {
      test('게시글 목록 조회 → 상세 보기 → 조회수 증가 시나리오 테스트', () async {
        // Given
        final mockBoards = [
          {'boardNo': 1, 'title': '공지사항', 'category': '공지사항', 'viewCount': 100},
        ];

        final mockBoardDetail = {
          'boardNo': 1,
          'title': '공지사항',
          'content': '상세 내용',
          'viewCount': 100,
        };

        // 1. 목록 조회
        final listResponse = MockResponse();
        when(listResponse.data).thenReturn(mockBoards);
        when(mockDio.get('/api/board')).thenAnswer((_) async => listResponse);

        // 2. 상세 조회
        final detailResponse = MockResponse();
        when(detailResponse.data).thenReturn(mockBoardDetail);
        when(
          mockDio.get('/api/board/1'),
        ).thenAnswer((_) async => detailResponse);

        // 3. 조회수 증가
        final viewResponse = MockResponse();
        when(viewResponse.statusCode).thenReturn(200);
        when(
          mockDio.patch('/api/board/1/view'),
        ).thenAnswer((_) async => viewResponse);

        // When
        // 1. 목록 조회
        final boards = await boardService.getAllBoards();
        expect(boards, hasLength(1));

        // 2. 상세 조회
        final detail = await boardService.getBoardDetail(1);
        expect(detail['boardNo'], 1);

        // 3. 조회수 증가
        await boardService.increaseViewCount(1);

        // Then
        verifyInOrder([
          mockDio.get('/api/board'),
          mockDio.get('/api/board/1'),
          mockDio.patch('/api/board/1/view'),
        ]);
      });

      test('게시글 작성 → 수정 → 삭제 전체 플로우 테스트', () async {
        // Given
        final newBoardData = {
          'category': '자유게시판',
          'title': '새 게시글',
          'content': '새 게시글 내용',
          'writer': '테스트사용자',
        };

        final updateData = {'title': '수정된 게시글', 'content': '수정된 내용'};

        // 1. 게시글 작성
        final createResponse = MockResponse();
        when(createResponse.statusCode).thenReturn(201);
        when(
          mockDio.post('/api/board', data: anyNamed('data')),
        ).thenAnswer((_) async => createResponse);

        // 2. 게시글 수정
        final updateResponse = MockResponse();
        when(updateResponse.statusCode).thenReturn(200);
        when(
          mockDio.put('/api/board/1', data: anyNamed('data')),
        ).thenAnswer((_) async => updateResponse);

        // 3. 게시글 삭제
        final deleteResponse = MockResponse();
        when(deleteResponse.statusCode).thenReturn(200);
        when(
          mockDio.delete('/api/board/1'),
        ).thenAnswer((_) async => deleteResponse);

        // When
        // 1. 게시글 작성
        final createResult = await boardService.createBoard(newBoardData);
        expect(createResult, isTrue);

        // 2. 게시글 수정
        final updateResult = await boardService.updateBoard(1, updateData);
        expect(updateResult, isTrue);

        // 3. 게시글 삭제
        final deleteResult = await boardService.deleteBoard(1);
        expect(deleteResult, isTrue);

        // Then
        verifyInOrder([
          mockDio.post('/api/board', data: anyNamed('data')),
          mockDio.put('/api/board/1', data: anyNamed('data')),
          mockDio.delete('/api/board/1'),
        ]);
      });

      test('카테고리별 조회 → 검색 → 결과 확인 시나리오 테스트', () async {
        // Given
        const category = '자유게시판';
        const keyword = '취업';

        final categoryBoards = [
          {
            'boardNo': 2,
            'category': '자유게시판',
            'title': '취업 후기',
            'content': '취업 후기 내용',
          },
        ];

        final searchResults = [
          {
            'boardNo': 2,
            'category': '자유게시판',
            'title': '취업 후기',
            'content': '취업 후기 내용',
          },
          {
            'boardNo': 8,
            'category': 'QnA',
            'title': '취업 준비 질문',
            'content': '취업 준비 관련 질문',
          },
        ];

        // 1. 카테고리별 조회
        final categoryResponse = MockResponse();
        when(categoryResponse.data).thenReturn(categoryBoards);
        when(
          mockDio.get('/api/board/category/$category'),
        ).thenAnswer((_) async => categoryResponse);

        // 2. 검색
        final searchResponse = MockResponse();
        when(searchResponse.data).thenReturn(searchResults);
        when(
          mockDio.get('/api/board/search?keyword=$keyword'),
        ).thenAnswer((_) async => searchResponse);

        // When
        // 1. 카테고리별 조회
        final categoryResult = await boardService.getBoardsByCategory(category);
        expect(categoryResult, hasLength(1));
        expect(categoryResult[0]['category'], '자유게시판');

        // 2. 검색
        final searchResult = await boardService.searchBoards(keyword);
        expect(searchResult, hasLength(2));
        expect(
          searchResult.every(
            (board) =>
                board['title'].contains('취업') ||
                board['content'].contains('취업'),
          ),
          isTrue,
        );

        // Then
        verifyInOrder([
          mockDio.get('/api/board/category/$category'),
          mockDio.get('/api/board/search?keyword=$keyword'),
        ]);
      });
    });
  });
}
