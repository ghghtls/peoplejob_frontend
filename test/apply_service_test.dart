import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:peoplejob_frontend/services/apply_service.dart';

// Mock 클래스 정의
class MockDio extends Mock implements Dio {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('ApplyService Tests', () {
    late ApplyService applyService;
    late MockDio mockDio;
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      mockDio = MockDio();
      mockStorage = MockFlutterSecureStorage();

      // interceptors를 실제 Interceptors 인스턴스로 stub
      final interceptors = Interceptors();
      when(mockDio.interceptors).thenReturn(interceptors);

      // 서비스에 Mock 주입
      applyService = ApplyService(
        dio: mockDio,
        storage: mockStorage,
      );
    });

    group('지원하기 테스트', () {
      test('채용공고 지원 성공 테스트', () async {
        const jobopeningNo = 1;
        const resumeNo = 1;

        // 토큰 모킹
        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => 'mock-token');

        // API 호출 모킹
        when(
          mockDio.post(
            '/api/apply',
            data: anyNamed('data'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/api/apply'),
            data: {'success': true},
            statusCode: 200,
          ),
        );

        final result = await applyService.applyToJob(
          jobopeningNo: jobopeningNo,
          resumeNo: resumeNo,
        );

        expect(result, isTrue);
        verify(
          mockDio.post(
            '/api/apply',
            data: argThat(
              allOf([
                isA<Map>(),
                predicate((map) => (map as Map)['jobNo'] == jobopeningNo),
                predicate((map) => (map as Map)['resumeNo'] == resumeNo),
              ]),
              named: 'data',
            ),
          ),
        ).called(1);
      });

      test('중복 지원 시 실패 테스트', () async {
        const jobopeningNo = 1;
        const resumeNo = 1;

        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => 'mock-token');

        when(
          mockDio.post('/api/apply', data: anyNamed('data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/apply'),
            response: Response(
              requestOptions: RequestOptions(path: '/api/apply'),
              statusCode: 400,
            ),
          ),
        );

        expect(
          () => applyService.applyToJob(
            jobopeningNo: jobopeningNo,
            resumeNo: resumeNo,
          ),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('이미 지원한 채용공고입니다'),
            ),
          ),
        );
      });

      test('네트워크 오류 시 실패 테스트', () async {
        const jobopeningNo = 1;
        const resumeNo = 1;

        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => 'mock-token');

        when(
          mockDio.post('/api/apply', data: anyNamed('data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/apply'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        expect(
          () => applyService.applyToJob(
            jobopeningNo: jobopeningNo,
            resumeNo: resumeNo,
          ),
          throwsA(
            predicate(
              (e) =>
                  e is Exception && e.toString().contains('지원에 실패했습니다'),
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

        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => 'mock-token');
        when(mockStorage.read(key: 'userNo')).thenAnswer((_) async => '1');

        when(mockDio.get('/api/apply/user/1')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/api/apply/user/1'),
            data: mockApplications,
            statusCode: 200,
          ),
        );

        final result = await applyService.getMyApplications();

        expect(result, hasLength(2));
        expect(result[0]['status'], 'PENDING');
        expect(result[1]['status'], 'ACCEPTED');
        verify(mockDio.get('/api/apply/user/1')).called(1);
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

        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => 'mock-token');

        when(mockDio.get('/api/apply/job/$jobOpeningNo')).thenAnswer(
          (_) async => Response(
            requestOptions:
                RequestOptions(path: '/api/apply/job/$jobOpeningNo'),
            data: mockApplicants,
            statusCode: 200,
          ),
        );

        final result = await applyService.getJobApplications(jobOpeningNo);

        expect(result, hasLength(2));
        expect(result[0]['applicantName'], '홍길동');
        expect(result[1]['applicantName'], '김철수');
        verify(mockDio.get('/api/apply/job/$jobOpeningNo')).called(1);
      });

      test('모든 지원 내역 조회 성공 테스트 (관리자용)', () async {
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

        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => 'mock-token');

        when(mockDio.get('/api/apply')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/api/apply'),
            data: mockAllApplications,
            statusCode: 200,
          ),
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

        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => 'mock-token');

        when(mockDio.delete('/api/apply/$applyNo')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/api/apply/$applyNo'),
            data: {'success': true},
            statusCode: 200,
          ),
        );

        final result = await applyService.cancelApplication(applyNo);

        expect(result, isTrue);
        verify(mockDio.delete('/api/apply/$applyNo')).called(1);
      });

      test('존재하지 않는 지원 취소 시 실패 테스트', () async {
        const applyNo = 999;

        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => 'mock-token');

        when(mockDio.delete('/api/apply/$applyNo')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/apply/$applyNo'),
            response: Response(
              requestOptions: RequestOptions(path: '/api/apply/$applyNo'),
              statusCode: 404,
            ),
          ),
        );

        expect(
          () => applyService.cancelApplication(applyNo),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('지원 취소에 실패했습니다'),
            ),
          ),
        );
      });
    });

    group('지원 상태 확인 테스트', () {
      test('지원 상태 확인 성공 테스트', () async {
        const jobOpeningNo = 1;
        const resumeNo = 1;

        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => 'mock-token');

        when(
          mockDio.get(
            '/api/apply/status',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/api/apply/status'),
            data: {'applied': true, 'status': 'PENDING'},
            statusCode: 200,
          ),
        );

        final result = await applyService.checkApplicationStatus(
          jobOpeningNo,
          resumeNo,
        );

        expect(result, isNotNull);
        expect(result!['applied'], true);
        verify(
          mockDio.get(
            '/api/apply/status',
            queryParameters: {
              'jobopeningNo': jobOpeningNo,
              'resumeNo': resumeNo,
            },
          ),
        ).called(1);
      });

      test('특정 채용공고 지원 여부 확인 성공 테스트', () async {
        const jobOpeningNo = 1;

        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => 'mock-token');
        when(mockStorage.read(key: 'userNo')).thenAnswer((_) async => '1');

        when(
          mockDio.get(
            '/api/apply/check',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/api/apply/check'),
            data: {'hasApplied': false},
            statusCode: 200,
          ),
        );

        final result = await applyService.hasAppliedToJob(jobOpeningNo);

        expect(result, isFalse);
      });

      test('네트워크 오류 시 false 반환 테스트', () async {
        const jobOpeningNo = 1;

        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => 'mock-token');
        when(mockStorage.read(key: 'userNo')).thenAnswer((_) async => '1');

        when(
          mockDio.get(
            '/api/apply/check',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenThrow(Exception('Network error'));

        final result = await applyService.hasAppliedToJob(jobOpeningNo);

        expect(result, isFalse);
      });
    });

    group('에러 처리 테스트', () {
      test('토큰이 없을 때도 정상 동작 테스트', () async {
        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => null);

        const jobopeningNo = 1;
        const resumeNo = 1;

        when(
          mockDio.post('/api/apply', data: anyNamed('data')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/api/apply'),
            data: {'success': true},
            statusCode: 200,
          ),
        );

        final result = await applyService.applyToJob(
          jobopeningNo: jobopeningNo,
          resumeNo: resumeNo,
        );

        expect(result, isTrue);
      });

      test('DioException 상세 처리 테스트', () async {
        const jobopeningNo = 1;
        const resumeNo = 1;

        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => 'mock-token');

        when(
          mockDio.post('/api/apply', data: anyNamed('data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/apply'),
            message: 'Server Error',
          ),
        );

        expect(
          () => applyService.applyToJob(
            jobopeningNo: jobopeningNo,
            resumeNo: resumeNo,
          ),
          throwsA(
            predicate(
              (e) =>
                  e is Exception && e.toString().contains('지원에 실패했습니다'),
            ),
          ),
        );
      });
    });

    group('실제 사용 시나리오 테스트', () {
      test('전체 지원 프로세스 시뮬레이션 테스트', () async {
        const jobOpeningNo = 1;
        const resumeNo = 1;

        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => 'mock-token');
        when(mockStorage.read(key: 'userNo')).thenAnswer((_) async => '1');

        // 1. 지원 여부 확인
        when(
          mockDio.get(
            '/api/apply/check',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/api/apply/check'),
            data: {'hasApplied': false},
            statusCode: 200,
          ),
        );

        // 2. 지원하기
        when(
          mockDio.post('/api/apply', data: anyNamed('data')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/api/apply'),
            data: {'success': true},
            statusCode: 200,
          ),
        );

        // 3. 내 지원 내역 조회
        final myList = [
          {
            'applyNo': 1,
            'jobopeningNo': jobOpeningNo,
            'resumeNo': resumeNo,
            'regdate': '2024-01-01',
            'status': 'PENDING',
          },
        ];
        when(mockDio.get('/api/apply/user/1')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/api/apply/user/1'),
            data: myList,
            statusCode: 200,
          ),
        );

        final hasApplied = await applyService.hasAppliedToJob(jobOpeningNo);
        expect(hasApplied, isFalse);

        final applyResult = await applyService.applyToJob(
          jobopeningNo: jobOpeningNo,
          resumeNo: resumeNo,
        );
        expect(applyResult, isTrue);

        final myApplications = await applyService.getMyApplications();
        expect(myApplications, hasLength(1));
        expect(myApplications[0]['status'], 'PENDING');
      });
    });
  });
}
