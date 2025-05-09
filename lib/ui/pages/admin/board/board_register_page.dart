import 'package:flutter/material.dart';
import 'widgets/board_register_form.dart';

class BoardRegisterPage extends StatelessWidget {
  const BoardRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시판 등록')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: BoardRegisterForm(),
      ),
    );
  }
}
