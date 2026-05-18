import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/job_batch_actions.dart';
import '../../widgets/app_bar.dart';
import 'widgets/job_draft_fab.dart';
import 'widgets/job_list_item.dart';
import '../../../data/provider/job_provider.dart';
import '../../../data/model/job.dart';

class JobManagementPage extends ConsumerStatefulWidget {
  const JobManagementPage({super.key});

  @override
  ConsumerState<JobManagementPage> createState() => _JobManagementPageState();
}

class _JobManagementPageState extends ConsumerState<JobManagementPage>
    with TickerProviderStateMixin {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);
  static const Color _green = Color(0xFF0FA958);

  late TabController _tabController;
  final Set<int> _selectedJobs = {};
  bool _isSelectionMode = false;

  static const _tabLabels = ['전체', '임시저장', '게시중', '마감', '기타'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobProvider.notifier).loadUserJobs(refresh: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobState = ref.watch(jobProvider);
    final jobNotifier = ref.read(jobProvider.notifier);

    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '채용공고 관리',
        actions: [
          if (!_isSelectionMode)
            IconButton(
              onPressed: () => setState(() => _isSelectionMode = true),
              icon: const Icon(Icons.checklist_rounded, color: _secondary, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(8),
              ),
            )
          else
            TextButton(
              onPressed: () => setState(() { _isSelectionMode = false; _selectedJobs.clear(); }),
              style: TextButton.styleFrom(foregroundColor: _red, minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
              child: const Text('취소', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: Column(
        children: [
            // 탭바
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: TabBar(
                controller: _tabController,
                onTap: _onTabChanged,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicator: BoxDecoration(
                  color: _blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                labelColor: Colors.white,
                unselectedLabelColor: _secondary,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                dividerColor: Colors.transparent,
                tabs: _tabLabels.asMap().entries.map((e) {
                  final counts = jobState.statusCounts;
                  int count = 0;
                  switch (e.key) {
                    case 0: count = counts.values.fold(0, (s, c) => s + c); break;
                    case 1: count = counts['DRAFT'] ?? 0; break;
                    case 2: count = counts['PUBLISHED'] ?? 0; break;
                    case 3: count = counts['EXPIRED'] ?? 0; break;
                    case 4: count = (counts['PENDING'] ?? 0) + (counts['REJECTED'] ?? 0) + (counts['SUSPENDED'] ?? 0); break;
                  }
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(e.value),
                        if (count > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('$count', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // 일괄 작업 바
            if (_isSelectionMode && _selectedJobs.isNotEmpty)
              JobBatchActions(
                selectedCount: _selectedJobs.length,
                onBatchPublish: _onBatchPublish,
                onBatchDelete: _onBatchDelete,
                onBatchChangeStatus: _onBatchChangeStatus,
              ),

            // 목록
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _refreshCurrentTab(),
                color: _blue,
                child: _buildJobList(jobState, jobNotifier),
              ),
            ),
          ],
        ),
      floatingActionButton: JobDraftFab(onPressed: () => _navigateToJobForm()),
    );
  }

  Widget _buildJobList(JobState jobState, JobNotifier jobNotifier) {
    if (jobState.isLoading && jobState.jobs.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5));
    }

    if (jobState.jobs.isEmpty) {
      return _buildEmptyState();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            jobState.hasMore && !jobState.isLoading) {
          jobNotifier.loadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        itemCount: jobState.jobs.length + (jobState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == jobState.jobs.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5),
              ),
            );
          }
          final job = jobState.jobs[index];
          return JobListItem(
            job: job,
            isSelected: _selectedJobs.contains(job.jobNo),
            isSelectionMode: _isSelectionMode,
            onTap: () => _onJobTap(job),
            onSelect: (selected) => _onJobSelect(job.jobNo!, selected),
            onPublish: () => _onPublishJob(job.jobNo!),
            onEdit: () => _navigateToJobForm(job: job),
            onDelete: () => _onDeleteJob(job.jobNo!),
            onChangeStatus: (status) => _onChangeStatus(job.jobNo!, status),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final messages = [
      ('등록된 채용공고가 없습니다.\n새로운 채용공고를 작성해보세요.', '채용공고 작성', Icons.work_outline_rounded),
      ('임시저장된 채용공고가 없습니다.', '새로 작성', Icons.drafts_rounded),
      ('게시중인 채용공고가 없습니다.', '채용공고 작성', Icons.public_rounded),
      ('마감된 채용공고가 없습니다.', '새로 작성', Icons.schedule_rounded),
      ('해당 상태의 채용공고가 없습니다.', '새로 작성', Icons.help_outline_rounded),
    ];
    final idx = _tabController.index.clamp(0, messages.length - 1);
    final (msg, action, icon) = messages[idx];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
              child: Icon(icon, size: 36, color: _secondary),
            ),
            const SizedBox(height: 20),
            Text(msg, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: _secondary, height: 1.5)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _navigateToJobForm(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(action,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _onTabChanged(int index) {
    setState(() { _isSelectionMode = false; _selectedJobs.clear(); });
    final n = ref.read(jobProvider.notifier);
    n.resetJobs();
    switch (index) {
      case 0: n.loadUserJobs(refresh: true); break;
      case 1: n.loadJobsByStatus('DRAFT', refresh: true); break;
      case 2: n.loadJobsByStatus('PUBLISHED', refresh: true); break;
      case 3: n.loadJobsByStatus('EXPIRED', refresh: true); break;
      case 4: n.loadJobsByStatus('PENDING', refresh: true); break;
    }
  }

  Future<void> _refreshCurrentTab() async => _onTabChanged(_tabController.index);

  void _onJobTap(Job job) {
    if (_isSelectionMode) {
      _onJobSelect(job.jobNo!, !_selectedJobs.contains(job.jobNo));
    } else {
      Navigator.pushNamed(context, '/job-detail', arguments: job.jobNo);
    }
  }

  void _onJobSelect(int jobNo, bool selected) {
    setState(() {
      if (selected) { _selectedJobs.add(jobNo); } else { _selectedJobs.remove(jobNo); }
    });
  }

  Future<void> _onPublishJob(int jobNo) async {
    if (await _confirm('게시 확인', '이 채용공고를 게시하시겠습니까?') != true) return;
    final success = await ref.read(jobProvider.notifier).publishJob(jobNo);
    _showSnackBar(success ? '채용공고가 게시되었습니다.' : ref.read(jobProvider).error ?? '게시에 실패했습니다.',
        success ? _green : _red);
  }

  Future<void> _onDeleteJob(int jobNo) async {
    if (await _confirm('삭제 확인', '이 채용공고를 삭제하시겠습니까?\n삭제된 채용공고는 복구할 수 없습니다.') != true) return;
    final success = await ref.read(jobProvider.notifier).deleteJob(jobNo);
    _showSnackBar(success ? '채용공고가 삭제되었습니다.' : ref.read(jobProvider).error ?? '삭제에 실패했습니다.',
        success ? _green : _red);
  }

  Future<void> _onChangeStatus(int jobNo, String status) async {
    final success = await ref.read(jobProvider.notifier).changeJobStatus(jobNo, status);
    _showSnackBar(success ? '상태가 변경되었습니다.' : ref.read(jobProvider).error ?? '상태 변경에 실패했습니다.',
        success ? _green : _red);
  }

  void _navigateToJobForm({Job? job}) {
    Navigator.pushNamed(context, '/job-form', arguments: job).then((_) => _refreshCurrentTab());
  }

  Future<void> _onBatchPublish() async {
    if (await _confirm('일괄 게시 확인', '선택된 ${_selectedJobs.length}개의 채용공고를 게시하시겠습니까?') != true) return;
    final result = await ref.read(jobProvider.notifier).batchChangeStatus(_selectedJobs.toList(), 'PUBLISHED');
    _showBatchResult(result, '게시');
    setState(() { _isSelectionMode = false; _selectedJobs.clear(); });
  }

  Future<void> _onBatchDelete() async {
    if (await _confirm('일괄 삭제 확인', '선택된 ${_selectedJobs.length}개를 삭제하시겠습니까?\n삭제된 채용공고는 복구할 수 없습니다.') != true) return;
    final result = await ref.read(jobProvider.notifier).batchDeleteJobs(_selectedJobs.toList());
    _showBatchResult(result, '삭제');
    setState(() { _isSelectionMode = false; _selectedJobs.clear(); });
  }

  Future<void> _onBatchChangeStatus(String status) async {
    final statusText = _getStatusText(status);
    if (await _confirm('일괄 상태 변경', '선택된 ${_selectedJobs.length}개를 $statusText 상태로 변경하시겠습니까?') != true) return;
    final result = await ref.read(jobProvider.notifier).batchChangeStatus(_selectedJobs.toList(), status);
    _showBatchResult(result, '상태 변경');
    setState(() { _isSelectionMode = false; _selectedJobs.clear(); });
  }

  Future<bool?> _confirm(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소', style: TextStyle(color: _secondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('확인', style: TextStyle(color: _blue, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: color,
      behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showBatchResult(Map<String, dynamic> result, String action) {
    final successCount = result['successCount'] ?? 0;
    final failCount = result['failCount'] ?? 0;
    final total = result['totalCount'] ?? 0;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('$action 결과', style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('전체: $total개', style: const TextStyle(color: _secondary)),
            const SizedBox(height: 4),
            Text('성공: $successCount개', style: const TextStyle(color: _green, fontWeight: FontWeight.w600)),
            if (failCount > 0) ...[
              const SizedBox(height: 4),
              Text('실패: $failCount개', style: const TextStyle(color: _red, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('확인', style: TextStyle(color: _blue, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'DRAFT': return '임시저장';
      case 'PUBLISHED': return '게시중';
      case 'EXPIRED': return '마감';
      case 'SUSPENDED': return '게시중단';
      default: return status;
    }
  }
}
