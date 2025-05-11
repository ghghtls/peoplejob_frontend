import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AddressSearchPage extends StatelessWidget {
  const AddressSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (url) {
                // 주소 선택 시, JS에서 주소를 Navigator.pop으로 보내도록 구성 필요
              },
            ),
          )
          ..loadRequest(Uri.parse('https://postcode.map.daum.net/search'));

    return Scaffold(
      appBar: AppBar(title: const Text('주소 검색')),
      body: WebViewWidget(controller: controller),
    );
  }
}
