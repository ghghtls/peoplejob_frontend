import 'package:flutter/material.dart';
import 'package:peoplejob_frontend/ui/pages/board/widgets/board_write_form.dart';

class BoardWritePage extends StatelessWidget {
  const BoardWritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시글 작성')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: BoardWriteForm(),
      ),
    );
  }
}
