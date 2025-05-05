import 'package:flutter/material.dart';

class JobListView extends StatelessWidget {
  const JobListView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 실제 데이터 연동 예정
    final dummyJobs = List.generate(
      10,
      (index) => {
        'title': '백엔드 개발자 ${index + 1}',
        'company': '피플잡 주식회사',
        'location': '서울 강남구',
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
              // TODO: 채용공고 상세 페이지 이동
              print('공고 ${job['title']} 클릭');
            },
          ),
        );
      },
    );
  }
}
