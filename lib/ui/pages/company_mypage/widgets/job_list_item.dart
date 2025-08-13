import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:peoplejob_frontend/data/model/job.dart';

class JobListItem extends StatelessWidget {
  final Job job;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final Function(bool) onSelect;
  final VoidCallback? onPublish;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(String)? onChangeStatus;

  const JobListItem({
    super.key,
    required this.job,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onSelect,
    this.onPublish,
    this.onEdit,
    this.onDelete,
    this.onChangeStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 (제목, 상태, 선택 체크박스)
              Row(
                children: [
                  if (isSelectionMode) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => onSelect(value ?? false),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusChip(),
                ],
              ),

              const SizedBox(height: 12),

              // 회사 및 위치 정보
              Row(
                children: [
                  Icon(Icons.business, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.company,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  if (job.location != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.location!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 8),

              // 날짜 및 조회수 정보
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '등록일: ${_formatDate(job.regdate)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  if (job.deadline != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.event,
                      size: 16,
                      color: job.isExpired ? Colors.red : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '마감일: ${_formatDate(job.deadline)}',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            job.isExpired ? Colors.red : Colors.grey.shade600,
                        fontWeight:
                            job.isExpired ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (job.viewCount != null && job.viewCount! > 0) ...[
                    Icon(
                      Icons.visibility,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${job.viewCount}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),

              // 액션 버튼들
              if (!isSelectionMode) ...[
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (job.canEdit && onEdit != null)
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('수정'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),

                    if (job.canPublish && onPublish != null)
                      TextButton.icon(
                        onPressed: onPublish,
                        icon: const Icon(Icons.public, size: 16),
                        label: const Text('게시'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),

                    if (job.isPublished && onChangeStatus != null)
                      PopupMenuButton<String>(
                        onSelected: onChangeStatus,
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: 'SUSPENDED',
                                child: Text('게시 중단'),
                              ),
                              const PopupMenuItem(
                                value: 'EXPIRED',
                                child: Text('마감 처리'),
                              ),
                            ],
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.more_vert, size: 16),
                              SizedBox(width: 4),
                              Text('더보기'),
                            ],
                          ),
                        ),
                      ),

                    if (job.canDelete && onDelete != null)
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('삭제'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: job.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: job.statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(job.statusIcon, size: 12, color: job.statusColor),
          const SizedBox(width: 4),
          Text(
            job.statusDescription,
            style: TextStyle(
              fontSize: 11,
              color: job.statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy.MM.dd').format(date);
  }
}
