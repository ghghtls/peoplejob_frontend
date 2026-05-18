import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/job_service.dart';
import '../../widgets/app_bar.dart';

class JobListPage extends StatefulWidget {
  const JobListPage({super.key});

  @override
  State<JobListPage> createState() => _JobListPageState();
}

String _formatSalary(String? s) {
  if (s == null || s.isEmpty) return '';
  final digits = s.replaceAll(',', '');
  final n = int.tryParse(digits);
  return n != null ? '${NumberFormat('#,###').format(n)}만원' : s;
}

class _JobListPageState extends State<JobListPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);

  final JobService _jobService = JobService();
  final _searchController = TextEditingController();

  List<dynamic> _jobs = [];
  List<dynamic> _filteredJobs = [];
  bool _isLoading = true;
  String _searchKeyword = '';
  String _selectedJobType = '전체';
  String _selectedLocation = '전체';

  final List<String> _jobTypes = ['전체', '정규직', '계약직', '인턴', '프리랜서', '파트타임'];
  final List<String> _locations = [
    '전체', '서울', '경기', '인천', '부산', '대구', '대전', '광주', '울산', '세종',
    '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주',
  ];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);
    try {
      final jobs = await _jobService.getAllJobs();
      setState(() {
        _jobs = jobs;
        _filteredJobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _filterJobs() {
    setState(() {
      _filteredJobs = _jobs.where((job) {
        final matchesKeyword = _searchKeyword.isEmpty ||
            job['title'].toString().toLowerCase().contains(_searchKeyword.toLowerCase()) ||
            job['content'].toString().toLowerCase().contains(_searchKeyword.toLowerCase());
        final matchesJobType = _selectedJobType == '전체' || job['jobType'] == _selectedJobType;
        final matchesLocation = _selectedLocation == '전체' || job['location'] == _selectedLocation;
        return matchesKeyword && matchesJobType && matchesLocation;
      }).toList();
    });
  }

  bool _isDeadlinePassed(String? deadlineStr) {
    if (deadlineStr == null) return false;
    try {
      return DateTime.parse(deadlineStr).isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  int _daysLeft(String? deadlineStr) {
    if (deadlineStr == null) return -1;
    try {
      final deadline = DateTime.parse(deadlineStr);
      return deadline.difference(DateTime.now()).inDays;
    } catch (e) {
      return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '채용공고',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: _loadJobs,
            icon: const Icon(Icons.refresh_rounded, color: _secondary),
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
          _buildSearchBar(),
          _buildFilterChips(),
          _buildResultCount(),
          Expanded(child: _buildJobList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 15, color: _label),
          decoration: InputDecoration(
            hintText: '채용공고, 회사명으로 검색',
            hintStyle: const TextStyle(color: _secondary, fontSize: 15),
            prefixIcon: const Icon(Icons.search_rounded, color: _secondary, size: 20),
            suffixIcon: _searchKeyword.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.cancel_rounded, color: _secondary, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _searchKeyword = '';
                      _filterJobs();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onChanged: (value) {
            _searchKeyword = value;
            _filterJobs();
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Column(
      children: [
        const SizedBox(height: 12),
        _chipRow(
          label: '고용형태',
          items: _jobTypes,
          selected: _selectedJobType,
          onSelected: (v) {
            setState(() => _selectedJobType = v);
            _filterJobs();
          },
        ),
        const SizedBox(height: 8),
        _chipRow(
          label: '지역',
          items: _locations,
          selected: _selectedLocation,
          onSelected: (v) {
            setState(() => _selectedLocation = v);
            _filterJobs();
          },
        ),
      ],
    );
  }

  Widget _chipRow({
    required String label,
    required List<String> items,
    required String selected,
    required void Function(String) onSelected,
  }) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item == selected;
          return GestureDetector(
            onTap: () => onSelected(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? _blue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isSelected ? 0.0 : 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : _secondary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultCount() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Text(
            '${_filteredJobs.length}개',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _blue,
              letterSpacing: -0.3,
            ),
          ),
          const Text(
            '의 채용공고',
            style: TextStyle(fontSize: 15, color: _secondary, letterSpacing: -0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildJobList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5),
      );
    }

    if (_filteredJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.work_off_rounded, size: 36, color: _secondary),
            ),
            const SizedBox(height: 16),
            const Text(
              '검색 결과가 없습니다',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _label),
            ),
            const SizedBox(height: 6),
            const Text(
              '다른 키워드나 필터를 사용해보세요',
              style: TextStyle(fontSize: 14, color: _secondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      color: _blue,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _filteredJobs.length,
        itemBuilder: (context, index) => _buildJobCard(_filteredJobs[index]),
      ),
    );
  }

  Widget _buildJobCard(dynamic job) {
    final isExpired    = _isDeadlinePassed(job['deadline']);
    final days         = _daysLeft(job['deadline']);
    final isAdvertised = job['isAdvertised'] == true;
    final title        = (job['title'] ?? '').toString();
    final company      = (job['company'] ?? title).toString();
    final letter       = company.isNotEmpty ? company[0].toUpperCase() : 'J';

    // Avatar gradient colors based on letter
    const avatarColors = [
      [Color(0xFF0B5FFF), Color(0xFF4DA3FF)],
      [Color(0xFF34C759), Color(0xFF30D158)],
      [Color(0xFFFF9500), Color(0xFFFFCC00)],
      [Color(0xFFAF52DE), Color(0xFFBF5AF2)],
      [Color(0xFFFF2D55), Color(0xFFFF375F)],
      [Color(0xFF5AC8FA), Color(0xFF32ADE6)],
    ];
    final colorPair = avatarColors[letter.codeUnitAt(0) % avatarColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isAdvertised ? Border.all(color: const Color(0xFFFF9500), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: isAdvertised
                ? const Color(0xFFFF9500).withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            final jobNo = job['jobNo'];
            if (jobNo != null) {
              Navigator.pushNamed(
                context,
                '/job-detail',
                arguments: jobNo is int ? jobNo : int.tryParse(jobNo.toString()),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 그라디언트 이니셜 아바타
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: colorPair,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          letter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (isAdvertised)
                      Positioned(
                        top: -5,
                        right: -5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9500),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'AD',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                // 공고 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isExpired ? _secondary : _label,
                                letterSpacing: -0.3,
                                decoration: isExpired ? TextDecoration.lineThrough : null,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // D-day / 마감 배지
                          if (isExpired)
                            _badge('마감', _red.withValues(alpha: 0.12), _red)
                          else if (days >= 0 && days <= 7)
                            _badge('D-$days', const Color(0xFFFF9500).withValues(alpha: 0.12), const Color(0xFFFF9500)),
                        ],
                      ),
                      if (company.isNotEmpty && company != title) ...[
                        const SizedBox(height: 3),
                        Text(
                          company,
                          style: const TextStyle(fontSize: 12, color: _secondary, letterSpacing: -0.2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if ((job['jobType'] ?? '').toString().isNotEmpty)
                            _tag(Icons.work_outline_rounded, job['jobType']),
                          if ((job['location'] ?? '').toString().isNotEmpty)
                            _tag(Icons.location_on_outlined, job['location']),
                          if ((job['salary'] ?? '').toString().isNotEmpty)
                            _salaryTag(_formatSalary(job['salary']?.toString())),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D1D6), size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg, letterSpacing: -0.1)),
    );
  }

  Widget _tag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: _secondary),
          const SizedBox(width: 3),
          Text(text, style: const TextStyle(fontSize: 11, color: _secondary, letterSpacing: -0.1)),
        ],
      ),
    );
  }

  Widget _salaryTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0B5FFF), Color(0xFF4DA3FF)]),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.1),
      ),
    );
  }
}
