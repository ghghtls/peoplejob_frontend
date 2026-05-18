import 'package:flutter/material.dart';
import 'widgets/popup_list_view.dart';
import '../../../widgets/app_bar.dart';

class PopupManagePage extends StatelessWidget {
  const PopupManagePage({super.key});

  static const Color _blue = Color(0xFF0B5FFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: buildCommonAppBar(title: '팝업 관리', showHomeButton: false),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: PopupListView(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/admin/popup/register'),
        backgroundColor: _blue,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
