import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:peoplejob_frontend/services/resume_service.dart';

class MockClient extends Mock implements http.Client {}

@GenerateMocks([http.Client])
void main() {
  group('ResumeService Tests', () {
    late ResumeService resumeService;
    late MockClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockClient();
      resumeService = ResumeService();
    });

    group('이력서 조회 테스트', () {
      test('모든 이력서 조회 성공 테스트', () async {
        // Given
        final resumesData = [
          {
            'resumeNo': 1,
            'title': '백엔드 개발자 이력서',
            'content': '경력 3년의 백엔드 개발자입니다.',
            'name': '홍길동',
            'email': 'hong@example.com',
            'phone': '010-1234-5678',
            'hopeJobtype': '개발자',
            'hopeLocation': '서울',
            'education': '대졸',
            'career': '3년',
            'regdate': '2024-01-01T00:00:00',
          }
        ];

        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(jsonEncode(resumesData), 200));

        // When
        final result = await resumeService.getAllResumes();

        // Then
        expect(result, isNotEmpty);
        expect(result.first['title'], '백엔드 개발자 이력서');
        expect(result.first['name'], '홍길동');
      });

      test('특정 사용자 이력서 조회 성공 테스트', () async {
        // Given
        const userNo = 1;
        final userResumes = [
          {
            'resumeNo': 1,
            'title': '내 이력서',
            'userNo': 1,
            'name': '홍길동',
          }
        ];

        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(jsonEncode(userResumes), 200));

        // When
        final result = await resumeService.getUserResumes(userNo);

        // Then
        expect(result, isNotEmpty);
        expect(result.first['userNo'], 1);
        expect(result.first['name'], '홍길동');
      });

      test('특정 이력서 상세 조회 성공 테스트', () async {
        // Given
        const resumeId = 1;
        final resumeData = {
          'resumeNo': 1,
          'title': '백엔드 개발자 이력서',
          'content': '상세 내용',
          'name': '홍길동',
          'email': 'hong@example.com',
          'phone': '010-1234-5678',
          'address': '서울시 강남구',
          'education': '대졸',
          'career': '3년',
          'skills': 'Java, Spring, MySQL',
          'regdate': '2024-01-01T00:00:00',
        };

        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(jsonEncode(resumeData), 200));

        // When
        final result = await resumeService.getResumeById(resumeId);

        // Then
        expect(result, isNotNull);
        expect(result!['resumeNo'], 1);
        expect(result['title'], '백엔드 개발자 이력서');
        expect(result['skills'], 'Java, Spring, MySQL');
      });

      test('존재하지 않는 이력서 조회 시 null 반환 테스트', () async {
        // Given
        const resumeId = 999;

        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response('Not Found', 404));

        // When
        final result = await resumeService.getResumeById(resumeId);

        // Then
        expect(result, isNull);
      });
    });

    group('이력서 등록/수정 테스트', () {
      test('이력서 등록 성공 테스트', () async {
        // Given
        final resumeData = {
          'title': '새 이력서',
          'content': '이력서 내용',
          'name': '김철수',
          'email': 'kim@example.com',
          'phone': '010-9876-5432',
          'address': '부산시 해운대구',
          'education': '대졸',
          'career': '2년',
          'skills': 'React, JavaScript, CSS',
          'hopeJobtype': '프론트엔드',
          'hopeLocation': '부산',
          'hopeSalary': '3000만원',
        };

        final createdResume = {
          'resumeNo': 1,
          ...resumeData,
          'regdate': '2024-01-01T00:00
          final createdResume = {
          'resumeNo': 1,
          ...resumeData,
          'regdate': '2024-01-01T00:00:00',
        };

        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(jsonEncode(createdResume), 201));

        // When
        final result = await resumeService.createResume(resumeData);

        // Then
        expect(result, isNotNull);
        expect(result!['resumeNo'], 1);
        expect(result['title'], '새 이력서');
        expect(result['name'], '김철수');
      });

      test('이력서 수정 성공 테스트', () async {
        // Given
        const resumeId = 1;
        final updateData = {
          'title': '수정된 이력서',
          'content': '수정된 내용',
          'skills': 'Java, Spring, React',
        };

        final updatedResume = {
          'resumeNo': 1,
          'title': '수정된 이력서',
          'content': '수정된 내용',
          'name': '홍길동',
          'skills': 'Java, Spring, React',
        };

        when(mockHttpClient.put(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(jsonEncode(updatedResume), 200));

        // When
        final result = await resumeService.updateResume(resumeId, updateData);

        // Then
        expect(result, isNotNull);
        expect(result!['title'], '수정된 이력서');
        expect(result['content'], '수정된 내용');
        expect(result['skills'], 'Java, Spring, React');
      });

      test('이력서 삭제 성공 테스트', () async {
        // Given
        const resumeId = 1;

        when(mockHttpClient.delete(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('', 204));

        // When
        final result = await resumeService.deleteResume(resumeId);

        // Then
        expect(result, isTrue);
      });

      test('존재하지 않는 이력서 삭제 시 실패 테스트', () async {
        // Given
        const resumeId = 999;

        when(mockHttpClient.delete(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Not Found', 404));

        // When
        final result = await resumeService.deleteResume(resumeId);

        // Then
        expect(result, isFalse);
      });
    });

    group('이력서 검색 테스트', () {
      test('키워드로 이력서 검색 성공 테스트', () async {
        // Given
        const keyword = '개발자';
        final searchResults = [
          {
            'resumeNo': 1,
            'title': '백엔드 개발자 이력서',
            'name': '홍길동',
            'hopeJobtype': '개발자',
          },
          {
            'resumeNo': 2,
            'title': '프론트엔드 개발자 이력서',
            'name': '김철수',
            'hopeJobtype': '개발자',
          }
        ];

        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(jsonEncode(searchResults), 200));

        // When
        final result = await resumeService.searchResumes(keyword);

        // Then
        expect(result, hasLength(2));
        expect(result.first['title'], contains('개발자'));
        expect(result.last['title'], contains('개발자'));
      });

      test('빈 키워드로 검색 시 빈 배열 반환 테스트', () async {
        // Given
        const keyword = '';

        // When
        final result = await resumeService.searchResumes(keyword);

        // Then
        expect(result, isEmpty);
      });
    });

    group('이력서 필터링 테스트', () {
      test('희망직종별 필터링 테스트', () async {
        // Given
        const jobType = '개발자';
        final filteredResumes = [
          {
            'resumeNo': 1,
            'title': '백엔드 개발자 이력서',
            'hopeJobtype': '개발자',
            'name': '홍길동',
          }
        ];

        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(jsonEncode(filteredResumes), 200));

        // When
        final result = await resumeService.getResumesByJobType(jobType);

        // Then
        expect(result, isNotEmpty);
        expect(result.first['hopeJobtype'], '개발자');
      });

      test('희망지역별 필터링 테스트', () async {
        // Given
        const location = '서울';
        final filteredResumes = [
          {
            'resumeNo': 1,
            'title': '백엔드 개발자 이력서',
            'hopeLocation': '서울',
            'name': '홍길동',
          }
        ];

        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(jsonEncode(filteredResumes), 200));

        // When
        final result = await resumeService.getResumesByLocation(location);

        // Then
        expect(result, isNotEmpty);
        expect(result.first['hopeLocation'], '서울');
      });

      test('경력별 필터링 테스트', () async {
        // Given
        const career = '3년';
        final filteredResumes = [
          {
            'resumeNo': 1,
            'title': '백엔드 개발자 이력서',
            'career': '3년',
            'name': '홍길동',
          }
        ];

        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(jsonEncode(filteredResumes), 200));

        // When
        final result = await resumeService.getResumesByCareer(career);

        // Then
        expect(result, isNotEmpty);
        expect(result.first['career'], '3년');
      });
    });

    group('에러 처리 테스트', () {
      test('네트워크 오류 시 예외 발생 테스트', () async {
        // Given
        when(mockHttpClient.get(any))
            .thenThrow(Exception('Network error'));

        // When & Then
        expect(() => resumeService.getAllResumes(), throwsException);
      });

      test('서버 오류 시 예외 발생 테스트', () async {
        // Given
        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response('Server Error', 500));

        // When & Then
        expect(() => resumeService.getAllResumes(), throwsException);
      });

      test('잘못된 JSON 응답 시 예외 발생 테스트', () async {
        // Given
        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response('Invalid JSON', 200));

        // When & Then
        expect(() => resumeService.getAllResumes(), throwsException);
      });
    });
  });
}