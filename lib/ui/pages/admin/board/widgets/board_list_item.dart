import 'package:flutter/material.dart';

class BoardListItem extends StatelessWidget {
  final int id;
  final String title;
  final bool isActive;
  final bool allowUpload;
  final bool allowComment;

  const BoardListItem({
    super.key,
    required this.id,
    required this.title,
    required this.isActive,
    required this.allowUpload,
    required this.allowComment,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Row(
        children: [
          _buildToggle('사용', isActive),
          const SizedBox(width: 12),
          _buildToggle('업로드', allowUpload),
          const SizedBox(width: 12),
          _buildToggle('댓글', allowComment),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          Navigator.pushNamed(context, '/admin/board/edit/$id');
        },
      ),
    );
  }

  Widget _buildToggle(String label, bool value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        Switch(
          value: value,
          onChanged: (v) {
            // TODO: API 연동 예정
          },
        ),
      ],
    );
  }
}
