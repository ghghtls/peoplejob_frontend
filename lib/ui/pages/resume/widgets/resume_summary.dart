import 'package:flutter/material.dart';

class ResumeSummary extends StatelessWidget {
  const ResumeSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        '등록된 이력서: 3개',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
