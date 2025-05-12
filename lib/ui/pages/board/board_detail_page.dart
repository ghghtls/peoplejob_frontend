import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class BoardDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final String date;

  const BoardDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시글 상세')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('작성일: $date', style: const TextStyle(color: Colors.grey)),
            const Divider(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(content, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/board/edit',
                  arguments: {
                    'title': title,
                    'content': content,

                    'onSave': (String newTitle, quill.Document newContent) {
                      debugPrint('수정된 제목: $newTitle');
                      debugPrint('수정된 내용: ${newContent.toPlainText()}');
                    },
                  },
                );
              },
              child: const Text('수정하기'),
            ),
          ],
        ),
      ),
    );
  }
}
