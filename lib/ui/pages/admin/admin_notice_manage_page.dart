import 'package:flutter/material.dart';
import '../../widgets/app_bar.dart';

class AdminNoticeManagePage extends StatefulWidget {
  const AdminNoticeManagePage({super.key});

  @override
  State<AdminNoticeManagePage> createState() => _AdminNoticeManagePageState();
}

class _AdminNoticeManagePageState extends State<AdminNoticeManagePage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);

  final List<Notice> notices = [
    Notice(id: 1, title: '서비스 점검 안내', date: '2025-05-01'),
    Notice(id: 2, title: '5월 업데이트 공지', date: '2025-05-05'),
  ];

  void _deleteNotice(int id) {
    setState(() => notices.removeWhere((n) => n.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '공지사항 관리',
        showHomeButton: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded, size: 22, color: _blue),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
            const SizedBox(height: 8),

            Expanded(
              child: notices.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 72, height: 72,
                          decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
                          child: const Icon(Icons.campaign_outlined, size: 36, color: _secondary)),
                      const SizedBox(height: 16),
                      const Text('등록된 공지사항이 없습니다', style: TextStyle(fontSize: 15, color: _secondary)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: notices.length,
                      itemBuilder: (context, index) {
                        final notice = notices[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                          ),
                          child: Material(
                            color: Colors.transparent, borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38, height: 38,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF9500).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.campaign_rounded, size: 20, color: Color(0xFFFF9500)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(notice.title,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _label)),
                                        const SizedBox(height: 3),
                                        Text(notice.date, style: const TextStyle(fontSize: 12, color: _secondary)),
                                      ]),
                                    ),
                                    IconButton(
                                      onPressed: () => _deleteNotice(notice.id),
                                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: _red),
                                      style: IconButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.all(6)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
      ),
    );
  }
}

class Notice {
  final int id;
  final String title;
  final String date;
  Notice({required this.id, required this.title, required this.date});
}
