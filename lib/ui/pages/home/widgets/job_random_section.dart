import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../data/provider/job_provider.dart';
import '../../../widgets/company_logo.dart';

String _formatSalary(String? s) {
  if (s == null || s.isEmpty) return '';
  final digits = s.replaceAll(',', '');
  final n = int.tryParse(digits);
  return n != null ? '${NumberFormat('#,###').format(n)}만원' : s;
}

class JobRandomSection extends ConsumerWidget {
  const JobRandomSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final randomJobList = ref.watch(randomJobListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                '추천 채용공고',
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
                onPressed: () {
                  Navigator.pushNamed(context, '/job-list');
                },
                child: const Text(
                  '전체보기',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        randomJobList.when(
      data: (jobs) {
        if (jobs.isEmpty) {
          return Container(
            height: 160,
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  Text(
                    '등록된 채용공고가 없습니다',
                    style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: 252,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              final theme = CompanyLogo.resolveTheme(job.company);
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      if (job.jobNo != null) {
                        Navigator.pushNamed(
                          context,
                          '/job-detail',
                          arguments: job.jobNo,
                        );
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 그라디언트 배너 + 아바타
                        Container(
                          height: 96,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.gradient.first.withValues(alpha: 0.18),
                                theme.gradient.last.withValues(alpha: 0.10),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          ),
                          child: Center(
                            child: CompanyLogo(
                              company: job.company,
                              size: 56,
                              borderRadius: 16,
                            ),
                          ),
                        ),
                        // 정보 영역
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    letterSpacing: -0.3,
                                    color: Color(0xFF1C1C1E),
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  job.company,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF8E8E93),
                                    letterSpacing: -0.2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                if (job.salary != null && job.salary!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: theme.gradient),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _formatSalary(job.salary),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                else if (job.location != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 11, color: Color(0xFF8E8E93)),
                                      const SizedBox(width: 2),
                                      Text(
                                        job.location!,
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF8E8E93), letterSpacing: -0.2),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => Container(
        height: 160,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF0B5FFF), strokeWidth: 2.5),
        ),
      ),
      error: (e, _) => Container(
        height: 160,
        margin: const EdgeInsets.symmetric(horizontal: 16),
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
              const Text(
                '채용공고를 불러올 수 없습니다',
                style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => ref.invalidate(randomJobListProvider),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('다시 시도'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF0B5FFF)),
              ),
            ],
          ),
        ),
      ),
        ),
      ],
    );
  }
}
