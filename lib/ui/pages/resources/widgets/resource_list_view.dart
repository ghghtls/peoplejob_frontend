import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../resource_detail_page.dart';

class ResourceListView extends StatelessWidget {
  const ResourceListView({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyResources = [
      {
        'title': '2025 채용 설명회 자료집',
        'date': '2025-04-29',
        'fileUrl': 'https://example.com/files/resource1.pdf',
        'content': '채용 설명회 발표자료 및 기업 정보가 포함되어 있습니다.',
      },
      {
        'title': '자소서 작성 가이드',
        'date': '2025-04-22',
        'fileUrl': 'https://example.com/files/resource2.pdf',
        'content': '자기소개서 작성 꿀팁과 샘플 양식을 제공합니다.',
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
              onPressed: () async {
                final uri = Uri.parse(item['fileUrl']!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('파일 열기 실패')));
                }
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ResourceDetailPage(
                        title: item['title']!,
                        content: item['content']!,
                        date: item['date']!,
                        fileUrl: item['fileUrl']!,
                      ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
