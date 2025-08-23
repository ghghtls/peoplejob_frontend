import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';

import 'package:peoplejob_frontend/services/auth_service.dart';

// Mock 클래스들
class MockClient extends Mock implements http.Client {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockDio extends Mock implements Dio {}

class MockFile extends Mock implements File {}

class MockResponse extends Mock implements Response {}

@GenerateMocks([http.Client, FlutterSecureStorage, Dio])
void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockClient mockHttpClient;
    late MockFlutterSecureStorage mockStorage;
    late MockDio mockDio;

    setUp(() {
      mockHttpClient = MockClient();
      mockStorage = MockFlutterSecureStorage();
      mockDio = MockDio();

      // AuthService를 테스트용으로 초기화
      authService = AuthService();
    });

    group('로그인 테스트', () {
      test('성공적인 로그인 테스트', () async {
        // Given
        const userid = 'testuser';
        const password = 'password123';
        final loginResponse = {
          'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
          'userid': 'testuser',
          'userNo': 1,
          'role': 'USER',
          'userType': 'INDIVIDUAL',
          'name': '테스트 사용자',
          'email': 'test@example.com',
        };

        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(jsonEncode(loginResponse), 200),
        );

        when(
          mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
        ).thenAnswer((_) async {});

        // When
        final result = await authService.login(
          userid: userid,
          password: password,
        );

        // Then
        expect(result, isNotNull);
        expect(result!['token'], startsWith('eyJ'));
        expect(result['userid'], 'testuser');
        expect(result['userType'], 'INDIVIDUAL');
        expect(result['role'], 'USER');

        // 저장소에 올바른 값들이 저장되었는지 확인
        verify(
          mockStorage.write(key: 'jwt', value: loginResponse['token']),
        ).called(1);
        verify(
          mockStorage.write(key: 'userid', value: loginResponse['userid']),
        ).called(1);
        verify(
          mockStorage.write(
            key: 'userNo',
            value: loginResponse['userNo'].toString(),
          ),
        ).called(1);
        verify(
          mockStorage.write(key: 'role', value: loginResponse['role']),
        ).called(1);
        verify(
          mockStorage.write(key: 'userType', value: loginResponse['userType']),
        ).called(1);
        verify(
          mockStorage.write(key: 'name', value: loginResponse['name']),
        ).called(1);
        verify(
          mockStorage.write(key: 'email', value: loginResponse['email']),
        ).called(1);
      });

      test('잘못된 자격증명으로 로그인 실패 테스트', () async {
        // Given
        const userid = 'wronguser';
        const password = 'wrongpassword';

        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('{"error": "Invalid credentials"}', 401),
        );

        // When
        final result = await authService.login(
          userid: userid,
          password: password,
        );

        // Then
        expect(result, isNull);
        verifyNever(
          mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
        );
      });

      test('서버 오류 시 로그인 실패 테스트', () async {
        // Given
        const userid = 'testuser';
        const password = 'password123';

        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Server Error', 500));

        // When
        final result = await authService.login(
          userid: userid,
          password: password,
        );

        // Then
        expect(result, isNull);
      });

      test('네트워크 오류 시 로그인 실패 테스트', () async {
        // Given
        const userid = 'testuser';
        const password = 'password123';

        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenThrow(Exception('Network error'));

        // When
        final result = await authService.login(
          userid: userid,
          password: password,
        );

        // Then
        expect(result, isNull);
      });
    });

    group('토큰 관리 테스트', () {
      test('토큰 저장 및 조회 테스트', () async {
        // Given
        const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';

        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => token);

        // When
        final result = await authService.getToken();

        // Then
        expect(result, token);
        verify(mockStorage.read(key: 'jwt')).called(1);
      });

      test('토큰이 없을 때 null 반환 테스트', () async {
        // Given
        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => null);

        // When
        final result = await authService.getToken();

        // Then
        expect(result, isNull);
      });
    });

    group('사용자 정보 관리 테스트', () {
      test('사용자 번호 조회 테스트', () async {
        // Given
        const userNo = '123';

        when(mockStorage.read(key: 'userNo')).thenAnswer((_) async => userNo);

        // When
        final result = await authService.getUserNo();

        // Then
        expect(result, 123);
      });

      test('잘못된 사용자 번호 형식 처리 테스트', () async {
        // Given
        const invalidUserNo = 'invalid_number';

        when(
          mockStorage.read(key: 'userNo'),
        ).thenAnswer((_) async => invalidUserNo);

        // When
        final result = await authService.getUserNo();

        // Then
        expect(result, isNull);
      });

      test('사용자 정보 전체 조회 테스트', () async {
        // Given
        final expectedUserInfo = {
          'userid': 'testuser',
          'userNo': '123',
          'role': 'USER',
          'userType': 'INDIVIDUAL',
          'name': '테스트 사용자',
          'email': 'test@example.com',
        };

        when(mockStorage.read(key: anyNamed('key'))).thenAnswer((
          invocation,
        ) async {
          final key = invocation.namedArguments[const Symbol('key')] as String;
          return expectedUserInfo[key];
        });

        // When
        final result = await authService.getUserInfo();

        // Then
        expect(result['userid'], 'testuser');
        expect(result['userNo'], '123');
        expect(result['role'], 'USER');
        expect(result['userType'], 'INDIVIDUAL');
        expect(result['name'], '테스트 사용자');
        expect(result['email'], 'test@example.com');
      });
    });

    group('로그아웃 테스트', () {
      test('로그아웃 시 저장소 정리 테스트', () async {
        // Given
        when(mockStorage.deleteAll()).thenAnswer((_) async {});

        // When
        await authService.logout();

        // Then
        verify(mockStorage.deleteAll()).called(1);
      });
    });

    group('프로필 관리 테스트', () {
      test('사용자 프로필 조회 성공 테스트', () async {
        // Given
        const userNo = '1';
        const token = 'valid-token';
        final profileData = {
          'userNo': 1,
          'userid': 'testuser',
          'name': '테스트 사용자',
          'email': 'test@example.com',
          'phone': '010-1234-5678',
          'address': '서울시 강남구',
          'userType': 'INDIVIDUAL',
        };

        when(mockStorage.read(key: 'userNo')).thenAnswer((_) async => userNo);
        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => token);
        when(
          mockHttpClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(profileData), 200));

        // When
        final result = await authService.getUserProfile();

        // Then
        expect(result, isNotNull);
        expect(result!['name'], '테스트 사용자');
        expect(result['email'], 'test@example.com');
        expect(result['phone'], '010-1234-5678');
        expect(result['userType'], 'INDIVIDUAL');

        verify(
          mockHttpClient.get(
            argThat(contains('/api/users/profile/1')),
            headers: argThat(contains('Authorization'), named: 'headers'),
          ),
        ).called(1);
      });

      test('사용자 정보 없을 때 프로필 조회 실패 테스트', () async {
        // Given
        when(mockStorage.read(key: 'userNo')).thenAnswer((_) async => null);

        // When & Then
        expect(
          () => authService.getUserProfile(),
          throwsA(
            predicate(
              (e) =>
                  e is Exception && e.toString().contains('사용자 정보를 찾을 수 없습니다'),
            ),
          ),
        );
      });

      test('개인회원 프로필 수정 성공 테스트', () async {
        // Given
        const userNo = '1';
        const token = 'valid-token';
        final updateData = {
          'user': {
            'name': '수정된 이름',
            'email': 'updated@example.com',
            'phone': '010-9876-5432',
            'address': '부산시 해운대구',
          },
        };

        when(mockStorage.read(key: 'userNo')).thenAnswer((_) async => userNo);
        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => token);
        when(
          mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
        ).thenAnswer((_) async {});
        when(
          mockHttpClient.put(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(updateData), 200));

        // When
        final result = await authService.updateUserProfile(
          name: '수정된 이름',
          email: 'updated@example.com',
          phone: '010-9876-5432',
          address: '부산시 해운대구',
        );

        // Then
        expect(result, isNotNull);
        expect(result!['user']['name'], '수정된 이름');
        expect(result['user']['email'], 'updated@example.com');

        // 로컬 저장소 업데이트 확인
        verify(mockStorage.write(key: 'name', value: '수정된 이름')).called(1);
        verify(
          mockStorage.write(key: 'email', value: 'updated@example.com'),
        ).called(1);
      });

      test('기업회원 프로필 수정 성공 테스트', () async {
        // Given
        const userNo = '1';
        const token = 'valid-token';
        final updateData = {
          'user': {'name': '대표자명', 'email': 'company@example.com'},
          'company': {
            'companyName': '테스트 회사',
            'businessNumber': '123-45-67890',
            'ceoName': '대표자명',
          },
        };

        when(mockStorage.read(key: 'userNo')).thenAnswer((_) async => userNo);
        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => token);
        when(
          mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
        ).thenAnswer((_) async {});
        when(
          mockHttpClient.put(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(updateData), 200));

        // When
        final result = await authService.updateUserProfile(
          name: '대표자명',
          email: 'company@example.com',
          companyName: '테스트 회사',
          businessNumber: '123-45-67890',
          ceoName: '대표자명',
          companyType: '중소기업',
          employeeCount: 50,
        );

        // Then
        expect(result, isNotNull);
        expect(result!['user']['name'], '대표자명');
        expect(result['user']['email'], 'company@example.com');
      });

      test('비밀번호 변경 성공 테스트', () async {
        // Given
        const userNo = '1';
        const token = 'valid-token';
        const currentPassword = 'oldpassword123';
        const newPassword = 'newpassword456';

        when(mockStorage.read(key: 'userNo')).thenAnswer((_) async => userNo);
        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => token);
        when(
          mockHttpClient.put(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('{"success": true}', 200));

        // When
        final result = await authService.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );

        // Then
        expect(result, isTrue);

        verify(
          mockHttpClient.put(
            argThat(contains('/api/users/password/1')),
            headers: anyNamed('headers'),
            body: jsonEncode({
              'currentPassword': currentPassword,
              'newPassword': newPassword,
            }),
          ),
        ).called(1);
      });

      test('잘못된 현재 비밀번호로 변경 실패 테스트', () async {
        // Given
        const userNo = '1';
        const token = 'valid-token';
        const wrongCurrentPassword = 'wrongpassword';
        const newPassword = 'newpassword456';

        when(mockStorage.read(key: 'userNo')).thenAnswer((_) async => userNo);
        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => token);
        when(
          mockHttpClient.put(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('{"error": "현재 비밀번호가 일치하지 않습니다"}', 400),
        );

        // When & Then
        expect(
          () => authService.changePassword(
            currentPassword: wrongCurrentPassword,
            newPassword: newPassword,
          ),
          throwsA(
            predicate(
              (e) =>
                  e is Exception && e.toString().contains('현재 비밀번호가 일치하지 않습니다'),
            ),
          ),
        );
      });
    });

    group('프로필 이미지 관리 테스트', () {
      test('프로필 이미지 업로드 성공 테스트', () async {
        // Given
        const userNo = '1';
        const token = 'valid-token';
        const imageUrl = 'https://example.com/profile.jpg';

        final mockFile = MockFile();
        when(mockFile.path).thenReturn('/path/to/image.jpg');

        when(mockStorage.read(key: 'userNo')).thenAnswer((_) async => userNo);
        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => token);

        final mockResponse = MockResponse();
        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.data).thenReturn({'imageUrl': imageUrl});

        when(
          mockDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // When
        final result = await authService.uploadProfileImage(mockFile);

        // Then
        expect(result, imageUrl);
      });

      test('프로필 이미지 삭제 성공 테스트', () async {
        // Given
        const userNo = '1';
        const token = 'valid-token';

        when(mockStorage.read(key: 'userNo')).thenAnswer((_) async => userNo);
        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => token);
        when(
          mockHttpClient.delete(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('', 200));

        // When
        final result = await authService.deleteProfileImage();

        // Then
        expect(result, isTrue);

        verify(
          mockHttpClient.delete(
            argThat(contains('/api/users/profile/1/image')),
            headers: anyNamed('headers'),
          ),
        ).called(1);
      });

      test('프로필 이미지 삭제 실패 테스트', () async {
        // Given
        const userNo = '1';
        const token = 'valid-token';

        when(mockStorage.read(key: 'userNo')).thenAnswer((_) async => userNo);
        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => token);
        when(
          mockHttpClient.delete(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('Error', 500));

        // When
        final result = await authService.deleteProfileImage();

        // Then
        expect(result, isFalse);
      });
    });

    group('회원 탈퇴 테스트', () {
      test('회원 탈퇴 성공 테스트', () async {
        // Given
        const userNo = '1';
        const token = 'valid-token';

        when(mockStorage.read(key: 'userNo')).thenAnswer((_) async => userNo);
        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => token);
        when(mockStorage.deleteAll()).thenAnswer((_) async {});
        when(
          mockHttpClient.delete(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('', 200));

        // When
        final result = await authService.deleteAccount();

        // Then
        expect(result, isTrue);

        verify(
          mockHttpClient.delete(
            argThat(contains('/api/users/profile/1')),
            headers: anyNamed('headers'),
          ),
        ).called(1);
        verify(mockStorage.deleteAll()).called(1);
      });

      test('회원 탈퇴 실패 테스트', () async {
        // Given
        const userNo = '1';
        const token = 'valid-token';

        when(mockStorage.read(key: 'userNo')).thenAnswer((_) async => userNo);
        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => token);
        when(
          mockHttpClient.delete(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('Error', 500));

        // When
        final result = await authService.deleteAccount();

        // Then
        expect(result, isFalse);
        verifyNever(mockStorage.deleteAll());
      });
    });

    group('인증된 요청 테스트', () {
      test('인증된 GET 요청 테스트', () async {
        // Given
        const token = 'valid-token';
        const endpoint = '/api/test';

        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => token);
        when(
          mockHttpClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('{"data": "success"}', 200));

        // When
        final response = await authService.authenticatedGet(endpoint);

        // Then
        expect(response.statusCode, 200);
        expect(response.body, '{"data": "success"}');

        verify(
          mockHttpClient.get(
            argThat(contains(endpoint)),
            headers: argThat(
              allOf([
                containsPair('Authorization', 'Bearer $token'),
                containsPair('Content-Type', 'application/json'),
              ]),
              named: 'headers',
            ),
          ),
        ).called(1);
      });

      test('인증된 POST 요청 테스트', () async {
        // Given
        const token = 'valid-token';
        const endpoint = '/api/test';
        final requestBody = {'key': 'value', 'number': 123};

        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => token);
        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('{"success": true}', 200));

        // When
        final response = await authService.authenticatedPost(
          endpoint,
          requestBody,
        );

        // Then
        expect(response.statusCode, 200);
        expect(response.body, '{"success": true}');

        verify(
          mockHttpClient.post(
            argThat(contains(endpoint)),
            headers: argThat(
              allOf([
                containsPair('Authorization', 'Bearer $token'),
                containsPair('Content-Type', 'application/json'),
              ]),
              named: 'headers',
            ),
            body: jsonEncode(requestBody),
          ),
        ).called(1);
      });

      test('토큰이 없을 때 인증된 요청 테스트', () async {
        // Given
        const endpoint = '/api/test';

        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => null);
        when(
          mockHttpClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('{"data": "success"}', 200));

        // When
        final response = await authService.authenticatedGet(endpoint);

        // Then
        expect(response.statusCode, 200);

        verify(
          mockHttpClient.get(
            argThat(contains(endpoint)),
            headers: argThat(
              allOf([
                isNot(contains('Authorization')),
                containsPair('Content-Type', 'application/json'),
              ]),
              named: 'headers',
            ),
          ),
        ).called(1);
      });
    });

    group('전체 시나리오 테스트', () {
      test('로그인부터 프로필 수정까지 전체 플로우 테스트', () async {
        // Given
        const userid = 'testuser';
        const password = 'password123';
        final loginResponse = {
          'token': 'valid-token',
          'userid': 'testuser',
          'userNo': 1,
          'role': 'USER',
          'userType': 'INDIVIDUAL',
          'name': '테스트 사용자',
          'email': 'test@example.com',
        };

        // 1. 로그인 성공
        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(jsonEncode(loginResponse), 200),
        );

        when(
          mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
        ).thenAnswer((_) async {});

        // 2. 프로필 조회 성공
        when(mockStorage.read(key: 'userNo')).thenAnswer((_) async => '1');
        when(
          mockStorage.read(key: 'jwt'),
        ).thenAnswer((_) async => 'valid-token');

        final profileData = {
          'userNo': 1,
          'name': '테스트 사용자',
          'email': 'test@example.com',
        };

        when(
          mockHttpClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(profileData), 200));

        // 3. 프로필 수정 성공
        final updatedData = {
          'user': {'name': '수정된 이름', 'email': 'updated@example.com'},
        };

        when(
          mockHttpClient.put(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(updatedData), 200));

        // When & Then
        // 1. 로그인
        final loginResult = await authService.login(
          userid: userid,
          password: password,
        );
        expect(loginResult, isNotNull);
        expect(loginResult!['userid'], 'testuser');

        // 2. 프로필 조회
        final profile = await authService.getUserProfile();
        expect(profile, isNotNull);
        expect(profile!['name'], '테스트 사용자');

        // 3. 프로필 수정
        final updateResult = await authService.updateUserProfile(
          name: '수정된 이름',
          email: 'updated@example.com',
        );
        expect(updateResult, isNotNull);
        expect(updateResult!['user']['name'], '수정된 이름');

        // 모든 요청이 순서대로 호출되었는지 확인
        verifyInOrder([
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
          mockHttpClient.get(any, headers: anyNamed('headers')),
          mockHttpClient.put(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ]);
      });
    });
  });
}
