import 'package:flutter/material.dart';

class TalentSearchPage extends StatefulWidget {
  const TalentSearchPage({super.key});

  @override
  State<TalentSearchPage> createState() => _TalentSearchPageState();
}

class _TalentSearchPageState extends State<TalentSearchPage> {
  final _locationController = TextEditingController();
  String _selectedJob = '모바일 앱 개발자';

  final List<Map<String, String>> _allResumes = [
    {
      'name': '김개발',
      'job': '모바일 앱 개발자',
      'location': '서울',
      'summary': 'Flutter 개발 경력 3년, 스타트업 다수 경험',
    },
    {
      'name': '박프론트',
      'job': '웹 프론트엔드',
      'location': '부산',
      'summary': 'React, Vue 기반 프로젝트 리드 경험',
    },
  ];

  List<Map<String, String>> _filteredResumes = [];

  void _search() {
    setState(() {
      _filteredResumes =
          _allResumes.where((resume) {
            return resume['location']!.contains(_locationController.text) &&
                resume['job'] == _selectedJob;
          }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _filteredResumes = _allResumes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('인재정보 검색')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: '지역'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedJob,
                    items:
                        ['모바일 앱 개발자', '웹 프론트엔드', '백엔드 개발자']
                            .map(
                              (job) => DropdownMenuItem(
                                value: job,
                                child: Text(job),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedJob = value);
                      }
                    },
                    decoration: const InputDecoration(labelText: '직무'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _search, child: const Text('검색')),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredResumes.length,
                itemBuilder: (context, index) {
                  final resume = _filteredResumes[index];
                  return Card(
                    child: ListTile(
                      title: Text('${resume['name']} (${resume['job']})'),
                      subtitle: Text(
                        '${resume['location']} • ${resume['summary']}',
                      ),
                      onTap: () {
                        // TODO: 이력서 상세 페이지 이동
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
