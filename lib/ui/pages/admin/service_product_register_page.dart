import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/app_bar.dart';

class ServiceProductRegisterPage extends StatefulWidget {
  const ServiceProductRegisterPage({super.key});

  @override
  State<ServiceProductRegisterPage> createState() => _ServiceProductRegisterPageState();
}

class _ServiceProductRegisterPageState extends State<ServiceProductRegisterPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _green = Color(0xFF0FA958);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('상품이 등록되었습니다.'),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      _formKey.currentState!.reset();
      _nameController.clear();
      _descriptionController.clear();
      _durationController.clear();
      _priceController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(title: '서비스 상품 등록', showHomeButton: false),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('상품명'),
                  _textField(controller: _nameController, hint: '상품명을 입력하세요',
                      validator: (v) => v == null || v.isEmpty ? '상품명을 입력하세요' : null),
                  const SizedBox(height: 16),
                  _fieldLabel('설명'),
                  _textField(controller: _descriptionController, hint: '상품 설명을 입력하세요',
                      maxLines: 3, validator: (v) => v == null || v.isEmpty ? '설명을 입력하세요' : null),
                  const SizedBox(height: 16),
                  _fieldLabel('노출 기간 (일)'),
                  _textField(controller: _durationController, hint: '예: 7',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => v == null || v.isEmpty ? '기간을 입력하세요' : null),
                  const SizedBox(height: 16),
                  _fieldLabel('가격 (원)'),
                  _textField(controller: _priceController, hint: '예: 50000',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => v == null || v.isEmpty ? '가격을 입력하세요' : null),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('등록하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _secondary)),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: _label),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _secondary, fontSize: 13),
        filled: true, fillColor: _bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _blue, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5342F))),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5342F), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}
