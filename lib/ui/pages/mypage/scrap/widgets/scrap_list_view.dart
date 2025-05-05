import 'package:flutter/material.dart';

class ScrapListView extends StatelessWidget {
  const ScrapListView({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyScraps = List.generate(
      5,
      (i) => {
        'title': '스크랩 공고 ${i + 1}',
        'company': '피플잡',
        'location': '서울 강남구',
      },
    );

    return ListView.separated(
      itemCount: dummyScraps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = dummyScraps[index];
        return Card(
          child: ListTile(
            title: Text(item['title']!),
            subtitle: Text('${item['company']} • ${item['location']}'),
            trailing: IconButton(
              icon: const Icon(Icons.bookmark_remove_outlined),
              onPressed: () {
                // TODO: 스크랩 해제 API 호출
                print('스크랩 해제: ${item['title']}');
              },
            ),
            onTap: () {
              // TODO: 상세 페이지 이동
              print('공고 클릭: ${item['title']}');
            },
          ),
        );
      },
    );
  }
}
