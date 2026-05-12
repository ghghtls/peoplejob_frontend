import 'package:flutter/material.dart';
import '../../services/job_service.dart';
import '../../services/auth_service.dart';

class JobStatusChangeButton extends StatelessWidget {
  final int jobNo;
  final String currentStatus;
  final VoidCallback onStatusChanged;

  const JobStatusChangeButton({
    super.key,
    required this.jobNo,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: '상태 변경',
      onSelected: (value) => _handleStatusChange(context, value),
      itemBuilder: (context) => _buildMenuItems(),
    );
  }

  Future<int?> _getUserNo() async {
    try {
      final authService = AuthService();
      final userInfo = await authService.getUserInfo();
      return userInfo['userNo'] as int?;
    } catch (e) {
      return null;
    }
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    final items = <PopupMenuEntry<String>>[];

    switch (currentStatus) {
      case 'DRAFT': // 임시저장
        items.addAll([
          const PopupMenuItem(
            value: 'publish',
            child: Row(
              children: [
                Icon(Icons.publish, color: Colors.green),
                SizedBox(width: 8),
                Text('게시하기'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('삭제하기'),
              ],
            ),
          ),
        ]);
        break;

      case 'PUBLISHED': // 게시중
        items.addAll([
          const PopupMenuItem(
            value: 'toDraft',
            child: Row(
              children: [
                Icon(Icons.save, color: Colors.orange),
                SizedBox(width: 8),
                Text('임시저장으로'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'expire',
            child: Row(
              children: [
                Icon(Icons.close, color: Colors.red),
                SizedBox(width: 8),
                Text('마감하기'),
              ],
            ),
          ),
        ]);
        break;

      case 'EXPIRED': // 마감
        items.addAll([
          const PopupMenuItem(
            value: 'reopen',
            child: Row(
              children: [
                Icon(Icons.refresh, color: Colors.blue),
                SizedBox(width: 8),
                Text('다시 게시하기'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('삭제하기'),
              ],
            ),
          ),
        ]);
        break;

      default:
        items.add(
          const PopupMenuItem(
            value: 'publish',
            child: Row(
              children: [
                Icon(Icons.publish, color: Colors.green),
                SizedBox(width: 8),
                Text('게시하기'),
              ],
            ),
          ),
        );
    }

    return items;
  }

  Future<void> _handleStatusChange(BuildContext context, String action) async {
    String confirmMessage = '';
    String newStatus = '';
    bool useExpireApi = false;
    bool usePublishApi = false;
    bool useDeleteApi = false;

    switch (action) {
      case 'publish':
        confirmMessage = '이 채용공고를 게시하시겠습니까?';
        newStatus = 'PUBLISHED';
        usePublishApi = true;
        break;
      case 'toDraft':
        confirmMessage = '이 채용공고를 임시저장으로 변경하시겠습니까?';
        newStatus = 'DRAFT';
        break;
      case 'expire':
        confirmMessage = '이 채용공고를 마감하시겠습니까?';
        useExpireApi = true;
        break;
      case 'reopen':
        confirmMessage = '이 채용공고를 다시 게시하시겠습니까?';
        newStatus = 'PUBLISHED';
        break;
      case 'delete':
        confirmMessage = '이 채용공고를 삭제하시겠습니까?\n삭제된 공고는 복구할 수 없습니다.';
        useDeleteApi = true;
        break;
      default:
        return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('확인'),
        content: Text(confirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'delete' ? Colors.red : null,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final jobService = JobService();
      final userNo = await _getUserNo();

      if (userNo == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('사용자 정보를 가져올 수 없습니다')),
          );
        }
        return;
      }

      if (useDeleteApi) {
        // 삭제 API 호출
        await jobService.deleteJob(jobNo);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('채용공고가 삭제되었습니다')),
          );
          Navigator.pop(context); // 상세 페이지 닫기
        }
      } else if (useExpireApi) {
        // 마감 API 호출
        await jobService.expireJob(jobNo);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('채용공고가 마감되었습니다')),
          );
          onStatusChanged();
        }
      } else if (usePublishApi) {
        // 게시 API 호출
        await jobService.publishJob(jobNo, userNo);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('채용공고가 게시되었습니다')),
          );
          onStatusChanged();
        }
      } else {
        // 상태 변경 API 호출
        await jobService.changeJobStatus(jobNo, newStatus, userNo);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('상태가 변경되었습니다')),
          );
          onStatusChanged();
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }
}
