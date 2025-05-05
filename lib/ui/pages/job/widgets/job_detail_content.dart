import 'package:flutter/material.dart';

class JobDetailContent extends StatelessWidget {
  const JobDetailContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('''📌 업무 내용:
- Java 백엔드 개발
- Spring Boot 기반 REST API

📌 자격 요건:
- 경력 1년 이상
- MySQL 사용 가능

📌 복지:
- 유연근무제
- 야근 식대 제공

더 많은 상세 내용을 백엔드 연동 후 가져오게 됩니다.''', style: TextStyle(fontSize: 16));
  }
}
