import 'package:flutter/material.dart';
import '../../../../data/model/inquiry.dart';

class InquiryListView extends StatelessWidget {
  final List<Inquiry> inquiries;
  final Function(int) onInquiryTap;
  final Function(Inquiry)? onEditTap;

  const InquiryListView({
    super.key,
    required this.inquiries,
    required this.onInquiryTap,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        itemCount: inquiries.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final inquiry = inquiries[index];
          return _InquiryCard(
            inquiry: inquiry,
            onTap: () => onInquiryTap(inquiry.inquiryNo!),
            onEditTap: onEditTap != null ? () => onEditTap!(inquiry) : null,
          );
        },
      ),
    );
  }
}

class _InquiryCard extends StatelessWidget {
  final Inquiry inquiry;
  final VoidCallback onTap;
  final VoidCallback? onEditTap;

  const _InquiryCard({
    required this.inquiry,
    required this.onTap,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 상태와 액션 버튼
              Row(
                children: [
                  // 상태 배지
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          inquiry.isAnswered
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          inquiry.isAnswered
                              ? Icons.check_circle
                              : Icons.schedule,
                          size: 14,
                          color:
                              inquiry.isAnswered ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          inquiry.statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color:
                                inquiry.isAnswered
                                    ? Colors.green
                                    : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // 수정 버튼 (답변 전에만 표시)
                  if (!inquiry.isAnswered && onEditTap != null)
                    IconButton(
                      onPressed: onEditTap,
                      icon: const Icon(Icons.edit_outlined),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // 제목
              Text(
                inquiry.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // 내용 미리보기
              Text(
                inquiry.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // 하단: 날짜 정보
              Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    '작성일: ${inquiry.regdate ?? '알 수 없음'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  if (inquiry.answerDate != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.reply, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      '답변일: ${inquiry.answerDate}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),

              // 답변이 있는 경우 미리보기
              if (inquiry.answer != null && inquiry.answer!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.support_agent,
                            size: 16,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '관리자 답변',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        inquiry.answer!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
