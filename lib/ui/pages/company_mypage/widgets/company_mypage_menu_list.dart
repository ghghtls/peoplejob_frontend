// lib/ui/pages/company_mypage/widgets/company_mypage_menu_list.dart
import 'package:flutter/material.dart';

class CompanyMyPageMenuList extends StatelessWidget {
  const CompanyMyPageMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'title': '채용공고 등록', 'icon': Icons.add_box},
      {'title': '채용공고 관리', 'icon': Icons.work_outline},
      {'title': '광고 결제 내역', 'icon': Icons.payment},
      {'title': '문의사항 관리', 'icon': Icons.question_answer},
    ];

    return Column(
      children:
          menuItems.map((item) {
            return Card(
              child: ListTile(
                leading: Icon(item['icon']),
                title: Text(item['title']),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: 각 메뉴별 페이지 이동 구현 필요
                },
              ),
            );
          }).toList(),
    );
  }
}
