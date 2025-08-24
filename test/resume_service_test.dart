import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:peoplejob_frontend/services/resume_service.dart';

/// ---------------------------------------------------------------------------
/// 로컬 Mock (build_runner 불필요)
/// ---------------------------------------------------------------------------
class _MockDio extends Mock implements Dio {}

class _MockStorage extends Mock implements FlutterSecureStorage {}

/// ---------------------------------------------------------------------------
/// 실사용 Response/DioException 헬퍼
/// ---------------------------------------------------------------------------
Response<dynamic> _resp(dynamic data, {int? statusCode, String path = '/'}) {
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
  group('ResumeService Tests', () {
    late ResumeService resumeService;
    late _MockDio mockDio;
    late _MockStorage mockStorage;

    setUp(() {
      mockDio = _MockDio();
      mockStorage = _MockStorage();

      // ✅ 테스트 훅으로 모의 객체 주입
      ResumeService.setTestOverrides(dio: mockDio, storage: mockStorage);

      // 생성자는 요청대로 인자 없이!
      resumeService = ResumeService();

      when(
        mockStorage.read(key: 'jwt'),
      ).thenAnswer((_) async => 'mock-jwt-token');
    });

    group('이력서 조회 테스트', () {
      test('모든 이력서 조회 성공 테스트', () async {
        final mockResumesData = [
          {
            'resumeNo': 1,
            'title': '백엔드 개발자 이력서',
            'content': '3년 경력의 백엔드 개발자입니다.',
            'name': '홍길동',
            'email': 'hong@example.com',
            'phone': '010-1234-5678',
            'address': '서울시 강남구',
            'birth': '1990-01-01',
            'gender': 'M',
            'education': '대졸',
            'career': '3년',
            'skills': 'Java, Spring Boot, MySQL, Redis',
            'certificates': 'AWS Solutions Architect',
            'hopeJobtype': '백엔드 개발자',
            'hopeLocation': '서울',
            'hopeSalary': '4000만원',
            'hopeWorktype': '정규직',
            'selfIntroduction': '열정적인 백엔드 개발자입니다.',
            'regdate': '2024-01-01T00:00:00',
            'userNo': 1,
            'isPublic': true,
          },
          {
            'resumeNo': 2,
            'title': '프론트엔드 개발자 이력서',
            'content': '2년 경력의 프론트엔드 개발자입니다.',
            'name': '김철수',
            'email': 'kim@example.com',
            'phone': '010-9876-5432',
            'address': '부산시 해운대구',
            'birth': '1992-05-15',
            'gender': 'M',
            'education': '대졸',
            'career': '2년',
            'skills': 'React, JavaScript, TypeScript, CSS',
            'certificates': '정보처리기사',
            'hopeJobtype': '프론트엔드 개발자',
            'hopeLocation': '부산',
            'hopeSalary': '3500만원',
            'hopeWorktype': '정규직',
            'selfIntroduction': '사용자 경험을 중시하는 개발자입니다.',
            'regdate': '2024-01-02T00:00:00',
            'userNo': 2,
            'isPublic': true,
          },
        ];

        when(mockDio.get('/api/resume')).thenAnswer(
          (_) async =>
              _resp(mockResumesData, statusCode: 200, path: '/api/resume'),
        );

        final result = await resumeService.getAllResumes();

        expect(result, hasLength(2));
        expect(result[0]['title'], '백엔드 개발자 이력서');
        expect(result[0]['name'], '홍길동');
        expect(result[0]['career'], '3년');
        expect(result[1]['title'], '프론트엔드 개발자 이력서');
        expect(result[1]['name'], '김철수');
        expect(result[1]['career'], '2년');

        verify(mockDio.get('/api/resume')).called(1);
      });

      test('특정 사용자의 이력서 조회 성공 테스트', () async {
        const userNo = 1;
        final mockUserResumes = [
          {
            'resumeNo': 1,
            'title': '내 첫 번째 이력서',
            'content': '메인 이력서입니다.',
            'name': '홍길동',
            'email': 'hong@example.com',
            'userNo': 1,
            'isDefault': true,
            'isPublic': true,
            'regdate': '2024-01-01T00:00:00',
          },
          {
            'resumeNo': 4,
            'title': '백엔드 전문 이력서',
            'content': '백엔드 포지션 전용 이력서입니다.',
            'name': '홍길동',
            'email': 'hong@example.com',
            'userNo': 1,
            'isDefault': false,
            'isPublic': false,
            'regdate': '2024-01-05T00:00:00',
          },
        ];

        when(mockDio.get('/api/resume/user/$userNo')).thenAnswer(
          (_) async => _resp(
            mockUserResumes,
            statusCode: 200,
            path: '/api/resume/user/$userNo',
          ),
        );

        final result = await resumeService.getUserResumes(userNo);

        expect(result, hasLength(2));
        expect(result[0]['userNo'], 1);
        expect(result[0]['isDefault'], true);
        expect(result[1]['userNo'], 1);
        expect(result[1]['isDefault'], false);

        verify(mockDio.get('/api/resume/user/$userNo')).called(1);
      });

      test('이력서 상세 조회 성공 테스트', () async {
        const resumeId = 1;
        final mockResumeDetail = {
          'resumeNo': 1,
          'title': '백엔드 개발자 이력서',
          'content': '상세한 경력 내용입니다.',
          'name': '홍길동',
          'email': 'hong@example.com',
          'phone': '010-1234-5678',
          'career': '3년',
          'skills': 'Java, Spring Boot, MySQL, Redis',
          'hopeJobtype': '백엔드 개발자',
          'viewCount': 45,
        };

        when(mockDio.get('/api/resume/$resumeId')).thenAnswer(
          (_) async => _resp(
            mockResumeDetail,
            statusCode: 200,
            path: '/api/resume/$resumeId',
          ),
        );

        final result = await resumeService.getResumeDetail(resumeId);

        expect(result['resumeNo'], 1);
        expect(result['title'], '백엔드 개발자 이력서');
        expect(result['name'], '홍길동');
        expect(result['career'], '3년');
        expect(result['skills'], contains('Spring Boot'));

        verify(mockDio.get('/api/resume/$resumeId')).called(1);
      });
    });

    group('이력서 등록/수정/삭제 테스트', () {
      test('이력서 등록 성공 테스트', () async {
        final resumeData = {
          'title': '새로운 이력서',
          'content': '새로운 이력서 내용입니다.',
          'name': '박민수',
          'email': 'park@example.com',
          'phone': '010-7777-8888',
          'education': '대졸',
          'career': '1년',
          'hopeJobtype': '풀스택 개발자',
          'isPublic': true,
        };

        when(mockDio.post('/api/resume', data: anyNamed('data'))).thenAnswer(
          (_) async =>
              _resp({'resumeId': 5}, statusCode: 200, path: '/api/resume'),
        );

        final result = await resumeService.createResume(resumeData);

        expect(result, 5);
        verify(mockDio.post('/api/resume', data: anyNamed('data'))).called(1);
      });

      test('이력서 수정 성공 테스트', () async {
        const resumeId = 1;
        final updateData = {
          'title': '수정된 이력서 제목',
          'content': '수정된 이력서 내용입니다.',
          'skills': 'Java, Spring Boot, Kotlin, JPA',
          'hopeSalary': '4500만원',
        };

        when(
          mockDio.put('/api/resume/$resumeId', data: anyNamed('data')),
        ).thenAnswer(
          (_) async =>
              _resp(null, statusCode: 200, path: '/api/resume/$resumeId'),
        );

        final result = await resumeService.updateResume(resumeId, updateData);

        expect(result, isTrue);
        verify(
          mockDio.put('/api/resume/$resumeId', data: anyNamed('data')),
        ).called(1);
      });

      test('이력서 삭제 성공 테스트', () async {
        const resumeId = 1;

        when(mockDio.delete('/api/resume/$resumeId')).thenAnswer(
          (_) async =>
              _resp(null, statusCode: 200, path: '/api/resume/$resumeId'),
        );

        final result = await resumeService.deleteResume(resumeId);

        expect(result, isTrue);
        verify(mockDio.delete('/api/resume/$resumeId')).called(1);
      });
    });

    group('이력서 검색 및 필터링 테스트', () {
      test('키워드로 이력서 검색 성공 테스트', () async {
        const keyword = '개발자';
        final mockSearchResults = [
          {
            'resumeNo': 1,
            'title': '백엔드 개발자 이력서',
            'name': '홍길동',
            'hopeJobtype': '백엔드 개발자',
            'career': '3년',
            'skills': 'Java, Spring',
            'hopeLocation': '서울',
          },
          {
            'resumeNo': 2,
            'title': '프론트엔드 개발자 이력서',
            'name': '김철수',
            'hopeJobtype': '프론트엔드 개발자',
            'career': '2년',
            'skills': 'React, JavaScript',
            'hopeLocation': '부산',
          },
        ];

        when(mockDio.get('/api/resume/search?keyword=$keyword')).thenAnswer(
          (_) async => _resp(
            mockSearchResults,
            statusCode: 200,
            path: '/api/resume/search?keyword=$keyword',
          ),
        );

        final result = await resumeService.searchResumes(keyword);

        expect(result, hasLength(2));
        expect(
          result.every(
            (r) =>
                r['title'].contains('개발자') || r['hopeJobtype'].contains('개발자'),
          ),
          isTrue,
        );
        verify(mockDio.get('/api/resume/search?keyword=$keyword')).called(1);
      });

      test('빈 키워드로 검색 시 빈 배열 반환 테스트', () async {
        const keyword = '';
        final result = await resumeService.searchResumes(keyword);
        expect(result, isEmpty);

        // (선택) 네트워크 호출이 없음을 강하게 검증하려면 아래처럼 전체 상호작용 0 확인:
        // verifyZeroInteractions(mockDio);
      });

      test('희망 직종별 이력서 필터링 성공 테스트', () async {
        const jobType = '백엔드 개발자';
        final mockJobTypeResults = [
          {
            'resumeNo': 1,
            'title': '시니어 백엔드 개발자',
            'name': '홍길동',
            'hopeJobtype': '백엔드 개발자',
            'career': '5년',
            'skills': 'Java, Spring Boot, MSA',
            'hopeLocation': '서울',
          },
        ];

        when(mockDio.get('/api/resume/jobtype/$jobType')).thenAnswer(
          (_) async => _resp(
            mockJobTypeResults,
            statusCode: 200,
            path: '/api/resume/jobtype/$jobType',
          ),
        );

        final result = await resumeService.getResumesByJobType(jobType);

        expect(result, hasLength(1));
        expect(result[0]['hopeJobtype'], '백엔드 개발자');
        verify(mockDio.get('/api/resume/jobtype/$jobType')).called(1);
      });

      test('희망 지역별 이력서 필터링 성공 테스트', () async {
        const location = '서울';
        final mockLocationResults = [
          {
            'resumeNo': 1,
            'title': '서울 근무 희망 개발자',
            'name': '홍길동',
            'hopeJobtype': '백엔드 개발자',
            'hopeLocation': '서울',
            'address': '서울시 강남구',
          },
        ];

        when(mockDio.get('/api/resume/location/$location')).thenAnswer(
          (_) async => _resp(
            mockLocationResults,
            statusCode: 200,
            path: '/api/resume/location/$location',
          ),
        );

        final result = await resumeService.getResumesByLocation(location);

        expect(result, hasLength(1));
        expect(result[0]['hopeLocation'], '서울');
        verify(mockDio.get('/api/resume/location/$location')).called(1);
      });
    });

    group('에러 처리 테스트', () {
      test('네트워크 연결 오류 시 예외 발생 테스트', () async {
        when(mockDio.get('/api/resume')).thenThrow(
          _dioEx(path: '/api/resume', type: DioExceptionType.connectionTimeout),
        );

        expect(
          () => resumeService.getAllResumes(),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('이력서 목록을 불러오는데 실패했습니다'),
            ),
          ),
        );
      });

      test('서버 내부 오류 시 예외 발생 테스트', () async {
        when(
          mockDio.get('/api/resume'),
        ).thenThrow(_dioEx(path: '/api/resume', statusCode: 500));

        expect(
          () => resumeService.getAllResumes(),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('이력서 목록을 불러오는데 실패했습니다'),
            ),
          ),
        );
      });

      test('인증 실패 시 처리 테스트', () async {
        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => null);
        when(
          mockDio.post('/api/resume', data: anyNamed('data')),
        ).thenThrow(_dioEx(path: '/api/resume', statusCode: 401));

        final resumeData = {'title': '테스트', 'content': '테스트'};
        final result = await resumeService.createResume(resumeData);

        expect(result, isNull);
      });
    });

    group('실제 사용 시나리오 테스트', () {
      test('이력서 목록 조회 → 상세 보기 → 수정 시나리오 테스트', () async {
        const userNo = 1;
        const resumeId = 1;

        final mockUserResumes = [
          {
            'resumeNo': 1,
            'title': '내 이력서',
            'name': '홍길동',
            'userNo': 1,
            'isDefault': true,
          },
        ];
        final mockResumeDetail = {
          'resumeNo': 1,
          'title': '내 이력서',
          'content': '기존 내용',
          'name': '홍길동',
          'career': '3년',
        };
        final updateData = {'content': '수정된 내용', 'career': '4년'};

        when(mockDio.get('/api/resume/user/$userNo')).thenAnswer(
          (_) async => _resp(
            mockUserResumes,
            statusCode: 200,
            path: '/api/resume/user/$userNo',
          ),
        );
        when(mockDio.get('/api/resume/$resumeId')).thenAnswer(
          (_) async => _resp(
            mockResumeDetail,
            statusCode: 200,
            path: '/api/resume/$resumeId',
          ),
        );
        when(
          mockDio.put('/api/resume/$resumeId', data: anyNamed('data')),
        ).thenAnswer(
          (_) async =>
              _resp(null, statusCode: 200, path: '/api/resume/$resumeId'),
        );

        final resumes = await resumeService.getUserResumes(userNo);
        expect(resumes, hasLength(1));

        final detail = await resumeService.getResumeDetail(resumeId);
        expect(detail['content'], '기존 내용');

        final updateResult = await resumeService.updateResume(
          resumeId,
          updateData,
        );
        expect(updateResult, isTrue);

        verifyInOrder([
          mockDio.get('/api/resume/user/$userNo'),
          mockDio.get('/api/resume/$resumeId'),
          mockDio.put('/api/resume/$resumeId', data: anyNamed('data')),
        ]);
      });
    });
  });
}
