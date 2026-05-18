import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AddressSearchPage extends StatelessWidget {
  const AddressSearchPage({super.key});

  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {},
      ))
      ..loadRequest(Uri.parse('https://postcode.map.daum.net/search'));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: _blue),
                    style: IconButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.all(8)),
                  ),
                  const Expanded(
                    child: Text('주소 검색',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _label, letterSpacing: -0.4)),
                  ),
                ],
              ),
            ),
            Expanded(child: WebViewWidget(controller: controller)),
          ],
        ),
      ),
    );
  }
}
