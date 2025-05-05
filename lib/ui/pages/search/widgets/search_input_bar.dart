import 'package:flutter/material.dart';

class SearchInputBar extends StatelessWidget {
  const SearchInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: '검색어를 입력하세요',
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 검색 API 연동
              print("검색 실행");
            },
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
