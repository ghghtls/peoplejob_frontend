import 'package:flutter/material.dart';
import 'widgets/resume_section_card.dart';

class ResumeDetailPage extends StatelessWidget {
  const ResumeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이력서 상세')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 프로필
            Row(
              children: const [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/profile_placeholder.png'),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '홍길동',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('hong@example.com'),
                    Text('010-1234-5678'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 자기소개
            const ResumeSectionCard(
              title: '자기소개',
              children: [
                Text('책임감 있고 성실한 개발자입니다. 다양한 프로젝트를 통해 협업과 문제 해결 능력을 키웠습니다.'),
              ],
            ),

            // 학력사항
            const ResumeSectionCard(
              title: '학력사항',
              children: [
                _InfoTile(
                  title: 'OO대학교',
                  subtitle: '컴퓨터공학과',
                  trailing: '2015.03 ~ 2019.02',
                ),
              ],
            ),

            // 경력사항
            const ResumeSectionCard(
              title: '경력사항',
              children: [
                _InfoTile(
                  title: 'ABC 회사',
                  subtitle: 'Flutter 개발자',
                  trailing: '2020.01 ~ 2023.04',
                ),
              ],
            ),

            // 자격증
            const ResumeSectionCard(
              title: '자격증',
              children: [
                _InfoTile(
                  title: '정보처리기사',
                  subtitle: '한국산업인력공단',
                  trailing: '2020.06',
                ),
              ],
            ),

            // 희망 근무 정보
            const ResumeSectionCard(
              title: '희망 근무 조건',
              children: [
                ListTile(title: Text('희망 지역'), trailing: Text('서울')),
                ListTile(title: Text('희망 직종'), trailing: Text('모바일 앱 개발자')),
                ListTile(title: Text('근무 형태'), trailing: Text('정규직')),
                ListTile(title: Text('희망 연봉'), trailing: Text('4,000만원')),
              ],
            ),

            const SizedBox(height: 24),

            // 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('수정')),
                ElevatedButton(onPressed: () {}, child: const Text('삭제')),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('목록으로'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 내부 정보 타일 위젯
class _InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;

  const _InfoTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(trailing),
    );
  }
}
