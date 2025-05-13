import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peoplejob_frontend/data/provider/resume_providers.dart';
import 'address_search_page.dart';

class ResumeAddressField extends ConsumerStatefulWidget {
  const ResumeAddressField({super.key});

  @override
  ConsumerState<ResumeAddressField> createState() => _ResumeAddressFieldState();
}

class _ResumeAddressFieldState extends ConsumerState<ResumeAddressField> {
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(resumeAddressProvider);
    _addressController = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _addressController,
      readOnly: true,
      decoration: const InputDecoration(labelText: '주소'),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddressSearchPage()),
        );
        if (result != null && result is String) {
          setState(() {
            _addressController.text = result;
            ref.read(resumeAddressProvider.notifier).state = result;
          });
        }
      },
    );
  }
}
