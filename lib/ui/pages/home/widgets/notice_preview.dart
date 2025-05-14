import 'package:flutter/material.dart';

class NoticePreview extends StatelessWidget {
  const NoticePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/notice');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '📢 공지사항',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('- 서버 점검 안내'),
            Text('- 신규 기능 출시 안내'),
            SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text('더 보기 →', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}
