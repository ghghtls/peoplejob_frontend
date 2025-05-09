import 'package:flutter/material.dart';
import '../payment_target_selection_page.dart';

class JobPostCard extends StatelessWidget {
  final JobPost jobPost;

  const JobPostCard({super.key, required this.jobPost});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          jobPost.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(jobPost.company),
        trailing: ElevatedButton(
          onPressed: () {
            // TODO: 선택된 공고로 다음 단계로 이동
          },
          child: const Text('선택'),
        ),
      ),
    );
  }
}
