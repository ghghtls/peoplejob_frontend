import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:peoplejob_frontend/services/board_service.dart';

/// ---------------------------------------------------------------------------
/// 로컬 Mock (build_runner 불필요)
/// ---------------------------------------------------------------------------
class _MockDio extends Mock implements Dio {}

class _MockStorage extends Mock implements FlutterSecureStorage {}

/// ---------------------------------------------------------------------------
/// 실사용 Response/DioException 생성 헬퍼
/// ---------------------------------------------------------------------------
Response<dynamic> _resp(dynamic data, {int? statusCode, required String path}) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: path),
    data: data,
    statusCode: statusCode,
  );
}

DioException _dioEx({
  required String path,
  int? statusCode,
  DioExceptionType type = DioExceptionType.badResponse,
}) {
  return DioException(
    requestOptions: RequestOptions(path: path),
    response:
        statusCode == null
            ? null
            : Response<dynamic>(
              requestOptions: RequestOptions(path: path),
              statusCode: statusCode,
            ),
    type: type,
  );
}

void main() {
  group('BoardService Tests', () {
    late BoardService boardService;
    late _MockDio mockDio;
    late _MockStorage mockStorage;

    setUp(() {
      mockDio = _MockDio();
      mockStorage = _MockStorage();

      // 테스트 훅으로 모의 의존성 주입 (무인자 생성자 유지)
      // BoardService.setTestOverrides는 서비스에 테스트 전용 정적 메서드로 추가되어 있어야 합니다.
      BoardService.setTestOverrides(dio: mockDio, storage: mockStorage);
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

        when(mockDio.get('/api/board')).thenAnswer(
          (_) async => _resp(mockBoards, statusCode: 200, path: '/api/board'),
        );

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

        when(mockDio.get('/api/board/category/$category')).thenAnswer(
          (_) async => _resp(
            mockNoticeBoards,
            statusCode: 200,
            path: '/api/board/category/$category',
          ),
        );

        final result = await boardService.getBoardsByCategory(category);

        expect(result, hasLength(2));
        expect(result.every((board) => board['category'] == '공지사항'), true);
        expect(result.every((board) => board['isNotice'] == true), true);

        verify(mockDio.get('/api/board/category/$category')).called(1);
      });

      test('게시글 상세 조회 성공 테스트', () async {
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

        when(mockDio.get('/api/board/$boardNo')).thenAnswer(
          (_) async => _resp(
            mockBoardDetail,
            statusCode: 200,
            path: '/api/board/$boardNo',
          ),
        );

        final result = await boardService.getBoardDetail(boardNo);

        expect(result['boardNo'], 1);
        expect(result['title'], '서비스 점검 안내');
        expect(result['content'], contains('점검 일시'));
        expect(result['writer'], '관리자');
        expect(result['viewCount'], 150);
        expect(result['attachments'], hasLength(1));

        verify(mockDio.get('/api/board/$boardNo')).called(1);
      });

      test('존재하지 않는 게시글 조회 시 예외 발생 테스트', () async {
        const boardNo = 999;

        when(
          mockDio.get('/api/board/$boardNo'),
        ).thenThrow(_dioEx(path: '/api/board/$boardNo', statusCode: 404));

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
        final boardData = {
          'category': '자유게시판',
          'title': '새로운 게시글 제목',
          'content': '게시글 내용입니다. 여러 줄로 작성된 내용입니다.',
          'writer': '홍길동',
          'userid': 'hong123',
          'isNotice': false,
        };

        when(mockDio.post('/api/board', data: anyNamed('data'))).thenAnswer(
          (_) async => _resp(
            {'boardNo': 5, 'success': true, 'message': '게시글이 성공적으로 등록되었습니다.'},
            statusCode: 201,
            path: '/api/board',
          ),
        );

        final result = await boardService.createBoard(boardData);

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
        final invalidBoardData = {
          'category': '자유게시판',
          // title 누락
          'content': '내용만 있는 게시글',
          'writer': '홍길동',
        };

        when(
          mockDio.post('/api/board', data: anyNamed('data')),
        ).thenThrow(_dioEx(path: '/api/board', statusCode: 400));

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
        const boardNo = 1;
        final updateData = {
          'title': '수정된 게시글 제목',
          'content': '수정된 게시글 내용입니다.',
          'category': 'QnA',
        };

        when(
          mockDio.put('/api/board/$boardNo', data: anyNamed('data')),
        ).thenAnswer(
          (_) async => _resp(
            {'success': true},
            statusCode: 200,
            path: '/api/board/$boardNo',
          ),
        );

        final result = await boardService.updateBoard(boardNo, updateData);

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
        const boardNo = 1;
        final updateData = {'title': '수정하려는 제목', 'content': '수정하려는 내용'};

        when(
          mockDio.put('/api/board/$boardNo', data: anyNamed('data')),
        ).thenThrow(_dioEx(path: '/api/board/$boardNo', statusCode: 403));

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
        const boardNo = 1;

        when(mockDio.delete('/api/board/$boardNo')).thenAnswer(
          (_) async => _resp(
            {'success': true},
            statusCode: 200,
            path: '/api/board/$boardNo',
          ),
        );

        final result = await boardService.deleteBoard(boardNo);

        expect(result, isTrue);
        verify(mockDio.delete('/api/board/$boardNo')).called(1);
      });

      test('존재하지 않는 게시글 삭제 실패 테스트', () async {
        const boardNo = 999;

        when(
          mockDio.delete('/api/board/$boardNo'),
        ).thenThrow(_dioEx(path: '/api/board/$boardNo', statusCode: 404));

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

        when(mockDio.get('/api/board/search?keyword=$keyword')).thenAnswer(
          (_) async => _resp(
            mockSearchResults,
            statusCode: 200,
            path: '/api/board/search?keyword=$keyword',
          ),
        );

        final result = await boardService.searchBoards(keyword);

        expect(result, hasLength(2));
        expect(result[0]['title'], contains('점검'));
        expect(result[1]['title'], contains('점검'));
        verify(mockDio.get('/api/board/search?keyword=$keyword')).called(1);
      });

      test('내용으로 게시글 검색 성공 테스트', () async {
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

        when(mockDio.get('/api/board/search?keyword=$keyword')).thenAnswer(
          (_) async => _resp(
            mockSearchResults,
            statusCode: 200,
            path: '/api/board/search?keyword=$keyword',
          ),
        );

        final result = await boardService.searchBoards(keyword);

        expect(result, hasLength(2));
        expect(result[0]['content'], contains('면접'));
        expect(result[1]['title'], contains('면접'));
        verify(mockDio.get('/api/board/search?keyword=$keyword')).called(1);
      });

      test('검색 결과가 없을 때 빈 배열 반환 테스트', () async {
        const keyword = '존재하지않는키워드';

        when(mockDio.get('/api/board/search?keyword=$keyword')).thenAnswer(
          (_) async => _resp(
            [],
            statusCode: 200,
            path: '/api/board/search?keyword=$keyword',
          ),
        );

        final result = await boardService.searchBoards(keyword);

        expect(result, isEmpty);
        verify(mockDio.get('/api/board/search?keyword=$keyword')).called(1);
      });

      test('빈 키워드로 검색 시 모든 게시글 반환 테스트', () async {
        const keyword = '';
        final mockAllBoards = [
          {'boardNo': 1, 'title': '첫 번째 게시글', 'category': '공지사항'},
          {'boardNo': 2, 'title': '두 번째 게시글', 'category': '자유게시판'},
        ];

        when(mockDio.get('/api/board/search?keyword=$keyword')).thenAnswer(
          (_) async => _resp(
            mockAllBoards,
            statusCode: 200,
            path: '/api/board/search?keyword=$keyword',
          ),
        );

        final result = await boardService.searchBoards(keyword);

        expect(result, hasLength(2));
      });
    });

    group('조회수 관리 테스트', () {
      test('조회수 증가 성공 테스트', () async {
        const boardNo = 1;

        when(mockDio.patch('/api/board/$boardNo/view')).thenAnswer(
          (_) async => _resp(
            {'success': true, 'newViewCount': 151},
            statusCode: 200,
            path: '/api/board/$boardNo/view',
          ),
        );

        await boardService.increaseViewCount(boardNo);

        verify(mockDio.patch('/api/board/$boardNo/view')).called(1);
      });

      test('존재하지 않는 게시글의 조회수 증가 시 무시 테스트', () async {
        const boardNo = 999;

        when(
          mockDio.patch('/api/board/$boardNo/view'),
        ).thenThrow(_dioEx(path: '/api/board/$boardNo/view', statusCode: 404));

        expect(() => boardService.increaseViewCount(boardNo), returnsNormally);
      });

      test('네트워크 오류 시 조회수 증가 무시 테스트', () async {
        const boardNo = 1;

        when(
          mockDio.patch('/api/board/$boardNo/view'),
        ).thenThrow(Exception('Network error'));

        expect(() => boardService.increaseViewCount(boardNo), returnsNormally);
      });
    });

    group('에러 처리 테스트', () {
      test('네트워크 연결 오류 시 예외 발생 테스트', () async {
        when(mockDio.get('/api/board')).thenThrow(
          _dioEx(path: '/api/board', type: DioExceptionType.connectionTimeout),
        );

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
        when(
          mockDio.get('/api/board'),
        ).thenThrow(_dioEx(path: '/api/board', statusCode: 500));

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
        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => null);
        when(
          mockDio.post('/api/board', data: anyNamed('data')),
        ).thenThrow(_dioEx(path: '/api/board', statusCode: 401));

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
        final mockBoards = [
          {'boardNo': 1, 'title': '공지사항', 'category': '공지사항', 'viewCount': 100},
        ];
        final mockBoardDetail = {
          'boardNo': 1,
          'title': '공지사항',
          'content': '상세 내용',
          'viewCount': 100,
        };

        when(mockDio.get('/api/board')).thenAnswer(
          (_) async => _resp(mockBoards, statusCode: 200, path: '/api/board'),
        );
        when(mockDio.get('/api/board/1')).thenAnswer(
          (_) async =>
              _resp(mockBoardDetail, statusCode: 200, path: '/api/board/1'),
        );
        when(mockDio.patch('/api/board/1/view')).thenAnswer(
          (_) async => _resp(
            {'success': true},
            statusCode: 200,
            path: '/api/board/1/view',
          ),
        );

        final boards = await boardService.getAllBoards();
        expect(boards, hasLength(1));

        final detail = await boardService.getBoardDetail(1);
        expect(detail['boardNo'], 1);

        await boardService.increaseViewCount(1);

        verifyInOrder([
          mockDio.get('/api/board'),
          mockDio.get('/api/board/1'),
          mockDio.patch('/api/board/1/view'),
        ]);
      });

      test('게시글 작성 → 수정 → 삭제 전체 플로우 테스트', () async {
        final newBoardData = {
          'category': '자유게시판',
          'title': '새 게시글',
          'content': '새 게시글 내용',
          'writer': '테스트사용자',
        };
        final updateData = {'title': '수정된 게시글', 'content': '수정된 내용'};

        when(mockDio.post('/api/board', data: anyNamed('data'))).thenAnswer(
          (_) async => _resp(null, statusCode: 201, path: '/api/board'),
        );
        when(mockDio.put('/api/board/1', data: anyNamed('data'))).thenAnswer(
          (_) async => _resp(null, statusCode: 200, path: '/api/board/1'),
        );
        when(mockDio.delete('/api/board/1')).thenAnswer(
          (_) async => _resp(null, statusCode: 200, path: '/api/board/1'),
        );

        final createResult = await boardService.createBoard(newBoardData);
        expect(createResult, isTrue);

        final updateResult = await boardService.updateBoard(1, updateData);
        expect(updateResult, isTrue);

        final deleteResult = await boardService.deleteBoard(1);
        expect(deleteResult, isTrue);

        verifyInOrder([
          mockDio.post('/api/board', data: anyNamed('data')),
          mockDio.put('/api/board/1', data: anyNamed('data')),
          mockDio.delete('/api/board/1'),
        ]);
      });

      test('카테고리별 조회 → 검색 → 결과 확인 시나리오 테스트', () async {
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

        when(mockDio.get('/api/board/category/$category')).thenAnswer(
          (_) async => _resp(
            categoryBoards,
            statusCode: 200,
            path: '/api/board/category/$category',
          ),
        );
        when(mockDio.get('/api/board/search?keyword=$keyword')).thenAnswer(
          (_) async => _resp(
            searchResults,
            statusCode: 200,
            path: '/api/board/search?keyword=$keyword',
          ),
        );

        final categoryResult = await boardService.getBoardsByCategory(category);
        expect(categoryResult, hasLength(1));
        expect(categoryResult[0]['category'], '자유게시판');

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

        verifyInOrder([
          mockDio.get('/api/board/category/$category'),
          mockDio.get('/api/board/search?keyword=$keyword'),
        ]);
      });
    });
  });
}
