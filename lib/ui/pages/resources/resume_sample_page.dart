import 'package:flutter/material.dart';

class ResumeSamplePage extends StatelessWidget {
  const ResumeSamplePage({super.key});

  // 임시 mock 데이터
  final List<Map<String, String>> _resumeSamples = const [
    {
      'title': '기본형 이력서 (한글)',
      'format': 'hwp',
      'url': 'https://example.com/resume_basic.hwp',
    },
    {
      'title': '간단형 이력서 (워드)',
      'format': 'docx',
      'url': 'https://example.com/resume_simple.docx',
    },
    {
      'title': '디자인 이력서 (PDF)',
      'format': 'pdf',
      'url': 'https://example.com/resume_design.pdf',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이력서 양식 다운로드')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _resumeSamples.length,
        itemBuilder: (context, index) {
          final sample = _resumeSamples[index];
          return Card(
            child: ListTile(
              leading: _buildIcon(sample['format']!),
              title: Text(sample['title']!),
              trailing: TextButton(
                onPressed: () {
                  // TODO: 실제 다운로드 기능 연결 (url_launcher 사용 예정)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${sample['title']} 다운로드 시작')),
                  );
                },
                child: const Text('다운로드'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIcon(String format) {
    switch (format) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'docx':
        return const Icon(Icons.description, color: Colors.blue);
      case 'hwp':
        return const Icon(Icons.text_snippet, color: Colors.green);
      default:
        return const Icon(Icons.insert_drive_file);
    }
  }
}
