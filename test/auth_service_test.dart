import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:peoplejob_frontend/services/auth_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockFlutterSecureStorage mockStorage;
    late MockHttpClient mockClient;

    const baseUrl = 'http://localhost:5000';

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      mockClient = MockHttpClient();
      authService = AuthService(
        client: mockClient,
        storage: mockStorage,
        baseUrl: baseUrl,
      );
    });

    // ── 로그아웃 ────────────────────────────────────────────
    group('로그아웃', () {
      test('logout() — storage.deleteAll 호출', () async {
        when(mockStorage.deleteAll()).thenAnswer((_) async {});

        await authService.logout();

        verify(mockStorage.deleteAll()).called(1);
      });
    });

    // ── 토큰/사용자 정보 조회 ───────────────────────────────
    group('로컬 저장소 조회', () {
      test('getToken() — jwt 키 반환', () async {
        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => 'test-token');

        final token = await authService.getToken();

        expect(token, 'test-token');
        verify(mockStorage.read(key: 'jwt')).called(1);
      });

      test('getToken() — 토큰 없으면 null 반환', () async {
        when(mockStorage.read(key: 'jwt')).thenAnswer((_) async => null);

        final token = await authService.getToken();

        expect(token, isNull);
      });

      test('getUserNo() — 숫자 파싱 성공', () async {
        when(mockStorage.read(key: 'userNo'))
            .thenAnswer((_) async => '42');

        final userNo = await authService.getUserNo();

        expect(userNo, 42);
      });

      test('getUserNo() — 저장값 없으면 null', () async {
        when(mockStorage.read(key: 'userNo'))
            .thenAnswer((_) async => null);

        final userNo = await authService.getUserNo();

        expect(userNo, isNull);
      });

      test('getUserInfo() — 모든 키 반환', () async {
        when(mockStorage.read(key: 'userid')).thenAnswer((_) async => 'user1');
        when(mockStorage.read(key: 'userNo')).thenAnswer((_) async => '1');
        when(mockStorage.read(key: 'role')).thenAnswer((_) async => 'USER');
        when(mockStorage.read(key: 'userType'))
            .thenAnswer((_) async => 'INDIVIDUAL');
        when(mockStorage.read(key: 'name')).thenAnswer((_) async => '홍길동');
        when(mockStorage.read(key: 'email'))
            .thenAnswer((_) async => 'test@example.com');

        final info = await authService.getUserInfo();

        expect(info['userid'], 'user1');
        expect(info['userNo'], '1');
        expect(info['role'], 'USER');
        expect(info['name'], '홍길동');
        expect(info['email'], 'test@example.com');
      });
    });

    // ── 로그인 ──────────────────────────────────────────────
    group('로그인', () {
      test('login() 성공 — 토큰 및 사용자 정보 저장', () async {
        final responseBody = {
          'token': 'jwt-token-123',
          'userid': 'user1',
          'userNo': 1,
          'role': 'USER',
          'userType': 'INDIVIDUAL',
          'name': '홍길동',
          'email': 'test@example.com',
        };

        when(
          mockClient.post(
            Uri.parse('$baseUrl/api/users/login'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(jsonEncode(responseBody), 200),
        );

        when(mockStorage.write(key: 'jwt', value: 'jwt-token-123')).thenAnswer((_) async {});
        when(mockStorage.write(key: 'userid', value: 'user1')).thenAnswer((_) async {});
        when(mockStorage.write(key: 'userNo', value: '1')).thenAnswer((_) async {});
        when(mockStorage.write(key: 'role', value: 'USER')).thenAnswer((_) async {});
        when(mockStorage.write(key: 'userType', value: 'INDIVIDUAL')).thenAnswer((_) async {});
        when(mockStorage.write(key: 'name', value: '홍길동')).thenAnswer((_) async {});
        when(mockStorage.write(key: 'email', value: 'test@example.com')).thenAnswer((_) async {});

        final result = await authService.login(
          userid: 'user1',
          password: 'pass123',
        );

        expect(result, isNotNull);
        expect(result!['token'], 'jwt-token-123');
        expect(result['userid'], 'user1');

        verify(mockStorage.write(key: 'jwt', value: 'jwt-token-123')).called(1);
        verify(mockStorage.write(key: 'userNo', value: '1')).called(1);
      });

      test('login() 실패 (401) — null 반환', () async {
        when(
          mockClient.post(
            Uri.parse('$baseUrl/api/users/login'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('{"message":"인증 실패"}', 401),
        );

        final result = await authService.login(
          userid: 'wrong',
          password: 'wrong',
        );

        expect(result, isNull);
        // 401 응답 시 어떤 키에도 write 하지 않아야 함
        verifyNever(mockStorage.write(key: 'jwt', value: 'jwt-token-123'));
      });

      test('login() 네트워크 오류 — null 반환', () async {
        when(
          mockClient.post(
            Uri.parse('$baseUrl/api/users/login'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenThrow(Exception('Network error'));

        final result = await authService.login(
          userid: 'user1',
          password: 'pass123',
        );

        expect(result, isNull);
      });
    });

    // ── 비밀번호 변경 ────────────────────────────────────────
    group('비밀번호 변경', () {
      test('changePassword() 성공', () async {
        when(mockStorage.read(key: 'userNo'))
            .thenAnswer((_) async => '1');
        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => 'test-token');
        when(
          mockClient.put(
            Uri.parse('$baseUrl/api/users/password/1'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('{}', 200));

        final result = await authService.changePassword(
          currentPassword: 'old123',
          newPassword: 'new456',
        );

        expect(result, isTrue);
      });

      test('changePassword() 실패 (400) — 예외 throw', () async {
        when(mockStorage.read(key: 'userNo'))
            .thenAnswer((_) async => '1');
        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => 'test-token');
        when(
          mockClient.put(
            Uri.parse('$baseUrl/api/users/password/1'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async =>
              http.Response('{"error":"현재 비밀번호가 일치하지 않습니다"}', 400),
        );

        expect(
          () => authService.changePassword(
            currentPassword: 'wrong',
            newPassword: 'new456',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ── 회원 탈퇴 ────────────────────────────────────────────
    group('회원 탈퇴', () {
      test('deleteAccount() 성공 — logout 호출', () async {
        when(mockStorage.read(key: 'userNo'))
            .thenAnswer((_) async => '1');
        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => 'test-token');
        when(
          mockClient.delete(
            Uri.parse('$baseUrl/api/users/profile/1'),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => http.Response('{}', 200));
        when(mockStorage.deleteAll()).thenAnswer((_) async {});

        final result = await authService.deleteAccount();

        expect(result, isTrue);
        verify(mockStorage.deleteAll()).called(1);
      });

      test('deleteAccount() userNo 없음 — 예외 throw', () async {
        when(mockStorage.read(key: 'userNo'))
            .thenAnswer((_) async => null);

        expect(
          () => authService.deleteAccount(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
