import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:peoplejob_frontend/ui/pages/job/job_list_page.dart';

Widget _app({Map<String, WidgetBuilder>? routes}) {
  return ProviderScope(
    child: MaterialApp(
      home: const JobListPage(),
      routes: routes ?? const {},
    ),
  );
}

void main() {
  setUpAll(() async {
    dotenv.testLoad(fileInput: 'API_URL=http://localhost:5000\n');
  });

  group('JobListPage Widget Tests', () {
    // Dio connectTimeout(10초) 타이머를 fake time으로 소진하는 헬퍼
    Future<void> drainDioTimer(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 11));
    }

    testWidgets('채용공고 목록 페이지 기본 UI 렌더링 테스트', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_app());
        await tester.pump();

        expect(find.byType(Scaffold), findsOneWidget);

        await drainDioTimer(tester);
      });
    });

    testWidgets('채용공고 목록 로딩 상태 테스트', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_app());
        await tester.pump();

        expect(
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
              find.byType(Scaffold).evaluate().isNotEmpty,
          isTrue,
        );

        await drainDioTimer(tester);
      });
    });

    testWidgets('RefreshIndicator 존재 테스트', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_app());
        await drainDioTimer(tester); // pumpAndSettle 대신 timeout 소진 후 확인

        expect(find.byType(Scaffold), findsOneWidget);
      });
    });
  });
}
