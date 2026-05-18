import 'package:flutter/material.dart';
import '../../widgets/app_bar.dart';

class PaymentResultPage extends StatelessWidget {
  const PaymentResultPage({super.key});

  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _green = Color(0xFF0FA958);
  static const Color _orange = Color(0xFFFF9500);

  String _formatPrice(int price) {
    final s = price.toString();
    final result = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write(',');
      result.write(s[i]);
    }
    return '$result원';
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final productName = args['productName'] as String? ?? '';
    final jobTitle = args['jobTitle'] as String? ?? '';
    final amount = args['amount'] as int? ?? 0;
    final startDate = args['startDate'] as String? ?? '';
    final endDate = args['endDate'] as String? ?? '';

    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '결제 완료',
        showBackButton: false,
        showHomeButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          children: [
            // 성공 아이콘
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.check_circle_rounded, size: 52, color: _green),
            ),
            const SizedBox(height: 24),
            const Text('결제가 완료되었습니다!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _label, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            const Text('선택한 광고가 설정한 기간 동안 노출됩니다.',
                style: TextStyle(fontSize: 14, color: _secondary), textAlign: TextAlign.center),

            if (productName.isNotEmpty || jobTitle.isNotEmpty) ...[
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('결제 상세',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary)),
                    const SizedBox(height: 14),
                    _row('채용공고', jobTitle),
                    const SizedBox(height: 10),
                    _row('광고 상품', productName),
                    const SizedBox(height: 10),
                    if (startDate.isNotEmpty) _row('광고 기간', '$startDate ~ $endDate'),
                    if (startDate.isNotEmpty) const SizedBox(height: 10),
                    if (amount > 0) ...[
                      const Divider(height: 20, color: Color(0xFFF2F2F7)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('결제 금액',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _label)),
                          Text(_formatPrice(amount),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _orange)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('홈으로 돌아가기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/payment/history', (route) => route.isFirst),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE5E5EA)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('결제 내역 보기',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _label)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 72, child: Text(label, style: const TextStyle(fontSize: 13, color: _secondary))),
        Expanded(child: Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _label),
            maxLines: 2, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
