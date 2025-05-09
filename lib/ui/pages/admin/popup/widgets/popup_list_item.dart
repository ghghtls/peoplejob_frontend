import 'package:flutter/material.dart';

class PopupListItem extends StatelessWidget {
  final int id;
  final String title;
  final String startDate;
  final String endDate;
  final bool isActive;

  const PopupListItem({
    super.key,
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('노출기간: $startDate ~ $endDate'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: isActive,
            onChanged: (val) {
              // TODO: 사용 여부 변경 처리
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/admin/popup/edit/$id');
            },
          ),
        ],
      ),
    );
  }
}
