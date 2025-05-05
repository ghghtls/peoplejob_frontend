import 'package:flutter/material.dart';

class MyPageMenuList extends StatelessWidget {
  const MyPageMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    final menus = [
      {'icon': Icons.assignment, 'title': '이력서 관리'},
      {'icon': Icons.check_circle, 'title': '지원 내역'},
      {'icon': Icons.bookmark, 'title': '스크랩 공고'},
      {'icon': Icons.help_outline, 'title': '문의하기'},
    ];

    return Column(
      children:
          menus
              .map(
                (menu) => ListTile(
                  leading: Icon(menu['icon'] as IconData),
                  title: Text(menu['title'] as String),
                  onTap: () {
                    // TODO: 각 메뉴별 페이지 이동
                    print('${menu['title']} 클릭됨');
                  },
                ),
              )
              .toList(),
    );
  }
}
