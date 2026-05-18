import 'package:flutter/material.dart';
import '../../widgets/app_bar.dart';
import '../../../services/resume_service.dart';

class TalentSearchPage extends StatefulWidget {
  const TalentSearchPage({super.key});

  @override
  State<TalentSearchPage> createState() => _TalentSearchPageState();
}

class _TalentSearchPageState extends State<TalentSearchPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _green = Color(0xFF0FA958);

  final ResumeService _resumeService = ResumeService();
  final _locationController = TextEditingController();

  String? _selectedJobType;
  List<Map<String, dynamic>> _allResumes = [];
  List<Map<String, dynamic>> _filteredResumes = [];
  bool _isLoading = true;
  String? _error;

  final List<String> _jobTypes = [
    '전체', '백엔드 개발', '프론트엔드', 'iOS 개발', '안드로이드 개발',
    '풀스택', 'UI/UX 디자인', '데이터 분석/ML', '마케팅', '기획/PM',
  ];

  @override
  void initState() {
    super.initState();
    _loadResumes();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadResumes() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final resumes = await _resumeService.getAllResumes();
      final active = resumes.where((r) => r['isActive'] != false).toList();
      setState(() {
        _allResumes = active;
        _filteredResumes = active;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _search() {
    final loc = _locationController.text.trim();
    setState(() {
      _filteredResumes = _allResumes.where((r) {
        final hopeLocation = (r['hopeLocation'] as String? ?? '');
        final hopeJobtype  = (r['hopeJobtype']  as String? ?? '');
        final matchLoc = loc.isEmpty || hopeLocation.contains(loc);
        final matchJob = _selectedJobType == null || _selectedJobType == '전체'
            || hopeJobtype.contains(_selectedJobType!);
        return matchLoc && matchJob;
      }).toList();
    });
  }

  void _navigateToDetail(Map<String, dynamic> resume) {
    final rawId = resume['resumeNo'];
    if (rawId == null) return;
    final resumeId = rawId is int ? rawId : int.tryParse(rawId.toString());
    if (resumeId == null) return;
    Navigator.pushNamed(context, '/resume-detail', arguments: resumeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(title: '인재정보 검색'),
      body: Column(
        children: [
            const SizedBox(height: 10),

            // 검색 카드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _locationController,
                      style: const TextStyle(fontSize: 15, color: _label),
                      onSubmitted: (_) => _search(),
                      decoration: InputDecoration(
                        hintText: '희망 지역 입력 (예: 서울, 경기)',
                        hintStyle: const TextStyle(color: _secondary, fontSize: 14),
                        prefixIcon: const Icon(Icons.location_on_outlined, color: _secondary, size: 20),
                        filled: true,
                        fillColor: _bg,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _blue, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('직무', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _secondary)),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _jobTypes.map((job) {
                          final selected = _selectedJobType == job ||
                              (_selectedJobType == null && job == '전체');
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedJobType = job == '전체' ? null : job);
                                _search();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: selected ? _blue : _bg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(job,
                                    style: TextStyle(
                                        fontSize: 13, fontWeight: FontWeight.w500,
                                        color: selected ? Colors.white : _secondary)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _search,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _blue, elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('검색',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 결과 수
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text('검색 결과',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: -0.2)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: _blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Text('${_filteredResumes.length}명',
                        style: const TextStyle(fontSize: 12, color: _blue, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 목록
            Expanded(child: _buildBody()),
          ],
        ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('인재 정보를 불러올 수 없습니다',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600])),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadResumes,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('다시 시도'),
              style: OutlinedButton.styleFrom(foregroundColor: _blue, side: const BorderSide(color: _blue)),
            ),
          ],
        ),
      );
    }

    if (_filteredResumes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.search_off_rounded, size: 36, color: _secondary),
            ),
            const SizedBox(height: 16),
            const Text('검색 결과가 없습니다',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _label)),
            const SizedBox(height: 6),
            const Text('다른 조건으로 검색해보세요',
                style: TextStyle(fontSize: 14, color: _secondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadResumes,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: _filteredResumes.length,
        itemBuilder: (context, i) => _buildCard(_filteredResumes[i]),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> resume) {
    final title       = (resume['title']       as String? ?? '이력서');
    final hopeJobtype = (resume['hopeJobtype'] as String? ?? '');
    final hopeLocation= (resume['hopeLocation']as String? ?? '');
    final workType    = (resume['workType']    as String? ?? '');
    final summary     = (resume['content']     as String? ?? '').replaceAll('\n', ' ');
    final initial     = title.isNotEmpty ? title[0] : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _navigateToDetail(resume),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // 아이콘
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(initial,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _blue)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _label, letterSpacing: -0.3),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          if (hopeJobtype.isNotEmpty)
                            _tag(Icons.work_outline_rounded, hopeJobtype, _blue),
                          if (hopeLocation.isNotEmpty) ...[
                            const SizedBox(width: 5),
                            _tag(Icons.location_on_outlined, hopeLocation, _secondary),
                          ],
                          if (workType.isNotEmpty) ...[
                            const SizedBox(width: 5),
                            _tag(Icons.schedule_outlined, workType, _green),
                          ],
                        ],
                      ),
                      if (summary.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(summary,
                            style: const TextStyle(fontSize: 12, color: _secondary),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFE5E5EA)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
