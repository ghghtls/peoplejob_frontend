import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/job_service.dart';

class JobListPage extends StatefulWidget {
  const JobListPage({super.key});

  @override
  State<JobListPage> createState() => _JobListPageState();
}

class _JobListPageState extends State<JobListPage> {
  final JobService _jobService = JobService();
  List<dynamic> _jobs = [];
  List<dynamic> _filteredJobs = [];
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
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final jobs = await _jobService.getAllJobs();
      setState(() {
        _jobs = jobs;
        _filteredJobs = jobs;
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

  void _filterJobs() {
    setState(() {
      _filteredJobs =
          _jobs.where((job) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채용공고'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadJobs),
        ],
      ),
      body: Column(
        children: [
          // 검색 및 필터 영역
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // 검색창
                TextField(
                  decoration: InputDecoration(
                    hintText: '채용공고를 검색하세요',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    _searchKeyword = value;
                    _filterJobs();
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
                          _filterJobs();
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
                          _filterJobs();
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
                Text(
                  '총 ${_filteredJobs.length}개의 채용공고',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          // 채용공고 목록
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredJobs.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_off,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '검색 결과가 없습니다',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '다른 키워드로 검색해보세요',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadJobs,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredJobs.length,
                        itemBuilder: (context, index) {
                          final job = _filteredJobs[index];
                          final isExpired = _isDeadlinePassed(job['deadline']);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/job-detail',
                                  arguments: job['jobopeningNo'],
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 제목과 상태
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
                                        if (isExpired)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
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
                                          '등록일: ${_formatDate(job['regdate'])}',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/job-register');
        },
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.blue[700]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
