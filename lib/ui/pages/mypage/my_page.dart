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
          children: const [
            ProfileCard(),
            SizedBox(height: 20),
            MyPageMenuList(),
          ],
        ),
      ),
      bottomSheet: const LogoutButton(),
    );
  }
}
