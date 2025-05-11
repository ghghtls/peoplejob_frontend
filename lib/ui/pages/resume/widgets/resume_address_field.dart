import 'package:flutter/material.dart';
import 'address_search_page.dart';

class ResumeAddressField extends StatefulWidget {
  const ResumeAddressField({super.key});

  @override
  State<ResumeAddressField> createState() => _ResumeAddressFieldState();
}

class _ResumeAddressFieldState extends State<ResumeAddressField> {
  final TextEditingController _addressController = TextEditingController();

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
        if (result != null) {
          setState(() {
            _addressController.text = result;
          });
        }
      },
    );
  }
}
