import 'package:flutter/material.dart';
import 'widgets/popup_register_form.dart';
import '../../../widgets/app_bar.dart';

class PopupEditPage extends StatelessWidget {
  final int popupId;

  const PopupEditPage({super.key, required this.popupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: buildCommonAppBar(title: '팝업 수정 (#$popupId)', showHomeButton: false),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: PopupRegisterForm(
          isEdit: true,
          initialValues: {
            'title': '5월 근로장려금 안내',
            'isActive': true,
            'startDate': DateTime(2025, 5, 1),
            'endDate': DateTime(2025, 5, 31),
            'imagePath': 'assets/sample.png',
          },
        ),
      ),
    );
  }
}
