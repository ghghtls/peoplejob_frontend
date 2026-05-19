import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../services/apply_service.dart';
import '../../../../services/auth_service.dart';
import '../../../widgets/app_bar.dart';

class ApplyListPage extends StatefulWidget {
  const ApplyListPage({super.key});

  @override
  State<ApplyListPage> createState() => _ApplyListPageState();
}

class _ApplyListPageState extends State<ApplyListPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);
  static const Color _green = Color(0xFF0FA958);

  final ApplyService _applyService = ApplyService();
  final AuthService _authService = AuthService();
  List<dynamic> _applications = [];
  bool _isLoading = true;
  String? _userType;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await _authService.getUserInfo();
    if (!mounted) return;
    setState(() => _userType = userInfo['userType']);
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    try {
      final apps = _userType == 'company'
          ? await _applyService.getAllApplications()
          : await _applyService.getMyApplications();
      if (!mounted) return;
      setState(() {
        _applications = apps;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      return DateFormat('yyyy.MM.dd').format(DateTime.parse(dateStr));
    } catch (e) {
      return dateStr;
    }
  }

  void _cancelApplication(int applyNo, String jobTitle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('지원 취소', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('$jobTitle 지원을 취소하시겠습니까?\n취소된 지원은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('닫기', style: TextStyle(color: _secondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await _applyService.cancelApplication(applyNo);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('지원이 취소되었습니다'),
                      backgroundColor: _green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  _loadApplications();
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('취소하기', style: TextStyle(color: _red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompany = _userType == 'company';
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: isCompany ? '지원자 관리' : '지원 내역',
        actions: [
          IconButton(
            onPressed: _loadApplications,
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
          _buildStats(isCompany),
          Expanded(child: _buildList(isCompany)),
        ],
      ),
    );
  }

  Widget _buildStats(bool isCompany) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Icon(isCompany ? Icons.people_rounded : Icons.send_rounded, color: _blue, size: 20),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${_applications.length}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _blue, letterSpacing: -0.3),
                  ),
                  TextSpan(
                    text: isCompany ? '건의 지원' : '건의 지원 내역',
                    style: const TextStyle(fontSize: 14, color: _secondary, letterSpacing: -0.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(bool isCompany) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5));
    }
    if (_applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
              child: Icon(isCompany ? Icons.people_outline_rounded : Icons.send_outlined, size: 36, color: _secondary),
            ),
            const SizedBox(height: 16),
            Text(
              isCompany ? '아직 지원자가 없습니다' : '지원한 채용공고가 없습니다',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _label),
            ),
            const SizedBox(height: 6),
            Text(
              isCompany ? '채용공고를 등록하여 지원자를 모집해보세요' : '관심있는 채용공고에 지원해보세요',
              style: const TextStyle(fontSize: 14, color: _secondary),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, isCompany ? '/job-form' : '/job-list'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _blue,
                side: const BorderSide(color: _blue, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(isCompany ? '채용공고 등록' : '채용공고 보기',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadApplications,
      color: _blue,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _applications.length,
        itemBuilder: (context, index) => _buildCard(_applications[index], isCompany),
      ),
    );
  }

  Widget _buildCard(dynamic app, bool isCompany) {
    final title = isCompany
        ? (app['resumeTitle'] ?? '이력서 제목 없음')
        : (app['jobTitle'] ?? '채용공고 제목 없음');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _label, letterSpacing: -0.4)),
                ),
                const SizedBox(width: 8),
                _statusBadge(app['status']),
              ],
            ),
            const SizedBox(height: 12),
            if (isCompany) ...[
              _infoRow(Icons.person_outline_rounded, '지원자', app['applicantName'] ?? '이름 없음'),
              _infoRow(Icons.work_outline_rounded, '채용공고', app['jobTitle'] ?? '제목 없음'),
            ] else ...[
              _infoRow(Icons.business_rounded, '회사명', app['companyName'] ?? '회사명 없음'),
              _infoRow(Icons.description_outlined, '지원 이력서', app['resumeTitle'] ?? '제목 없음'),
            ],
            _infoRow(Icons.calendar_today_rounded, '지원일', _formatDate(app['applyDate']?.toString())),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF2F2F7)),
            const SizedBox(height: 12),
            Row(
              children: [
                if (isCompany) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, '/resume-detail', arguments: app['resumeNo']),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _blue,
                        side: const BorderSide(color: Color(0xFFE5E5EA)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('이력서 보기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, '/job-detail', arguments: app['jobNo']),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _blue,
                        side: const BorderSide(color: Color(0xFFE5E5EA)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('공고 보기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _cancelApplication(app['applyNo'], app['jobTitle'] ?? '채용공고'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _red.withValues(alpha: 0.1),
                        foregroundColor: _red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('지원 취소', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(dynamic status) {
    final s = (status as String? ?? '').toUpperCase();
    final Color bg;
    final Color fg;
    final String label;
    switch (s) {
      case 'ACCEPTED':
        bg = _green; fg = _green; label = '합격';
      case 'REJECTED':
        bg = _red; fg = _red; label = '불합격';
      case 'REVIEWING':
      case 'PENDING':
        bg = const Color(0xFFFF9500); fg = const Color(0xFFFF9500); label = '검토중';
      default:
        bg = _blue; fg = _blue; label = '지원완료';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: _secondary),
          const SizedBox(width: 8),
          Text('$label  ', style: const TextStyle(fontSize: 13, color: _secondary, letterSpacing: -0.2)),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, color: _label, fontWeight: FontWeight.w500, letterSpacing: -0.2),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
