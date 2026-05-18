import 'package:flutter/material.dart';
import '../../../services/payment_service.dart';
import '../../widgets/app_bar.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _green = Color(0xFF0FA958);
  static const Color _orange = Color(0xFFFF9500);
  static const Color _red = Color(0xFFE5342F);

  final PaymentService _paymentService = PaymentService();
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final list = await _paymentService.getMyPayments();
      setState(() {
        _payments = list.map((e) => (e as Map).cast<String, dynamic>()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  String _formatPrice(dynamic amount) {
    final price = (amount is num) ? amount.toInt() : int.tryParse(amount.toString()) ?? 0;
    final s = price.toString();
    final result = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write(',');
      result.write(s[i]);
    }
    return '$result원';
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
      case 'SUCCESS': return _green;
      case 'PENDING': return _orange;
      case 'CANCELLED':
      case 'CANCELED':
      case 'FAILED': return _red;
      default: return _secondary;
    }
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
      case 'SUCCESS': return '결제완료';
      case 'PENDING': return '처리중';
      case 'CANCELLED':
      case 'CANCELED': return '취소됨';
      case 'FAILED': return '실패';
      default: return status;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      return dateStr.split('T').first;
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(title: '광고 결제 내역'),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('결제 내역을 불러올 수 없습니다',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600])),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadPayments,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('다시 시도'),
              style: OutlinedButton.styleFrom(foregroundColor: _blue, side: const BorderSide(color: _blue)),
            ),
          ],
        ),
      );
    }

    if (_payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.receipt_long_outlined, size: 36, color: _secondary),
            ),
            const SizedBox(height: 16),
            const Text('결제 내역이 없습니다',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _label)),
            const SizedBox(height: 6),
            const Text('광고를 신청하면 여기에 표시됩니다',
                style: TextStyle(fontSize: 14, color: _secondary)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/payment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('광고 신청하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }

    // 총액 계산
    final totalPaid = _payments
        .where((p) => ['PAID', 'SUCCESS'].contains((p['paymentStatus'] as String? ?? '').toUpperCase()))
        .fold<int>(0, (sum, p) {
      final amt = p['amount'];
      return sum + ((amt is num) ? amt.toInt() : int.tryParse(amt.toString()) ?? 0);
    });

    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          // 요약 카드
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B5FFF), Color(0xFF5A99FF)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('총 결제 금액', style: TextStyle(fontSize: 13, color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text(_formatPrice(totalPaid),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('전체 건수', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text('${_payments.length}건',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('결제 내역',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: -0.2)),
          ),

          ..._payments.map((payment) {
            final status = payment['paymentStatus'] as String? ?? '';
            final statusColor = _statusColor(status);
            final description = payment['description'] as String? ?? '광고 결제';
            final date = _formatDate(payment['paymentDate'] as String?);
            final amount = payment['amount'];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.campaign_rounded, size: 22, color: statusColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(description,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _label),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(_statusLabel(status),
                                    style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                              ),
                              if (date.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Text(date, style: const TextStyle(fontSize: 11, color: _secondary)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_formatPrice(amount),
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: ['CANCELLED', 'CANCELED', 'FAILED'].contains(status.toUpperCase())
                              ? _secondary : _label,
                          decoration: ['CANCELLED', 'CANCELED'].contains(status.toUpperCase())
                              ? TextDecoration.lineThrough : null,
                        )),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
