import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: NetworkImage(
            'https://via.placeholder.com/150', // TODO: 유저 프로필 URL 연동
          ),
        ),
        title: const Text('홍길동'),
        subtitle: const Text('hong@example.com'),
      ),
    );
  }
}
