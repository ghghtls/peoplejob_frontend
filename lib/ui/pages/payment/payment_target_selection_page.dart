import 'package:flutter/material.dart';

class PaymentTargetSelectionPage extends StatelessWidget {
  const PaymentTargetSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 예시 채용공고 리스트
    final jobPosts = [
      JobPost(id: 1, title: 'Flutter 개발자 모집', company: '피플잡'),
      JobPost(id: 2, title: '백엔드 개발자(Spring)', company: '피플잡'),
      JobPost(id: 3, title: 'UI/UX 디자이너', company: '피플잡'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('광고할 채용공고 선택')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: jobPosts.length,
        itemBuilder: (context, index) {
          final job = jobPosts[index];
          return JobPostCard(jobPost: job);
        },
      ),
    );
  }
}

class JobPost {
  final int id;
  final String title;
  final String company;

  JobPost({required this.id, required this.title, required this.company});
}

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
            // TODO: 선택된 채용공고와 함께 다음 단계로 이동
          },
          child: const Text('선택'),
        ),
      ),
    );
  }
}
