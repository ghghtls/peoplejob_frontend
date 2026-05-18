import 'package:flutter/material.dart';
import 'widgets/board_list_view.dart';
import '../../../widgets/app_bar.dart';

class BoardManagePage extends StatelessWidget {
  const BoardManagePage({super.key});

  static const Color _blue = Color(0xFF0B5FFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: buildCommonAppBar(title: '게시판 관리', showHomeButton: false),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: BoardListView(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/admin/board/register'),
        backgroundColor: _blue,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
