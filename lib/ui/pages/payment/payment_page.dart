import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../widgets/app_bar.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _orange = Color(0xFFFF9500);

  final _storage = const FlutterSecureStorage();
  String? _userType;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final userType = await _storage.read(key: 'userType');
    if (mounted) {
      setState(() {
        _userType = userType?.toLowerCase();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userType != 'company') {
      return Scaffold(
        backgroundColor: _bg,
        appBar: buildCommonAppBar(title: '광고 결제'),
        body: const Center(
          child: Text('접근 권한이 없습니다.', style: TextStyle(color: _secondary, fontSize: 15)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(title: '광고 결제'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          children: [
            // 광고 안내 배너
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_orange.withValues(alpha: 0.12), _orange.withValues(alpha: 0.06)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: _orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.campaign_rounded, size: 28, color: _orange),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('채용공고 광고',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _label)),
                        SizedBox(height: 4),
                        Text('광고를 통해 더 많은 지원자를 만나보세요',
                            style: TextStyle(fontSize: 13, color: _secondary, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 광고 효과 안내
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('광고 효과',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _label)),
                  const SizedBox(height: 16),
                  _benefitRow(Icons.visibility_rounded, '최대 10배 더 많은 노출'),
                  const SizedBox(height: 12),
                  _benefitRow(Icons.trending_up_rounded, '지원자 수 평균 3배 증가'),
                  const SizedBox(height: 12),
                  _benefitRow(Icons.star_rounded, '프리미엄 배지 부여'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 광고 신청 버튼
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/payment/target'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.rocket_launch_rounded, size: 20, color: Colors.white),
                    SizedBox(width: 8),
                    Text('광고 신청하기',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefitRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: _orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: _orange),
        ),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14, color: _label, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
