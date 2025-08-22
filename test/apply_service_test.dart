import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:peoplejob_frontend/services/apply_service.dart';

class MockClient extends Mock implements http.Client {}

@GenerateMocks([http.Client])
void main() {
  group('ApplyService Tests', () {
    late ApplyService applyService;
    late MockClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockClient();
      applyService = ApplyService();
    });

    group('지원 내역 조회 테스트', () {
      test('사용자 지원 내역 조회 성공 테스트', () async {
        // Given
        const userNo = 1;
        final appliesData = [
          {
            'applyNo': 1,
            'userNo': 1,
            'jobNo': 1,
            'resumeNo': 1,
            'status': 'PENDING',
            'applyDate': '2024-01-01T10:00:00',
            'jobTitle': '백엔드 개발자 모집',
            'companyName': '테스트 회사',
          },
          {
            'applyNo': 2,
            'userNo': 1,
            'jobNo': 2,
            'resumeNo': 1,
            'status': 'ACCEPTED',
            'applyDate': '2024-01-02T14:00:00',
            'jobTitle': '프론트엔드 개발자 모집',
            'companyName': '테스트 회사2',
          }
        ];

        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(jsonEncode(appliesData), 200));

        // When
        final result = await applyService.getUserApplications(userNo);

        // Then
        expect(result, hasLength(2));
        expect(result.first['status'], 'PENDING');
        expect(result.last['status'], 'ACCEPTED');
      });

      test('특정 지원 내역 조회 성공 테스트', () async {
        // Given
        const applyId = 1;
        final applyData = {
          'applyNo': 1,
          'userNo': 1,
          'jobNo': 1,
          'resumeNo': 1,
          'status': 'PENDING',
          'applyDate': '2024-01-01T10:00:00',
          'coverLetter': '지원 동기입니다.',
          'jobTitle': '백엔드 개발자 모집',
          'companyName': '테스트 회사',
        };

        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(jsonEncode(applyData), 200));

        // When
        final result = await applyService.getApplicationById(applyId);

        // Then
        expect(result, isNotNull);
        expect(result!['applyNo'], 1);
        expect(result['status'], 'PENDING');
        expect(result['coverLetter'], '지원 동기입니다.');
      });
    });

    group('지원하기 테스트', () {
      test('채용공고 지원 성공 테스트', () async {
        // Given
        final applyData = {
          'jobNo': 1,
          'resumeNo': 1,
          'coverLetter': '지원 동기입니다.',
        };

        final createdApply = {
          'applyNo': 1,
          'userNo': 1,
          'jobNo': 1,
          'resumeNo': 1,
          'status': 'PENDING',
          'applyDate': '2024-01-01T10:00:00',
          'coverLetter': '지원 동기입니다.',
        };

        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(jsonEncode(createdApply), 201));

        // When
        final result = await applyService.applyToJob(applyData);

        // Then
        expect(result, isNotNull);
        expect(result!['applyNo'], 1);
        expect(result['status'], 'PENDING');
      });

      test('중복 지원 시 실패 테스트', () async {
        // Given
        final applyData = {
          'jobNo': 1,
          'resumeNo': 1,
          'coverLetter': '지원 동기입니다.',
        };

        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          '{"error": "이미 지원한 채용공고입니다."}', 409));

        // When & Then
        expect(() => applyService.applyToJob(applyData), throwsException);
      });

      test('잘못된 데이터로 지원 시 실패 테스트', () async {
        // Given
        final invalidApplyData = {
          'jobNo': null,
          'resumeNo': 1,
          'coverLetter': '',
        };

        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          '{"error": "필수 정보가 누락되었습니다."}', 400));

        // When & Then
        expect(() => applyService.applyToJob(invalidApplyData), throwsException);
      });
    });

    group('지원 취소 테스트', () {
      test('지원 취소 성공 테스트', () async {
        // Given
        const applyId = 1;

        when(mockHttpClient.delete(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('', 204));

        // When
        final result = await applyService.cancelApplication(applyId);

        // Then
        expect(result, isTrue);
      });

      test('이미 처리된 지원의 취소 시도 시 실패 테스트', () async {
        // Given
        const applyId = 1;

        when(mockHttpClient.delete(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          '{"error": "이미 처리된 지원은 취소할 수 없습니다."}', 400));

        // When
        final result = await applyService.cancelApplication(applyId);

        // Then
        expect(result, isFalse);
      });
    });

    group('지원 상태 조회 테스트', () {
      test('대기 중인 지원 조회 성공 테스트', () async {
        // Given
        const userNo = 1;
        final pendingApplies = [
          {
            'applyNo': 1,
            'status': 'PENDING',
            'jobTitle': '백엔드 개발자 모집',
          }
        ];

        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(jsonEncode(pendingApplies), 200));

        // When
        final result = await applyService.getPendingApplications(userNo);

        // Then
        expect(result, isNotEmpty);
        expect(result.first['status'], 'PENDING');
      });

      test('합격한 지원 조회 성공 테스트', () async {
        // Given
        const userNo = 1;
        final acceptedApplies = [
          {
            'applyNo': 2,
            'status': 'ACCEPTED',
            'jobTitle': '프론트엔드 개발자 모집',
          }
        ];

        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(jsonEncode(acceptedApplies), 200));

        // When
        final result = await applyService.getAcceptedApplications(userNo);

        // Then
        expect(result, isNotEmpty);
        expect(result.first['status'], 'ACCEPTED');
      });

      test('불합격한 지원 조회 성공 테스트', () async {
        // Given
        const userNo = 1;
        final rejectedApplies = [
          {
            'applyNo': 3,
            'status': 'REJECTED',
            'jobTitle': 'DevOps 엔지니어 모집',
          }
        ];

        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(jsonEncode(rejectedApplies), 200));

        // When
        final result = await applyService.getRejectedApplications(userNo);

        // Then
        expect(result, isNotEmpty);
        expect(result.first['status'], 'REJECTED');
      });
    });

    group('지원 통계 테스트', () {
      test('지원 통계 조회 성공 테스트', () async {
        // Given
        const userNo = 1;
        final statsData = {
          'totalApplications': 10,
          'pendingApplications': 3,
          'acceptedApplications': 2,
          'rejectedApplications': 5,
        };

        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(jsonEncode(statsData), 200));

        // When
        final result = await applyService.getApplicationStats(userNo);

        // Then
        expect(result, isNotNull);
        expect(result!['totalApplications'], 10);
        expect(result['pendingApplications'], 3);
        expect(result['acceptedApplications'], 2);
        expect(result['rejectedApplications'], 5);
      });
    });

    group('기업용 지원 관리 테스트', () {
      test('채용공고별 지원자 조회 성공 테스트', () async {
        // Given
        const jobId = 1;
        final applicantsData = [
          {
            'applyNo': 1,
            'userNo': 1,
            'resumeNo': 1,
            'status': 'PENDING',
            'applicantName': '홍길동',
            'applyDate': '2024-01-01T10:00:00',
          },
          {
            'applyNo': 2,
            'userNo': 2,
            'resumeNo': 2,
            'status': 'PENDING',
            'applicantName': '김철수',
            'applyDate': '2024-01-02T14:00:00',
          }
        ];

        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(jsonEncode(applicantsData), 200));

        // When
        final result = await applyService.getJobApplicants(jobId);

        // Then
        expect(result, hasLength(2));
        expect(result.first['applicantName'], '홍길동');
        expect(result.last['applicantName'], '김철수');
      });

      test('지원 상태 변경 성공 테스트', () async {
        // Given
        const applyId = 1;
        const newStatus = 'ACCEPTED';

        final updatedApply = {
          'applyNo
          final updatedApply = {
          'applyNo': 1,
          'status': 'ACCEPTED',
          'statusUpdateDate': '2024-01-03T09:00:00',
        };

        when(mockHttpClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(jsonEncode(updatedApply), 200));

        // When
        final result = await applyService.updateApplicationStatus(applyId, newStatus);

        // Then
        expect(result, isNotNull);
        expect(result!['status'], 'ACCEPTED');
      });

      test('잘못된 상태로 변경 시도 시 실패 테스트', () async {
        // Given
        const applyId = 1;
        const invalidStatus = 'INVALID_STATUS';

        when(mockHttpClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          '{"error": "유효하지 않은 상태입니다."}', 400));

        // When & Then
        expect(() => applyService.updateApplicationStatus(applyId, invalidStatus),
            throwsException);
      });
    });

    group('에러 처리 테스트', () {
      test('네트워크 오류 시 예외 발생 테스트', () async {
        // Given
        const userNo = 1;
        when(mockHttpClient.get(any))
            .thenThrow(Exception('Network error'));

        // When & Then
        expect(() => applyService.getUserApplications(userNo), throwsException);
      });

      test('서버 오류 시 예외 발생 테스트', () async {
        // Given
        const userNo = 1;
        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response('Server Error', 500));

        // When & Then
        expect(() => applyService.getUserApplications(userNo), throwsException);
      });

      test('인증 실패 시 예외 발생 테스트', () async {
        // Given
        const userNo = 1;
        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response('Unauthorized', 401));

        // When & Then
        expect(() => applyService.getUserApplications(userNo), throwsException);
      });
    });
  });
}