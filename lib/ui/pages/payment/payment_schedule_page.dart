import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'widgets/schedule_picker.dart';

class PaymentSchedulePage extends StatefulWidget {
  const PaymentSchedulePage({super.key});

  @override
  State<PaymentSchedulePage> createState() => _PaymentSchedulePageState();
}

class _PaymentSchedulePageState extends State<PaymentSchedulePage> {
  DateTime? selectedDate;
  int selectedDuration = 7;

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('광고 시작일 및 기간 선택')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SchedulePicker(
              selectedDate: selectedDate,
              selectedDuration: selectedDuration,
              onPickDate: _pickDate,
              onDurationChanged: (int newDuration) {
                setState(() {
                  selectedDuration = newDuration;
                });
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // TODO: 결제 완료 페이지로 이동
              },
              child: const Text('결제 진행'),
            ),
          ],
        ),
      ),
    );
  }
}
