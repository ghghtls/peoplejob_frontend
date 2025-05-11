import 'package:flutter/material.dart';

class ServiceProductRegisterPage extends StatefulWidget {
  const ServiceProductRegisterPage({super.key});

  @override
  State<ServiceProductRegisterPage> createState() =>
      _ServiceProductRegisterPageState();
}

class _ServiceProductRegisterPageState
    extends State<ServiceProductRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final duration = int.tryParse(_durationController.text.trim()) ?? 0;
      final price = int.tryParse(_priceController.text.trim()) ?? 0;

      // TODO: 서버에 등록 요청 보내기

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('상품이 등록되었습니다.')));

      // 초기화
      _formKey.currentState!.reset();
      _nameController.clear();
      _descriptionController.clear();
      _durationController.clear();
      _priceController.clear();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('서비스 상품 등록')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '상품명'),
                validator: (v) => v == null || v.isEmpty ? '상품명을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: '설명'),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? '설명을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '노출 기간 (일)'),
                validator: (v) => v == null || v.isEmpty ? '기간을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '가격 (원)'),
                validator: (v) => v == null || v.isEmpty ? '가격을 입력하세요' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _handleSubmit, child: const Text('등록')),
            ],
          ),
        ),
      ),
    );
  }
}
