import 'package:flutter/material.dart';

class PopupRegisterForm extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? initialValues;

  const PopupRegisterForm({super.key, this.isEdit = false, this.initialValues});

  @override
  State<PopupRegisterForm> createState() => _PopupRegisterFormState();
}

class _PopupRegisterFormState extends State<PopupRegisterForm> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late bool isActive;
  DateTime? startDate;
  DateTime? endDate;
  String? imagePath;

  @override
  void initState() {
    super.initState();
    title = widget.initialValues?['title'] ?? '';
    isActive = widget.initialValues?['isActive'] ?? true;
    startDate = widget.initialValues?['startDate'];
    endDate = widget.initialValues?['endDate'];
    imagePath = widget.initialValues?['imagePath'];
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: title,
            decoration: const InputDecoration(labelText: '팝업 제목'),
            validator:
                (value) =>
                    value == null || value.isEmpty ? '필수 입력 항목입니다' : null,
            onSaved: (value) => title = value!,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDatePickerButton('시작일', startDate, (picked) {
                setState(() => startDate = picked);
              }),
              const SizedBox(width: 10),
              _buildDatePickerButton('종료일', endDate, (picked) {
                setState(() => endDate = picked);
              }),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: 이미지 업로드 구현
              setState(() => imagePath = 'assets/sample_image.png');
            },
            child: const Text('이미지 업로드'),
          ),
          if (imagePath != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('업로드된 이미지: $imagePath'),
            ),
          SwitchListTile(
            title: const Text('사용 여부'),
            value: isActive,
            onChanged: (val) => setState(() => isActive = val),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                // TODO: 등록 또는 수정 처리
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(widget.isEdit ? '팝업 수정 완료' : '팝업 등록 완료'),
                  ),
                );
              }
            },
            child: Text(widget.isEdit ? '수정' : '등록'),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerButton(
    String label,
    DateTime? value,
    ValueChanged<DateTime> onDatePicked,
  ) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            onDatePicked(picked);
          }
        },
        child: Text(
          value == null
              ? '$label 선택'
              : '$label: ${value.toLocal()}'.split(' ')[0],
        ),
      ),
    );
  }
}
