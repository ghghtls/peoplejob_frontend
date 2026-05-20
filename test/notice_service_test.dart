import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:peoplejob_frontend/services/notice_service.dart';
import 'package:peoplejob_frontend/data/model/notice.dart';
import 'test_mocks.mocks.dart';

Response<dynamic> _resp(dynamic data, {int statusCode = 200, required String path}) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: path),
    data: data,
    statusCode: statusCode,
  );
}

DioException _dioEx({required String path, int? statusCode}) {
  return DioException(
    requestOptions: RequestOptions(path: path),
    response: statusCode == null
        ? null
        : Response<dynamic>(
            requestOptions: RequestOptions(path: path),
            statusCode: statusCode,
          ),
    type: statusCode == null
        ? DioExceptionType.connectionTimeout
        : DioExceptionType.badResponse,
  );
}

final _noticeJson = {
  'noticeNo': 1,
  'title': '서비스 점검 안내',
  'content': '서버 점검으로 인한 서비스 일시 중단 안내입니다.',
  'writer': '관리자',
  'regdate': '2024-01-01',
  'viewCount': 150,
  'isImportant': false,
  'isActive': true,
};

void main() {
  group('NoticeService Tests', () {
    late NoticeService noticeService;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      when(mockDio.interceptors).thenReturn(Interceptors());
      noticeService = NoticeService(dio: mockDio);
    });

    group('공지사항 조회 테스트', () {
      test('전체 공지사항 조회 성공', () async {
        when(mockDio.get('/api/notice')).thenAnswer(
          (_) async => _resp([_noticeJson], path: '/api/notice'),
        );

        final result = await noticeService.getAllNotices();

        expect(result, hasLength(1));
        expect(result[0], isA<Notice>());
        expect(result[0].title, '서비스 점검 안내');
        expect(result[0].writer, '관리자');
        verify(mockDio.get('/api/notice')).called(1);
      });

      test('전체 공지사항 조회 실패 시 예외 발생', () async {
        when(mockDio.get('/api/notice')).thenThrow(
          _dioEx(path: '/api/notice', statusCode: 500),
        );

        expect(
          () => noticeService.getAllNotices(),
          throwsA(predicate(
            (e) => e is Exception && e.toString().contains('공지사항 목록을 불러오는데 실패했습니다'),
          )),
        );
      });

      test('공지사항 상세 조회 성공', () async {
        const noticeId = 1;
        when(mockDio.get('/api/notice/$noticeId')).thenAnswer(
          (_) async => _resp(_noticeJson, path: '/api/notice/$noticeId'),
        );

        final result = await noticeService.getNoticeDetail(noticeId);

        expect(result, isNotNull);
        expect(result!.noticeNo, 1);
        expect(result.title, '서비스 점검 안내');
        verify(mockDio.get('/api/notice/$noticeId')).called(1);
      });

      test('존재하지 않는 공지사항 상세 조회 시 예외 발생', () async {
        const noticeId = 999;
        when(mockDio.get('/api/notice/$noticeId')).thenThrow(
          _dioEx(path: '/api/notice/$noticeId', statusCode: 404),
        );

        expect(
          () => noticeService.getNoticeDetail(noticeId),
          throwsA(predicate(
            (e) => e is Exception && e.toString().contains('공지사항 상세 정보를 불러오는데 실패했습니다'),
          )),
        );
      });

      test('중요 공지사항 조회 성공', () async {
        final importantJson = {..._noticeJson, 'isImportant': true};
        when(mockDio.get('/api/notice/important')).thenAnswer(
          (_) async => _resp([importantJson], path: '/api/notice/important'),
        );

        final result = await noticeService.getImportantNotices();

        expect(result, hasLength(1));
        expect(result[0].isImportantNotice, isTrue);
        verify(mockDio.get('/api/notice/important')).called(1);
      });

      test('네트워크 오류 시 예외 발생', () async {
        when(mockDio.get('/api/notice')).thenThrow(
          _dioEx(path: '/api/notice'),
        );

        expect(
          () => noticeService.getAllNotices(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('관리자 기능 테스트', () {
      test('공지사항 삭제 성공', () async {
        const noticeId = 1;
        when(mockDio.delete('/api/notice/$noticeId')).thenAnswer(
          (_) async => _resp(null, path: '/api/notice/$noticeId'),
        );

        final result = await noticeService.deleteNotice(noticeId);

        expect(result, isTrue);
        verify(mockDio.delete('/api/notice/$noticeId')).called(1);
      });
    });
  });
}
