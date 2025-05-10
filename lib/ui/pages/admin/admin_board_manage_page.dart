import 'package:flutter/material.dart';

class AdminBoardManagePage extends StatefulWidget {
  const AdminBoardManagePage({super.key});

  @override
  State<AdminBoardManagePage> createState() => _AdminBoardManagePageState();
}

class _AdminBoardManagePageState extends State<AdminBoardManagePage> {
  final List<BoardItem> boards = [
    BoardItem(id: 1, title: '자유게시판', enabled: true),
    BoardItem(id: 2, title: 'Q&A', enabled: false),
  ];

  void _toggleBoardStatus(int id) {
    setState(() {
      final board = boards.firstWhere((b) => b.id == id);
      board.enabled = !board.enabled;
    });
  }

  void _addBoard() {
    // TODO: 게시판 추가 폼 또는 다이얼로그로 이동
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시판 관리')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(onPressed: _addBoard, child: const Text('게시판 추가')),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: boards.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final board = boards[index];
                  return ListTile(
                    title: Text(board.title),
                    subtitle: Text(board.enabled ? '사용 중' : '미사용'),
                    trailing: Switch(
                      value: board.enabled,
                      onChanged: (_) => _toggleBoardStatus(board.id),
                    ),
                    onTap: () {
                      // TODO: 상세 설정 이동 처리
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BoardItem {
  final int id;
  final String title;
  bool enabled;

  BoardItem({required this.id, required this.title, required this.enabled});
}
