import 'package:flutter/material.dart';

class ResumeListView extends StatelessWidget {
  const ResumeListView({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyResumes = List.generate(
      3,
      (i) => {'title': '이력서 ${i + 1}', 'date': '2025-05-0${i + 1}'},
    );

    return ListView.separated(
      itemCount: dummyResumes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final resume = dummyResumes[index];
        return Card(
          child: ListTile(
            title: Text(resume['title']!),
            subtitle: Text('작성일: ${resume['date']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // TODO: 수정 페이지 이동
                    print("수정 ${resume['title']}");
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // TODO: 삭제 로직
                    print("삭제 ${resume['title']}");
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
