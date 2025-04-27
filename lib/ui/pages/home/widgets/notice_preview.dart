import 'package:flutter/material.dart';

class NoticePreview extends StatelessWidget {
  const NoticePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: Colors.red[100],
      child: const Center(child: Text('공지사항 3개 요약')),
    );
  }
}
