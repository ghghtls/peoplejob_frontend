import 'package:flutter/material.dart';

class JobBatchActions extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onBatchPublish;
  final VoidCallback onBatchDelete;
  final Function(String) onBatchChangeStatus;

  const JobBatchActions({
    super.key,
    required this.selectedCount,
    required this.onBatchPublish,
    required this.onBatchDelete,
    required this.onBatchChangeStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '$selectedCount개 선택됨',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const Spacer(),

          // 일괄 게시 버튼
          TextButton.icon(
            onPressed: onBatchPublish,
            icon: const Icon(Icons.public, size: 16),
            label: const Text('게시'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),

          // 일괄 상태 변경 드롭다운
          PopupMenuButton<String>(
            onSelected: onBatchChangeStatus,
            icon: const Icon(Icons.edit),
            tooltip: '상태 변경',
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'DRAFT',
                    child: Row(
                      children: [
                        Icon(Icons.edit_note, size: 16),
                        SizedBox(width: 8),
                        Text('임시저장으로'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'PUBLISHED',
                    child: Row(
                      children: [
                        Icon(Icons.public, size: 16, color: Colors.green),
                        SizedBox(width: 8),
                        Text('게시중으로'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'SUSPENDED',
                    child: Row(
                      children: [
                        Icon(Icons.pause, size: 16, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('게시중단으로'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'EXPIRED',
                    child: Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('마감으로'),
                      ],
                    ),
                  ),
                ],
          ),

          // 일괄 삭제 버튼
          TextButton.icon(
            onPressed: onBatchDelete,
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('삭제'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }
}
