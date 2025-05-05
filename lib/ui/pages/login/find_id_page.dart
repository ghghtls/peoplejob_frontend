import 'package:flutter/material.dart';

class FindIdPage extends StatefulWidget {
  const FindIdPage({super.key});

  @override
  State<FindIdPage> createState() => _FindIdPageState();
}

class _FindIdPageState extends State<FindIdPage> {
  final emailController = TextEditingController();
  String? foundId;

  void _findId() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이메일을 입력해주세요.')));
      return;
    }

    // TODO: 실제 API 연동 필요
    setState(() {
      foundId = 'peoplejob123'; // 예시용 아이디
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('아이디 찾기')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: '가입한 이메일'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _findId, child: const Text('아이디 찾기')),
            const SizedBox(height: 24),
            if (foundId != null)
              Text(
                '회원님의 아이디는 [$foundId] 입니다.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
