import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/board_service.dart';
import '../../../services/auth_service.dart';

class BoardDetailPage extends StatefulWidget {
  final int boardNo;

  const BoardDetailPage({super.key, required this.boardNo});

  @override
  State<BoardDetailPage> createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  final BoardService _boardService = BoardService();
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _boardDetail;
  bool _isLoading = true;
  String? _currentUser;
  bool _isMyBoard = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadBoardDetail();
  }

  Future<void> _loadCurrentUser() async {
    final userInfo = await _authService.getUserInfo();
    setState(() {
      _currentUser = userInfo['name'] ?? userInfo['userid'];
    });
  }

  Future<void> _loadBoardDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final boardDetail = await _boardService.getBoardDetail(widget.boardNo);
      setState(() {
        _boardDetail = boardDetail;
        _isMyBoard =
            _currentUser != null && boardDetail['writer'] == _currentUser;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy년 MM월 dd일 HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case '공지사항':
        return Colors.red;
      case '자유게시판':
        return Colors.blue;
      case '질문게시판':
        return Colors.orange;
      case '취업정보':
        return Colors.green;
      case '후기':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _editBoard() {
    Navigator.pushNamed(context, '/board-edit', arguments: widget.boardNo);
  }

  void _deleteBoard() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('게시글 삭제'),
          content: const Text('정말로 이 게시글을 삭제하시겠습니까?\n삭제된 게시글은 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _boardService.deleteBoard(widget.boardNo);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('게시글이 삭제되었습니다'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _shareBoard() {
    // TODO: 공유 기능 구현
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('공유 기능은 준비 중입니다')));
  }

  void _reportBoard() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('게시글 신고'),
          content: const Text('이 게시글을 신고하시겠습니까?\n신고 사유를 확인 후 조치하겠습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: 신고 기능 구현
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('신고가 접수되었습니다'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('신고'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('게시글'),
          backgroundColor: Colors.indigo[600],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_boardDetail == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('게시글'),
          backgroundColor: Colors.indigo[600],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('게시글을 찾을 수 없습니다')),
      );
    }

    final isNotice = _boardDetail!['category'] == '공지사항';

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        actions: [
          if (_isMyBoard) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editBoard,
              tooltip: '수정',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteBoard,
              tooltip: '삭제',
            ),
          ] else ...[
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'share':
                    _shareBoard();
                    break;
                  case 'report':
                    _reportBoard();
                    break;
                }
              },
              itemBuilder:
                  (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share),
                          SizedBox(width: 8),
                          Text('공유하기'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.report, color: Colors.red),
                          SizedBox(width: 8),
                          Text('신고하기'),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 헤더 영역
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isNotice ? Colors.red[50] : Colors.indigo[50],
                border:
                    isNotice
                        ? Border(
                          bottom: BorderSide(color: Colors.red[200]!, width: 2),
                        )
                        : Border(
                          bottom: BorderSide(
                            color: Colors.indigo[200]!,
                            width: 1,
                          ),
                        ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리와 상태
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(_boardDetail!['category']),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _boardDetail!['category'] ?? '일반',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_isMyBoard)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '내가 쓴 글',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 제목
                  Text(
                    _boardDetail!['title'] ?? '',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isNotice ? Colors.red[800] : Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 작성자 정보
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.indigo[100],
                        child: Text(
                          (_boardDetail!['writer'] ?? 'U')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: TextStyle(
                            color: Colors.indigo[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _boardDetail!['writer'] ?? '익명',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _formatDate(_boardDetail!['regdate']),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 조회수
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_boardDetail!['viewCount'] ?? 0}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 본문 내용
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 첨부파일
                  if (_boardDetail!['originalFilename'] != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.attach_file, color: Colors.blue[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '첨부파일',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _boardDetail!['originalFilename'],
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              // TODO: 파일 다운로드 구현
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('파일 다운로드 기능은 준비 중입니다'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.download, size: 16),
                            label: const Text('다운로드'),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 본문 내용
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      _boardDetail!['content'] ?? '내용이 없습니다.',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 댓글 섹션 (향후 구현)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '댓글 기능은 준비 중입니다',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 하단 버튼
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // 목록으로 버튼
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.list),
                  label: const Text('목록으로'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.indigo[600],
                    side: BorderSide(color: Colors.indigo[600]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(0, 50),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 글쓰기 버튼
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/board-write');
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('글쓰기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(0, 50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
