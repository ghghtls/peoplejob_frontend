import 'package:flutter/material.dart';
import '../../widgets/app_bar.dart';

class AdminPopupManagePage extends StatefulWidget {
  const AdminPopupManagePage({super.key});

  @override
  State<AdminPopupManagePage> createState() => _AdminPopupManagePageState();
}

class _AdminPopupManagePageState extends State<AdminPopupManagePage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _green = Color(0xFF0FA958);

  final List<PopupItem> popups = [
    PopupItem(id: 1, title: '긴급 공지', enabled: true),
    PopupItem(id: 2, title: '서비스 업데이트 안내', enabled: false),
  ];

  void _togglePopupStatus(int id) {
    setState(() {
      final popup = popups.firstWhere((p) => p.id == id);
      popup.enabled = !popup.enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '팝업 관리',
        showHomeButton: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/admin/popup/register'),
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
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: popups.length,
                itemBuilder: (context, index) {
                  final popup = popups[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: (popup.enabled ? _blue : _secondary).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.web_asset_rounded, size: 20,
                                color: popup.enabled ? _blue : _secondary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(popup.title,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _label)),
                              const SizedBox(height: 2),
                              Text(popup.enabled ? '노출 중' : '미노출',
                                  style: TextStyle(fontSize: 12, color: popup.enabled ? _green : _secondary)),
                            ]),
                          ),
                          Switch(
                            value: popup.enabled,
                            onChanged: (_) => _togglePopupStatus(popup.id),
                            activeThumbColor: _blue,
                          ),
                        ],
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

class PopupItem {
  final int id;
  final String title;
  bool enabled;
  PopupItem({required this.id, required this.title, required this.enabled});
}
