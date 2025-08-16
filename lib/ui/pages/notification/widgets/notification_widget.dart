import 'package:flutter/material.dart';
import 'package:peoplejob_frontend/data/provider/notification_provider.dart';
import 'package:peoplejob_frontend/ui/pages/notification/notification_page.dart';
import 'package:provider/provider.dart';

/// 알림 아이콘과 뱃지를 표시하는 위젯
class NotificationBadge extends StatefulWidget {
  final String token;
  final Color? iconColor;
  final double? iconSize;

  const NotificationBadge({
    Key? key,
    required this.token,
    this.iconColor,
    this.iconSize,
  }) : super(key: key);

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUnreadCount();
    });
  }

  void _refreshUnreadCount() {
    context.read<NotificationProvider>().refreshUnreadCount(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: widget.iconColor ?? Colors.white,
                size: widget.iconSize ?? 24,
              ),
              onPressed: () => _navigateToNotifications(context),
              tooltip: '알림 보기',
            ),
            if (provider.unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    provider.unreadCount > 99
                        ? '99+'
                        : provider.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => NotificationPage(token: widget.token),
          ),
        )
        .then((_) {
          // 알림 페이지에서 돌아온 후 개수 새로고침
          _refreshUnreadCount();
        });
  }
}

/// 최근 알림을 간단히 표시하는 드롭다운 위젯
class NotificationDropdown extends StatefulWidget {
  final String token;
  final Widget child;

  const NotificationDropdown({
    Key? key,
    required this.token,
    required this.child,
  }) : super(key: key);

  @override
  State<NotificationDropdown> createState() => _NotificationDropdownState();
}

class _NotificationDropdownState extends State<NotificationDropdown> {
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (_isOpen) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });

    // 최근 알림 로드
    context.read<NotificationProvider>().loadUnreadNotifications(widget.token);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_isOpen) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder:
          (context) => Positioned(
            left: offset.dx,
            top: offset.dy + size.height,
            width: 300,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '최근 알림',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              _closeDropdown();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          NotificationPage(token: widget.token),
                                ),
                              );
                            },
                            child: const Text(
                              '모두 보기',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Consumer<NotificationProvider>(
                        builder: (context, provider, child) {
                          if (provider.unreadNotifications.isEmpty) {
                            return const Center(child: Text('새로운 알림이 없습니다.'));
                          }

                          // 안전하게 5개까지만 잘라서 사용
                          final items =
                              provider.unreadNotifications.take(5).toList();

                          return ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final notification = items[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: _getTypeColor(
                                    notification.type,
                                  ),
                                  child: Text(
                                    _getTypeIcon(notification.type),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                title: Text(
                                  notification.title,
                                  style: const TextStyle(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  notification.message,
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(
                                  notification.timeAgo,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                onTap: () {
                                  _closeDropdown();
                                  provider.markAsRead(
                                    widget.token,
                                    notification.id,
                                  );
                                  // 알림 관련 페이지로 이동
                                  if (notification.actionUrl != null) {
                                    _navigateToActionUrl(
                                      notification.actionUrl!,
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: _toggleDropdown, child: widget.child);
  }

  void _navigateToActionUrl(String actionUrl) {
    debugPrint('Navigate to: $actionUrl');
    // 실제 라우팅 로직 구현
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
      default:
        return '🔔';
    }
  }

  Color _getTypeColor(String type) {
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
      default:
        return Colors.grey;
    }
  }
}

/// 간단한 알림 토스트 위젯
class NotificationToast {
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = Colors.black87,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }
}
