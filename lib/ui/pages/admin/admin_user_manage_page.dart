import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/provider/admin_provider.dart';
import 'widgets/excel_download_button.dart';

class AdminUserManagePage extends ConsumerStatefulWidget {
  const AdminUserManagePage({super.key});

  @override
  ConsumerState<AdminUserManagePage> createState() =>
      _AdminUserManagePageState();
}

class _AdminUserManagePageState extends ConsumerState<AdminUserManagePage> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).loadUsers());
  }

  Future<void> _downloadUsersExcel() async {
    setState(() => _isDownloading = true);
    try {
      final filePath =
          await ref.read(adminProvider.notifier).downloadUsersExcel();
      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel 파일이 다운로드되었습니다: $filePath'),
            action: SnackBarAction(label: '확인', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('다운로드 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _deleteUser(dynamic user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('회원 삭제'),
            content: Text(
              '정말로 "${user['name'] ?? user['userid']}" 회원을 삭제하시겠습니까?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  final success = await ref
                      .read(adminProvider.notifier)
                      .deleteUser(user['userNo'] ?? 0);
                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('회원이 삭제되었습니다.')),
                    );
                  }
                },
                child: const Text('삭제'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원 관리'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(adminProvider.notifier).loadUsers(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Excel 다운로드 버튼
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ExcelDownloadButton(
                    onPressed: _downloadUsersExcel,
                    label: '회원 목록 Excel 다운로드',
                    icon: Icons.download,
                    isLoading: _isDownloading,
                  ),
                ),
              ],
            ),
          ),

          // 회원 목록
          Expanded(
            child:
                adminState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : adminState.error != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '오류: ${adminState.error}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed:
                                () =>
                                    ref
                                        .read(adminProvider.notifier)
                                        .loadUsers(),
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    )
                    : adminState.users.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '등록된 회원이 없습니다.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(adminProvider.notifier).loadUsers();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: adminState.users.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final user = adminState.users[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: _getUserTypeColor(
                                          user['userType'],
                                        ),
                                        child: Icon(
                                          user['userType'] == 'COMPANY'
                                              ? Icons.business
                                              : Icons.person,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  user['name'] ?? '이름 없음',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: _getUserTypeColor(
                                                      user['userType'],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    _getUserTypeText(
                                                      user['userType'],
                                                    ),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'ID: ${user['userid'] ?? ''}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (value) {
                                          switch (value) {
                                            case 'detail':
                                              _showUserDetails(user);
                                              break;
                                            case 'delete':
                                              _deleteUser(user);
                                              break;
                                          }
                                        },
                                        itemBuilder:
                                            (context) => [
                                              const PopupMenuItem(
                                                value: 'detail',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.info_outline,
                                                      color: Colors.blue,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text('상세보기'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text('삭제'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        _buildInfoRow(
                                          Icons.email,
                                          '이메일',
                                          user['email'] ?? '',
                                        ),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                          Icons.phone,
                                          '전화번호',
                                          user['phone'] ?? '',
                                        ),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                          Icons.location_on,
                                          '주소',
                                          user['address'] ?? '',
                                        ),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                          Icons.account_circle,
                                          '회원번호',
                                          '${user['userNo'] ?? ''}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value.isEmpty ? '정보 없음' : value,
            style: TextStyle(
              fontSize: 12,
              color:
                  value.isEmpty ? Colors.grey.shade400 : Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Color _getUserTypeColor(String? userType) {
    switch (userType) {
      case 'COMPANY':
        return Colors.purple.shade600;
      case 'INDIVIDUAL':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String _getUserTypeText(String? userType) {
    switch (userType) {
      case 'INDIVIDUAL':
        return '개인회원';
      case 'COMPANY':
        return '기업회원';
      default:
        return '알 수 없음';
    }
  }

  void _showUserDetails(dynamic user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  user['userType'] == 'COMPANY' ? Icons.business : Icons.person,
                  color: _getUserTypeColor(user['userType']),
                ),
                const SizedBox(width: 8),
                const Text('회원 상세정보'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('회원번호', '${user['userNo'] ?? ''}'),
                  _buildDetailRow('아이디', user['userid'] ?? ''),
                  _buildDetailRow('이름', user['name'] ?? ''),
                  _buildDetailRow('이메일', user['email'] ?? ''),
                  _buildDetailRow('전화번호', user['phone'] ?? ''),
                  _buildDetailRow('주소', user['address'] ?? ''),
                  _buildDetailRow('회원타입', _getUserTypeText(user['userType'])),
                  _buildDetailRow(
                    '활성상태',
                    user['isActive'] == true ? '활성' : '비활성',
                  ),
                  if (user['createdAt'] != null)
                    _buildDetailRow('가입일', user['createdAt'].toString()),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
              if (user['userType'] == 'COMPANY')
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // 기업 전용 관리 페이지로 이동
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('기업 관리 기능은 추후 구현 예정입니다.')),
                    );
                  },
                  child: const Text('기업 관리'),
                ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '정보 없음' : value,
              style: TextStyle(
                fontSize: 14,
                color: value.isEmpty ? Colors.grey.shade400 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
