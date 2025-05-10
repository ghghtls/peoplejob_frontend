import 'package:flutter/material.dart';

class AdminPopupManagePage extends StatefulWidget {
  const AdminPopupManagePage({super.key});

  @override
  State<AdminPopupManagePage> createState() => _AdminPopupManagePageState();
}

class _AdminPopupManagePageState extends State<AdminPopupManagePage> {
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

  void _addPopup() {
    // TODO: 팝업 추가 폼 또는 다이얼로그로 이동
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('팝업 관리')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(onPressed: _addPopup, child: const Text('팝업 추가')),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: popups.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final popup = popups[index];
                  return ListTile(
                    title: Text(popup.title),
                    subtitle: Text(popup.enabled ? '사용 중' : '미사용'),
                    trailing: Switch(
                      value: popup.enabled,
                      onChanged: (_) => _togglePopupStatus(popup.id),
                    ),
                    onTap: () {
                      // TODO: 상세 설정 이동 처리
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
