import 'package:flutter/material.dart';
import '../../widgets/app_bar.dart';

class ServiceProductListPage extends StatelessWidget {
  const ServiceProductListPage({super.key});

  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);

  static const List<Map<String, dynamic>> _mockProducts = [
    {'name': '프리미엄 공고', 'description': '상단 고정 + 강조 표시', 'duration': 7, 'price': 50000, 'color': Color(0xFFFF9500)},
    {'name': '배너 광고', 'description': '메인 배너 영역 노출', 'duration': 3, 'price': 80000, 'color': Color(0xFF0B5FFF)},
    {'name': '기업 로고 강조', 'description': '공고 리스트에서 로고 크게 표시', 'duration': 5, 'price': 30000, 'color': Color(0xFF34C759)},
  ];

  String _formatPrice(int price) {
    final s = price.toString();
    final result = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) { result.write(','); }
      result.write(s[i]);
    }
    return '$result원';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '서비스 상품 조회',
        showHomeButton: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/admin/service-product/register'),
            icon: const Icon(Icons.add_rounded, size: 22, color: _blue),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: _mockProducts.length,
                itemBuilder: (context, index) {
                  final product = _mockProducts[index];
                  final color = product['color'] as Color;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                child: Icon(Icons.campaign_rounded, size: 22, color: color),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(product['name'] as String,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _label)),
                                  const SizedBox(height: 3),
                                  Text(product['description'] as String,
                                      style: const TextStyle(fontSize: 13, color: _secondary)),
                                ]),
                              ),
                              Text(_formatPrice(product['price'] as int),
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _bg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule_rounded, size: 14, color: _secondary),
                                const SizedBox(width: 5),
                                Text('노출 기간: ${product['duration']}일',
                                    style: const TextStyle(fontSize: 12, color: _secondary)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFE5E5EA)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: Size.zero,
                              ),
                              child: const Text('수정', style: TextStyle(fontSize: 13, color: _label, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: _red.withValues(alpha: 0.3)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: Size.zero,
                              ),
                              child: const Text('삭제', style: TextStyle(fontSize: 13, color: _red, fontWeight: FontWeight.w600)),
                            ),
                          ]),
                        ],
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
