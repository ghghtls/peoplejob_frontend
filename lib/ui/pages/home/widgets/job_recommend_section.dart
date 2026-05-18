import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../data/model/job.dart';
import '../../../../data/provider/job_provider.dart';
import '../../../widgets/company_logo.dart';

String _formatSalary(String? s) {
  if (s == null || s.isEmpty) return '';
  final digits = s.replaceAll(',', '');
  final n = int.tryParse(digits);
  return n != null ? '${NumberFormat('#,###').format(n)}만원' : s;
}

class JobRecommendSection extends ConsumerWidget {
  const JobRecommendSection({super.key});

  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _green = Color(0xFF0FA958);
  static const Color _orange = Color(0xFFFF9500);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestJobs = ref.watch(latestJobListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                '맞춤 채용공고',
                style: TextStyle(
                  fontFamily: 'Ownglyph',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: Color(0xFF0B1220),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/job-list'),
                child: const Text(
                  '전체보기',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: -0.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        latestJobs.when(
          data: (jobs) {
            if (jobs.isEmpty) return _buildEmpty();
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: jobs.length,
              itemBuilder: (context, index) => _buildJobCard(context, jobs[index]),
            );
          },
          loading: () => _buildLoading(),
          error: (e, _) => _buildError(ref),
        ),
      ],
    );
  }

  Widget _buildJobCard(BuildContext context, Job job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: job.isAdvertised ? Border.all(color: _orange, width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: job.isAdvertised
                ? _orange.withValues(alpha: 0.15)
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
            if (job.jobNo != null) {
              Navigator.pushNamed(context, '/job-detail', arguments: job.jobNo);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 회사 로고
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CompanyLogo(company: job.company, size: 48, borderRadius: 12),
                    if (job.isAdvertised)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: _orange,
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _label,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: TextStyle(
                          fontSize: 13,
                          color: _secondary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (job.location != null && job.location!.isNotEmpty)
                            _tag(Icons.location_on_outlined, job.location!, _secondary),
                          if (job.jobType != null && job.jobType!.isNotEmpty)
                            _tag(Icons.work_outline_rounded, job.jobType!, _blue),
                          if (job.salary != null && job.salary!.isNotEmpty)
                            _tag(Icons.attach_money_rounded, _formatSalary(job.salary), _green),
                        ],
                      ),
                    ],
                  ),
                ),
                // 마감일
                if (job.deadline != null) ...[
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: 2),
                      _deadlineBadge(job.deadline!),
                    ],
                  ),
                ],
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
          Text(
            text,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500, letterSpacing: -0.1),
          ),
        ],
      ),
    );
  }

  Widget _deadlineBadge(DateTime deadline) {
    final now = DateTime.now();
    final days = deadline.difference(DateTime(now.year, now.month, now.day)).inDays;
    final isExpired = days < 0;
    final isUrgent = days >= 0 && days <= 7;

    final color = isExpired ? Colors.grey : (isUrgent ? _orange : _blue);
    final label = isExpired ? '마감' : (days == 0 ? 'D-Day' : 'D-$days');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off_rounded, size: 36, color: Color(0xFF8E8E93)),
            SizedBox(height: 10),
            Text('등록된 채용공고가 없습니다', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF0B5FFF), strokeWidth: 2.5),
      ),
    );
  }

  Widget _buildError(WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 36, color: Color(0xFF8E8E93)),
            const SizedBox(height: 10),
            const Text('채용공고를 불러올 수 없습니다', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93), fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => ref.invalidate(latestJobListProvider),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('다시 시도'),
              style: TextButton.styleFrom(foregroundColor: _blue),
            ),
          ],
        ),
      ),
    );
  }
}
