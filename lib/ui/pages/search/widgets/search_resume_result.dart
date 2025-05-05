import 'package:flutter/material.dart';

class SearchResumeResult extends StatelessWidget {
  const SearchResumeResult({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyResumes = [
      {'name': '홍길동', 'title': '신입 백엔드 개발자 이력서'},
      {'name': '이순신', 'title': '경력 앱 개발자 포트폴리오'},
    ];

    if (dummyResumes.isEmpty) {
      return const Text('이력서 검색 결과가 없습니다.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이력서 결과',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...dummyResumes.map(
          (resume) => ListTile(
            title: Text(resume['title']!),
            subtitle: Text(resume['name']!),
            onTap: () {
              // TODO: 이력서 상세 보기
            },
          ),
        ),
      ],
    );
  }
}
