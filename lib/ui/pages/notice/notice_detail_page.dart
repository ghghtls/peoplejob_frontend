import 'package:flutter/material.dart';

class NoticeDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final String date;

  const NoticeDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('공지사항 상세')),
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
          ],
        ),
      ),
    );
  }
}
