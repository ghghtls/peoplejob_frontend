import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class JobNewsPage extends StatelessWidget {
  const JobNewsPage({super.key});

  final List<Map<String, String>> _newsList = const [
    {
      'title': '2024 상반기 취업 트렌드 총정리',
      'summary': 'MZ세대 중심 채용 증가, AI 면접 확산 등 올해 채용 경향 분석.',
      'date': '2024-03-01',
      'url': 'https://example.com/news1',
    },
    {
      'title': '중소기업 취업 장려금 확대 안내',
      'summary': '고용노동부, 청년 채용 기업에 최대 900만원 지원.',
      'date': '2024-02-20',
      'url': 'https://example.com/news2',
    },
    {
      'title': '면접 합격률 높이는 자소서 작성법',
      'summary': '전문가가 알려주는 자소서 항목별 꿀팁과 사례.',
      'date': '2024-01-15',
      'url': 'https://example.com/news3',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '📰 취업 뉴스',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._newsList.map((news) {
          return Card(
            child: ListTile(
              title: Text(news['title']!),
              subtitle: Text(news['summary']!),
              trailing: Text(
                news['date']!,
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () async {
                final Uri url = Uri.parse(news['url']!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('URL을 열 수 없습니다.')),
                  );
                }
              },
            ),
          );
        }).toList(),
      ],
    );
  }
}
