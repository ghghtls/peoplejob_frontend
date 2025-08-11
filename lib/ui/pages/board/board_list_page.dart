import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/board_service.dart';
import '../../../services/auth_service.dart';

class BoardListPage extends StatefulWidget {
  const BoardListPage({super.key});

  @override
  State<BoardListPage> createState() => _BoardListPageState();
}

class _BoardListPageState extends State<BoardListPage> {
  final BoardService _boardService = BoardService();
  final AuthService _authService = AuthService();
  List<dynamic> _boards = [];
  List<dynamic> _filteredBoards = [];
  bool _isLoading = true;
  String _searchKeyword = '';
  String _selectedCategory = '전체';
  String? _currentUser;

  final List<String> _categories = [
    '전체',
    '공지사항',
    '자유게시판',
    '질문게시판',
    '취업정보',
    '후기',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadBoards();
  }

  Future<void> _loadCurrentUser() async {
    final userInfo = await _authService.getUserInfo();
    setState(() {
      _currentUser = userInfo['name'] ?? userInfo['userid'];
    });
  }

  Future<void> _loadBoards() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<dynamic> boards;

      if (_selectedCategory == '전체') {
        boards = await _boardService.getAllBoards();
      } else {
        boards = await _boardService.getBoardsByCategory(_selectedCategory);
      }

      setState(() {
        _boards = boards;
        _filteredBoards = boards;
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

  void _filterBoards() {
    setState(() {
      _filteredBoards =
          _boards.where((board) {
            final matchesKeyword =
                _searchKeyword.isEmpty ||
                board['title'].toString().toLowerCase().contains(
                  _searchKeyword.toLowerCase(),
                ) ||
                board['content'].toString().toLowerCase().contains(
                  _searchKeyword.toLowerCase(),
                ) ||
                board['writer'].toString().toLowerCase().contains(
                  _searchKeyword.toLowerCase(),
                );

            return matchesKeyword;
          }).toList();
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return DateFormat('HH:mm').format(date);
      } else if (difference.inDays < 7) {
        return '${difference.inDays}일 전';
      } else {
        return DateFormat('MM.dd').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  void _viewBoardDetail(int boardNo) {
    Navigator.pushNamed(context, '/board-detail', arguments: boardNo);
  }

  void _writeBoard() {
    Navigator.pushNamed(context, '/board-write');
  }

  bool _isMyBoard(String writer) {
    return _currentUser != null && writer == _currentUser;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시판'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBoards),
        ],
      ),
      body: Column(
        children: [
          // 검색 및 카테고리 필터
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.indigo[50],
            child: Column(
              children: [
                // 검색창
                TextField(
                  decoration: InputDecoration(
                    hintText: '제목, 내용, 작성자로 검색',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  onChanged: (value) {
                    _searchKeyword = value;
                    _filterBoards();
                  },
                ),
                const SizedBox(height: 12),
                // 카테고리 필터
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                            _loadBoards();
                          },
                          selectedColor: Colors.indigo[100],
                          checkmarkColor: Colors.indigo[600],
                          labelStyle: TextStyle(
                            color:
                                isSelected
                                    ? Colors.indigo[600]
                                    : Colors.grey[700],
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 게시글 개수 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.article, color: Colors.indigo[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  '총 ${_filteredBoards.length}개의 게시글',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo[800],
                  ),
                ),
              ],
            ),
          ),

          // 게시글 목록
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredBoards.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _boards.isEmpty ? '아직 게시글이 없습니다' : '검색 결과가 없습니다',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _boards.isEmpty
                                ? '첫 번째 게시글을 작성해보세요'
                                : '다른 키워드로 검색해보세요',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          if (_boards.isEmpty) ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _writeBoard,
                              icon: const Icon(Icons.edit),
                              label: const Text('게시글 작성'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo[600],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadBoards,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredBoards.length,
                        itemBuilder: (context, index) {
                          final board = _filteredBoards[index];
                          final isMyBoard = _isMyBoard(board['writer'] ?? '');
                          final isNotice = board['category'] == '공지사항';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: isNotice ? 3 : 1,
                            color: isNotice ? Colors.red[50] : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side:
                                  isNotice
                                      ? BorderSide(
                                        color: Colors.red[200]!,
                                        width: 1,
                                      )
                                      : BorderSide.none,
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _viewBoardDetail(board['boardNo']),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 카테고리와 작성자 정보
                                    Row(
                                      children: [
                                        // 카테고리 배지
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getCategoryColor(
                                              board['category'],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            board['category'] ?? '일반',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // 내가 쓴 글 표시
                                        if (isMyBoard) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '내글',
                                              style: TextStyle(
                                                color: Colors.orange[700],
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        // 첨부파일 표시
                                        if (board['originalFilename'] !=
                                            null) ...[
                                          Icon(
                                            Icons.attach_file,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        const Spacer(),
                                        Text(
                                          _formatDate(board['regdate']),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // 제목
                                    Text(
                                      board['title'] ?? '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isNotice
                                                ? Colors.red[800]
                                                : Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),

                                    // 내용 미리보기
                                    if (board['content'] != null &&
                                        board['content'].toString().isNotEmpty)
                                      Text(
                                        board['content'].toString().replaceAll(
                                          '\n',
                                          ' ',
                                        ),
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    const SizedBox(height: 12),

                                    // 하단 정보
                                    Row(
                                      children: [
                                        // 작성자
                                        Icon(
                                          Icons.person,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          board['writer'] ?? '익명',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // 조회수
                                        Icon(
                                          Icons.visibility,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${board['viewCount'] ?? 0}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _writeBoard,
        backgroundColor: Colors.indigo[600],
        child: const Icon(Icons.edit, color: Colors.white),
        tooltip: '게시글 작성',
      ),
    );
  }
}
