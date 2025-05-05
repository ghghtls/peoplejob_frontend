import 'package:flutter/material.dart';

class FindPasswordPage extends StatefulWidget {
  const FindPasswordPage({super.key});

  @override
  State<FindPasswordPage> createState() => _FindPasswordPageState();
}

class _FindPasswordPageState extends State<FindPasswordPage> {
  final idController = TextEditingController();
  final emailController = TextEditingController();
  bool isSent = false;

  void _findPassword() {
    final id = idController.text.trim();
    final email = emailController.text.trim();

    if (id.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('아이디와 이메일 모두 입력해주세요.')));
      return;
    }

    // TODO: 실제 이메일 발송 API 연동 필요
    setState(() {
      isSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('비밀번호 찾기')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: '아이디'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: '가입한 이메일'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _findPassword,
              child: const Text('임시 비밀번호 발송'),
            ),
            const SizedBox(height: 24),
            if (isSent)
              const Text(
                '입력하신 이메일로 임시 비밀번호를 발송했습니다.',
                style: TextStyle(color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
