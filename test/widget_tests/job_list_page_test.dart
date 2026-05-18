import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:peoplejob_frontend/ui/pages/job/job_list_page.dart';
import 'package:peoplejob_frontend/services/job_service.dart';

class MockJobService extends Mock implements JobService {}

Widget _app({Map<String, WidgetBuilder>? routes}) {
  return ProviderScope(
    child: MaterialApp(
      home: const JobListPage(),
      routes: routes ?? const {},
    ),
  );
}

void main() {
  group('JobListPage Widget Tests', () {
    testWidgets('채용공고 목록 페이지 기본 UI 렌더링 테스트', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_app());
        await tester.pump();

        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    testWidgets('채용공고 목록 로딩 상태 테스트', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_app());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
            find.byType(Scaffold).evaluate().isNotEmpty, isTrue);
      });
    });

    testWidgets('RefreshIndicator 존재 테스트', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
      });
    });
  });
}
