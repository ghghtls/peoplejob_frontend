import 'package:flutter/material.dart';
import 'widgets/profile_card.dart';
import 'widgets/mypage_menu_list.dart';
import 'widgets/logout_button.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const ProfileCard(),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('이력서 관리'),
              onTap: () => Navigator.pushNamed(context, '/resume'),
            ),
            ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('문의사항'),
              onTap: () {
                Navigator.pushNamed(context, '/inquiry/list');
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('자료실'),
              onTap: () {
                Navigator.pushNamed(context, '/resources/list');
              },
            ),

            const MyPageMenuList(),
          ],
        ),
      ),
      bottomSheet: const LogoutButton(),
    );
  }
}
