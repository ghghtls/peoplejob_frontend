import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../services/scrap_service.dart';
import '../../../../services/auth_service.dart';

class ScrapListPage extends StatefulWidget {
  const ScrapListPage({super.key});

  @override
  State<ScrapListPage> createState() => _ScrapListPageState();
}

class _ScrapListPageState extends State<ScrapListPage> {
  final ScrapService _scrapService = ScrapService();
  final AuthService _authService = AuthService();
  List<dynamic> _scraps = [];
  List<dynamic> _filteredScraps = [];
  bool _isLoading = true;
  String _searchKeyword = '';
  String _selectedJobType = '전체';
  String _selectedLocation = '전체';

  final List<String> _jobTypes = ['전체', '정규직', '계약직', '인턴', '프리랜서', '파트타임'];
  final List<String> _locations = [
    '전체',
    '서울',
    '경기',
    '인천',
    '부산',
    '대구',
    '대전',
    '광주',
    '울산',
    '세종',
    '강원',
    '충북',
    '충남',
    '전북',
    '전남',
    '경북',
    '경남',
    '제주',
  ];

  @override
  void initState() {
    super.initState();
    _loadScraps();
  }

  Future<void> _loadScraps() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final scraps = await _scrapService.getMyScrapList();
      setState(() {
        _scraps = scraps;
        _filteredScraps = scraps;
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

  void _filterScraps() {
    setState(() {
      _filteredScraps =
          _scraps.where((scrap) {
            final job = scrap['jobopening'];
            final matchesKeyword =
                _searchKeyword.isEmpty ||
                job['title'].toString().toLowerCase().contains(
                  _searchKeyword.toLowerCase(),
                ) ||
                job['content'].toString().toLowerCase().contains(
                  _searchKeyword.toLowerCase(),
                );

            final matchesJobType =
                _selectedJobType == '전체' || job['jobtype'] == _selectedJobType;
            final matchesLocation =
                _selectedLocation == '전체' ||
                job['location'] == _selectedLocation;

            return matchesKeyword && matchesJobType && matchesLocation;
          }).toList();
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy.MM.dd').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  bool _isDeadlinePassed(String? deadlineStr) {
    if (deadlineStr == null) return false;
    try {
      final deadline = DateTime.parse(deadlineStr);
      return deadline.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  int _getDaysRemaining(String? deadlineStr) {
    if (deadlineStr == null) return 0;
    try {
      final deadline = DateTime.parse(deadlineStr);
      final now = DateTime.now();
      return deadline.difference(now).inDays;
    } catch (e) {
      return 0;
    }
  }

  void _removeScrap(int scrapNo, int jobOpeningNo, String jobTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('스크랩 제거'),
          content: Text('$jobTitle을(를) 스크랩에서 제거하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _scrapService.deleteScrapById(scrapNo);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('스크랩에서 제거되었습니다'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadScraps();
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
              child: const Text('제거'),
            ),
          ],
        );
      },
    );
  }

  void _viewJobDetail(int jobOpeningNo) {
    Navigator.pushNamed(context, '/job-detail', arguments: jobOpeningNo);
  }

  void _clearAllScraps() {
    if (_scraps.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('전체 스크랩 제거'),
          content: Text(
            '모든 스크랩(${_scraps.length}개)을 제거하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = true;
                });

                try {
                  // 모든 스크랩을 하나씩 삭제
                  for (var scrap in _scraps) {
                    await _scrapService.deleteScrapById(scrap['scrapNo']);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('모든 스크랩이 제거되었습니다'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadScraps();
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('전체 제거'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스크랩 목록'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        actions: [
          if (_scraps.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear_all') {
                  _clearAllScraps();
                }
              },
              itemBuilder:
                  (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'clear_all',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all, color: Colors.red),
                          SizedBox(width: 8),
                          Text('전체 제거'),
                        ],
                      ),
                    ),
                  ],
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadScraps),
        ],
      ),
      body: Column(
        children: [
          // 검색 및 필터 영역
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.orange[50],
            child: Column(
              children: [
                // 검색창
                TextField(
                  decoration: InputDecoration(
                    hintText: '스크랩한 채용공고를 검색하세요',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    _searchKeyword = value;
                    _filterScraps();
                  },
                ),
                const SizedBox(height: 12),
                // 필터 영역
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedJobType,
                        decoration: InputDecoration(
                          labelText: '고용형태',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items:
                            _jobTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedJobType = value!;
                          });
                          _filterScraps();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedLocation,
                        decoration: InputDecoration(
                          labelText: '지역',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items:
                            _locations.map((location) {
                              return DropdownMenuItem(
                                value: location,
                                child: Text(location),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLocation = value!;
                          });
                          _filterScraps();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 결과 개수 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.bookmark, color: Colors.orange[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  '총 ${_filteredScraps.length}개의 스크랩',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
          ),
          // 스크랩 목록
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredScraps.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _scraps.isEmpty ? '스크랩한 채용공고가 없습니다' : '검색 결과가 없습니다',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _scraps.isEmpty
                                ? '관심있는 채용공고를 스크랩해보세요'
                                : '다른 키워드로 검색해보세요',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          if (_scraps.isEmpty) ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/job-list');
                              },
                              icon: const Icon(Icons.search),
                              label: const Text('채용공고 보기'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[600],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadScraps,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredScraps.length,
                        itemBuilder: (context, index) {
                          final scrap = _filteredScraps[index];
                          final job = scrap['jobopening'];
                          final isExpired = _isDeadlinePassed(job['deadline']);
                          final daysRemaining = _getDaysRemaining(
                            job['deadline'],
                          );

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _viewJobDetail(job['jobopeningNo']),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 제목과 스크랩 제거 버튼
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            job['title'] ?? '',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  isExpired
                                                      ? Colors.grey
                                                      : Colors.black87,
                                              decoration:
                                                  isExpired
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : null,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isExpired)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red[100],
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  '마감',
                                                  style: TextStyle(
                                                    color: Colors.red[700],
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              )
                                            else
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      daysRemaining <= 3
                                                          ? Colors.red[100]
                                                          : Colors.green[100],
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  daysRemaining <= 0
                                                      ? '오늘 마감'
                                                      : 'D-$daysRemaining',
                                                  style: TextStyle(
                                                    color:
                                                        daysRemaining <= 3
                                                            ? Colors.red[700]
                                                            : Colors.green[700],
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.bookmark_remove,
                                                color: Colors.red,
                                              ),
                                              onPressed:
                                                  () => _removeScrap(
                                                    scrap['scrapNo'],
                                                    job['jobopeningNo'],
                                                    job['title'] ?? '채용공고',
                                                  ),
                                              tooltip: '스크랩 제거',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // 기본 정보
                                    Row(
                                      children: [
                                        _buildInfoChip(
                                          Icons.work,
                                          job['jobtype'] ?? '',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildInfoChip(
                                          Icons.location_on,
                                          job['location'] ?? '',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _buildInfoChip(
                                          Icons.school,
                                          job['education'] ?? '',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildInfoChip(
                                          Icons.timeline,
                                          job['career'] ?? '',
                                        ),
                                      ],
                                    ),
                                    if (job['salary'] != null &&
                                        job['salary']
                                            .toString()
                                            .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      _buildInfoChip(
                                        Icons.attach_money,
                                        job['salary'],
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    // 날짜 정보
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '스크랩일: ${_formatDate(scrap['regdate'])}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          '마감일: ${_formatDate(job['deadline'])}',
                                          style: TextStyle(
                                            color:
                                                isExpired
                                                    ? Colors.red
                                                    : Colors.grey[600],
                                            fontSize: 12,
                                            fontWeight:
                                                isExpired
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
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
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.orange[700]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
