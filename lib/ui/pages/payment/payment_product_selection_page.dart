import 'package:flutter/material.dart';
import 'package:peoplejob_frontend/ui/pages/payment/widgets/product_card.dart';

class PaymentProductSelectionPage extends StatelessWidget {
  const PaymentProductSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      Product(
        name: 'Premium',
        price: 50000,
        description: '메인 최상단 1순위 노출',
        duration: 7,
      ),
      Product(
        name: 'Standard',
        price: 30000,
        description: '메인 중간 영역 노출',
        duration: 7,
      ),
      Product(
        name: 'Basic',
        price: 10000,
        description: '채용공고 하단 배너',
        duration: 7,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('광고 상품 선택')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(product: product);
        },
      ),
    );
  }
}

class Product {
  final String name;
  final int price;
  final String description;
  final int duration;

  Product({
    required this.name,
    required this.price,
    required this.description,
    required this.duration,
  });
}
