import 'package:flutter/material.dart';

class JobPostRegisterPage extends StatefulWidget {
  const JobPostRegisterPage({super.key});

  @override
  State<JobPostRegisterPage> createState() => _JobPostRegisterPageState();
}

class _JobPostRegisterPageState extends State<JobPostRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _contentController = TextEditingController();

  String _employmentType = '정규직';
  DateTime? _deadline;

  Future<void> _selectDeadline(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // TODO: API 연동
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('채용공고가 등록되었습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('채용공고 등록')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '공고 제목'),
                validator: (value) => value!.isEmpty ? '제목을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: '근무 지역'),
                validator: (value) => value!.isEmpty ? '지역을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _employmentType,
                items:
                    ['정규직', '계약직', '인턴', '프리랜서']
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _employmentType = value);
                },
                decoration: const InputDecoration(labelText: '고용 형태'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(labelText: '급여'),
                validator: (value) => value!.isEmpty ? '급여를 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('마감일'),
                subtitle: Text(
                  _deadline != null
                      ? _deadline!.toLocal().toString().split(' ')[0]
                      : '날짜를 선택하세요',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDeadline(context),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: '공고 내용',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? '내용을 입력하세요' : null,
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
