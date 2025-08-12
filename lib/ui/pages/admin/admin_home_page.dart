import 'package:flutter/material.dart';
import 'widgets/admin_section_title.dart';
import 'widgets/job_manage_list.dart';
import 'widgets/resume_manage_list.dart';
import 'widgets/user_manage_list.dart';
import 'widgets/inquiry_manage_list.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('관리자 페이지')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AdminSectionTitle(title: '대시보드'),
          ListTile(
            title: const Text('관리 요약/통계 보기'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, '/admin/dashboard');
            },
          ),
          const SizedBox(height: 16),

          AdminSectionTitle(title: '공지사항 관리'),
          ListTile(
            title: const Text('공지사항 목록/수정'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, '/admin/notice');
            },
          ),
          const SizedBox(height: 16),

          AdminSectionTitle(title: '문의사항 관리'),
          ListTile(
            title: const Text('문의사항 목록/답변'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, '/admin/inquiry');
            },
          ),
          const SizedBox(height: 16),

          AdminSectionTitle(title: '회원 관리'),
          ListTile(
            title: const Text('일반/기업회원 목록'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, '/admin/user');
            },
          ),
          const SizedBox(height: 16),

          AdminSectionTitle(title: '게시판 관리'),
          ListTile(
            title: const Text('게시판 생성/사용여부 설정'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, '/admin/board');
            },
          ),
          const SizedBox(height: 16),

          AdminSectionTitle(title: '팝업 관리'),
          ListTile(
            title: const Text('팝업 등록/노출 설정'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, '/admin/popup');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
