import 'package:flutter/material.dart';

class SearchJobResult extends StatelessWidget {
  const SearchJobResult({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyJobs = [
      {'title': '백엔드 개발자', 'company': '피플잡'},
      {'title': '앱 개발자', 'company': '잡앤조이'},
    ];

    if (dummyJobs.isEmpty) {
      return const Text('채용공고 검색 결과가 없습니다.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '채용공고 결과',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...dummyJobs.map(
          (job) => ListTile(
            title: Text(job['title']!),
            subtitle: Text(job['company']!),
            onTap: () {
              // TODO: 상세 이동
            },
          ),
        ),
      ],
    );
  }
}
