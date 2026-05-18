import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/app_bar.dart';

class CompanyInfoPage extends StatelessWidget {
  const CompanyInfoPage({super.key});

  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);

  static const Map<String, String> _company = {
    'name': '(주)피플잡',
    'businessNumber': '123-45-67890',
    'industry': 'IT 서비스',
    'location': '서울특별시 강남구 테헤란로',
    'manager': '홍길동',
    'contact': '010-1234-5678',
    'email': 'ceo@peoplejob.com',
    'homepage': 'https://peoplejob.com',
  };

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final messenger = ScaffoldMessenger.of(context);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      messenger.showSnackBar(const SnackBar(content: Text('홈페이지를 열 수 없습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(title: '기업정보'),
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    // 회사 아이콘 & 이름
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_blue.withValues(alpha: 0.08), _blue.withValues(alpha: 0.04)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              color: _blue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.business_rounded, size: 32, color: _blue),
                          ),
                          const SizedBox(height: 12),
                          Text(_company['name']!,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                                  color: _label, letterSpacing: -0.5)),
                          const SizedBox(height: 4),
                          Text(_company['industry']!,
                              style: const TextStyle(fontSize: 14, color: _secondary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 상세 정보
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          _infoRow(Icons.badge_outlined, '사업자등록번호', _company['businessNumber']!),
                          _divider(),
                          _infoRow(Icons.location_on_outlined, '근무지역', _company['location']!),
                          _divider(),
                          _infoRow(Icons.person_outline_rounded, '담당자', _company['manager']!),
                          _divider(),
                          _infoRow(Icons.phone_outlined, '연락처', _company['contact']!),
                          _divider(),
                          _infoRow(Icons.email_outlined, '이메일', _company['email']!),
                          _divider(),
                          Material(
                            color: Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16),
                            ),
                            child: InkWell(
                              onTap: () => _launchUrl(context, _company['homepage']!),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    const Icon(Icons.language_rounded, size: 18, color: _secondary),
                                    const SizedBox(width: 12),
                                    const SizedBox(width: 72,
                                        child: Text('홈페이지', style: TextStyle(fontSize: 13, color: _secondary))),
                                    Expanded(
                                      child: Text(_company['homepage']!,
                                          style: const TextStyle(fontSize: 14, color: _blue, fontWeight: FontWeight.w500)),
                                    ),
                                    const Icon(Icons.open_in_new_rounded, size: 16, color: _blue),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _secondary),
          const SizedBox(width: 12),
          SizedBox(width: 72, child: Text(label, style: const TextStyle(fontSize: 13, color: _secondary))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: _label, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 16, endIndent: 0, color: Color(0xFFF2F2F7));
}
