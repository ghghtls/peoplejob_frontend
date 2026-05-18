import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResumeSamplePage extends StatelessWidget {
  const ResumeSamplePage({super.key});

  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);
  static const Color _green = Color(0xFF0FA958);

  static const List<Map<String, String>> _resumeSamples = [
    {
      'title': '기본형 이력서 (한글)',
      'format': 'hwp',
      'desc': '공공기관·대기업 제출용 표준 양식',
      'url': 'https://example.com/resume_basic.hwp',
    },
    {
      'title': '간단형 이력서 (워드)',
      'format': 'docx',
      'desc': '중소기업·스타트업 제출에 적합',
      'url': 'https://example.com/resume_simple.docx',
    },
    {
      'title': '디자인 이력서 (PDF)',
      'format': 'pdf',
      'desc': '디자인·크리에이티브 직군 추천',
      'url': 'https://example.com/resume_design.pdf',
    },
  ];

  Color _formatColor(String format) {
    switch (format) {
      case 'pdf': return _red;
      case 'docx': return _blue;
      case 'hwp': return _green;
      default: return _secondary;
    }
  }

  IconData _formatIcon(String format) {
    switch (format) {
      case 'pdf': return Icons.picture_as_pdf_rounded;
      case 'docx': return Icons.description_rounded;
      case 'hwp': return Icons.text_snippet_rounded;
      default: return Icons.insert_drive_file_rounded;
    }
  }

  Future<void> _download(BuildContext context, Map<String, String> sample) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(sample['url']!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text('${sample['title']} 다운로드를 시작합니다'),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: _blue),
                    style: IconButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.all(8)),
                  ),
                  const Expanded(
                    child: Text('이력서 양식 다운로드',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _label, letterSpacing: -0.4)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  // 안내 배너
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_blue.withValues(alpha: 0.08), _blue.withValues(alpha: 0.04)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: _blue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.download_rounded, size: 22, color: _blue),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('무료 이력서 양식',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _label)),
                              SizedBox(height: 3),
                              Text('원하는 형식을 선택하여 다운로드하세요',
                                  style: TextStyle(fontSize: 13, color: _secondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 양식 목록
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      children: _resumeSamples.asMap().entries.map((entry) {
                        final i = entry.key;
                        final sample = entry.value;
                        final color = _formatColor(sample['format']!);
                        final isLast = i == _resumeSamples.length - 1;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(_formatIcon(sample['format']!), size: 22, color: color),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(sample['title']!,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _label)),
                                        const SizedBox(height: 3),
                                        Text(sample['desc']!,
                                            style: const TextStyle(fontSize: 12, color: _secondary)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _download(context, sample),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text('다운로드',
                                          style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast) const Divider(height: 1, indent: 16, color: Color(0xFFF2F2F7)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
