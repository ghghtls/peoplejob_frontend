import 'package:flutter/material.dart';

class ServiceProductListPage extends StatelessWidget {
  const ServiceProductListPage({super.key});

  final List<Map<String, dynamic>> _mockProducts = const [
    {
      'name': '프리미엄 공고',
      'description': '상단 고정 + 강조 표시',
      'duration': 7,
      'price': 50000,
    },
    {
      'name': '배너 광고',
      'description': '메인 배너 영역 노출',
      'duration': 3,
      'price': 80000,
    },
    {
      'name': '기업 로고 강조',
      'description': '공고 리스트에서 로고 크게 표시',
      'duration': 5,
      'price': 30000,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('서비스 상품 조회')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mockProducts.length,
        itemBuilder: (context, index) {
          final product = _mockProducts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(product['description']),
                  const SizedBox(height: 8),
                  Text('노출 기간: ${product['duration']}일'),
                  Text('가격: ${product['price'].toString()}원'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // TODO: 수정 기능 연결
                        },
                        child: const Text('수정'),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: 삭제 기능 연결
                        },
                        child: const Text(
                          '삭제',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
