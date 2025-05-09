import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchedulePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final int selectedDuration;
  final VoidCallback onPickDate;
  final ValueChanged<int> onDurationChanged;

  const SchedulePicker({
    super.key,
    required this.selectedDate,
    required this.selectedDuration,
    required this.onPickDate,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
            : '날짜를 선택해주세요';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '광고 시작일',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(formattedDate),
            const SizedBox(width: 20),
            ElevatedButton(onPressed: onPickDate, child: const Text('날짜 선택')),
          ],
        ),
        const SizedBox(height: 30),
        const Text(
          '광고 기간 (일)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        DropdownButton<int>(
          value: selectedDuration,
          items:
              const [7, 14, 30]
                  .map(
                    (days) =>
                        DropdownMenuItem(value: days, child: Text('$days일')),
                  )
                  .toList(),
          onChanged: (int? value) {
            if (value != null) {
              onDurationChanged(value);
            }
          },
        ),
      ],
    );
  }
}
