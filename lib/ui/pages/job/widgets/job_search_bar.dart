import 'package:flutter/material.dart';

class JobSearchBar extends StatelessWidget {
  const JobSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: '검색어를 입력하세요',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onSubmitted: (value) {
        // TODO: 검색 API 연동
        print('검색어: $value');
      },
    );
  }
}
