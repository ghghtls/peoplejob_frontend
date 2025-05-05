import 'package:flutter/material.dart';

class EmptyScrapMessage extends StatelessWidget {
  const EmptyScrapMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '스크랩한 공고가 없습니다.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
