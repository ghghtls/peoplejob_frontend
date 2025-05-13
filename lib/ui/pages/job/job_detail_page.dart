import 'package:flutter/material.dart';
import 'widgets/job_detail_header.dart';
import 'widgets/job_detail_content.dart';
import 'widgets/apply_button.dart';

class JobDetailPage extends StatelessWidget {
  final String title;
  final String company;
  final String location;
  final String description;

  const JobDetailPage({
    super.key,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JobDetailHeader(title: title, company: company, location: location),
            const SizedBox(height: 16),
            JobDetailContent(description: description),
            const SizedBox(height: 80), // 하단 버튼 공간 확보
          ],
        ),
      ),
      bottomSheet: ApplyButton(jobTitle: title), //
    );
  }
}
