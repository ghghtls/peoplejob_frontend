import 'package:flutter/material.dart';
import 'widgets/board_register_form.dart';
import '../../../widgets/app_bar.dart';

class BoardEditPage extends StatelessWidget {
  final int boardId;

  const BoardEditPage({super.key, required this.boardId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: buildCommonAppBar(
        title: '게시판 수정 (#$boardId)',
        showHomeButton: false,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: BoardRegisterForm(),
      ),
    );
  }
}
