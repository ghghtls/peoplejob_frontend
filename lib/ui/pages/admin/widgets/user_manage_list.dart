import 'package:flutter/material.dart';

class UserManageList extends StatelessWidget {
  const UserManageList({super.key});

  @override
  Widget build(BuildContext context) {
    final users = [
      {'name': '홍길동', 'email': 'hong@naver.com'},
      {'name': '김영희', 'email': 'kim@gmail.com'},
    ];

    return Column(
      children:
          users.map((u) {
            return ListTile(
              title: Text(u['name']!),
              subtitle: Text(u['email']!),
              trailing: const Icon(Icons.person),
            );
          }).toList(),
    );
  }
}
