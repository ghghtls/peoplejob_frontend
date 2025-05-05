import 'package:flutter/material.dart';

class JobFilterBar extends StatelessWidget {
  const JobFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('총 24건', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: '최신순',
          items: [
            DropdownMenuItem(value: '최신순', child: Text('최신순')),
            DropdownMenuItem(value: '마감임박', child: Text('마감임박')),
          ],
          onChanged: null, // TODO: 정렬 로직 추가 예정
        ),
      ],
    );
  }
}
