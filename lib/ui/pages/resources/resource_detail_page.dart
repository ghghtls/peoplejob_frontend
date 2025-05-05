import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final String fileUrl;

  const ResourceDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.date,
    required this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('자료 상세')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('업로드일: $date', style: const TextStyle(color: Colors.grey)),
            const Divider(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(content, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('파일 다운로드'),
              onPressed: () async {
                final uri = Uri.parse(fileUrl);
                if (await canLaunchUrl(uri)) {
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("파일 열기 실패")));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
