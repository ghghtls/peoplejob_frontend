import 'package:flutter/material.dart';

class ApplyListView extends StatelessWidget {
  const ApplyListView({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyApplies = [
      {
        'title': '백엔드 개발자',
        'company': '피플잡',
        'date': '2025-05-01',
        'status': '서류 심사중',
      },
      {
        'title': '앱 개발자',
        'company': '잡앤조이',
        'date': '2025-04-28',
        'status': '불합격',
      },
    ];

    return ListView.separated(
      itemCount: dummyApplies.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = dummyApplies[index];
        return Card(
          child: ListTile(
            title: Text(item['title']!),
            subtitle: Text('${item['company']} • 지원일: ${item['date']}'),
            trailing: Text(
              item['status']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // TODO: 상세 이동
              print('지원공고 클릭: ${item['title']}');
            },
          ),
        );
      },
    );
  }
}
