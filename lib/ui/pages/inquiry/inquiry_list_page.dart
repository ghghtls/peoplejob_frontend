import 'package:flutter/material.dart';
import 'package:peoplejob_frontend/ui/pages/inquiry/inquiry_form_page.dart';
import 'widgets/inquiry_list_view.dart';
import 'widgets/empty_inquiry_message.dart';
import 'widgets/add_inquiry_button.dart';

class InquiryListPage extends StatelessWidget {
  const InquiryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hasInquiry = true; // TODO: 상태로 변경

    return Scaffold(
      appBar: AppBar(title: const Text('문의 내역')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            hasInquiry ? const InquiryListView() : const EmptyInquiryMessage(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InquiryFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
