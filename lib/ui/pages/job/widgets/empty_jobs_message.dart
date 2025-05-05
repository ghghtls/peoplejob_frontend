import 'package:flutter/material.dart';

class EmptyJobsMessage extends StatelessWidget {
  const EmptyJobsMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('등록된 채용공고가 없습니다.'));
  }
}
