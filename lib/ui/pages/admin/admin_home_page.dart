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
        children: const [
          AdminSectionTitle(title: '채용공고 관리'),
          JobManageList(),
          SizedBox(height: 24),
          AdminSectionTitle(title: '이력서 관리'),
          ResumeManageList(),
          SizedBox(height: 24),
          AdminSectionTitle(title: '회원 관리'),
          UserManageList(),
          SizedBox(height: 24),
          AdminSectionTitle(title: '문의 내역 관리'),
          InquiryManageList(),
        ],
      ),
    );
  }
}
