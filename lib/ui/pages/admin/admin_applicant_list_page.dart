import 'package:flutter/material.dart';
import 'widgets/excel_download_button.dart';

class AdminApplicantListPage extends StatelessWidget {
  const AdminApplicantListPage({super.key});

  void _downloadExcel(BuildContext context) {
    // TODO: 실제 다운로드 로직 추가 (API 연동 등)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Excel 다운로드가 시작되었습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('지원자 목록')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ExcelDownloadButton(
              onPressed: () => _downloadExcel(context),
            ),
          ),
          const Divider(),
          const Expanded(child: Center(child: Text('지원자 리스트 예시'))),
        ],
      ),
    );
  }
}
