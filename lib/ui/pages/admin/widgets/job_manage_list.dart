import 'package:flutter/material.dart';

class JobManageList extends StatelessWidget {
  const JobManageList({super.key});

  @override
  Widget build(BuildContext context) {
    final jobs = [
      {'title': '백엔드 개발자', 'date': '2025-05-01'},
      {'title': '디자이너', 'date': '2025-04-28'},
    ];

    return Column(
      children:
          jobs.map((job) {
            return ListTile(
              title: Text(job['title']!),
              subtitle: Text('등록일: ${job['date']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // TODO: 삭제 API 호출
                  print('공고 삭제: ${job['title']}');
                },
              ),
            );
          }).toList(),
    );
  }
}
