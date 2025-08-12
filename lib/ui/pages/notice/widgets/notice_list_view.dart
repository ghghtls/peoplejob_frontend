import 'package:flutter/material.dart';
import '../../../../data/model/notice.dart';

class NoticeListView extends StatelessWidget {
  final List<Notice> notices;
  final ScrollController scrollController;
  final Function(int) onNoticeTap;
  final bool isLoading;
  final bool hasMore;

  const NoticeListView({
    super.key,
    required this.notices,
    required this.scrollController,
    required this.onNoticeTap,
    this.isLoading = false,
    this.hasMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: notices.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= notices.length) {
          // 로딩 인디케이터
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final notice = notices[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _NoticeCard(
            notice: notice,
            onTap: () => onNoticeTap(notice.noticeNo!),
          ),
        );
      },
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final Notice notice;
  final VoidCallback onTap;

  const _NoticeCard({required this.notice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            notice.isImportantNotice
                ? BorderSide(color: Colors.red.shade300, width: 1)
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration:
              notice.isImportantNotice
                  ? BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.red.shade50, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  )
                  : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 중요 배지와 첨부파일 아이콘
              Row(
                children: [
                  if (notice.isImportantNotice)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '중요',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (notice.hasAttachment)
                    Icon(
                      Icons.attach_file,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                ],
              ),

              if (notice.isImportantNotice || notice.hasAttachment)
                const SizedBox(height: 8),

              // 제목
              Text(
                notice.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      notice.isImportantNotice
                          ? Colors.red.shade700
                          : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // 내용 미리보기
              Text(
                notice.getContentSummary(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // 하단: 메타 정보
              Row(
                children: [
                  Icon(Icons.person, size: 12, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    notice.writer,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 12, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    notice.formattedDate,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 12,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${notice.viewCount ?? 0}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
