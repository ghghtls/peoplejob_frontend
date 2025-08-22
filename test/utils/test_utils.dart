import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:faker/faker.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:dio/dio.dart';

class TestUtils {
  static final Faker faker = Faker();
  static late DioAdapter dioAdapter;
  static late Dio dio;

  static void setupHttpMocks() {
    dio = Dio();
    dioAdapter = DioAdapter(dio: dio);

    // 기본 성공 응답 설정
    dioAdapter.onGet('/api/test').reply(200, {'message': 'success'});
  }

  // 테스트용 위젯 래퍼
  static Widget wrapWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  // 가짜 데이터 생성
  static Map<String, dynamic> generateFakeUser() {
    return {
      'id': faker.randomGenerator.integer(9999),
      'name': faker.person.name(),
      'email': faker.internet.email(),
      'phone': faker.phoneNumber.us(),
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

  // 테스트 헬퍼 메서드
  static Future<void> pumpAndSettle(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  // 에러 시뮬레이션
  static void simulateNetworkError() {
    dioAdapter
        .onGet('/api/test')
        .throws(
          404,
          DioException.connectionError(
            requestOptions: RequestOptions(path: '/api/test'),
            reason: 'Network error',
          ),
        );
  }
}
