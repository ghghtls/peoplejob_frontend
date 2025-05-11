import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyInfoPage extends StatelessWidget {
  const CompanyInfoPage({super.key});

  final Map<String, String> _company = const {
    'name': '(주)피플잡',
    'businessNumber': '123-45-67890',
    'industry': 'IT 서비스',
    'location': '서울특별시 강남구 테헤란로',
    'manager': '홍길동',
    'contact': '010-1234-5678',
    'email': 'ceo@peoplejob.com',
    'homepage': 'https://peoplejob.com',
  };

  void _launchUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('홈페이지를 열 수 없습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기업정보 조회')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.business, size: 60, color: Colors.blue),
          const SizedBox(height: 16),
          _buildInfoTile('회사명', _company['name']!),
          _buildInfoTile('사업자등록번호', _company['businessNumber']!),
          _buildInfoTile('업종', _company['industry']!),
          _buildInfoTile('근무지역', _company['location']!),
          _buildInfoTile('담당자', _company['manager']!),
          _buildInfoTile('연락처', _company['contact']!),
          _buildInfoTile('이메일', _company['email']!),
          ListTile(
            title: const Text('홈페이지'),
            subtitle: Text(_company['homepage']!),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _launchUrl(context, _company['homepage']!),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String content) {
    return ListTile(title: Text(title), subtitle: Text(content));
  }
}
