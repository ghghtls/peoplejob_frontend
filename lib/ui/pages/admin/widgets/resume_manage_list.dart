import 'package:flutter/material.dart';

class ResumeManageList extends StatelessWidget {
  const ResumeManageList({super.key});

  @override
  Widget build(BuildContext context) {
    final resumes = [
      {'title': '이력서 1', 'user': '홍길동'},
      {'title': '이력서 2', 'user': '이순신'},
    ];

    return Column(
      children:
          resumes.map((r) {
            return ListTile(
              title: Text(r['title']!),
              subtitle: Text('작성자: ${r['user']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  print('이력서 삭제: ${r['title']}');
                },
              ),
            );
          }).toList(),
    );
  }
}
