import 'package:flutter/material.dart';

class CompanyAdsSection extends StatelessWidget {
  const CompanyAdsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      color: Colors.purple[100],
      child: const Center(child: Text('광고기업 공고')),
    );
  }
}
