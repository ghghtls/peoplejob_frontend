import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../data/provider/notice_provider.dart';
import '../../../data/model/notice.dart';
import '../../widgets/app_bar.dart';

class NoticeDetailPage extends ConsumerStatefulWidget {
  final int noticeId;
  const NoticeDetailPage({super.key, required this.noticeId});

  @override
  ConsumerState<NoticeDetailPage> createState() => _NoticeDetailPageState();
}

class _NoticeDetailPageState extends ConsumerState<NoticeDetailPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);

  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNoticeDetail());
  }

  Future<void> _loadNoticeDetail() async {
    await ref.read(noticeProvider.notifier).loadNoticeDetail(widget.noticeId);
  }

  Future<void> _downloadFile(String fileName, String? fileUrl) async {
    if (fileUrl == null || fileUrl.isEmpty) {
      _showSnackBar('다운로드할 파일이 없습니다.');
      return;
    }
    try {
      setState(() { _isDownloading = true; _downloadProgress = 0.0; });

      if (Platform.isAndroid) {
        final permission = await Permission.storage.request();
        if (!permission.isGranted) {
          _showSnackBar('저장소 권한이 필요합니다.');
          setState(() => _isDownloading = false);
          return;
        }
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      if (directory == null) {
        _showSnackBar('다운로드 폴더를 찾을 수 없습니다.');
        setState(() => _isDownloading = false);
        return;
      }

      final ext = fileName.split('.').last;
      final ts = DateTime.now().millisecondsSinceEpoch;
      final dlName = '${fileName.split('.').first}_$ts.$ext';
      final filePath = '${directory.path}/$dlName';

      final dio = Dio();
      await dio.download(
        fileUrl, filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) setState(() => _downloadProgress = received / total);
        },
        options: Options(headers: {'Accept': '*/*'}),
      );

      setState(() => _isDownloading = false);
      _showDownloadCompleteDialog(filePath, dlName);
    } catch (e) {
      setState(() => _isDownloading = false);
      _showSnackBar('파일 다운로드에 실패했습니다.');
    }
  }

  void _showDownloadCompleteDialog(String filePath, String fileName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('다운로드 완료', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('파일이 성공적으로 다운로드되었습니다.'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(8)),
              child: Text(fileName, style: const TextStyle(fontSize: 12, color: _secondary)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('확인', style: TextStyle(color: _secondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _openFile(filePath);
            },
            child: const Text('파일 열기', style: TextStyle(color: _blue, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _openFile(String filePath) async {
    try {
      final uri = Uri.file(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnackBar('파일을 열 수 있는 앱이 없습니다.');
      }
    } catch (_) {
      _showSnackBar('파일 열기에 실패했습니다.');
    }
  }

  Future<void> _shareNotice(Notice notice) async {
    final shareText = '📢 ${notice.title}\n\n${notice.content}\n\n작성자: ${notice.writer}\n작성일: ${notice.formattedDate}';
    final shareUrl = 'https://peoplejob.com/notice/${notice.noticeNo}';
    final shareUri = Uri(scheme: 'mailto', queryParameters: {
      'subject': '[피플잡] ${notice.title}',
      'body': '$shareText\n\n링크: $shareUrl',
    });
    if (await canLaunchUrl(shareUri)) {
      await launchUrl(shareUri);
    } else {
      _showShareDialog(shareText, shareUrl);
    }
  }

  void _showShareDialog(String shareText, String shareUrl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('공유하기', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(8)),
              child: SelectableText(shareText, style: const TextStyle(fontSize: 12, color: _label)),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _blue.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(8)),
              child: SelectableText(shareUrl, style: const TextStyle(fontSize: 12, color: _blue)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('닫기', style: TextStyle(color: _secondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _copyToClipboard('$shareText\n\n링크: $shareUrl');
            },
            child: const Text('복사', style: TextStyle(color: _blue, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('클립보드에 복사되었습니다.');
  }

  void _showSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg), behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final noticeState = ref.watch(noticeProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '공지사항',
        actions: [
          if (noticeState.selectedNotice != null)
            IconButton(
              onPressed: () => _shareNotice(noticeState.selectedNotice!),
              icon: const Icon(Icons.share_rounded, color: _blue, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(8),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: Builder(builder: (context) {
                if (noticeState.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5));
                }

                if (noticeState.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: _red),
                        const SizedBox(height: 12),
                        Text(noticeState.errorMessage!, style: const TextStyle(color: _secondary), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            ref.read(noticeProvider.notifier).clearError();
                            _loadNoticeDetail();
                          },
                          style: OutlinedButton.styleFrom(foregroundColor: _blue,
                              side: const BorderSide(color: _blue, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  );
                }

                final notice = noticeState.selectedNotice;
                if (notice == null) {
                  return const Center(child: Text('공지사항을 찾을 수 없습니다.', style: TextStyle(color: _secondary)));
                }

                final isImportant = notice.isImportantNotice;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 헤더 카드
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isImportant ? _red.withValues(alpha: 0.06) : _blue.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isImportant) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _red.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.priority_high_rounded, size: 12, color: _red),
                                    SizedBox(width: 3),
                                    Text('중요 공지', style: TextStyle(fontSize: 11, color: _red, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                            Text(notice.title,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                                    color: isImportant ? _red : _label, letterSpacing: -0.5, height: 1.3)),
                            const SizedBox(height: 12),
                            Row(children: [
                              const Icon(Icons.person_outline_rounded, size: 14, color: _secondary),
                              const SizedBox(width: 4),
                              Text(notice.writer, style: const TextStyle(fontSize: 12, color: _secondary)),
                              const SizedBox(width: 12),
                              const Icon(Icons.schedule_rounded, size: 14, color: _secondary),
                              const SizedBox(width: 4),
                              Text(notice.formattedDate, style: const TextStyle(fontSize: 12, color: _secondary)),
                              const Spacer(),
                              const Icon(Icons.visibility_outlined, size: 14, color: _secondary),
                              const SizedBox(width: 4),
                              Text('${notice.viewCount ?? 0}', style: const TextStyle(fontSize: 12, color: _secondary)),
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 첨부파일
                      if (notice.hasAttachment) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _blue.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_file_rounded, color: _blue, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('첨부파일', style: TextStyle(fontSize: 11, color: _secondary)),
                                    Text(notice.originalFilename ?? notice.filename ?? '',
                                        style: const TextStyle(fontSize: 13, color: _blue, fontWeight: FontWeight.w500)),
                                    if (_isDownloading) ...[
                                      const SizedBox(height: 6),
                                      LinearProgressIndicator(
                                        value: _downloadProgress, backgroundColor: _blue.withValues(alpha: 0.1),
                                        valueColor: const AlwaysStoppedAnimation<Color>(_blue),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      const SizedBox(height: 2),
                                      Text('${(_downloadProgress * 100).toInt()}%',
                                          style: const TextStyle(fontSize: 11, color: _blue)),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: _isDownloading ? null
                                    : () => _downloadFile(notice.originalFilename ?? notice.filename ?? '', notice.filename),
                                icon: _isDownloading
                                    ? const SizedBox(width: 18, height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(_blue)))
                                    : const Icon(Icons.download_rounded, color: _blue),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // 내용
                      const Text('내용',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: -0.2)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Text(notice.content,
                            style: const TextStyle(fontSize: 15, height: 1.7, color: _label, letterSpacing: -0.2)),
                      ),
                      const SizedBox(height: 20),

                      // 하단 버튼
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _secondary,
                                side: const BorderSide(color: Color(0xFFE5E5EA)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('목록으로', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _shareNotice(notice),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _blue, elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('공유하기',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
    );
  }
}
