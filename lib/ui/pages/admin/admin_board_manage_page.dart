import 'package:flutter/material.dart';
import '../../widgets/app_bar.dart';

class AdminBoardManagePage extends StatefulWidget {
  const AdminBoardManagePage({super.key});

  @override
  State<AdminBoardManagePage> createState() => _AdminBoardManagePageState();
}

class _AdminBoardManagePageState extends State<AdminBoardManagePage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _green = Color(0xFF0FA958);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '게시판 관리',
        showHomeButton: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded, size: 22, color: _blue),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: boards.length,
                itemBuilder: (context, index) {
                  final board = boards[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: (board.enabled ? _blue : _secondary).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.forum_rounded, size: 20,
                                color: board.enabled ? _blue : _secondary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(board.title,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _label)),
                              const SizedBox(height: 2),
                              Text(board.enabled ? '사용 중' : '미사용',
                                  style: TextStyle(fontSize: 12, color: board.enabled ? _green : _secondary)),
                            ]),
                          ),
                          Switch(
                            value: board.enabled,
                            onChanged: (_) => _toggleBoardStatus(board.id),
                            activeThumbColor: _blue,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
