import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:faker/faker.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

class TestUtils {
  static final Faker faker = Faker();
  static late DioAdapter dioAdapter;
  static late Dio dio;

  /// Dio + http_mock_adapter 기본 세팅
  static void setupHttpMocks() {
    dio = Dio();
    dioAdapter = DioAdapter(dio: dio);
    // 혹시 버전에 따라 필요할 수 있어 명시적으로 바인딩
    dio.httpClientAdapter = dioAdapter;

    // 기본 성공 응답: 콜백(server) 스타일 사용
    dioAdapter.onGet(
      '/api/test',
      (server) => server.reply(200, {'message': 'success'}),
    );
  }

  /// 공통 GET 목킹 헬퍼
  static void mockGet(String path, int statusCode, dynamic data) {
    dioAdapter.onGet(path, (server) => server.reply(statusCode, data));
  }

  /// 공통 POST 목킹 헬퍼 (필요하면 계속 추가)
  static void mockPost(String path, int statusCode, dynamic data) {
    dioAdapter.onPost(
      path,
      (server) => server.reply(statusCode, data),
      // body/headers/queries 매칭이 필요하면 여기 인자 추가
    );
  }

  /// 에러 시뮬레이션 (네트워크/서버)
  static void simulateNetworkError() {
    dioAdapter.onGet(
      '/api/test',
      (server) => server.throws(
        404,
        DioException.connectionError(
          requestOptions: RequestOptions(path: '/api/test'),
          reason: 'Network error',
        ),
      ),
    );
  }

  /// 테스트용 위젯 래퍼
  static Widget wrapWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  /// 가짜 데이터 생성
  static Map<String, dynamic> generateFakeUser() {
    return {
      'id': faker.randomGenerator.integer(9999),
      'name': faker.person.name(),
      'email': faker.internet.email(),
      'phone': faker.phoneNumber.us(), // 패키지 버전에 따라 다르면 phoneNumber.random() 사용
    };
  }

  static Map<String, dynamic> generateFakeJob() {
    return {
      'id': faker.randomGenerator.integer(9999),
      'title': faker.job.title(),
      'company': faker.company.name(),
      'location': faker.address.city(),
      'salary': faker.randomGenerator.integer(100000, min: 30000),
    };
  }

  /// 비동기 안정화 헬퍼
  static Future<void> pumpAndSettle(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }
}
