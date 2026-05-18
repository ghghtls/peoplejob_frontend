import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/payment_service.dart';
import '../../widgets/app_bar.dart';

class PaymentSchedulePage extends StatefulWidget {
  const PaymentSchedulePage({super.key});

  @override
  State<PaymentSchedulePage> createState() => _PaymentSchedulePageState();
}

class _PaymentSchedulePageState extends State<PaymentSchedulePage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _orange = Color(0xFFFF9500);

  final PaymentService _paymentService = PaymentService();

  DateTime? _selectedDate;
  int _selectedDuration = 7;
  bool _isProcessing = false;

  static const List<int> _durations = [7, 14, 30];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _blue),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _processPayment(Map<String, dynamic> args) async {
    if (_selectedDate == null || _isProcessing) return;
    setState(() => _isProcessing = true);

    final productName = args['productName'] as String? ?? '';
    final price = args['price'] as int? ?? 0;
    final jobTitle = args['jobTitle'] as String? ?? '';
    final jobNo = args['jobNo'] as int?;
    final endDate = _selectedDate!.add(Duration(days: _selectedDuration - 1));
    final description =
        '$productName - $jobTitle (${DateFormat('yyyy.MM.dd').format(_selectedDate!)} ~ ${DateFormat('yyyy.MM.dd').format(endDate)})';

    final result = await _paymentService.processPayment(
      amount: price,
      paymentMethod: '카드',
      description: description,
      jobNo: jobNo,
      adEndDate: '${DateFormat('yyyy-MM-dd').format(endDate)}T23:59:59',
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (result['success'] == true) {
      Navigator.pushReplacementNamed(context, '/payment/result', arguments: {
        'success': true,
        'productName': productName,
        'jobTitle': jobTitle,
        'amount': price,
        'startDate': DateFormat('yyyy.MM.dd').format(_selectedDate!),
        'endDate': DateFormat('yyyy.MM.dd').format(endDate),
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] as String? ?? '결제에 실패했습니다.'),
          backgroundColor: const Color(0xFFE5342F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final productName = args['productName'] as String? ?? '';
    final price = args['price'] as int? ?? 0;
    final jobTitle = args['jobTitle'] as String? ?? '';

    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(title: '광고 일정 설정'),
      body: Column(
        children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 선택 요약 카드
                    if (productName.isNotEmpty || jobTitle.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Column(
                          children: [
                            _summaryRow('공고', jobTitle, _label),
                            const SizedBox(height: 8),
                            _summaryRow('상품', productName, _blue),
                            const SizedBox(height: 8),
                            _summaryRow('금액', '${_formatPrice(price)}원', _orange),
                          ],
                        ),
                      ),

                    // 시작일 선택
                    const Text('광고 시작일',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: -0.2)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(color: _blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.calendar_today_rounded, size: 20, color: _blue),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('시작일 선택', style: TextStyle(fontSize: 12, color: _secondary)),
                                  const SizedBox(height: 2),
                                  Text(
                                    _selectedDate != null
                                        ? DateFormat('yyyy년 M월 d일').format(_selectedDate!)
                                        : '날짜를 선택하세요',
                                    style: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w600,
                                      color: _selectedDate != null ? _label : _secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFE5E5EA)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 기간 선택
                    const Text('광고 기간',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: -0.2)),
                    const SizedBox(height: 8),
                    Row(
                      children: _durations.map((days) {
                        final isSelected = _selectedDuration == days;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedDuration = days),
                            child: Container(
                              margin: EdgeInsets.only(right: days != _durations.last ? 8 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? _blue : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: isSelected ? null : Border.all(color: const Color(0xFFE5E5EA)),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: _blue.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
                                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
                              ),
                              child: Column(
                                children: [
                                  Text('$days일',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                                          color: isSelected ? Colors.white : _label)),
                                  const SizedBox(height: 2),
                                  Text(days == 7 ? '1주' : days == 14 ? '2주' : '1개월',
                                      style: TextStyle(fontSize: 11,
                                          color: isSelected ? Colors.white.withValues(alpha: 0.8) : _secondary)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    if (_selectedDate != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _orange.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _orange.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            _summaryRow('시작일', DateFormat('yyyy.MM.dd').format(_selectedDate!), _label),
                            const SizedBox(height: 8),
                            _summaryRow('종료일', DateFormat('yyyy.MM.dd').format(
                                _selectedDate!.add(Duration(days: _selectedDuration - 1))), _label),
                            const SizedBox(height: 8),
                            _summaryRow('광고 기간', '$_selectedDuration일', _label),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (_selectedDate != null && !_isProcessing)
                      ? () => _processPayment(args)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    disabledBackgroundColor: _secondary.withValues(alpha: 0.3),
                  ),
                  child: _isProcessing
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text('${_formatPrice(price)} 결제하기',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
          ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: _secondary)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  String _formatPrice(int price) {
    final s = price.toString();
    final result = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write(',');
      result.write(s[i]);
    }
    return result.toString();
  }
}
