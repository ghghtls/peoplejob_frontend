import 'package:flutter/material.dart';

class JobDetailHeader extends StatelessWidget {
  const JobDetailHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          '백엔드 개발자 모집',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text('피플잡 주식회사 • 서울 강남구'),
        SizedBox(height: 4),
        Text('마감일: 2025-06-01', style: TextStyle(color: Colors.redAccent)),
      ],
    );
  }
}
