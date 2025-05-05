import 'package:flutter/material.dart';
import 'widgets/payment_form.dart';
import 'widgets/payment_list.dart';
import 'widgets/payment_section_title.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('광고 신청')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          PaymentSectionTitle(title: '광고 신청서'),
          PaymentForm(),
          SizedBox(height: 24),
          PaymentSectionTitle(title: '신청 내역'),
          PaymentList(),
        ],
      ),
    );
  }
}
