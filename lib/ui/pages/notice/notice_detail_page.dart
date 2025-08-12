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

class NoticeDetailPage extends ConsumerStatefulWidget {
  final int noticeId;

  const NoticeDetailPage({super.key, required this.noticeId});

  @override
  ConsumerState<NoticeDetailPage> createState() => _NoticeDetailPageState();
}

class _NoticeDetailPageState extends ConsumerState<NoticeDetailPage> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNoticeDetail();
    });
  }

  Future<void> _loadNoticeDetail() async {
    await ref.read(noticeProvider.notifier).loadNoticeDetail(widget.noticeId);
  }

  // 파일 다운로드 기능
  Future<void> _downloadFile(String fileName, String? fileUrl) async {
    if (fileUrl == null || fileUrl.isEmpty) {
      _showSnackBar('다운로드할 파일이 없습니다.');
      return;
    }

    try {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
      });

      // 권한 확인 및 요청
      if (Platform.isAndroid) {
        final permission = await Permission.storage.request();
        if (!permission.isGranted) {
          _showSnackBar('저장소 권한이 필요합니다.');
          setState(() => _isDownloading = false);
          return;
        }
      }

      // 다운로드 디렉토리 가져오기
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        // Downloads 폴더로 변경
        final downloadPath = '/storage/emulated/0/Download';
        directory = Directory(downloadPath);
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        _showSnackBar('다운로드 폴더를 찾을 수 없습니다.');
        setState(() => _isDownloading = false);
        return;
      }

      // 파일 확장자 확인
      final fileExtension = fileName.split('.').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final downloadFileName =
          '${fileName.split('.').first}_$timestamp.$fileExtension';
      final filePath = '${directory.path}/$downloadFileName';

      // Dio를 사용한 파일 다운로드
      final dio = Dio();

      await dio.download(
        fileUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
        options: Options(headers: {'Accept': '*/*'}),
      );

      setState(() => _isDownloading = false);

      // 성공 메시지와 함께 파일 열기 옵션 제공
      _showDownloadCompleteDialog(filePath, downloadFileName);
    } catch (e) {
      setState(() => _isDownloading = false);
      print('파일 다운로드 실패: $e');
      _showSnackBar('파일 다운로드에 실패했습니다: ${e.toString()}');
    }
  }

  // 다운로드 완료 다이얼로그
  void _showDownloadCompleteDialog(String filePath, String fileName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('다운로드 완료'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('파일이 성공적으로 다운로드되었습니다.'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(fileName, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _openFile(filePath);
                },
                child: const Text('파일 열기'),
              ),
            ],
          ),
    );
  }

  // 파일 열기
  Future<void> _openFile(String filePath) async {
    try {
      final uri = Uri.file(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnackBar('파일을 열 수 있는 앱이 없습니다.');
      }
    } catch (e) {
      print('파일 열기 실패: $e');
      _showSnackBar('파일 열기에 실패했습니다.');
    }
  }

  // 공유 기능
  Future<void> _shareNotice(Notice notice) async {
    try {
      final shareText = '''
📢 ${notice.title}

${notice.content}

작성자: ${notice.writer}
작성일: ${notice.formattedDate}
      ''';

      // 공유할 URL 생성 (딥링크 또는 웹 링크)
      final shareUrl = 'https://peoplejob.com/notice/${notice.noticeNo}';

      // URL 런처를 사용한 공유
      final Uri shareUri = Uri(
        scheme: 'mailto',
        queryParameters: {
          'subject': '[피플잡] ${notice.title}',
          'body': '$shareText\n\n링크: $shareUrl',
        },
      );

      if (await canLaunchUrl(shareUri)) {
        await launchUrl(shareUri);
      } else {
        // 대체 공유 방법
        _showShareDialog(shareText, shareUrl);
      }
    } catch (e) {
      print('공유 실패: $e');
      _showSnackBar('공유에 실패했습니다.');
    }
  }

  // 공유 다이얼로그
  void _showShareDialog(String shareText, String shareUrl) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('공유하기'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    shareText,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    shareUrl,
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _copyToClipboard(shareText + '\n\n링크: ' + shareUrl);
                },
                child: const Text('복사'),
              ),
            ],
          ),
    );
  }

  // 클립보드에 복사
  Future<void> _copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      _showSnackBar('클립보드에 복사되었습니다.');
    } catch (e) {
      _showSnackBar('복사에 실패했습니다.');
    }
  }

  // 스낵바 표시
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final noticeState = ref.watch(noticeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (noticeState.selectedNotice != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareNotice(noticeState.selectedNotice!),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (noticeState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (noticeState.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    noticeState.errorMessage!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(noticeProvider.notifier).clearError();
                      _loadNoticeDetail();
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final notice = noticeState.selectedNotice;
          if (notice == null) {
            return const Center(child: Text('공지사항을 찾을 수 없습니다.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 공지사항 헤더
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          notice.isImportantNotice
                              ? [Colors.red.shade50, Colors.red.shade100]
                              : [Colors.blue.shade50, Colors.blue.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          notice.isImportantNotice
                              ? Colors.red.shade200
                              : Colors.blue.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 중요 공지 배지
                      if (notice.isImportantNotice)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.priority_high,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '중요',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // 제목
                      Text(
                        notice.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 메타 정보
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notice.writer,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notice.formattedDate,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.visibility,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${notice.viewCount ?? 0}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 첨부파일 (있는 경우)
                if (notice.hasAttachment) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.attach_file,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '첨부파일',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                notice.originalFilename ??
                                    notice.filename ??
                                    '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (_isDownloading) ...[
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: _downloadProgress,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '다운로드 중... ${(_downloadProgress * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed:
                              _isDownloading
                                  ? null
                                  : () => _downloadFile(
                                    notice.originalFilename ??
                                        notice.filename ??
                                        '',
                                    notice.filename,
                                  ),
                          icon:
                              _isDownloading
                                  ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue.shade600,
                                      ),
                                    ),
                                  )
                                  : Icon(
                                    Icons.download,
                                    color: Colors.blue.shade600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 공지사항 내용
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade100,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '내용',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        notice.content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 하단 액션 버튼
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.list),
                        label: const Text('목록으로'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _shareNotice(notice),
                        icon: const Icon(Icons.share),
                        label: const Text('공유하기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
