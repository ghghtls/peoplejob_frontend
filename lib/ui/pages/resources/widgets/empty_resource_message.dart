import 'package:flutter/material.dart';

class EmptyResourceMessage extends StatelessWidget {
  const EmptyResourceMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '등록된 자료가 없습니다.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
