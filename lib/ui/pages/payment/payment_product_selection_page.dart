import 'package:flutter/material.dart';
import '../../widgets/app_bar.dart';

class PaymentProductSelectionPage extends StatelessWidget {
  const PaymentProductSelectionPage({super.key});

  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _orange = Color(0xFFFF9500);

  static const _products = [
    {'name': 'Premium', 'price': 50000, 'description': '메인 최상단 1순위 노출', 'duration': 7,
      'color': Color(0xFFFF9500), 'icon': Icons.star_rounded},
    {'name': 'Standard', 'price': 30000, 'description': '메인 중간 영역 노출', 'duration': 7,
      'color': Color(0xFF0B5FFF), 'icon': Icons.trending_up_rounded},
    {'name': 'Basic', 'price': 10000, 'description': '채용공고 하단 배너', 'duration': 7,
      'color': Color(0xFF34C759), 'icon': Icons.campaign_rounded},
  ];

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
    final jobArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(title: '광고 상품 선택'),
      body: Column(
        children: [
            if (jobArgs != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.work_outline_rounded, size: 16, color: _blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          jobArgs['jobTitle'] as String? ?? '',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _blue),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Text('원하는 광고 상품을 선택해주세요',
                  style: TextStyle(fontSize: 13, color: _secondary.withValues(alpha: 0.8))),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  final isFirst = index == 0;
                  final color = product['color'] as Color;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: isFirst ? Border.all(color: _orange.withValues(alpha: 0.4), width: 1.5) : null,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/payment/schedule',
                            arguments: {
                              ...?jobArgs,
                              'productName': product['name'],
                              'price': product['price'],
                              'productDesc': product['description'],
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(product['icon'] as IconData, size: 24, color: color),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(product['name'] as String,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _label)),
                                        if (isFirst) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: _orange.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text('추천', style: TextStyle(fontSize: 10, color: _orange, fontWeight: FontWeight.w700)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('${product['description']} · ${product['duration']}일',
                                        style: const TextStyle(fontSize: 13, color: _secondary)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(_formatPrice(product['price'] as int),
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                                    child: const Text('선택', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
      ),
    );
  }
}
