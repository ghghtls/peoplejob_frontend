import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peoplejob_frontend/data/model/notification_model.dart';
import 'package:peoplejob_frontend/data/provider/notification_provider.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage>
    with TickerProviderStateMixin {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _red = Color(0xFFE5342F);

  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  List<int> _selectedNotifications = [];
  bool _isSelectionMode = false;

  static const _tabs = ['전체', '읽지 않음', '통계'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final notifier = ref.read(notificationProvider.notifier);
    notifier.loadNotifications(refresh: true);
    notifier.loadUnreadNotifications();
    notifier.loadStats();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      final state = ref.read(notificationProvider);
      if (state.hasMore && !state.isLoading) {
        ref.read(notificationProvider.notifier).loadNotifications();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: _blue),
                    style: IconButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.all(8)),
                  ),
                  const Expanded(
                    child: Text('알림',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _label, letterSpacing: -0.4)),
                  ),
                  if (_isSelectionMode) ...[
                    TextButton(
                      onPressed: _selectAll,
                      style: TextButton.styleFrom(foregroundColor: _blue, minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                      child: const Text('전체선택', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                    TextButton(
                      onPressed: () => setState(() { _isSelectionMode = false; _selectedNotifications.clear(); }),
                      style: TextButton.styleFrom(foregroundColor: _red, minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                      child: const Text('취소', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ] else ...[
                    IconButton(
                      onPressed: () => _handleMenuAction('markAllRead'),
                      icon: const Icon(Icons.done_all_rounded, size: 20, color: _blue),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(8),
                      ),
                      tooltip: '모두 읽음',
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: () => setState(() => _isSelectionMode = true),
                      icon: const Icon(Icons.checklist_rounded, size: 20, color: _secondary),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ],
              ),
            ),

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
                indicator: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(8)),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                labelColor: Colors.white,
                unselectedLabelColor: _secondary,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                dividerColor: Colors.transparent,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // 선택 모드 액션 바
            if (_isSelectionMode && _selectedNotifications.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
                ),
                child: Row(
                  children: [
                    Text('${_selectedNotifications.length}개 선택됨',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _label)),
                    const Spacer(),
                    TextButton(
                      onPressed: _markSelectedAsRead,
                      style: TextButton.styleFrom(foregroundColor: _blue, minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                      child: const Text('읽음처리', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: _deleteSelected,
                      style: TextButton.styleFrom(foregroundColor: _red, minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                      child: const Text('삭제', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllTab(),
                  _buildUnreadTab(),
                  _buildStatsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllTab() {
    final state = ref.watch(notificationProvider);
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5));
    }
    if (state.error != null) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: _secondary),
          const SizedBox(height: 16),
          Text(state.error!, style: const TextStyle(color: _secondary)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadInitialData,
              style: ElevatedButton.styleFrom(backgroundColor: _blue, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('다시 시도', style: TextStyle(color: Colors.white))),
        ]),
      );
    }
    if (state.notifications.isEmpty) {
      return _emptyState('알림이 없습니다', Icons.notifications_none_rounded);
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(notificationProvider.notifier).loadNotifications(refresh: true),
      color: _blue,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.notifications.length) {
            return const Center(child: Padding(padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5)));
          }
          return _buildNotificationItem(state.notifications[index]);
        },
      ),
    );
  }

  Widget _buildUnreadTab() {
    final state = ref.watch(notificationProvider);
    if (state.unreadNotifications.isEmpty) {
      return _emptyState('읽지 않은 알림이 없습니다', Icons.mark_email_read_rounded);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: state.unreadNotifications.length,
      itemBuilder: (context, index) => _buildNotificationItem(state.unreadNotifications[index]),
    );
  }

  Widget _buildStatsTab() {
    final state = ref.watch(notificationProvider);
    final stats = state.stats;
    if (stats == null) { return const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5)); }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 요약 카드 그리드
          Row(children: [
            Expanded(child: _statsCard('전체', stats.totalCount.toString(), Icons.notifications_rounded, _blue)),
            const SizedBox(width: 12),
            Expanded(child: _statsCard('읽지 않음', stats.unreadCount.toString(), Icons.mark_email_unread_rounded, _red)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statsCard('오늘', stats.todayCount.toString(), Icons.today_rounded, const Color(0xFF34C759))),
            const SizedBox(width: 12),
            Expanded(child: _statsCard('이번 주', stats.weekCount.toString(), Icons.date_range_rounded, const Color(0xFFFF9500))),
          ]),
          const SizedBox(height: 20),

          const Text('타입별 통계',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: -0.2)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: stats.typeCountMap.entries.toList().asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value;
                final type = NotificationType.fromValue(e.key);
                final isLast = i == stats.typeCountMap.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Text(_getTypeIcon(e.key), style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(type.description,
                              style: const TextStyle(fontSize: 14, color: _label, fontWeight: FontWeight.w500))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: _blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('${e.value}',
                                style: const TextStyle(fontSize: 13, color: _blue, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast) const Divider(height: 1, indent: 16, color: Color(0xFFF2F2F7)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 12, color: _secondary)),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final isSelected = _selectedNotifications.contains(notification.id);
    final typeColor = _getTypeColor(notification.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : _blue.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: notification.isRead ? null : Border.all(color: _blue.withValues(alpha: 0.15), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _onNotificationTap(notification),
          onLongPress: () => _enterSelectionMode(notification.id),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isSelectionMode)
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSelection(notification.id),
                    activeColor: _blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  )
                else
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(_getTypeIcon(notification.type), style: const TextStyle(fontSize: 18))),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(notification.title,
                                style: TextStyle(fontSize: 14, fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                                    color: _label)),
                          ),
                          if (!notification.isRead)
                            Container(width: 7, height: 7,
                                decoration: const BoxDecoration(color: _blue, shape: BoxShape.circle)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(notification.message,
                          style: const TextStyle(fontSize: 13, color: _secondary, height: 1.4),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(notification.typeDescription,
                                style: TextStyle(fontSize: 11, color: typeColor, fontWeight: FontWeight.w600)),
                          ),
                          const Spacer(),
                          Text(notification.timeAgo, style: const TextStyle(fontSize: 12, color: _secondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(String message, IconData icon) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 72, height: 72,
            decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, size: 36, color: _secondary)),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(fontSize: 15, color: _secondary)),
      ]),
    );
  }

  void _onNotificationTap(NotificationModel notification) {
    if (_isSelectionMode) { _toggleSelection(notification.id); return; }
    if (notification.isUnread) { ref.read(notificationProvider.notifier).markAsRead(notification.id); }
    if (notification.actionUrl != null) { _navigateToActionUrl(notification.actionUrl!); }
  }

  void _handleMenuAction(String action) {
    final notifier = ref.read(notificationProvider.notifier);
    switch (action) {
      case 'markAllRead':
        _showConfirmDialog('모든 알림을 읽음 처리하시겠습니까?', () => notifier.markAllAsRead());
        break;
      case 'deleteAll':
        _showConfirmDialog('모든 알림을 삭제하시겠습니까?', () => notifier.deleteAllNotifications());
        break;
    }
  }

  void _enterSelectionMode(int? initialId) {
    setState(() {
      _isSelectionMode = true;
      _selectedNotifications.clear();
      if (initialId != null) { _selectedNotifications.add(initialId); }
    });
  }

  void _toggleSelection(int notificationId) {
    setState(() {
      if (_selectedNotifications.contains(notificationId)) {
        _selectedNotifications.remove(notificationId);
      } else {
        _selectedNotifications.add(notificationId);
      }
    });
  }

  void _selectAll() {
    final state = ref.read(notificationProvider);
    setState(() { _selectedNotifications = state.notifications.map((n) => n.id).toList(); });
  }

  void _deleteSelected() {
    if (_selectedNotifications.isEmpty) return;
    _showConfirmDialog('선택한 ${_selectedNotifications.length}개의 알림을 삭제하시겠습니까?', () {
      ref.read(notificationProvider.notifier).deleteMultipleNotifications(_selectedNotifications);
      setState(() { _isSelectionMode = false; _selectedNotifications.clear(); });
    });
  }

  void _markSelectedAsRead() {
    if (_selectedNotifications.isEmpty) return;
    final notifier = ref.read(notificationProvider.notifier);
    for (final id in _selectedNotifications) { notifier.markAsRead(id); }
    setState(() { _isSelectionMode = false; _selectedNotifications.clear(); });
  }

  void _showConfirmDialog(String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('확인', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(color: _secondary))),
          TextButton(
            onPressed: () { Navigator.pop(ctx); onConfirm(); },
            child: const Text('확인', style: TextStyle(color: _blue, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _navigateToActionUrl(String actionUrl) {
    debugPrint('Navigate to: $actionUrl');
    if (actionUrl.startsWith('/jobs/')) {
      // 채용공고 상세로 이동
    } else if (actionUrl.startsWith('/mypage/')) {
      // 마이페이지로 이동
    }
  }

  String _getTypeIcon(String type) {
    switch (type) {
      case 'JOB_APPLICATION': return '📝';
      case 'JOB_STATUS_UPDATE': return '📊';
      case 'NEW_JOB_POSTING': return '💼';
      case 'RESUME_VIEW': return '👀';
      case 'MESSAGE': return '💬';
      case 'SYSTEM': return '⚙️';
      case 'PAYMENT': return '💳';
      case 'EMAIL_VERIFICATION': return '✉️';
      case 'PASSWORD_RESET': return '🔐';
      case 'COMPANY_APPROVAL': return '✅';
      case 'JOB_EXPIRED': return '⏰';
      case 'INTERVIEW_SCHEDULE': return '📅';
      default: return '🔔';
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'JOB_APPLICATION': return const Color(0xFF34C759);
      case 'JOB_STATUS_UPDATE': return _blue;
      case 'NEW_JOB_POSTING': return const Color(0xFFFF9500);
      case 'RESUME_VIEW': return const Color(0xFFAF52DE);
      case 'MESSAGE': return const Color(0xFF5AC8FA);
      case 'SYSTEM': return _secondary;
      case 'PAYMENT': return _red;
      case 'EMAIL_VERIFICATION': return const Color(0xFF32ADE6);
      case 'PASSWORD_RESET': return const Color(0xFFFF6B35);
      case 'COMPANY_APPROVAL': return const Color(0xFF34C759);
      case 'JOB_EXPIRED': return const Color(0xFFFF9500);
      case 'INTERVIEW_SCHEDULE': return const Color(0xFF5856D6);
      default: return _secondary;
    }
  }
}
