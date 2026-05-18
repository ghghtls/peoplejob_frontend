import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/provider/admin_provider.dart';
import '../../../data/model/job.dart';
import 'widgets/excel_download_button.dart';
import '../../widgets/app_bar.dart';

class AdminJobManagePage extends ConsumerStatefulWidget {
  const AdminJobManagePage({super.key});

  @override
  ConsumerState<AdminJobManagePage> createState() => _AdminJobManagePageState();
}

class _AdminJobManagePageState extends ConsumerState<AdminJobManagePage>
    with SingleTickerProviderStateMixin {
  static const Color _blue    = Color(0xFF0B5FFF);
  static const Color _label   = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg      = Color(0xFFF2F2F7);
  static const Color _green   = Color(0xFF0FA958);
  static const Color _red     = Color(0xFFE5342F);
  static const Color _orange  = Color(0xFFFF9500);
  static const Color _purple  = Color(0xFFAF52DE);

  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchKeyword = '';
  bool _isDownloading = false;

  final List<String> _tabs = ['전체', '승인 대기', '게시중', '마감'];
  final List<String?> _tabStatus = [null, 'PENDING', 'PUBLISHED', 'EXPIRED'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    Future.microtask(() => ref.read(adminProvider.notifier).loadJobs());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── 필터링 ────────────────────────────────────────────────────────────────
  List<Job> _filtered(List<Job> jobs) {
    final statusFilter = _tabStatus[_tabController.index];
    return jobs.where((j) {
      final matchStatus = statusFilter == null || j.status == statusFilter;
      final matchSearch = _searchKeyword.isEmpty ||
          j.title.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
          j.company.toLowerCase().contains(_searchKeyword.toLowerCase());
      return matchStatus && matchSearch;
    }).toList();
  }

  // ── 상태 표시 ─────────────────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status) {
      case 'PUBLISHED': return _green;
      case 'PENDING':   return _orange;
      case 'EXPIRED':   return _secondary;
      case 'DRAFT':     return _purple;
      default:          return _secondary;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'PUBLISHED': return '게시중';
      case 'PENDING':   return '승인 대기';
      case 'EXPIRED':   return '마감';
      case 'DRAFT':     return '임시저장';
      default:          return status;
    }
  }

  // ── Excel 다운로드 ────────────────────────────────────────────────────────
  Future<void> _downloadExcel() async {
    setState(() => _isDownloading = true);
    try {
      await ref.read(adminProvider.notifier).downloadJobsExcel();
      if (mounted) {
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

  // ── 승인 ─────────────────────────────────────────────────────────────────
  void _approveJob(Job job) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('채용공고 승인', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('"${job.title}" 공고를 승인하시겠습니까?\n승인 즉시 게시됩니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(color: _secondary))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref.read(adminProvider.notifier).approveJob(job.jobNo!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? '승인되었습니다' : '승인에 실패했습니다'),
                  backgroundColor: ok ? _green : _red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
              }
            },
            child: const Text('승인', style: TextStyle(color: _green, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── 반려 ─────────────────────────────────────────────────────────────────
  void _rejectJob(Job job) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('채용공고 반려', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('"${job.title}" 공고를 반려하시겠습니까?\n기업 측에 반려 처리됩니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(color: _secondary))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref.read(adminProvider.notifier).rejectJob(job.jobNo!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? '반려되었습니다' : '반려에 실패했습니다'),
                  backgroundColor: ok ? _orange : _red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
              }
            },
            child: const Text('반려', style: TextStyle(color: _red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── 마감 ─────────────────────────────────────────────────────────────────
  void _expireJob(Job job) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('채용공고 마감', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('"${job.title}" 공고를 강제 마감하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(color: _secondary))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref.read(adminProvider.notifier).expireJob(job.jobNo!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? '마감 처리되었습니다' : '마감 처리에 실패했습니다'),
                  backgroundColor: ok ? _secondary : _red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
              }
            },
            child: const Text('마감', style: TextStyle(color: _orange, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── 삭제 ─────────────────────────────────────────────────────────────────
  void _deleteJob(Job job) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('채용공고 삭제', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('"${job.title}" 공고를 삭제하시겠습니까?\n삭제된 데이터는 복구할 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(color: _secondary))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref.read(adminProvider.notifier).deleteJob(job.jobNo!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? '삭제되었습니다' : '삭제에 실패했습니다'),
                  backgroundColor: ok ? _green : _red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
              }
            },
            child: const Text('삭제', style: TextStyle(color: _red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── 상세 다이얼로그 ───────────────────────────────────────────────────────
  void _showDetail(Job job) {
    final statusColor = _statusColor(job.status);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: _blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.work_rounded, size: 16, color: _blue),
          ),
          const SizedBox(width: 10),
          const Text('공고 상세정보', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('공고번호', '${job.jobNo ?? '-'}'),
              _detailRow('제목', job.title),
              _detailRow('기업명', job.company),
              _detailRow('지역', job.location ?? '-'),
              _detailRow('고용형태', job.jobType ?? '-'),
              _detailRow('급여', job.salary ?? '-'),
              _detailRow('경력', job.experience ?? '-'),
              _detailRow('학력', job.education ?? '-'),
              if (job.deadline != null)
                _detailRow('마감일', DateFormat('yyyy.MM.dd').format(job.deadline!)),
              if (job.regdate != null)
                _detailRow('등록일', DateFormat('yyyy.MM.dd').format(job.regdate!)),
              _detailRow('조회수', '${job.viewCount ?? 0}회'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_statusText(job.status),
                    style: TextStyle(fontSize: 13, color: statusColor, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('닫기', style: TextStyle(color: _secondary))),
          if (job.status == 'PENDING') ...[
            TextButton(
              onPressed: () { Navigator.pop(ctx); _rejectJob(job); },
              child: const Text('반려', style: TextStyle(color: _red, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () { Navigator.pop(ctx); _approveJob(job); },
              child: const Text('승인', style: TextStyle(color: _green, fontWeight: FontWeight.w600)),
            ),
          ],
          if (job.status == 'PUBLISHED')
            TextButton(
              onPressed: () { Navigator.pop(ctx); _expireJob(job); },
              child: const Text('마감', style: TextStyle(color: _orange, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 64,
              child: Text(label, style: const TextStyle(fontSize: 13, color: _secondary))),
          Expanded(child: Text(value.isEmpty ? '-' : value,
              style: TextStyle(fontSize: 13, color: value.isEmpty ? _secondary : _label,
                  fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '채용공고 관리',
        showHomeButton: false,
        actions: [
          IconButton(
            onPressed: () => ref.read(adminProvider.notifier).loadJobs(),
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
          // Excel 다운로드
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: ExcelDownloadButton(
              onPressed: _downloadExcel,
              label: '채용공고 목록 Excel 다운로드',
              icon: Icons.download_rounded,
              isLoading: _isDownloading,
            ),
          ),

          // 검색
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 15, color: _label),
                decoration: InputDecoration(
                  hintText: '공고 제목 또는 기업명 검색',
                  hintStyle: const TextStyle(color: _secondary, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: _secondary, size: 20),
                  suffixIcon: _searchKeyword.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel_rounded, color: _secondary, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchKeyword = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (v) => setState(() => _searchKeyword = v),
              ),
            ),
          ),

          // 탭
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: _blue,
                unselectedLabelColor: _secondary,
                indicatorColor: _blue,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                dividerColor: Colors.transparent,
                onTap: (_) => setState(() {}),
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 카운트
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Builder(builder: (_) {
              if (adminState.isLoading) return const SizedBox.shrink();
              final count = _filtered(adminState.jobs).length;
              return Row(children: [
                Text('$count개',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _blue)),
                const Text('의 공고', style: TextStyle(fontSize: 14, color: _secondary)),
              ]);
            }),
          ),

          const SizedBox(height: 4),

          // 목록
          Expanded(child: _buildBody(adminState)),
        ],
      ),
    );
  }

  Widget _buildBody(AdminState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5));
    }

    if (state.error != null) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: _secondary),
          const SizedBox(height: 12),
          Text('오류: ${state.error}', style: const TextStyle(color: _secondary, fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(adminProvider.notifier).loadJobs(),
            style: ElevatedButton.styleFrom(backgroundColor: _blue, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('다시 시도', style: TextStyle(color: Colors.white)),
          ),
        ]),
      );
    }

    final jobs = _filtered(state.jobs);

    if (jobs.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.work_outline_rounded, size: 36, color: _secondary),
          ),
          const SizedBox(height: 16),
          const Text('채용공고가 없습니다', style: TextStyle(fontSize: 15, color: _secondary)),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminProvider.notifier).loadJobs(),
      color: _blue,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: jobs.length,
        itemBuilder: (context, i) => _buildCard(jobs[i]),
      ),
    );
  }

  Widget _buildCard(Job job) {
    final statusColor = _statusColor(job.status);
    final deadlineStr = job.deadline != null
        ? DateFormat('yyyy.MM.dd').format(job.deadline!)
        : '-';
    final regStr = job.regdate != null
        ? DateFormat('yyyy.MM.dd').format(job.regdate!)
        : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 행
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.work_rounded, size: 20, color: _blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(job.title,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                                  color: _label, letterSpacing: -0.3),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(_statusText(job.status),
                              style: TextStyle(fontSize: 11, color: statusColor,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ]),
                      const SizedBox(height: 3),
                      Text(job.company,
                          style: const TextStyle(fontSize: 13, color: _secondary)),
                    ],
                  ),
                ),
                // 액션 메뉴
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'detail') _showDetail(job);
                    if (v == 'approve') _approveJob(job);
                    if (v == 'reject') _rejectJob(job);
                    if (v == 'expire') _expireJob(job);
                    if (v == 'delete') _deleteJob(job);
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  icon: const Icon(Icons.more_vert_rounded, size: 20, color: _secondary),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'detail',
                        child: Row(children: [
                          Icon(Icons.info_outline_rounded, color: _blue, size: 18),
                          SizedBox(width: 8), Text('상세보기'),
                        ])),
                    if (job.status == 'PENDING') ...[
                      const PopupMenuItem(value: 'approve',
                          child: Row(children: [
                            Icon(Icons.check_circle_outline_rounded, color: Color(0xFF0FA958), size: 18),
                            SizedBox(width: 8), Text('승인'),
                          ])),
                      const PopupMenuItem(value: 'reject',
                          child: Row(children: [
                            Icon(Icons.cancel_outlined, color: Color(0xFFE5342F), size: 18),
                            SizedBox(width: 8), Text('반려'),
                          ])),
                    ],
                    if (job.status == 'PUBLISHED')
                      const PopupMenuItem(value: 'expire',
                          child: Row(children: [
                            Icon(Icons.timer_off_outlined, color: Color(0xFFFF9500), size: 18),
                            SizedBox(width: 8), Text('강제 마감'),
                          ])),
                    const PopupMenuItem(value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_outline_rounded, color: Color(0xFFE5342F), size: 18),
                          SizedBox(width: 8), Text('삭제'),
                        ])),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 정보 행
            Wrap(spacing: 6, runSpacing: 6, children: [
              if ((job.location ?? '').isNotEmpty) _tag(Icons.location_on_outlined, job.location!),
              if ((job.jobType ?? '').isNotEmpty) _tag(Icons.work_outline_rounded, job.jobType!),
              if ((job.workType ?? '').isNotEmpty) _tag(Icons.schedule_outlined, job.workType!),
            ]),

            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF2F2F7)),
            const SizedBox(height: 8),

            // 날짜 행
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 12, color: _secondary),
                const SizedBox(width: 4),
                Text('등록 $regStr',
                    style: const TextStyle(fontSize: 12, color: _secondary)),
                const Spacer(),
                const Icon(Icons.timer_outlined, size: 12, color: _secondary),
                const SizedBox(width: 4),
                Text('마감 $deadlineStr',
                    style: TextStyle(
                        fontSize: 12,
                        color: job.isExpired ? _red : _secondary,
                        fontWeight: job.isExpired ? FontWeight.w600 : FontWeight.w400)),
                const Spacer(),
                const Icon(Icons.visibility_outlined, size: 12, color: _secondary),
                const SizedBox(width: 4),
                Text('${job.viewCount ?? 0}회',
                    style: const TextStyle(fontSize: 12, color: _secondary)),
              ],
            ),

            // 승인 대기 시 빠른 액션 버튼
            if (job.status == 'PENDING') ...[
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectJob(job),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _red,
                      side: const BorderSide(color: _red),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('반려', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveJob(job),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('승인', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: _secondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: _secondary)),
      ]),
    );
  }
}
