import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () {
          // TODO: 로그아웃 로직 연결
          print('로그아웃 클릭');
        },
        child: const Text('로그아웃', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
