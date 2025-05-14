// lib/ui/pages/company_mypage/company_mypage_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peoplejob_frontend/data/provider/auth_provider.dart';
import 'widgets/company_profile_card.dart';
import 'widgets/company_mypage_menu_list.dart';
import 'widgets/company_job_ads_list.dart';
import 'widgets/company_payment_status.dart';

class CompanyMyPage extends ConsumerWidget {
  const CompanyMyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userType = ref.watch(userTypeProvider);

    if (userType != 'company') {
      return const Scaffold(body: Center(child: Text('기업회원만 접근 가능합니다.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('기업 마이페이지')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            CompanyProfileCard(),
            SizedBox(height: 20),
            CompanyMyPageMenuList(),
            Divider(),
            CompanyJobAdsList(),
            Divider(),
            CompanyPaymentStatus(),
          ],
        ),
      ),
    );
  }
}
