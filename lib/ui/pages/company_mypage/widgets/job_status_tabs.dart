import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/provider/job_provider.dart';

class JobStatusTabs extends ConsumerWidget implements PreferredSizeWidget {
  final TabController tabController;
  final Function(int) onTabChanged;

  const JobStatusTabs({
    super.key,
    required this.tabController,
    required this.onTabChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusCounts = ref.watch(jobProvider).statusCounts;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: tabController,
        onTap: onTabChanged,
        isScrollable: true,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: Theme.of(context).primaryColor,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        tabs: [
          _buildTab('전체', _getTotalCount(statusCounts)),
          _buildTab('임시저장', statusCounts['DRAFT'] ?? 0),
          _buildTab('게시중', statusCounts['PUBLISHED'] ?? 0),
          _buildTab('마감', statusCounts['EXPIRED'] ?? 0),
          _buildTab('기타', _getOtherCount(statusCounts)),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  int _getTotalCount(Map<String, int> counts) {
    return counts.values.fold(0, (sum, count) => sum + count);
  }

  int _getOtherCount(Map<String, int> counts) {
    final pending = counts['PENDING'] ?? 0;
    final rejected = counts['REJECTED'] ?? 0;
    final suspended = counts['SUSPENDED'] ?? 0;
    return pending + rejected + suspended;
  }
}
