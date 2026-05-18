import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/provider/admin_provider.dart';
import 'widgets/excel_download_button.dart';
import '../../widgets/app_bar.dart';

class AdminApplicantListPage extends ConsumerStatefulWidget {
  const AdminApplicantListPage({super.key});

  @override
  ConsumerState<AdminApplicantListPage> createState() => _AdminApplicantListPageState();
}

class _AdminApplicantListPageState extends ConsumerState<AdminApplicantListPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _green = Color(0xFF0FA958);
  static const Color _red = Color(0xFFE5342F);
  static const Color _orange = Color(0xFFFF9500);

  String _filterStatus = 'ALL';
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).loadApplicants());
  }

  Future<void> _downloadExcel() async {
    setState(() => _isDownloading = true);
    try {
      final filePath = await ref.read(adminProvider.notifier).downloadApplicantsExcel(0);
      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Excel 파일이 다운로드되었습니다'),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('다운로드 실패: $e'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'ACCEPTED': return _green;
      case 'REJECTED': return _red;
      case 'REVIEWED': return _blue;
      case 'CANCELED': return _secondary;
      default: return _orange;
    }
  }

  String _statusText(String? s) {
    switch (s) {
      case 'PENDING': return '지원완료';
      case 'REVIEWED': return '검토중';
      case 'ACCEPTED': return '합격';
      case 'REJECTED': return '불합격';
      case 'CANCELED': return '지원취소';
      default: return s ?? '알 수 없음';
    }
  }

  List<dynamic> _filtered(List<dynamic> list) {
    if (_filterStatus == 'ALL') return list;
    return list.where((a) => a['status'] == _filterStatus).toList();
  }

  void _showDetail(dynamic applicant) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('지원 상세정보', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _detailRow('지원번호', '${applicant['applyNo'] ?? ''}'),
            _detailRow('채용공고', applicant['jobTitle'] ?? '공고번호 ${applicant['jobNo']}'),
            _detailRow('회사명', applicant['company'] ?? '-'),
            _detailRow('지원자', applicant['applicantName'] ?? '회원번호 ${applicant['userNo']}'),
            _detailRow('이메일', applicant['applicantEmail'] ?? '-'),
            _detailRow('상태', _statusText(applicant['status'])),
            _detailRow('지원일', applicant['applyDate']?.toString() ?? '-'),
            if (applicant['message'] != null && applicant['message'].toString().isNotEmpty)
              _detailRow('메시지', applicant['message']),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('닫기', style: TextStyle(color: _secondary)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 64, child: Text(label, style: const TextStyle(fontSize: 13, color: _secondary))),
        Expanded(child: Text(value.isEmpty ? '-' : value,
            style: const TextStyle(fontSize: 13, color: _label, fontWeight: FontWeight.w500))),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final filtered = _filtered(adminState.applicants);

    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '지원자 목록',
        showHomeButton: false,
        actions: [
          IconButton(
            onPressed: () => ref.read(adminProvider.notifier).loadApplicants(),
            icon: const Icon(Icons.refresh_rounded, size: 20, color: _secondary),
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
            // Excel + 필터
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(children: [
                ExcelDownloadButton(
                  onPressed: _downloadExcel,
                  label: '지원자 목록 Excel 다운로드',
                  icon: Icons.download_rounded,
                  isLoading: _isDownloading,
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _filterChip('ALL', '전체', adminState.applicants.length),
                    const SizedBox(width: 8),
                    _filterChip('PENDING', '지원완료', adminState.applicants.where((a) => a['status'] == 'PENDING').length),
                    const SizedBox(width: 8),
                    _filterChip('REVIEWED', '검토중', adminState.applicants.where((a) => a['status'] == 'REVIEWED').length),
                    const SizedBox(width: 8),
                    _filterChip('ACCEPTED', '합격', adminState.applicants.where((a) => a['status'] == 'ACCEPTED').length),
                    const SizedBox(width: 8),
                    _filterChip('REJECTED', '불합격', adminState.applicants.where((a) => a['status'] == 'REJECTED').length),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 8),

            // 목록
            Expanded(
              child: adminState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5))
                  : adminState.error != null
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: _secondary),
                      const SizedBox(height: 12),
                      Text('오류: ${adminState.error}', style: const TextStyle(color: _secondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(adminProvider.notifier).loadApplicants(),
                        style: ElevatedButton.styleFrom(backgroundColor: _blue, elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text('다시 시도', style: TextStyle(color: Colors.white)),
                      ),
                    ]))
                  : filtered.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 72, height: 72,
                          decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
                          child: const Icon(Icons.people_outline_rounded, size: 36, color: _secondary)),
                      const SizedBox(height: 16),
                      const Text('지원자가 없습니다', style: TextStyle(fontSize: 15, color: _secondary)),
                    ]))
                  : RefreshIndicator(
                      onRefresh: () => ref.read(adminProvider.notifier).loadApplicants(),
                      color: _blue,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final a = filtered[index];
                          final statusColor = _statusColor(a['status'] as String?);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                            ),
                            child: Material(
                              color: Colors.transparent, borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _showDetail(a),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(children: [
                                    Container(
                                      width: 44, height: 44,
                                      decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12)),
                                      child: Icon(Icons.assignment_ind_rounded, size: 22, color: statusColor),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Row(children: [
                                          Expanded(
                                            child: Text(
                                              a['applicantName'] as String? ?? '회원번호 ${a['userNo']}',
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _label),
                                              maxLines: 1, overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(7),
                                            ),
                                            child: Text(_statusText(a['status'] as String?),
                                                style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w700)),
                                          ),
                                        ]),
                                        const SizedBox(height: 4),
                                        Text(
                                          a['jobTitle'] as String? ?? '공고번호 ${a['jobNo']}',
                                          style: const TextStyle(fontSize: 13, color: _secondary),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                        if (a['company'] != null) ...[
                                          const SizedBox(height: 2),
                                          Text(a['company'] as String,
                                              style: const TextStyle(fontSize: 12, color: _secondary)),
                                        ],
                                        const SizedBox(height: 4),
                                        Text('지원일: ${a['applyDate'] ?? '-'}',
                                            style: const TextStyle(fontSize: 11, color: _secondary)),
                                      ]),
                                    ),
                                    const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFE5E5EA)),
                                  ]),
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

  Widget _filterChip(String value, String label, int count) {
    final isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? _blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
        ),
        child: Text('$label ($count)',
            style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : _secondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
      ),
    );
  }
}
