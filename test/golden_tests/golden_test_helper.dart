import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

class GoldenTestHelper {
  static Future<void> setupGoldenTests() async {
    await loadAppFonts();
  }

  static Future<void> testGoldenWidget(
    String description,
    Widget widget, {
    Device? device,
  }) async {
    testGoldens(description, (tester) async {
      await tester.pumpWidgetBuilder(
        widget,
        wrapper: materialAppWrapper(),
        surfaceSize: device?.size ?? const Size(400, 600),
      );

      await screenMatchesGolden(tester, description);
    });
  }

  static Future<void> testMultiScreenGolden(
    String description,
    Widget widget,
  ) async {
    testGoldens(description, (tester) async {
      final builder =
          DeviceBuilder()
            ..overrideDevicesForAllScenarios(
              devices: [Device.phone, Device.iphone11, Device.tabletPortrait],
            )
            ..addScenario(widget: widget, name: 'default');

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, description);
    });
  }
}
