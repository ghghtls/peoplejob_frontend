import 'package:flutter/material.dart';

class EmptyApplyMessage extends StatelessWidget {
  const EmptyApplyMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '지원한 공고가 없습니다.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
