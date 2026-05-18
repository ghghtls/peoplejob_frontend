import 'package:flutter/material.dart';
import 'widgets/board_register_form.dart';
import '../../../widgets/app_bar.dart';

class BoardRegisterPage extends StatelessWidget {
  const BoardRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: buildCommonAppBar(title: '게시판 등록', showHomeButton: false),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: BoardRegisterForm(),
      ),
    );
  }
}
