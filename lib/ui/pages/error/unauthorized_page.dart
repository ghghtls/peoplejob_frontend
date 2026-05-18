import 'package:flutter/material.dart';

class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key});

  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _red = Color(0xFFE5342F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: _blue),
                    style: IconButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.all(8)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: _red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(Icons.lock_outline_rounded, size: 40, color: _red),
                      ),
                      const SizedBox(height: 24),
                      const Text('접근 권한 없음',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _label, letterSpacing: -0.5)),
                      const SizedBox(height: 10),
                      const Text('이 페이지에 접근할 권한이 없습니다.\n로그인 후 다시 시도해주세요.',
                          style: TextStyle(fontSize: 15, color: _secondary, height: 1.5, letterSpacing: -0.2),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _blue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('홈으로 이동',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
