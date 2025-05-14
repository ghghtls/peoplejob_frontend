import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peoplejob_frontend/data/provider/auth_provider.dart';

class PaymentPage extends ConsumerWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userType = ref.watch(userTypeProvider);

    if (userType != 'company') {
      return const Scaffold(body: Center(child: Text('접근 권한이 없습니다.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('광고 결제 시작')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/payment/target');
          },
          child: const Text('광고 신청하기'),
        ),
      ),
    );
  }
}
