import 'package:flutter/material.dart';

class ResumeListView extends StatelessWidget {
  const ResumeListView({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyResumes = [
      {
        'title': '백엔드 개발자 이력서',
        'description': 'Java, Spring Boot 프로젝트 경험 있음',
        'date': '2025-05-10',
      },
      {
        'title': '플러터 앱 개발자',
        'description': 'Flutter로 앱 3개 출시 경험',
        'date': '2025-04-28',
      },
    ];

    return ListView.builder(
      itemCount: dummyResumes.length,
      itemBuilder: (context, index) {
        final resume = dummyResumes[index];
        return Card(
          child: ListTile(
            title: Text(resume['title']!),
            subtitle: Text('작성일: ${resume['date']}'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/resume/detail',
                arguments: {
                  'title': resume['title'],
                  'description': resume['description'],
                  'date': resume['date'],
                },
              );
            },
          ),
        );
      },
    );
  }
}
