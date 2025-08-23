import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:peoplejob_frontend/services/apply_service.dart';

// Mock 클래스들
class MockDio extends Mock implements Dio {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockResponse extends Mock implements Response {}

class MockRequestOptions extends Mock implements RequestOptions {}

@GenerateMocks([Dio, FlutterSecureStorage])
void main() {
  group('ApplyService Tests', () {
    late ApplyService applyService;
    late MockDio mockDio;
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      mockDio = MockDio();
      mockStorage = MockFlutterSecureStorage();

      // ApplyService를 테스트용으로 수정하여 mock 객체들을 주입
      applyService = ApplyService();

      // 토큰 읽기 모킹 설정
      when(
        mockStorage.read(key: 'jwt'),
      ).thenAnswer((_) async => 'mock-jwt-token');
    });

    group('지원하기 테스트', () {
      test('채용공고 지원 성공 테스트', () async {
        // Given
        const jobOpeningNo = 1;
        const resumeNo = 1;

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.data).thenReturn({'success': true});

        when(
          mockDio.post('/api/apply', data: anyNamed('data')),
        ).thenAnswer((_) async => mockResponse);

        // When
        final result = await applyService.applyToJob(
          jobOpeningNo: jobOpeningNo,
          resumeNo: resumeNo,
        );

        // Then
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
        // Given
        const jobOpeningNo = 1;
        const resumeNo = 1;

        final dioException = DioException(
          requestOptions: MockRequestOptions(),
          response: MockResponse()..statusCode = 400,
          type: DioExceptionType.badResponse,
        );

        when(
          mockDio.post('/api/apply', data: anyNamed('data')),
        ).thenThrow(dioException);

        // When & Then
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
        // Given
        const jobOpeningNo = 1;
        const resumeNo = 1;

        final dioException = DioException(
          requestOptions: MockRequestOptions(),
          type: DioExceptionType.connectionTimeout,
        );

        when(
          mockDio.post('/api/apply', data: anyNamed('data')),
        ).thenThrow(dioException);

        // When & Then
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
        // Given
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

        final mockResponse = MockResponse();
        when(mockResponse.data).thenReturn(mockApplications);
        when(
          mockDio.get('/api/apply/my'),
        ).thenAnswer((_) async => mockResponse);

        // When
        final result = await applyService.getMyApplications();

        // Then
        expect(result, hasLength(2));
        expect(result[0]['status'], 'PENDING');
        expect(result[1]['status'], 'ACCEPTED');
        verify(mockDio.get('/api/apply/my')).called(1);
      });

      test('특정 채용공고의 지원자 목록 조회 성공 테스트', () async {
        // Given
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

        final mockResponse = MockResponse();
        when(mockResponse.data).thenReturn(mockApplicants);
        when(
          mockDio.get('/api/apply/job/$jobOpeningNo'),
        ).thenAnswer((_) async => mockResponse);

        // When
        final result = await applyService.getJobApplications(jobOpeningNo);

        // Then
        expect(result, hasLength(2));
        expect(result[0]['applicantName'], '홍길동');
        expect(result[1]['applicantName'], '김철수');
        verify(mockDio.get('/api/apply/job/$jobOpeningNo')).called(1);
      });

      test('모든 지원 내역 조회 성공 테스트 (기업용)', () async {
        // Given
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

        final mockResponse = MockResponse();
        when(mockResponse.data).thenReturn(mockAllApplications);
        when(mockDio.get('/api/apply')).thenAnswer((_) async => mockResponse);

        // When
        final result = await applyService.getAllApplications();

        // Then
        expect(result, hasLength(1));
        expect(result[0]['applicantName'], '홍길동');
        verify(mockDio.get('/api/apply')).called(1);
      });
    });

    group('지원 취소 테스트', () {
      test('지원 취소 성공 테스트', () async {
        // Given
        const applyNo = 1;

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(200);
        when(
          mockDio.delete('/api/apply/$applyNo'),
        ).thenAnswer((_) async => mockResponse);

        // When
        final result = await applyService.cancelApplication(applyNo);

        // Then
        expect(result, isTrue);
        verify(mockDio.delete('/api/apply/$applyNo')).called(1);
      });

      test('존재하지 않는 지원 취소 시 실패 테스트', () async {
        // Given
        const applyNo = 999;

        final dioException = DioException(
          requestOptions: MockRequestOptions(),
          type: DioExceptionType.badResponse,
        );

        when(mockDio.delete('/api/apply/$applyNo')).thenThrow(dioException);

        // When & Then
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
        // Given
        const jobOpeningNo = 1;
        const resumeNo = 1;

        final mockResponse = MockResponse();
        when(mockResponse.data).thenReturn({'applied': true});
        when(
          mockDio.get(
            '/api/apply/check',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // When
        final result = await applyService.checkApplicationStatus(
          jobOpeningNo: jobOpeningNo,
          resumeNo: resumeNo,
        );

        // Then
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
        // Given
        const jobOpeningNo = 1;

        final mockResponse = MockResponse();
        when(mockResponse.data).thenReturn({'applied': false});
        when(
          mockDio.get('/api/apply/check-job/$jobOpeningNo'),
        ).thenAnswer((_) async => mockResponse);

        // When
        final result = await applyService.hasAppliedToJob(jobOpeningNo);

        // Then
        expect(result, isFalse);
        verify(mockDio.get('/api/apply/check-job/$jobOpeningNo')).called(1);
      });

      test('네트워크 오류 시 false 반환 테스트', () async {
        // Given
        const jobOpeningNo = 1;

        when(
          mockDio.get('/api/apply/check-job/$jobOpeningNo'),
        ).thenThrow(Exception('Network error'));

        // When
        final result = await applyService.hasAppliedToJob(jobOpeningNo);

        // Then
        expect(result, isFalse);
      });
    });

    group('지원 통계 테스트', () {
      test('지원 통계 조회 성공 테스트 (기업용)', () async {
        // Given
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

        final mockResponse = MockResponse();
        when(mockResponse.data).thenReturn(mockStats);
        when(
          mockDio.get('/api/apply/stats'),
        ).thenAnswer((_) async => mockResponse);

        // When
        final result = await applyService.getApplicationStats();

        // Then
        expect(result, isNotNull);
        expect(result['totalApplications'], 100);
        expect(result['pendingApplications'], 30);
        expect(result['acceptedApplications'], 25);
        expect(result['rejectedApplications'], 45);
        expect(result['monthlyStats'], hasLength(3));
        verify(mockDio.get('/api/apply/stats')).called(1);
      });

      test('통계 조회 실패 테스트', () async {
        // Given
        when(
          mockDio.get('/api/apply/stats'),
        ).thenThrow(Exception('Network error'));

        // When & Then
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
        // Given
        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => null);

        const jobOpeningNo = 1;
        const resumeNo = 1;

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.data).thenReturn({'success': true});

        when(
          mockDio.post('/api/apply', data: anyNamed('data')),
        ).thenAnswer((_) async => mockResponse);

        // When
        final result = await applyService.applyToJob(
          jobOpeningNo: jobOpeningNo,
          resumeNo: resumeNo,
        );

        // Then
        expect(result, isTrue);
      });

      test('DioException 상세 처리 테스트', () async {
        // Given
        const jobOpeningNo = 1;
        const resumeNo = 1;

        final dioException = DioException(
          requestOptions: MockRequestOptions(),
          message: 'Server Error',
          type: DioExceptionType.badResponse,
        );

        when(
          mockDio.post('/api/apply', data: anyNamed('data')),
        ).thenThrow(dioException);

        // When & Then
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
        // Given
        const jobOpeningNo = 1;
        const resumeNo = 1;

        // 1. 지원 상태 확인
        final checkResponse = MockResponse();
        when(checkResponse.data).thenReturn({'applied': false});
        when(
          mockDio.get('/api/apply/check-job/$jobOpeningNo'),
        ).thenAnswer((_) async => checkResponse);

        // 2. 지원하기
        final applyResponse = MockResponse();
        when(applyResponse.statusCode).thenReturn(200);
        when(applyResponse.data).thenReturn({'success': true});
        when(
          mockDio.post('/api/apply', data: anyNamed('data')),
        ).thenAnswer((_) async => applyResponse);

        // 3. 지원 내역 확인
        final myApplyResponse = MockResponse();
        when(myApplyResponse.data).thenReturn([
          {
            'applyNo': 1,
            'jobopeningNo': jobOpeningNo,
            'resumeNo': resumeNo,
            'regdate': '2024-01-01',
            'status': 'PENDING',
          },
        ]);
        when(
          mockDio.get('/api/apply/my'),
        ).thenAnswer((_) async => myApplyResponse);

        // When
        // 1. 지원 상태 확인
        final hasApplied = await applyService.hasAppliedToJob(jobOpeningNo);
        expect(hasApplied, isFalse);

        // 2. 지원하기
        final applyResult = await applyService.applyToJob(
          jobOpeningNo: jobOpeningNo,
          resumeNo: resumeNo,
        );
        expect(applyResult, isTrue);

        // 3. 지원 내역 확인
        final myApplications = await applyService.getMyApplications();
        expect(myApplications, hasLength(1));
        expect(myApplications[0]['status'], 'PENDING');

        // Then - 모든 API가 순서대로 호출되었는지 확인
        verifyInOrder([
          mockDio.get('/api/apply/check-job/$jobOpeningNo'),
          mockDio.post('/api/apply', data: anyNamed('data')),
          mockDio.get('/api/apply/my'),
        ]);
      });
    });
  });
}
