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

  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _red = Color(0xFFE5342F);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: notices.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= notices.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5)),
          );
        }
        final notice = notices[index];
        final isImportant = notice.isImportantNotice;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isImportant ? Border.all(color: _red.withValues(alpha: 0.3), width: 1) : null,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () => onNoticeTap(notice.noticeNo!),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isImportant)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: _red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('중요',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _red)),
                          ),
                        if (isImportant) const SizedBox(width: 8),
                        Expanded(
                          child: Text(notice.title,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                                  color: isImportant ? _red : _label, letterSpacing: -0.3),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                        if (notice.hasAttachment) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.attach_file_rounded, size: 15, color: _secondary.withValues(alpha: 0.7)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(notice.getContentSummary(),
                        style: const TextStyle(fontSize: 13, color: _secondary, height: 1.4),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 12, color: _secondary),
                        const SizedBox(width: 3),
                        Text(notice.writer, style: const TextStyle(fontSize: 11, color: _secondary)),
                        const SizedBox(width: 10),
                        const Icon(Icons.schedule_rounded, size: 12, color: _secondary),
                        const SizedBox(width: 3),
                        Text(notice.formattedDate, style: const TextStyle(fontSize: 11, color: _secondary)),
                        const Spacer(),
                        const Icon(Icons.visibility_outlined, size: 12, color: _secondary),
                        const SizedBox(width: 3),
                        Text('${notice.viewCount ?? 0}', style: const TextStyle(fontSize: 11, color: _secondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
