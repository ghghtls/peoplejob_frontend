import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:peoplejob_frontend/services/auth_service.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

class MockClient extends Mock implements http.Client {}

@GenerateMocks([http.Client])
void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockSecureStorage mockStorage;
    late MockClient mockHttpClient;

    setUp(() {
      mockStorage = MockSecureStorage();
      mockHttpClient = MockClient();
      authService = AuthService();
    });

    group('로그인 테스트', () {
      test('성공적인 로그인 테스트', () async {
        // Given
        const userid = 'testuser';
        const password = 'password123';
        final responseBody = jsonEncode({
          'token': 'mock-jwt-token',
          'userid': 'testuser',
          'userNo': 1,
          'role': 'USER',
          'userType': 'INDIVIDUAL',
          'name': '테스트 사용자',
          'email': 'test@example.com',
        });

        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(responseBody, 200));

        // When
        final result = await authService.login(
          userid: userid,
          password: password,
        );

        // Then
        expect(result, isNotNull);
        expect(result!['token'], 'mock-jwt-token');
        expect(result['userid'], 'testuser');
        expect(result['userType'], 'INDIVIDUAL');
      });

      test('잘못된 자격증명으로 로그인 실패 테스트', () async {
        // Given
        const userid = 'testuser';
        const password = 'wrongpassword';

        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Unauthorized', 401));

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
        const token = 'mock-jwt-token';

        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => token);

        // When
        final result = await authService.getToken();

        // Then
        expect(result, token);
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

    group('사용자 정보 테스트', () {
      test('사용자 정보 조회 테스트', () async {
        // Given
        final userInfo = {
          'userid': 'testuser',
          'userNo': '1',
          'role': 'USER',
          'userType': 'INDIVIDUAL',
          'name': '테스트 사용자',
          'email': 'test@example.com',
        };

        when(mockStorage.read(key: anyNamed('key'))).thenAnswer((
          invocation,
        ) async {
          final key = invocation.namedArguments[const Symbol('key')] as String;
          return userInfo[key];
        });

        // When
        final result = await authService.getUserInfo();

        // Then
        expect(result['userid'], 'testuser');
        expect(result['userType'], 'INDIVIDUAL');
        expect(result['name'], '테스트 사용자');
      });

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
        const invalidUserNo = 'invalid';

        when(
          mockStorage.read(key: 'userNo'),
        ).thenAnswer((_) async => invalidUserNo);

        // When
        final result = await authService.getUserNo();

        // Then
        expect(result, isNull);
      });
    });

    group('로그아웃 테스트', () {
      test('로그아웃 시 저장소 정리 테스트', () async {
        // When
        await authService.logout();

        // Then
        verify(mockStorage.deleteAll()).called(1);
      });
    });

    group('프로필 관리 테스트', () {
      test('프로필 정보 조회 성공 테스트', () async {
        // Given
        const userNo = 1;
        const token = 'mock-jwt-token';
        final profileData = {
          'userNo': 1,
          'name': '테스트 사용자',
          'email': 'test@example.com',
          'phone': '010-1234-5678',
        };

        when(
          mockStorage.read(key: 'userNo'),
        ).thenAnswer((_) async => userNo.toString());
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
      });

      test('프로필 정보 수정 성공 테스트', () async {
        // Given
        const userNo = 1;
        const token = 'mock-jwt-token';
        final updatedData = {
          'user': {'name': '수정된 이름', 'email': 'updated@example.com'},
        };

        when(
          mockStorage.read(key: 'userNo'),
        ).thenAnswer((_) async => userNo.toString());
        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => token);
        when(
          mockHttpClient.put(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(updatedData), 200));

        // When
        final result = await authService.updateUserProfile(
          name: '수정된 이름',
          email: 'updated@example.com',
        );

        // Then
        expect(result, isNotNull);
        expect(result!['user']['name'], '수정된 이름');
        expect(result['user']['email'], 'updated@example.com');
      });

      test('비밀번호 변경 성공 테스트', () async {
        // Given
        const userNo = 1;
        const token = 'mock-jwt-token';

        when(
          mockStorage.read(key: 'userNo'),
        ).thenAnswer((_) async => userNo.toString());
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
          currentPassword: 'oldpassword',
          newPassword: 'newpassword',
        );

        // Then
        expect(result, isTrue);
      });

      test('잘못된 현재 비밀번호로 변경 실패 테스트', () async {
        // Given
        const userNo = 1;
        const token = 'mock-jwt-token';

        when(
          mockStorage.read(key: 'userNo'),
        ).thenAnswer((_) async => userNo.toString());
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
            currentPassword: 'wrongpassword',
            newPassword: 'newpassword',
          ),
          throwsException,
        );
      });
    });

    group('인증된 요청 테스트', () {
      test('인증된 GET 요청 테스트', () async {
        // Given
        const token = 'mock-jwt-token';
        const endpoint = '/api/test';

        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => token);
        when(
          mockHttpClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('{"data": "test"}', 200));

        // When
        final response = await authService.authenticatedGet(endpoint);

        // Then
        expect(response.statusCode, 200);
        verify(
          mockHttpClient.get(
            any,
            headers: argThat(contains('Authorization'), named: 'headers'),
          ),
        ).called(1);
      });

      test('인증된 POST 요청 테스트', () async {
        // Given
        const token = 'mock-jwt-token';
        const endpoint = '/api/test';
        final body = {'test': 'data'};

        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => token);
        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('{"success": true}', 200));

        // When
        final response = await authService.authenticatedPost(endpoint, body);

        // Then
        expect(response.statusCode, 200);
        verify(
          mockHttpClient.post(
            any,
            headers: argThat(contains('Authorization'), named: 'headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });
    });
  });
}
