import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/app_bar.dart';

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

  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _red = Color(0xFFE5342F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: buildCommonAppBar(title: '자료 상세'),
      body: Column(
        children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더 카드
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                                  color: _label, letterSpacing: -0.5, height: 1.3)),
                          const SizedBox(height: 10),
                          Row(children: [
                            const Icon(Icons.calendar_today_rounded, size: 13, color: _secondary),
                            const SizedBox(width: 5),
                            Text('업로드일: $date',
                                style: const TextStyle(fontSize: 13, color: _secondary)),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 첨부파일
                    if (fileUrl.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _blue.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.attach_file_rounded, color: _blue, size: 18),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text('첨부파일',
                                  style: TextStyle(fontSize: 14, color: _blue, fontWeight: FontWeight.w500)),
                            ),
                            TextButton(
                              onPressed: () async {
                                final uri = Uri.parse(fileUrl);
                                final messenger = ScaffoldMessenger.of(context);
                                if (await canLaunchUrl(uri)) {
                                  launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else {
                                  messenger.showSnackBar(SnackBar(
                                    content: const Text('파일 열기에 실패했습니다'),
                                    backgroundColor: _red, behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ));
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: _blue, minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                              child: const Text('다운로드', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    if (fileUrl.isNotEmpty) const SizedBox(height: 12),

                    // 내용
                    const Text('내용',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: -0.2)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Text(content,
                          style: const TextStyle(fontSize: 15, height: 1.7, color: _label, letterSpacing: -0.2)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}
