import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/app_bar.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  static const Color _blue      = Color(0xFF0B5FFF);
  static const Color _label     = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg        = Color(0xFFF2F2F7);
  static const Color _green     = Color(0xFF34C759);

  // 설정 키
  static const _kAll            = 'notif_all';
  static const _kJobApplication = 'notif_job_application';
  static const _kJobStatus      = 'notif_job_status';
  static const _kNewJob         = 'notif_new_job';
  static const _kResumeView     = 'notif_resume_view';
  static const _kMessage        = 'notif_message';
  static const _kSystem         = 'notif_system';
  static const _kPayment        = 'notif_payment';

  bool _allEnabled      = true;
  bool _jobApplication  = true;
  bool _jobStatus       = true;
  bool _newJob          = true;
  bool _resumeView      = true;
  bool _message         = true;
  bool _system          = true;
  bool _payment         = true;
  bool _loading         = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allEnabled     = prefs.getBool(_kAll)            ?? true;
      _jobApplication = prefs.getBool(_kJobApplication) ?? true;
      _jobStatus      = prefs.getBool(_kJobStatus)      ?? true;
      _newJob         = prefs.getBool(_kNewJob)         ?? true;
      _resumeView     = prefs.getBool(_kResumeView)     ?? true;
      _message        = prefs.getBool(_kMessage)        ?? true;
      _system         = prefs.getBool(_kSystem)         ?? true;
      _payment        = prefs.getBool(_kPayment)        ?? true;
      _loading        = false;
    });
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _toggleAll(bool value) {
    setState(() {
      _allEnabled     = value;
      _jobApplication = value;
      _jobStatus      = value;
      _newJob         = value;
      _resumeView     = value;
      _message        = value;
      _system         = value;
      _payment        = value;
    });
    _save(_kAll, value);
    _save(_kJobApplication, value);
    _save(_kJobStatus, value);
    _save(_kNewJob, value);
    _save(_kResumeView, value);
    _save(_kMessage, value);
    _save(_kSystem, value);
    _save(_kPayment, value);
  }

  void _updateAll() {
    final anyOn = _jobApplication || _jobStatus || _newJob ||
        _resumeView || _message || _system || _payment;
    if (_allEnabled != anyOn) {
      setState(() => _allEnabled = anyOn);
      _save(_kAll, anyOn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(title: '알림 설정'),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _masterToggleCard(),
                const SizedBox(height: 20),
                _sectionTitle('알림 유형'),
                _settingsGroup([
                  _NotifItem(
                    icon: '📝', label: '채용공고 지원',
                    description: '내가 지원한 채용공고의 새 지원 알림',
                    value: _jobApplication,
                    onChanged: (v) {
                      setState(() => _jobApplication = v);
                      _save(_kJobApplication, v);
                      _updateAll();
                    },
                  ),
                  _NotifItem(
                    icon: '📊', label: '지원 상태 변경',
                    description: '합격·불합격·검토중 등 지원 결과 알림',
                    value: _jobStatus,
                    onChanged: (v) {
                      setState(() => _jobStatus = v);
                      _save(_kJobStatus, v);
                      _updateAll();
                    },
                  ),
                  _NotifItem(
                    icon: '💼', label: '새 채용공고',
                    description: '관심 직종의 새 채용공고 등록 알림',
                    value: _newJob,
                    onChanged: (v) {
                      setState(() => _newJob = v);
                      _save(_kNewJob, v);
                      _updateAll();
                    },
                  ),
                  _NotifItem(
                    icon: '👀', label: '이력서 열람',
                    description: '기업이 내 이력서를 조회했을 때 알림',
                    value: _resumeView,
                    onChanged: (v) {
                      setState(() => _resumeView = v);
                      _save(_kResumeView, v);
                      _updateAll();
                    },
                  ),
                  _NotifItem(
                    icon: '💬', label: '메시지',
                    description: '새 메시지 수신 알림',
                    value: _message,
                    onChanged: (v) {
                      setState(() => _message = v);
                      _save(_kMessage, v);
                      _updateAll();
                    },
                  ),
                  _NotifItem(
                    icon: '💳', label: '결제',
                    description: '결제 완료 및 광고 만료 알림',
                    value: _payment,
                    onChanged: (v) {
                      setState(() => _payment = v);
                      _save(_kPayment, v);
                      _updateAll();
                    },
                  ),
                  _NotifItem(
                    icon: '⚙️', label: '시스템',
                    description: '서비스 점검·업데이트 등 공지 알림',
                    value: _system,
                    onChanged: (v) {
                      setState(() => _system = v);
                      _save(_kSystem, v);
                      _updateAll();
                    },
                    isLast: true,
                  ),
                ]),
                const SizedBox(height: 12),
                _infoCard(),
              ],
            ),
    );
  }

  Widget _masterToggleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _allEnabled
              ? [const Color(0xFF0B5FFF), const Color(0xFF4DA3FF)]
              : [const Color(0xFF8E8E93), const Color(0xFFAEAEB2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (_allEnabled ? _blue : _secondary).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _allEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
              color: Colors.white, size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('알림 전체',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(
                  _allEnabled ? '모든 알림을 수신 중입니다' : '모든 알림이 꺼져 있습니다',
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          Switch(
            value: _allEnabled,
            onChanged: _toggleAll,
            activeThumbColor: Colors.white,
            activeTrackColor: _green.withValues(alpha: 0.8),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _secondary, letterSpacing: -0.2)),
    );
  }

  Widget _settingsGroup(List<_NotifItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast  = item.isLast;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(item.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.label,
                              style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500,
                                color: _label,
                                letterSpacing: -0.2,
                              )),
                          const SizedBox(height: 2),
                          Text(item.description,
                              style: const TextStyle(fontSize: 12, color: _secondary, letterSpacing: -0.1)),
                        ],
                      ),
                    ),
                    Switch(
                      value: item.value,
                      onChanged: item.onChanged,
                      activeThumbColor: _blue,
                      inactiveThumbColor: _secondary,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(height: 1, indent: 60, color: Color(0xFFF2F2F7)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _blue.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: _blue),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '알림은 30초 간격으로 서버에서 가져옵니다. 전체 알림을 끄면 폴링도 중단됩니다.',
              style: TextStyle(fontSize: 12, color: _blue, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifItem {
  final String icon;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isLast;

  const _NotifItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });
}
