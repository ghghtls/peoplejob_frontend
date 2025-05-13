import 'package:flutter/material.dart';

class JobListView extends StatelessWidget {
  const JobListView({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyJobs = List.generate(
      10,
      (index) => {
        'title': '백엔드 개발자 ${index + 1}',
        'company': '피플잡 주식회사',
        'location': '서울 강남구',
        'description': 'Java/Spring 기반 백엔드 개발자 모집합니다.',
      },
    );

    return ListView.builder(
      itemCount: dummyJobs.length,
      itemBuilder: (context, index) {
        final job = dummyJobs[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(job['title']!),
            subtitle: Text('${job['company']} • ${job['location']}'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/job/detail',
                arguments: {
                  'title': job['title'],
                  'company': job['company'],
                  'location': job['location'],
                  'description': job['description'],
                },
              );
            },
          ),
        );
      },
    );
  }
}
