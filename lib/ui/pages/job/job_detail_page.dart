import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/job_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/apply_service.dart';
import '../../widgets/app_bar.dart';
import '../../../services/scrap_service.dart';
import '../../widgets/apply_dialog.dart';

class JobDetailPage extends StatefulWidget {
  final int jobId;
  const JobDetailPage({super.key, required this.jobId});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  static const Color _blue      = Color(0xFF0B5FFF);
  static const Color _label     = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg        = Color(0xFFF2F2F7);
  static const Color _separator = Color(0xFFD1D1D6);
  static const Color _red       = Color(0xFFE5342F);
  static const Color _green     = Color(0xFF0FA958);
  static const Color _orange    = Color(0xFFFF9500);

  final JobService _jobService = JobService();
  final AuthService _authService = AuthService();
  final ApplyService _applyService = ApplyService();
  final ScrapService _scrapService = ScrapService();

  Map<String, dynamic>? _jobDetail;
  bool _isLoading = true;
  bool _isScraped = false;
  bool _hasApplied = false;
  String? _userType;
  int? _currentUserNo;

  @override
  void initState() {
    super.initState();
    _loadJobDetail();
    _loadUserRole();
  }

  Future<void> _loadJobDetail() async {
    setState(() => _isLoading = true);
    try {
      final jobDetail = await _jobService.getJobDetail(widget.jobId);
      if (mounted) {
        setState(() { _jobDetail = jobDetail; _isLoading = false; });
        if (_userType == 'user') {
          _checkApplicationStatus();
          _checkScrapStatus();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: _red,
              behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        );
      }
    }
  }

  Future<void> _loadUserRole() async {
    final info = await _authService.getUserInfo();
    if (mounted) {
      setState(() {
        _userType = info['userType'];
        _currentUserNo = int.tryParse(info['userNo'] ?? '');
      });
      if (_userType == 'user') {
        _checkApplicationStatus();
        _checkScrapStatus();
      }
    }
  }

  bool get _isJobOwner =>
      _currentUserNo != null &&
      _jobDetail != null &&
      _jobDetail!['userNo'] == _currentUserNo;

  Future<void> _checkApplicationStatus() async {
    try {
      final has = await _applyService.hasAppliedToJob(widget.jobId);
      if (mounted) setState(() => _hasApplied = has);
    } catch (_) {}
  }

  Future<void> _checkScrapStatus() async {
    try {
      final is_ = await _scrapService.isScraped(widget.jobId);
      if (mounted) setState(() => _isScraped = is_);
    } catch (_) {}
  }

  String _formatDate(String? d) {
    if (d == null) return '';
    try { return DateFormat('yyyy년 MM월 dd일').format(DateTime.parse(d)); }
    catch (_) { return d; }
  }

  bool _isDeadlinePassed(String? d) {
    if (d == null) return false;
    try { return DateTime.parse(d).isBefore(DateTime.now()); }
    catch (_) { return false; }
  }

  int _getDaysRemaining(String? d) {
    if (d == null) return 0;
    try { return DateTime.parse(d).difference(DateTime.now()).inDays; }
    catch (_) { return 0; }
  }

  String _formatSalary(String? s) {
    if (s == null || s.isEmpty) return '';
    final digits = s.replaceAll(',', '');
    final n = int.tryParse(digits);
    return n != null ? '${NumberFormat('#,###').format(n)}만원' : s;
  }

  Future<void> _toggleScrap() async {
    try {
      if (_isScraped) {
        await _scrapService.removeScrap(widget.jobId);
        if (mounted) {
          setState(() => _isScraped = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('스크랩에서 제거되었습니다'), backgroundColor: _orange,
            behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
      } else {
        await _scrapService.addScrap(widget.jobId);
        if (mounted) {
          setState(() => _isScraped = true);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('스크랩에 추가되었습니다'), backgroundColor: _green,
            behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: _red),
        );
      }
    }
  }

  Future<void> _showApplyDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ApplyDialog(jobOpeningNo: widget.jobId, jobTitle: _jobDetail!['title'] ?? '채용공고'),
    );
    if (result == true && mounted) setState(() => _hasApplied = true);
  }

  void _deleteJob() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('채용공고 삭제', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('정말로 이 채용공고를 삭제하시겠습니까?\n삭제된 공고는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: _secondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _jobService.deleteJob(widget.jobId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('채용공고가 삭제되었습니다'), backgroundColor: _green,
                    behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ));
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: _red),
                  );
                }
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
        appBar: AppBar(
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [const HomeButton()],
        ),
        body: const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5)),
      );
    }

    if (_jobDetail == null) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [const HomeButton()],
        ),
        body: const Center(
          child: Text('채용공고를 찾을 수 없습니다', style: TextStyle(color: _secondary)),
        ),
      );
    }

    final isExpired   = _isDeadlinePassed(_jobDetail!['deadline']);
    final daysLeft    = _getDaysRemaining(_jobDetail!['deadline']);
    final companyName = (_jobDetail!['company'] ?? _jobDetail!['title'] ?? '').toString();
    final letter      = companyName.isNotEmpty ? companyName[0].toUpperCase() : 'J';
    final showApplyBar = _userType == 'user' && !isExpired;
    final showCompanyBar = (_userType == 'company' || _userType == 'admin') && _isJobOwner;

    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: (showApplyBar || showCompanyBar)
          ? _buildBottomBar(isExpired, showCompanyBar)
          : null,
      body: CustomScrollView(
        slivers: [
          // ── 그라디언트 헤더 (스크롤 시 자연스럽게 사라짐) ────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: const Color(0xFF0B5FFF),
            surfaceTintColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: Colors.white),
            ),
            actions: [
              if ((_userType == 'company' || _userType == 'admin') && _isJobOwner) ...[
                _navIconBtn(Icons.people_outline_rounded, Colors.white, () =>
                    Navigator.pushNamed(context, '/job-applications', arguments: widget.jobId)),
                _navIconBtn(Icons.edit_outlined, Colors.white, () =>
                    Navigator.pushNamed(context, '/job-edit', arguments: widget.jobId)),
                _navIconBtn(Icons.delete_outline_rounded, const Color(0xFFFFCDD2), _deleteJob),
              ] else if (_userType == 'user') ...[
                _navIconBtn(
                  _isScraped ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  _isScraped ? _orange : Colors.white,
                  _toggleScrap,
                ),
              ],
              const HomeButton(),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // 그라디언트
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0B5FFF), Color(0xFF4DA3FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // 장식 원
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  // 이니셜 아바타 (중앙)
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A6FFF), Color(0xFF5AB3FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(11, 95, 255, 0.40),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          letter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 콘텐츠 ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildHeaderCard(isExpired, daysLeft),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSpecGrid(),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildContentCard(),
                ),
                if (_jobDetail!['originalFilename'] != null) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildAttachmentCard(),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 22, color: color),
      style: IconButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.all(8)),
    );
  }

  Widget _buildHeaderCard(bool isExpired, int daysLeft) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 배지 행
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (!isExpired)
                _badge(
                  daysLeft <= 0 ? 'D-Day' : 'D-$daysLeft',
                  daysLeft <= 3 ? _red : _green,
                )
              else
                _badge('모집 마감', _secondary),
              if (_userType == 'user' && _hasApplied)
                _badge('지원완료', _orange),
              if (_userType == 'user' && _isScraped)
                _badge('스크랩됨', const Color(0xFF5856D6)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _jobDetail!['title'] ?? '',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _label,
              letterSpacing: -0.5,
              height: 1.35,
            ),
          ),
          if ((_jobDetail!['company'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.apartment_rounded, size: 14, color: _secondary),
                const SizedBox(width: 4),
                Text(
                  _jobDetail!['company'],
                  style: const TextStyle(fontSize: 14, color: _secondary, letterSpacing: -0.2),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecGrid() {
    final salary   = _formatSalary(_jobDetail!['salary']?.toString());
    final location = _jobDetail!['location']?.toString() ?? '';
    final deadline = _formatDate(_jobDetail!['deadline']);
    final jobType  = _jobDetail!['jobType']?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _specCell(Icons.payments_outlined, '급여', salary.isEmpty ? '협의' : salary, _blue)),
                VerticalDivider(width: 1, color: _separator),
                Expanded(child: _specCell(Icons.location_on_outlined, '지역', location.isEmpty ? '미정' : location, const Color(0xFF34C759))),
              ],
            ),
          ),
          Divider(height: 1, color: _separator),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _specCell(Icons.event_rounded, '마감일', deadline.isEmpty ? '없음' : deadline, _orange)),
                VerticalDivider(width: 1, color: _separator),
                Expanded(child: _specCell(Icons.work_outline_rounded, '고용형태', jobType.isEmpty ? '미정' : jobType, const Color(0xFFAF52DE))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specCell(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _secondary, letterSpacing: -0.1)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _label, letterSpacing: -0.3),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard() {
    final extra = <Map<String, dynamic>>[
      if ((_jobDetail!['workType'] ?? '').toString().isNotEmpty)
        {'icon': Icons.schedule_rounded, 'label': '근무형태', 'value': _jobDetail!['workType']},
      if ((_jobDetail!['education'] ?? '').toString().isNotEmpty)
        {'icon': Icons.school_outlined, 'label': '학력요건', 'value': _jobDetail!['education']},
      if ((_jobDetail!['experience'] ?? '').toString().isNotEmpty)
        {'icon': Icons.timeline_rounded, 'label': '경력요건', 'value': _jobDetail!['experience']},
    ];

    final regdate  = _formatDate(_jobDetail!['regdate']);
    final deadline = _formatDate(_jobDetail!['deadline']);
    final content  = (_jobDetail!['content'] ?? '').toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (extra.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              children: extra.map((item) => _infoRow(item['icon'] as IconData, item['label'] as String, item['value']?.toString())).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // 모집 기간
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              _infoRow(Icons.calendar_today_rounded, '등록일', regdate),
              _infoRow(Icons.event_rounded, '마감일', deadline),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 상세 내용
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '상세 내용',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _label, letterSpacing: -0.3),
              ),
              const SizedBox(height: 12),
              Text(
                content.isEmpty ? '상세 내용이 없습니다.' : content,
                style: const TextStyle(fontSize: 15, height: 1.7, color: _label, letterSpacing: -0.2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentCard() {
    return Container(
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
                Text(_jobDetail!['originalFilename'],
                    style: const TextStyle(fontSize: 14, color: _blue, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isExpired, bool isCompany) {
    if (isCompany) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/job-applications', arguments: widget.jobId),
                icon: const Icon(Icons.people_outline_rounded, size: 18),
                label: const Text('지원자 보기'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _blue,
                  side: const BorderSide(color: _blue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/job-edit', arguments: widget.jobId),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('수정하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          // 스크랩 버튼
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              border: Border.all(color: _isScraped ? _orange : _separator),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              onPressed: _toggleScrap,
              icon: Icon(
                _isScraped ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: _isScraped ? _orange : _secondary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 지원하기 버튼
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _hasApplied ? null : _showApplyDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasApplied ? _secondary : _blue,
                  disabledBackgroundColor: _secondary.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  _hasApplied ? '지원완료' : '지원하기',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _infoRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _secondary),
          const SizedBox(width: 10),
          SizedBox(width: 72, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _secondary))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: _label))),
        ],
      ),
    );
  }
}
