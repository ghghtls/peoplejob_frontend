import 'package:flutter/material.dart';
import 'widgets/popup_register_form.dart';

class PopupRegisterPage extends StatelessWidget {
  const PopupRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('팝업 등록')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: PopupRegisterForm(),
      ),
    );
  }
}
