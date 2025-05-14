import 'package:flutter/material.dart';

class PaymentTargetSelectionPage extends StatelessWidget {
  const PaymentTargetSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                job.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(job.company),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/payment/product');
                },
                child: const Text('선택'),
              ),
            ),
          );
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
