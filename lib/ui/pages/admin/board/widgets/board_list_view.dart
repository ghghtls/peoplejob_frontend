import 'package:flutter/material.dart';
import 'board_list_item.dart';

class BoardListView extends StatelessWidget {
  const BoardListView({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 데이터
    final boards = [
      {
        'id': 1,
        'title': '자유게시판',
        'isActive': true,
        'allowUpload': true,
        'allowComment': true,
      },
      {
        'id': 2,
        'title': 'FAQ',
        'isActive': false,
        'allowUpload': false,
        'allowComment': false,
      },
    ];

    return ListView.separated(
      itemCount: boards.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final board = boards[index];
        return BoardListItem(
          id: board['id'] as int,
          title: board['title'] as String,
          isActive: board['isActive'] as bool,
          allowUpload: board['allowUpload'] as bool,
          allowComment: board['allowComment'] as bool,
        );
      },
    );
  }
}
