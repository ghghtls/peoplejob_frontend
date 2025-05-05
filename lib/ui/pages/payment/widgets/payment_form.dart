import 'package:flutter/material.dart';

class PaymentForm extends StatefulWidget {
  const PaymentForm({super.key});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  String selectedType = '메인 배너 광고';
  String memo = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('광고 상품'),
        DropdownButton<String>(
          value: selectedType,
          items: const [
            DropdownMenuItem(value: '메인 배너 광고', child: Text('메인 배너 광고')),
            DropdownMenuItem(value: '상단 노출 광고', child: Text('상단 노출 광고')),
            DropdownMenuItem(value: '채용공고 강조', child: Text('채용공고 강조')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedType = value);
            }
          },
        ),
        const SizedBox(height: 12),
        const Text('메모'),
        TextField(
          onChanged: (val) => memo = val,
          maxLines: 2,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            // TODO: 신청 처리
            print('신청: $selectedType / 메모: $memo');
          },
          child: const Text('신청하기'),
        ),
      ],
    );
  }
}
