import 'package:flutter/material.dart';
import 'popup_list_item.dart';

class PopupListView extends StatelessWidget {
  const PopupListView({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 데이터
    final popupList = [
      {
        'id': 1,
        'title': '5월 근로장려금 신청 안내',
        'startDate': '2025-05-01',
        'endDate': '2025-05-31',
        'isActive': true,
      },
      {
        'id': 2,
        'title': '서비스 점검 공지',
        'startDate': '2025-04-15',
        'endDate': '2025-04-16',
        'isActive': false,
      },
    ];

    return ListView.separated(
      itemCount: popupList.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final popup = popupList[index];
        return PopupListItem(
          id: popup['id'] as int,
          title: popup['title'] as String,
          startDate: popup['startDate'] as String,
          endDate: popup['endDate'] as String,
          isActive: popup['isActive'] as bool,
        );
      },
    );
  }
}
