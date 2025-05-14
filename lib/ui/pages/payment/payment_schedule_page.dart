import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final formattedDate =
        selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
            : '날짜를 선택하세요';

    return Scaffold(
      appBar: AppBar(title: const Text('광고 시작일 및 기간 선택')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              title: const Text('광고 시작일'),
              subtitle: Text(formattedDate),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _pickDate,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              value: selectedDuration,
              decoration: const InputDecoration(
                labelText: '광고 기간(일)',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 7, child: Text('7일')),
                DropdownMenuItem(value: 14, child: Text('14일')),
                DropdownMenuItem(value: 30, child: Text('30일')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedDuration = value!;
                });
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    selectedDate != null
                        ? () {
                          Navigator.pushNamed(context, '/payment/result');
                        }
                        : null,
                child: const Text('결제 진행'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
