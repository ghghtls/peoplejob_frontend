import 'package:flutter/material.dart';
import 'widgets/popup_list_view.dart';

class PopupManagePage extends StatelessWidget {
  const PopupManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('팝업 관리')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: PopupListView(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/admin/popup/register');
        },
        child: const Icon(Icons.add),
        tooltip: '팝업 등록',
      ),
    );
  }
}
