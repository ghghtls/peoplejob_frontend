import 'package:flutter/material.dart';
import 'widgets/popup_register_form.dart';
import '../../../widgets/app_bar.dart';

class PopupRegisterPage extends StatelessWidget {
  const PopupRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: buildCommonAppBar(title: '팝업 등록', showHomeButton: false),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: PopupRegisterForm(),
      ),
    );
  }
}
