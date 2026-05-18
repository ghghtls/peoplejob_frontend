import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/board_service.dart';
import '../../../services/auth_service.dart';
import '../../widgets/app_bar.dart';

class BoardDetailPage extends StatefulWidget {
  final int boardNo;
  const BoardDetailPage({super.key, required this.boardNo});

  @override
  State<BoardDetailPage> createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);

  final BoardService _boardService = BoardService();
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _board;
  bool _isLoading = true;
  String? _currentUser;
  bool _isMyBoard = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadBoard();
  }

  Future<void> _loadCurrentUser() async {
    final info = await _authService.getUserInfo();
    setState(() => _currentUser = info['name'] ?? info['userid']);
  }

  Future<void> _loadBoard() async {
    setState(() => _isLoading = true);
    try {
      final board = await _boardService.getBoardDetail(widget.boardNo);
      setState(() {
        _board = board;
        _isMyBoard = _currentUser != null && board['writer'] == _currentUser;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  String _formatDate(String? d) {
    if (d == null) return '';
    try {
      return DateFormat('yyyy년 MM월 dd일 HH:mm').format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }

  Color _categoryColor(String? cat) {
    switch (cat) {
      case '공지사항': return _red;
      case '자유게시판': return _blue;
      case '질문게시판': return const Color(0xFFFF9500);
      case '취업정보': return const Color(0xFF34C759);
      case '후기': return const Color(0xFF5856D6);
      default: return _secondary;
    }
  }

  void _deleteBoard() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('게시글 삭제', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('이 게시글을 삭제하시겠습니까?\n삭제된 게시글은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소', style: TextStyle(color: _secondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await _boardService.deleteBoard(widget.boardNo);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('게시글이 삭제되었습니다'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('삭제', style: TextStyle(color: _red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: buildCommonAppBar(title: '게시글'),
        body: const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5)),
      );
    }

    if (_board == null) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: buildCommonAppBar(title: '게시글'),
        body: const Center(child: Text('게시글을 찾을 수 없습니다', style: TextStyle(color: _secondary))),
      );
    }

    final isNotice = _board!['category'] == '공지사항';
    final catColor = _categoryColor(_board!['category']);
    final writerInitial = (_board!['writer'] ?? 'U').substring(0, 1).toUpperCase();

    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '게시글',
        actions: [
          if (_isMyBoard) ...[
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/board-edit', arguments: widget.boardNo),
              icon: const Icon(Icons.edit_outlined, color: _blue, size: 20),
            ),
            IconButton(
              onPressed: _deleteBoard,
              icon: const Icon(Icons.delete_outline_rounded, color: _red, size: 20),
            ),
          ] else ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded, color: _secondary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (v) {
                if (v == 'report') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('신고가 접수되었습니다'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'report',
                  child: Row(children: [
                    Icon(Icons.report_outlined, color: _red, size: 18),
                    SizedBox(width: 8),
                    Text('신고하기'),
                  ]),
                ),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // 본문 스크롤
          Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카테고리 배지
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_board!['category'] ?? '일반',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: catColor)),
                    ),
                    const SizedBox(height: 12),

                    // 제목
                    Text(_board!['title'] ?? '',
                        style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w700,
                          color: isNotice ? _red : _label,
                          letterSpacing: -0.5, height: 1.3,
                        )),
                    const SizedBox(height: 16),

                    // 작성자 정보
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: _blue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(writerInitial,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _blue)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_board!['writer'] ?? '익명',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _label, letterSpacing: -0.3)),
                                Text(_formatDate(_board!['regdate']),
                                    style: const TextStyle(fontSize: 12, color: _secondary, letterSpacing: -0.2)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.visibility_outlined, size: 14, color: _secondary),
                                const SizedBox(width: 4),
                                Text('${_board!['viewCount'] ?? 0}',
                                    style: const TextStyle(fontSize: 13, color: _secondary, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 첨부파일
                    if (_board!['originalFilename'] != null) ...[
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
                                  const Text('첨부파일', style: TextStyle(fontSize: 11, color: _secondary, fontWeight: FontWeight.w500)),
                                  Text(_board!['originalFilename'],
                                      style: const TextStyle(fontSize: 14, color: _blue, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final fileUrl = _board!['filename'] as String?;
                                if (fileUrl == null) return;
                                final uri = Uri.parse(fileUrl);
                                final messenger = ScaffoldMessenger.of(context);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else {
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('파일을 열 수 없습니다')),
                                  );
                                }
                              },
                              child: const Text('다운로드', style: TextStyle(color: _blue, fontWeight: FontWeight.w600, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 본문
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Text(_board!['content'] ?? '내용이 없습니다.',
                          style: const TextStyle(fontSize: 16, height: 1.7, color: _label, letterSpacing: -0.2)),
                    ),
                    const SizedBox(height: 24),

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
                            onPressed: () => Navigator.pushNamed(context, '/board-write'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('글쓰기',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}
