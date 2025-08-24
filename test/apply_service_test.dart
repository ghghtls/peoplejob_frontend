import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart' hide any, anyNamed;
import 'package:mockito/mockito.dart' as m show any, anyNamed;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:peoplejob_frontend/services/apply_service.dart';

// ---- 로컬 Mock 클래스 ----
class MockDio extends Mock implements Dio {}

class MockStorage extends Mock implements FlutterSecureStorage {}

// ---- Helpers: 실사용 Response/DioException 생성 ----
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
  String? message,
}) {
  return DioException(
    requestOptions: RequestOptions(path: path),
    response:
        statusCode == null
            ? null
            : Response(
              requestOptions: RequestOptions(path: path),
              statusCode: statusCode,
            ),
    type: type,
    message: message,
  );
}

void main() {
  group('ApplyService Tests', () {
    late ApplyService applyService;
    late MockDio mockDio;
    late MockStorage mockStorage;

    setUp(() {
      mockDio = MockDio();
      mockStorage = MockStorage();

      // Dio 인터셉터 NPE 방지
      when(mockDio.interceptors).thenReturn(Interceptors());

      // 서비스에 Mock 주입
      applyService = ApplyService(
        dio: mockDio,
        storage: mockStorage,
        baseUrl: 'http://localhost:8888',
      );

      // 기본 토큰 모킹
      when(
        mockStorage.read(key: 'jwt'),
      ).thenAnswer((_) async => 'mock-jwt-token');
    });

    group('지원하기 테스트', () {
      test('채용공고 지원 성공 테스트', () async {
        const jobOpeningNo = 1;
        const resumeNo = 1;

        when(mockDio.post('/api/apply', data: m.anyNamed('data'))).thenAnswer(
          (_) async =>
              _resp({'success': true}, statusCode: 200, path: '/api/apply'),
        );

        final result = await applyService.applyToJob(
          jobOpeningNo: jobOpeningNo,
          resumeNo: resumeNo,
        );

        expect(result, isTrue);
        verify(
          mockDio.post(
            '/api/apply',
            data: argThat(
              allOf([
                containsPair('jobopeningNo', jobOpeningNo),
                containsPair('resumeNo', resumeNo),
                containsPair('regdate', isA<String>()),
              ]),
              named: 'data',
            ),
          ),
        ).called(1);
      });

      test('중복 지원 시 실패 테스트', () async {
        const jobOpeningNo = 1;
        const resumeNo = 1;

        when(
          mockDio.post('/api/apply', data: m.anyNamed('data')),
        ).thenThrow(_dioEx(path: '/api/apply', statusCode: 400));

        expect(
          () => applyService.applyToJob(
            jobOpeningNo: jobOpeningNo,
            resumeNo: resumeNo,
          ),
          throwsA(
            predicate(
              (e) => e is Exception && e.toString().contains('이미 지원한 채용공고입니다'),
            ),
          ),
        );
      });

      test('네트워크 오류 시 실패 테스트', () async {
        const jobOpeningNo = 1;
        const resumeNo = 1;

        when(mockDio.post('/api/apply', data: m.anyNamed('data'))).thenThrow(
          _dioEx(path: '/api/apply', type: DioExceptionType.connectionTimeout),
        );

        expect(
          () => applyService.applyToJob(
            jobOpeningNo: jobOpeningNo,
            resumeNo: resumeNo,
          ),
          throwsA(
            predicate(
              (e) => e is Exception && e.toString().contains('지원에 실패했습니다'),
            ),
          ),
        );
      });
    });

    group('지원 내역 조회 테스트', () {
      test('내 지원 내역 조회 성공 테스트', () async {
        final mockApplications = [
          {
            'applyNo': 1,
            'jobopeningNo': 1,
            'resumeNo': 1,
            'regdate': '2024-01-01',
            'jobTitle': '백엔드 개발자',
            'companyName': '테스트 회사',
            'status': 'PENDING',
          },
          {
            'applyNo': 2,
            'jobopeningNo': 2,
            'resumeNo': 1,
            'regdate': '2024-01-02',
            'jobTitle': '프론트엔드 개발자',
            'companyName': '테스트 회사2',
            'status': 'ACCEPTED',
          },
        ];

        when(mockDio.get('/api/apply')).thenAnswer(
          (_) async =>
              _resp(mockApplications, statusCode: 200, path: '/api/apply'),
        );
        when(mockDio.get('/api/apply/my')).thenAnswer(
          (_) async =>
              _resp(mockApplications, statusCode: 200, path: '/api/apply/my'),
        );

        final result = await applyService.getMyApplications();

        expect(result, hasLength(2));
        expect(result[0]['status'], 'PENDING');
        expect(result[1]['status'], 'ACCEPTED');
        verify(mockDio.get('/api/apply/my')).called(1);
      });

      test('특정 채용공고의 지원자 목록 조회 성공 테스트', () async {
        const jobOpeningNo = 1;
        final mockApplicants = [
          {
            'applyNo': 1,
            'resumeNo': 1,
            'regdate': '2024-01-01',
            'applicantName': '홍길동',
            'status': 'PENDING',
          },
          {
            'applyNo': 2,
            'resumeNo': 2,
            'regdate': '2024-01-02',
            'applicantName': '김철수',
            'status': 'PENDING',
          },
        ];

        when(mockDio.get('/api/apply/job/$jobOpeningNo')).thenAnswer(
          (_) async => _resp(
            mockApplicants,
            statusCode: 200,
            path: '/api/apply/job/$jobOpeningNo',
          ),
        );

        final result = await applyService.getJobApplications(jobOpeningNo);

        expect(result, hasLength(2));
        expect(result[0]['applicantName'], '홍길동');
        expect(result[1]['applicantName'], '김철수');
        verify(mockDio.get('/api/apply/job/$jobOpeningNo')).called(1);
      });

      test('모든 지원 내역 조회 성공 테스트 (기업용)', () async {
        final mockAllApplications = [
          {
            'applyNo': 1,
            'jobopeningNo': 1,
            'resumeNo': 1,
            'regdate': '2024-01-01',
            'applicantName': '홍길동',
            'jobTitle': '백엔드 개발자',
            'status': 'PENDING',
          },
        ];

        when(mockDio.get('/api/apply')).thenAnswer(
          (_) async =>
              _resp(mockAllApplications, statusCode: 200, path: '/api/apply'),
        );

        final result = await applyService.getAllApplications();

        expect(result, hasLength(1));
        expect(result[0]['applicantName'], '홍길동');
        verify(mockDio.get('/api/apply')).called(1);
      });
    });

    group('지원 취소 테스트', () {
      test('지원 취소 성공 테스트', () async {
        const applyNo = 1;

        when(mockDio.delete('/api/apply/$applyNo')).thenAnswer(
          (_) async => _resp(
            {'success': true},
            statusCode: 200,
            path: '/api/apply/$applyNo',
          ),
        );

        final result = await applyService.cancelApplication(applyNo);

        expect(result, isTrue);
        verify(mockDio.delete('/api/apply/$applyNo')).called(1);
      });

      test('존재하지 않는 지원 취소 시 실패 테스트', () async {
        const applyNo = 999;

        when(
          mockDio.delete('/api/apply/$applyNo'),
        ).thenThrow(_dioEx(path: '/api/apply/$applyNo', statusCode: 404));

        expect(
          () => applyService.cancelApplication(applyNo),
          throwsA(
            predicate(
              (e) => e is Exception && e.toString().contains('지원 취소에 실패했습니다'),
            ),
          ),
        );
      });
    });

    group('지원 상태 확인 테스트', () {
      test('지원 상태 확인 성공 테스트', () async {
        const jobOpeningNo = 1;
        const resumeNo = 1;

        when(
          mockDio.get(
            '/api/apply/check',
            queryParameters: m.anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => _resp(
            {'applied': true},
            statusCode: 200,
            path: '/api/apply/check',
          ),
        );

        final result = await applyService.checkApplicationStatus(
          jobOpeningNo: jobOpeningNo,
          resumeNo: resumeNo,
        );

        expect(result, isTrue);
        verify(
          mockDio.get(
            '/api/apply/check',
            queryParameters: {
              'jobopeningNo': jobOpeningNo,
              'resumeNo': resumeNo,
            },
          ),
        ).called(1);
      });

      test('특정 채용공고 지원 여부 확인 성공 테스트', () async {
        const jobOpeningNo = 1;

        when(mockDio.get('/api/apply/check-job/$jobOpeningNo')).thenAnswer(
          (_) async => _resp(
            {'applied': false},
            statusCode: 200,
            path: '/api/apply/check-job/$jobOpeningNo',
          ),
        );

        final result = await applyService.hasAppliedToJob(jobOpeningNo);

        expect(result, isFalse);
        verify(mockDio.get('/api/apply/check-job/$jobOpeningNo')).called(1);
      });

      test('네트워크 오류 시 false 반환 테스트', () async {
        const jobOpeningNo = 1;

        when(
          mockDio.get('/api/apply/check-job/$jobOpeningNo'),
        ).thenThrow(Exception('Network error'));

        final result = await applyService.hasAppliedToJob(jobOpeningNo);

        expect(result, isFalse);
      });
    });

    group('지원 통계 테스트', () {
      test('지원 통계 조회 성공 테스트 (기업용)', () async {
        final mockStats = {
          'totalApplications': 100,
          'pendingApplications': 30,
          'acceptedApplications': 25,
          'rejectedApplications': 45,
          'monthlyStats': [
            {'month': '2024-01', 'count': 20},
            {'month': '2024-02', 'count': 35},
            {'month': '2024-03', 'count': 45},
          ],
        };

        when(mockDio.get('/api/apply/stats')).thenAnswer(
          (_) async =>
              _resp(mockStats, statusCode: 200, path: '/api/apply/stats'),
        );

        final result = await applyService.getApplicationStats();

        expect(result['totalApplications'], 100);
        expect(result['pendingApplications'], 30);
        expect(result['acceptedApplications'], 25);
        expect(result['rejectedApplications'], 45);
        expect(result['monthlyStats'], hasLength(3));
        verify(mockDio.get('/api/apply/stats')).called(1);
      });

      test('통계 조회 실패 테스트', () async {
        when(
          mockDio.get('/api/apply/stats'),
        ).thenThrow(Exception('Network error'));

        expect(
          () => applyService.getApplicationStats(),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('지원 통계를 불러오는데 실패했습니다'),
            ),
          ),
        );
      });
    });

    group('에러 처리 테스트', () {
      test('토큰이 없을 때도 정상 동작 테스트', () async {
        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => null);

        const jobOpeningNo = 1;
        const resumeNo = 1;

        when(mockDio.post('/api/apply', data: m.anyNamed('data'))).thenAnswer(
          (_) async =>
              _resp({'success': true}, statusCode: 200, path: '/api/apply'),
        );

        final result = await applyService.applyToJob(
          jobOpeningNo: jobOpeningNo,
          resumeNo: resumeNo,
        );

        expect(result, isTrue);
      });

      test('DioException 상세 처리 테스트', () async {
        const jobOpeningNo = 1;
        const resumeNo = 1;

        when(
          mockDio.post('/api/apply', data: m.anyNamed('data')),
        ).thenThrow(_dioEx(path: '/api/apply', message: 'Server Error'));

        expect(
          () => applyService.applyToJob(
            jobOpeningNo: jobOpeningNo,
            resumeNo: resumeNo,
          ),
          throwsA(
            predicate(
              (e) => e is Exception && e.toString().contains('지원에 실패했습니다'),
            ),
          ),
        );
      });
    });

    group('실제 사용 시나리오 테스트', () {
      test('전체 지원 프로세스 시뮬레이션 테스트', () async {
        const jobOpeningNo = 1;
        const resumeNo = 1;

        when(mockDio.get('/api/apply/check-job/$jobOpeningNo')).thenAnswer(
          (_) async => _resp(
            {'applied': false},
            statusCode: 200,
            path: '/api/apply/check-job/$jobOpeningNo',
          ),
        );

        when(mockDio.post('/api/apply', data: m.anyNamed('data'))).thenAnswer(
          (_) async =>
              _resp({'success': true}, statusCode: 200, path: '/api/apply'),
        );

        final myList = [
          {
            'applyNo': 1,
            'jobopeningNo': jobOpeningNo,
            'resumeNo': resumeNo,
            'regdate': '2024-01-01',
            'status': 'PENDING',
          },
        ];
        when(mockDio.get('/api/apply/my')).thenAnswer(
          (_) async => _resp(myList, statusCode: 200, path: '/api/apply/my'),
        );

        final hasApplied = await applyService.hasAppliedToJob(jobOpeningNo);
        expect(hasApplied, isFalse);

        final applyResult = await applyService.applyToJob(
          jobOpeningNo: jobOpeningNo,
          resumeNo: resumeNo,
        );
        expect(applyResult, isTrue);

        final myApplications = await applyService.getMyApplications();
        expect(myApplications, hasLength(1));
        expect(myApplications[0]['status'], 'PENDING');

        verifyInOrder([
          mockDio.get('/api/apply/check-job/$jobOpeningNo'),
          mockDio.post('/api/apply', data: m.anyNamed('data')),
          mockDio.get('/api/apply/my'),
        ]);
      });
    });
  });
}
