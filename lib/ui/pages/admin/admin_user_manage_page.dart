import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/provider/admin_provider.dart';
import 'widgets/excel_download_button.dart';
import '../../widgets/app_bar.dart';

class AdminUserManagePage extends ConsumerStatefulWidget {
  const AdminUserManagePage({super.key});

  @override
  ConsumerState<AdminUserManagePage> createState() => _AdminUserManagePageState();
}

class _AdminUserManagePageState extends ConsumerState<AdminUserManagePage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _green = Color(0xFF0FA958);
  static const Color _red = Color(0xFFE5342F);

  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).loadUsers());
  }

  Future<void> _downloadUsersExcel() async {
    setState(() => _isDownloading = true);
    try {
      final filePath = await ref.read(adminProvider.notifier).downloadUsersExcel();
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
      if (mounted) { setState(() => _isDownloading = false); }
    }
  }

  Color _typeColor(String? t) {
    if (t == 'COMPANY') { return const Color(0xFFAF52DE); }
    if (t == 'INDIVIDUAL') { return _blue; }
    return _secondary;
  }

  String _typeText(String? t) {
    if (t == 'COMPANY') { return '기업회원'; }
    if (t == 'INDIVIDUAL') { return '개인회원'; }
    return '알 수 없음';
  }

  void _deleteUser(dynamic user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('회원 삭제', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('정말로 "${user['name'] ?? user['userid']}" 회원을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(color: _secondary))),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final success = await ref.read(adminProvider.notifier).deleteUser(user['userNo'] ?? 0);
              if (success && mounted) {
                Navigator.pop(ctx);
                messenger.showSnackBar(SnackBar(
                  content: const Text('회원이 삭제되었습니다.'),
                  backgroundColor: _green,
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

  void _showUserDetails(dynamic user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(user['userType'] == 'COMPANY' ? Icons.business_rounded : Icons.person_rounded,
              color: _typeColor(user['userType']), size: 22),
          const SizedBox(width: 8),
          const Text('회원 상세정보', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('회원번호', '${user['userNo'] ?? ''}'),
              _detailRow('아이디', user['userid'] ?? ''),
              _detailRow('이름', user['name'] ?? ''),
              _detailRow('이메일', user['email'] ?? ''),
              _detailRow('전화번호', user['phone'] ?? ''),
              _detailRow('주소', user['address'] ?? ''),
              _detailRow('회원타입', _typeText(user['userType'])),
              _detailRow('활성상태', user['isActive'] == true ? '활성' : '비활성'),
              if (user['createdAt'] != null) _detailRow('가입일', user['createdAt'].toString()),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('닫기', style: TextStyle(color: _secondary))),
          if (user['userType'] == 'COMPANY')
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('기업 관리 기능은 추후 구현 예정입니다.'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
              },
              child: const Text('기업 관리', style: TextStyle(color: _blue, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 72, child: Text(label, style: const TextStyle(fontSize: 13, color: _secondary))),
          Expanded(child: Text(value.isEmpty ? '정보 없음' : value,
              style: TextStyle(fontSize: 13, color: value.isEmpty ? _secondary : _label, fontWeight: FontWeight.w500))),
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
        title: '회원 관리',
        showHomeButton: false,
        actions: [
          IconButton(
            onPressed: () => ref.read(adminProvider.notifier).loadUsers(),
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
                onPressed: _downloadUsersExcel,
                label: '회원 목록 Excel 다운로드',
                icon: Icons.download_rounded,
                isLoading: _isDownloading,
              ),
            ),

            const SizedBox(height: 8),

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
                        onPressed: () => ref.read(adminProvider.notifier).loadUsers(),
                        style: ElevatedButton.styleFrom(backgroundColor: _blue, elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text('다시 시도', style: TextStyle(color: Colors.white)),
                      ),
                    ]))
                  : adminState.users.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 72, height: 72,
                          decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
                          child: const Icon(Icons.people_outline_rounded, size: 36, color: _secondary)),
                      const SizedBox(height: 16),
                      const Text('등록된 회원이 없습니다', style: TextStyle(fontSize: 15, color: _secondary)),
                    ]))
                  : RefreshIndicator(
                      onRefresh: () => ref.read(adminProvider.notifier).loadUsers(),
                      color: _blue,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: adminState.users.length,
                        itemBuilder: (context, index) {
                          final user = adminState.users[index];
                          final color = _typeColor(user['userType']);
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
                                  Row(
                                    children: [
                                      Container(
                                        width: 44, height: 44,
                                        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                        child: Icon(user['userType'] == 'COMPANY' ? Icons.business_rounded : Icons.person_rounded,
                                            size: 22, color: color),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              Text(user['name'] ?? '이름 없음',
                                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _label)),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: color.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(_typeText(user['userType']),
                                                    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
                                              ),
                                            ]),
                                            const SizedBox(height: 2),
                                            Text('ID: ${user['userid'] ?? ''}',
                                                style: const TextStyle(fontSize: 12, color: _secondary)),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (v) {
                                          if (v == 'detail') { _showUserDetails(user); }
                                          if (v == 'delete') { _deleteUser(user); }
                                        },
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        itemBuilder: (ctx) => [
                                          const PopupMenuItem(value: 'detail',
                                              child: Row(children: [
                                                Icon(Icons.info_outline_rounded, color: _blue, size: 18),
                                                SizedBox(width: 8), Text('상세보기'),
                                              ])),
                                          const PopupMenuItem(value: 'delete',
                                              child: Row(children: [
                                                Icon(Icons.delete_outline_rounded, color: _red, size: 18),
                                                SizedBox(width: 8), Text('삭제'),
                                              ])),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F2F7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(children: [
                                      _infoRow(Icons.email_outlined, '이메일', user['email'] ?? ''),
                                      const SizedBox(height: 6),
                                      _infoRow(Icons.phone_outlined, '전화번호', user['phone'] ?? ''),
                                      const SizedBox(height: 6),
                                      _infoRow(Icons.location_on_outlined, '주소', user['address'] ?? ''),
                                    ]),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _secondary),
        const SizedBox(width: 6),
        SizedBox(width: 52, child: Text(label, style: const TextStyle(fontSize: 12, color: _secondary))),
        Expanded(child: Text(value.isEmpty ? '정보 없음' : value,
            style: TextStyle(fontSize: 12, color: value.isEmpty ? _secondary : _label))),
      ],
    );
  }
}
