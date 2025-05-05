import 'package:flutter/material.dart';

class ResourceListView extends StatelessWidget {
  const ResourceListView({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyResources = [
      {
        'title': '2025 채용 설명회 자료집',
        'date': '2025-04-29',
        'fileUrl': 'https://example.com/files/resource1.pdf',
      },
      {
        'title': '자소서 작성 가이드',
        'date': '2025-04-22',
        'fileUrl': 'https://example.com/files/resource2.pdf',
      },
    ];

    return ListView.separated(
      itemCount: dummyResources.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = dummyResources[index];
        return Card(
          child: ListTile(
            title: Text(item['title']!),
            subtitle: Text('업로드일: ${item['date']}'),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                // TODO: 실제 파일 다운로드 로직 필요
                print('다운로드: ${item['fileUrl']}');
              },
            ),
          ),
        );
      },
    );
  }
}
