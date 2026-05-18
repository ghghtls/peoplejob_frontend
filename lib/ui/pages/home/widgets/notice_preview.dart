import 'package:flutter/material.dart';
import '../../../../services/notice_service.dart';
import '../../../../data/model/notice.dart';

class NoticePreview extends StatefulWidget {
  const NoticePreview({super.key});

  @override
  State<NoticePreview> createState() => _NoticePreviewState();
}

class _NoticePreviewState extends State<NoticePreview> {
  static const Color _label     = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _separator = Color(0xFFD1D1D6);
  static const Color _blue      = Color(0xFF0B5FFF);
  static const Color _purple    = Color(0xFFAF52DE);

  final NoticeService _noticeService = NoticeService();
  List<Notice> _notices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    try {
      final notices = await _noticeService.getAllNotices();
      if (mounted) {
        setState(() {
          _notices = notices.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2)),
              )
            : Column(
                children: [
                  if (_notices.isEmpty)
                    _buildEmptyRow()
                  else
                    ...List.generate(_notices.length, (i) => Column(
                      children: [
                        _buildNoticeRow(_notices[i], i),
                        if (i < _notices.length - 1)
                          const Divider(height: 1, indent: 64, color: _separator),
                      ],
                    )),
                  const Divider(height: 1, color: _separator),
                  _buildMoreButton(),
                ],
              ),
      ),
    );
  }

  Widget _buildNoticeRow(Notice notice, int i) {
    return InkWell(
      borderRadius: BorderRadius.vertical(
        top: i == 0 ? const Radius.circular(16) : Radius.zero,
      ),
      onTap: () => Navigator.pushNamed(context, '/notice'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (notice.isImportant == true ? _blue : _purple).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                notice.isImportant == true ? Icons.priority_high_rounded : Icons.campaign_rounded,
                color: notice.isImportant == true ? _blue : _purple,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _label,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (notice.regdate != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      notice.formattedDate,
                      style: const TextStyle(fontSize: 11, color: _secondary, letterSpacing: -0.1),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _separator, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.campaign_rounded, color: _purple, size: 18),
          ),
          const SizedBox(width: 12),
          const Text(
            '등록된 공지사항이 없습니다',
            style: TextStyle(fontSize: 14, color: _secondary, letterSpacing: -0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreButton() {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, '/notice'),
      style: TextButton.styleFrom(
        foregroundColor: _secondary,
        minimumSize: const Size(double.infinity, 44),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      child: const Text(
        '전체 공지사항 보기',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
