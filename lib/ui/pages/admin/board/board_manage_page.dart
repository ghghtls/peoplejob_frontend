import 'package:flutter/material.dart';
import 'widgets/board_list_view.dart';

class BoardManagePage extends StatelessWidget {
  const BoardManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시판 관리')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: BoardListView(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/admin/board/register');
        },
        child: const Icon(Icons.add),
        tooltip: '게시판 등록',
      ),
    );
  }
}
