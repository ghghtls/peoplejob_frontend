import 'package:flutter/material.dart';
import 'widgets/popup_register_form.dart';

class PopupEditPage extends StatelessWidget {
  final int popupId;

  const PopupEditPage({super.key, required this.popupId});

  @override
  Widget build(BuildContext context) {
    // TODO: popupId를 기반으로 팝업 상세 정보 불러오기 (API 연동 예정)

    return Scaffold(
      appBar: AppBar(title: Text('팝업 수정 (#$popupId)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PopupRegisterForm(
          isEdit: true,
          initialValues: {
            'title': '5월 근로장려금 안내',
            'isActive': true,
            'startDate': DateTime(2025, 5, 1),
            'endDate': DateTime(2025, 5, 31),
            'imagePath': 'assets/sample.png',
          },
        ), // TODO: 수정용으로 변형 필요
      ),
    );
  }
}
