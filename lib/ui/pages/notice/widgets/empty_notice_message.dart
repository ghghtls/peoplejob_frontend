import 'package:flutter/material.dart';

class EmptyNoticeMessage extends StatelessWidget {
  const EmptyNoticeMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '등록된 공지사항이 없습니다.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
