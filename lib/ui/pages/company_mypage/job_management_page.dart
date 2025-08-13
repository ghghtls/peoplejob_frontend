// lib/ui/pages/company_mypage/job_management_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peoplejob_frontend/ui/pages/company_mypage/widgets/job_batch_actions.dart';
import 'package:peoplejob_frontend/ui/pages/company_mypage/widgets/job_draft_fab.dart';
import 'package:peoplejob_frontend/ui/pages/company_mypage/widgets/job_list_item.dart';
import 'package:peoplejob_frontend/ui/pages/company_mypage/widgets/job_status_tabs.dart';
import '../../../data/provider/job_provider.dart';
import '../../../data/model/job.dart';

class JobManagementPage extends ConsumerStatefulWidget {
  const JobManagementPage({super.key});

  @override
  ConsumerState<JobManagementPage> createState() => _JobManagementPageState();
}

class _JobManagementPageState extends ConsumerState<JobManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final Set<int> _selectedJobs = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // 초기 데이터 로드
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
      appBar: AppBar(
        title: const Text('채용공고 관리'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (!_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: () => setState(() => _isSelectionMode = true),
              tooltip: '일괄 선택',
            )
          else
            TextButton(
              onPressed:
                  () => setState(() {
                    _isSelectionMode = false;
                    _selectedJobs.clear();
                  }),
              child: const Text('취소'),
            ),
        ],
        bottom: JobStatusTabs(
          tabController: _tabController,
          onTabChanged: _onTabChanged,
        ),
      ),
      body: Column(
        children: [
          // 일괄 작업 바
          if (_isSelectionMode && _selectedJobs.isNotEmpty)
            JobBatchActions(
              selectedCount: _selectedJobs.length,
              onBatchPublish: _onBatchPublish,
              onBatchDelete: _onBatchDelete,
              onBatchChangeStatus: _onBatchChangeStatus,
            ),

          // 채용공고 목록
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _refreshCurrentTab(),
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
      return const Center(child: CircularProgressIndicator());
    }

    if (jobState.jobs.isEmpty) {
      return _buildEmptyState();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            jobState.hasMore &&
            !jobState.isLoading) {
          jobNotifier.loadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: jobState.jobs.length + (jobState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == jobState.jobs.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
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
    final currentTab = _tabController.index;
    String message;
    String actionText;
    IconData icon;

    switch (currentTab) {
      case 0: // 전체
        message = '등록된 채용공고가 없습니다.\n새로운 채용공고를 작성해보세요.';
        actionText = '채용공고 작성';
        icon = Icons.work_outline;
        break;
      case 1: // 임시저장
        message = '임시저장된 채용공고가 없습니다.';
        actionText = '새로 작성';
        icon = Icons.drafts;
        break;
      case 2: // 게시중
        message = '게시중인 채용공고가 없습니다.';
        actionText = '채용공고 작성';
        icon = Icons.public;
        break;
      case 3: // 마감
        message = '마감된 채용공고가 없습니다.';
        actionText = '새로 작성';
        icon = Icons.schedule;
        break;
      case 4: // 기타
        message = '해당 상태의 채용공고가 없습니다.';
        actionText = '새로 작성';
        icon = Icons.help_outline;
        break;
      default:
        message = '채용공고가 없습니다.';
        actionText = '새로 작성';
        icon = Icons.work_outline;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 24),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _navigateToJobForm(),
            icon: const Icon(Icons.add),
            label: Text(actionText),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ============ 이벤트 핸들러들 ============

  void _onTabChanged(int index) {
    setState(() {
      _isSelectionMode = false;
      _selectedJobs.clear();
    });

    final jobNotifier = ref.read(jobProvider.notifier);
    jobNotifier.resetJobs();

    switch (index) {
      case 0: // 전체
        jobNotifier.loadUserJobs(refresh: true);
        break;
      case 1: // 임시저장
        jobNotifier.loadJobsByStatus('DRAFT', refresh: true);
        break;
      case 2: // 게시중
        jobNotifier.loadJobsByStatus('PUBLISHED', refresh: true);
        break;
      case 3: // 마감
        jobNotifier.loadJobsByStatus('EXPIRED', refresh: true);
        break;
      case 4: // 기타 (승인대기, 거부, 중단)
        jobNotifier.loadJobsByStatus('PENDING', refresh: true);
        break;
    }
  }

  Future<void> _refreshCurrentTab() async {
    _onTabChanged(_tabController.index);
  }

  void _onJobTap(Job job) {
    if (_isSelectionMode) {
      _onJobSelect(job.jobNo!, !_selectedJobs.contains(job.jobNo));
    } else {
      Navigator.pushNamed(context, '/job-detail', arguments: job.jobNo);
    }
  }

  void _onJobSelect(int jobNo, bool selected) {
    setState(() {
      if (selected) {
        _selectedJobs.add(jobNo);
      } else {
        _selectedJobs.remove(jobNo);
      }
    });
  }

  Future<void> _onPublishJob(int jobNo) async {
    final result = await _showConfirmDialog('게시 확인', '이 채용공고를 게시하시겠습니까?');

    if (result == true) {
      final success = await ref.read(jobProvider.notifier).publishJob(jobNo);

      if (success) {
        _showSnackBar('채용공고가 게시되었습니다.', Colors.green);
      } else {
        final error = ref.read(jobProvider).error;
        _showSnackBar(error ?? '게시에 실패했습니다.', Colors.red);
      }
    }
  }

  Future<void> _onDeleteJob(int jobNo) async {
    final result = await _showConfirmDialog(
      '삭제 확인',
      '이 채용공고를 삭제하시겠습니까?\n삭제된 채용공고는 복구할 수 없습니다.',
    );

    if (result == true) {
      final success = await ref.read(jobProvider.notifier).deleteJob(jobNo);

      if (success) {
        _showSnackBar('채용공고가 삭제되었습니다.', Colors.green);
      } else {
        final error = ref.read(jobProvider).error;
        _showSnackBar(error ?? '삭제에 실패했습니다.', Colors.red);
      }
    }
  }

  Future<void> _onChangeStatus(int jobNo, String status) async {
    final success = await ref
        .read(jobProvider.notifier)
        .changeJobStatus(jobNo, status);

    if (success) {
      _showSnackBar('상태가 변경되었습니다.', Colors.green);
    } else {
      final error = ref.read(jobProvider).error;
      _showSnackBar(error ?? '상태 변경에 실패했습니다.', Colors.red);
    }
  }

  void _navigateToJobForm({Job? job}) {
    Navigator.pushNamed(context, '/job-form', arguments: job).then((_) {
      // 폼에서 돌아왔을 때 목록 새로고침
      _refreshCurrentTab();
    });
  }

  // ============ 일괄 작업 핸들러들 ============

  Future<void> _onBatchPublish() async {
    final result = await _showConfirmDialog(
      '일괄 게시 확인',
      '선택된 ${_selectedJobs.length}개의 채용공고를 게시하시겠습니까?',
    );

    if (result == true) {
      final batchResult = await ref
          .read(jobProvider.notifier)
          .batchChangeStatus(_selectedJobs.toList(), 'PUBLISHED');

      _showBatchResultDialog(batchResult, '게시');

      setState(() {
        _isSelectionMode = false;
        _selectedJobs.clear();
      });
    }
  }

  Future<void> _onBatchDelete() async {
    final result = await _showConfirmDialog(
      '일괄 삭제 확인',
      '선택된 ${_selectedJobs.length}개의 채용공고를 삭제하시겠습니까?\n삭제된 채용공고는 복구할 수 없습니다.',
    );

    if (result == true) {
      final batchResult = await ref
          .read(jobProvider.notifier)
          .batchDeleteJobs(_selectedJobs.toList());

      _showBatchResultDialog(batchResult, '삭제');

      setState(() {
        _isSelectionMode = false;
        _selectedJobs.clear();
      });
    }
  }

  Future<void> _onBatchChangeStatus(String status) async {
    final statusText = _getStatusText(status);
    final result = await _showConfirmDialog(
      '일괄 상태 변경 확인',
      '선택된 ${_selectedJobs.length}개의 채용공고를 $statusText 상태로 변경하시겠습니까?',
    );

    if (result == true) {
      final batchResult = await ref
          .read(jobProvider.notifier)
          .batchChangeStatus(_selectedJobs.toList(), status);

      _showBatchResultDialog(batchResult, '상태 변경');

      setState(() {
        _isSelectionMode = false;
        _selectedJobs.clear();
      });
    }
  }

  // ============ 유틸리티 메서드들 ============

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showBatchResultDialog(Map<String, dynamic> result, String action) {
    final successCount = result['successCount'] ?? 0;
    final failCount = result['failCount'] ?? 0;
    final totalCount = result['totalCount'] ?? 0;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('$action 결과'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('전체: $totalCount개'),
                Text(
                  '성공: $successCount개',
                  style: const TextStyle(color: Colors.green),
                ),
                if (failCount > 0)
                  Text(
                    '실패: $failCount개',
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'DRAFT':
        return '임시저장';
      case 'PUBLISHED':
        return '게시중';
      case 'EXPIRED':
        return '마감';
      case 'SUSPENDED':
        return '게시중단';
      default:
        return status;
    }
  }
}
