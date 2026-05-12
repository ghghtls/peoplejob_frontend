import 'package:flutter/material.dart';
import 'package:peoplejob_frontend/data/model/notification_model.dart';
import 'package:peoplejob_frontend/data/provider/notification_provider.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  List<int> _selectedNotifications = [];
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final provider = context.read<NotificationProvider>();
    provider.loadNotifications(refresh: true);
    provider.loadUnreadNotifications();
    provider.loadStats();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final provider = context.read<NotificationProvider>();
      if (provider.hasMore && !provider.isLoading) {
        provider.loadNotifications();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: '전체'), Tab(text: '읽지 않음'), Tab(text: '통계')],
        ),
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _selectAll,
              tooltip: '전체 선택',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelected,
              tooltip: '선택 삭제',
            ),
            IconButton(
              icon: const Icon(Icons.mark_email_read),
              onPressed: _markSelectedAsRead,
              tooltip: '선택 읽음 처리',
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _exitSelectionMode,
              tooltip: '선택 모드 종료',
            ),
          ] else ...[
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder:
                  (context) => const [
                    PopupMenuItem(
                      value: 'markAllRead',
                      child: Text('모두 읽음 처리'),
                    ),
                    PopupMenuItem(value: 'deleteAll', child: Text('모두 삭제')),
                    PopupMenuItem(value: 'refresh', child: Text('새로고침')),
                    PopupMenuItem(value: 'select', child: Text('선택 모드')),
                  ],
            ),
          ],
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllNotificationsTab(),
          _buildUnreadNotificationsTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }

  Widget _buildAllNotificationsTab() {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(provider.error!),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loadInitialData,
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }

        if (provider.notifications.isEmpty) {
          return const Center(child: Text('알림이 없습니다.'));
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadNotifications(refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            itemCount:
                provider.notifications.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= provider.notifications.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final notification = provider.notifications[index];
              return _buildNotificationItem(notification);
            },
          ),
        );
      },
    );
  }

  Widget _buildUnreadNotificationsTab() {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        if (provider.unreadNotifications.isEmpty) {
          return const Center(child: Text('읽지 않은 알림이 없습니다.'));
        }

        return ListView.builder(
          itemCount: provider.unreadNotifications.length,
          itemBuilder: (context, index) {
            final notification = provider.unreadNotifications[index];
            return _buildNotificationItem(notification);
          },
        );
      },
    );
  }

  Widget _buildStatsTab() {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        final stats = provider.stats;

        if (stats == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsCard(
                '전체 알림',
                stats.totalCount.toString(),
                Icons.notifications,
              ),
              _buildStatsCard(
                '읽지 않음',
                stats.unreadCount.toString(),
                Icons.mark_email_unread,
              ),
              _buildStatsCard('오늘', stats.todayCount.toString(), Icons.today),
              _buildStatsCard(
                '이번 주',
                stats.weekCount.toString(),
                Icons.date_range,
              ),
              const SizedBox(height: 20),
              const Text(
                '타입별 통계',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...stats.typeCountMap.entries.map((entry) {
                final type = NotificationType.fromValue(entry.key);
                return ListTile(
                  leading: Text(
                    _getTypeIcon(entry.key),
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(type.description),
                  trailing: Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final isSelected = _selectedNotifications.contains(notification.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: notification.isRead ? null : Colors.blue.withOpacity(0.1),
      child: ListTile(
        leading:
            _isSelectionMode
                ? Checkbox(
                  value: isSelected,
                  onChanged: (_) => _toggleSelection(notification.id),
                )
                : CircleAvatar(
                  backgroundColor: _getTypeColorFromString(notification.type),
                  child: Text(
                    _getTypeIcon(notification.type),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  notification.typeDescription,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getTypeColorFromString(notification.type),
                  ),
                ),
                const Spacer(),
                Text(
                  notification.timeAgo,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing:
            _isSelectionMode
                ? null
                : PopupMenuButton<String>(
                  onSelected:
                      (value) => _handleNotificationAction(value, notification),
                  itemBuilder:
                      (context) => [
                        if (notification.isUnread)
                          const PopupMenuItem(
                            value: 'markRead',
                            child: Text('읽음 처리'),
                          ),
                        const PopupMenuItem(value: 'delete', child: Text('삭제')),
                        if (notification.actionUrl != null)
                          const PopupMenuItem(
                            value: 'action',
                            child: Text('바로가기'),
                          ),
                      ],
                ),
        onTap: () => _onNotificationTap(notification),
        onLongPress: () => _enterSelectionMode(notification.id),
      ),
    );
  }

  void _onNotificationTap(NotificationModel notification) {
    if (_isSelectionMode) {
      _toggleSelection(notification.id);
      return;
    }

    // 읽지 않은 알림이면 읽음 처리
    if (notification.isUnread) {
      context.read<NotificationProvider>().markAsRead(notification.id);
    }

    // 액션 URL이 있으면 해당 페이지로 이동
    if (notification.actionUrl != null) {
      _navigateToActionUrl(notification.actionUrl!);
    }
  }

  void _handleMenuAction(String action) {
    final provider = context.read<NotificationProvider>();

    switch (action) {
      case 'markAllRead':
        _showConfirmDialog(
          '모든 알림을 읽음 처리하시겠습니까?',
          () => provider.markAllAsRead(),
        );
        break;
      case 'deleteAll':
        _showConfirmDialog(
          '모든 알림을 삭제하시겠습니까?',
          () => provider.deleteAllNotifications(),
        );
        break;
      case 'refresh':
        _loadInitialData();
        break;
      case 'select':
        _enterSelectionMode(null);
        break;
    }
  }

  void _handleNotificationAction(
    String action,
    NotificationModel notification,
  ) {
    final provider = context.read<NotificationProvider>();

    switch (action) {
      case 'markRead':
        provider.markAsRead(notification.id);
        break;
      case 'delete':
        provider.deleteNotification(notification.id);
        break;
      case 'action':
        if (notification.actionUrl != null) {
          _navigateToActionUrl(notification.actionUrl!);
        }
        break;
    }
  }

  void _enterSelectionMode(int? initialId) {
    setState(() {
      _isSelectionMode = true;
      _selectedNotifications.clear();
      if (initialId != null) {
        _selectedNotifications.add(initialId);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedNotifications.clear();
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
    final provider = context.read<NotificationProvider>();
    setState(() {
      _selectedNotifications = provider.notifications.map((n) => n.id).toList();
    });
  }

  void _deleteSelected() {
    if (_selectedNotifications.isEmpty) return;

    _showConfirmDialog(
      '선택한 ${_selectedNotifications.length}개의 알림을 삭제하시겠습니까?',
      () {
        context.read<NotificationProvider>().deleteMultipleNotifications(
          _selectedNotifications,
        );
        _exitSelectionMode();
      },
    );
  }

  void _markSelectedAsRead() {
    if (_selectedNotifications.isEmpty) return;

    // (일괄 API 있으면 교체)
    final provider = context.read<NotificationProvider>();
    for (final id in _selectedNotifications) {
      provider.markAsRead(id);
    }
    _exitSelectionMode();
  }

  void _showConfirmDialog(String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('확인'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  void _navigateToActionUrl(String actionUrl) {
    // 실제 구현에서는 라우팅 시스템에 맞게 구현
    debugPrint('Navigate to: $actionUrl');

    // 예시: 간단한 URL 파싱 및 네비게이션
    if (actionUrl.startsWith('/jobs/')) {
      // 채용공고 상세 페이지로 이동
    } else if (actionUrl.startsWith('/mypage/')) {
      // 마이페이지로 이동
    }
    // 추가 라우팅 로직...
  }

  String _getTypeIcon(String type) {
    switch (type) {
      case 'JOB_APPLICATION':
        return '📝';
      case 'JOB_STATUS_UPDATE':
        return '📊';
      case 'NEW_JOB_POSTING':
        return '💼';
      case 'RESUME_VIEW':
        return '👀';
      case 'MESSAGE':
        return '💬';
      case 'SYSTEM':
        return '⚙️';
      case 'PAYMENT':
        return '💳';
      case 'EMAIL_VERIFICATION':
        return '✉️';
      case 'PASSWORD_RESET':
        return '🔐';
      case 'COMPANY_APPROVAL':
        return '✅';
      case 'JOB_EXPIRED':
        return '⏰';
      case 'INTERVIEW_SCHEDULE':
        return '📅';
      default:
        return '🔔';
    }
  }

  Color _getTypeColorFromString(String type) {
    switch (type) {
      case 'JOB_APPLICATION':
        return Colors.green;
      case 'JOB_STATUS_UPDATE':
        return Colors.blue;
      case 'NEW_JOB_POSTING':
        return Colors.orange;
      case 'RESUME_VIEW':
        return Colors.purple;
      case 'MESSAGE':
        return Colors.blueGrey;
      case 'SYSTEM':
        return Colors.brown;
      case 'PAYMENT':
        return Colors.red;
      case 'EMAIL_VERIFICATION':
        return Colors.cyan;
      case 'PASSWORD_RESET':
        return Colors.deepOrange;
      case 'COMPANY_APPROVAL':
        return Colors.lightGreen;
      case 'JOB_EXPIRED':
        return Colors.amber;
      case 'INTERVIEW_SCHEDULE':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
