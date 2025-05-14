// lib/ui/pages/company_mypage/widgets/company_mypage_menu_list.dart
import 'package:flutter/material.dart';

class CompanyMyPageMenuList extends StatelessWidget {
  const CompanyMyPageMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'title': '광고 신청하기', 'icon': Icons.campaign, 'route': '/payment'},
      {'title': '채용공고 등록', 'icon': Icons.add_box, 'route': '/job/register'},
      {'title': '채용공고 관리', 'icon': Icons.work_outline, 'route': '/job/manage'},
      {'title': '광고 결제 내역', 'icon': Icons.payment, 'route': '/payment'},
      {
        'title': '문의사항 관리',
        'icon': Icons.question_answer,
        'route': '/inquiry/list',
      },
      {
        'title': '인재정보 검색',
        'icon': Icons.search,
        'route': '/search/talentSearchPage',
      },
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
                  if (item['route'] != null) {
                    Navigator.pushNamed(context, item['route']);
                  }
                },
              ),
            );
          }).toList(),
    );
  }
}
