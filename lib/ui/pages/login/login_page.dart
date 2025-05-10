import 'package:flutter/material.dart';
import 'widgets/login_form.dart';
import 'widgets/signup_link.dart';
import 'find_id_page.dart';
import 'find_password_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const LoginForm(), //  핵심: 로그인 폼 연결됨
            const SizedBox(height: 20),
            const SignUpLink(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FindIdPage()),
                    );
                  },
                  child: const Text('아이디 찾기'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FindPasswordPage(),
                      ),
                    );
                  },
                  child: const Text('비밀번호 찾기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
