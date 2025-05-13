import 'package:flutter/material.dart';
import 'package:peoplejob_frontend/ui/pages/board/board_detail_page.dart';

class BoardListPage extends StatelessWidget {
  const BoardListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyPosts = [
      {
        'title': '첫 번째 게시글',
        'content': '이것은 첫 번째 게시글 내용입니다.',
        'date': '2025-05-13',
      },
      {
        'title': '두 번째 게시글',
        'content': '두 번째 게시글 내용도 있어요.',
        'date': '2025-05-12',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('게시판')),
      body: ListView.builder(
        itemCount: dummyPosts.length,
        itemBuilder: (context, index) {
          final post = dummyPosts[index];
          return Card(
            child: ListTile(
              title: Text(post['title']!),
              subtitle: Text('작성일: ${post['date']}'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/board/detail',
                  arguments: {
                    'title': post['title'],
                    'content': post['content'],
                    'date': post['date'],
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/board/write');
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
