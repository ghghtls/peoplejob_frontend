import 'package:flutter/material.dart';

class AdminUserManagePage extends StatefulWidget {
  const AdminUserManagePage({super.key});

  @override
  State<AdminUserManagePage> createState() => _AdminUserManagePageState();
}

class _AdminUserManagePageState extends State<AdminUserManagePage> {
  final List<UserItem> users = [
    UserItem(id: 1, name: '홍길동', type: '개인회원', email: 'user1@example.com'),
    UserItem(id: 2, name: '김회사', type: '기업회원', email: 'corp@example.com'),
  ];

  void _deleteUser(int id) {
    setState(() {
      users.removeWhere((user) => user.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원 관리')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '회원 목록',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: users.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text('${user.name} (${user.type})'),
                    subtitle: Text(user.email),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteUser(user.id),
                    ),
                    onTap: () {
                      // TODO: 상세 정보 또는 수정 이동 처리
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserItem {
  final int id;
  final String name;
  final String type;
  final String email;

  UserItem({
    required this.id,
    required this.name,
    required this.type,
    required this.email,
  });
}
