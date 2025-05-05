import 'package:flutter/material.dart';
import 'widgets/search_input_bar.dart';
import 'widgets/search_job_result.dart';
import 'widgets/search_resume_result.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hasKeyword = true; // TODO: 상태 연동 (입력값 기반)
    return Scaffold(
      appBar: AppBar(title: const Text("통합 검색")),
      body: Column(
        children: [
          const SearchInputBar(),
          Expanded(
            child:
                hasKeyword
                    ? ListView(
                      padding: const EdgeInsets.all(16),
                      children: const [
                        SearchJobResult(),
                        SizedBox(height: 16),
                        SearchResumeResult(),
                      ],
                    )
                    : const Center(child: Text('검색어를 입력하세요')),
          ),
        ],
      ),
    );
  }
}
