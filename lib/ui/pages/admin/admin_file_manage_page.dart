// admin_file_manage_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/file_upload_service.dart';

class AdminFileManagePage extends ConsumerStatefulWidget {
  const AdminFileManagePage({super.key});

  @override
  ConsumerState<AdminFileManagePage> createState() =>
      _AdminFileManagePageState();
}

class _AdminFileManagePageState extends ConsumerState<AdminFileManagePage> {
  final FileUploadService _fileService = FileUploadService();
  Map<String, dynamic>? fileListData;
  bool isLoading = false;
  String? selectedType;
  int currentPage = 0;
  final int pageSize = 20;

  final List<String> fileTypes = [
    'all',
    'resume',
    'job',
    'board',
    'image',
    'document',
  ];

  @override
  void initState() {
    super.initState();
    _loadFileList();
  }

  Future<void> _loadFileList() async {
    setState(() => isLoading = true);
    try {
      final data = await _fileService.getFileList(
        type: selectedType == 'all' ? null : selectedType,
        page: currentPage,
        size: pageSize,
      );
      setState(() {
        fileListData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('파일 목록 로드 실패: $e')));
    }
  }

  Future<void> _downloadFile(Map<String, dynamic> fileInfo) async {
    try {
      final fileUrl = fileInfo['fileUrl'] as String;
      final fileName = fileInfo['fileName'] as String;

      final savePath = await _fileService.downloadFile(
        fileUrl,
        fileName: fileName,
      );
      if (savePath != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('파일 다운로드 완료: $savePath')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('다운로드 실패: $e')));
    }
  }

  Future<void> _deleteFile(Map<String, dynamic> fileInfo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('파일 삭제'),
            content: Text('정말로 "${fileInfo['fileName']}" 파일을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('삭제'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final fileUrl = fileInfo['fileUrl'] as String;
        final success = await _fileService.deleteFile(fileUrl);
        if (success && mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('파일이 삭제되었습니다.')));
          _loadFileList(); // 목록 새로고침
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
      }
    }
  }

  Widget _buildFileTypeFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: fileTypes.length,
        itemBuilder: (context, index) {
          final type = fileTypes[index];
          final isSelected =
              selectedType == type || (selectedType == null && type == 'all');

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getTypeDisplayName(type)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedType = type == 'all' ? null : type;
                  currentPage = 0;
                });
                _loadFileList();
              },
            ),
          );
        },
      ),
    );
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'all':
        return '전체';
      case 'resume':
        return '이력서';
      case 'job':
        return '채용공고';
      case 'board':
        return '게시판';
      case 'image':
        return '이미지';
      case 'document':
        return '문서';
      default:
        return type;
    }
  }

  Widget _buildFileList() {
    if (fileListData == null) return const SizedBox.shrink();

    final files = fileListData!['content'] as List;
    if (files.isEmpty) {
      return const Center(child: Text('파일이 없습니다.'));
    }

    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index] as Map<String, dynamic>;
        return _buildFileItem(file);
      },
    );
  }

  Widget _buildFileItem(Map<String, dynamic> file) {
    final fileName = file['fileName'] as String;
    final fileSize = file['fileSize'] as int;
    final category = file['category'] as String;
    final isImage = file['isImage'] as bool? ?? false;
    final lastModified = file['lastModified'] as String;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          isImage ? Icons.image : Icons.insert_drive_file,
          color: _getCategoryColor(category),
        ),
        title: Text(
          fileName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('크기: ${_fileService.formatFileSize(fileSize)}'),
            Text('분류: ${_getCategoryDisplayName(category)}'),
            Text('수정일: ${_formatDateTime(lastModified)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download, color: Colors.blue),
              onPressed: () => _downloadFile(file),
              tooltip: '다운로드',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteFile(file),
              tooltip: '삭제',
            ),
          ],
        ),
        onTap: () => _showFileDetails(file),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'resume':
        return Colors.blue;
      case 'job':
        return Colors.green;
      case 'board':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'resume':
        return '이력서';
      case 'job':
        return '채용공고';
      case 'board':
        return '게시판';
      default:
        return '기타';
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  void _showFileDetails(Map<String, dynamic> file) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('파일 정보'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('파일명: ${file['fileName']}'),
                Text('크기: ${_fileService.formatFileSize(file['fileSize'])}'),
                Text('분류: ${_getCategoryDisplayName(file['category'])}'),
                Text('경로: ${file['filePath']}'),
                Text('수정일: ${_formatDateTime(file['lastModified'])}'),
                Text('이미지: ${file['isImage'] ? '예' : '아니오'}'),
                Text('문서: ${file['isDocument'] ? '예' : '아니오'}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _downloadFile(file);
                },
                child: const Text('다운로드'),
              ),
            ],
          ),
    );
  }

  Widget _buildPagination() {
    if (fileListData == null) return const SizedBox.shrink();

    final totalPages = fileListData!['totalPages'] as int;
    final hasNext = fileListData!['hasNext'] as bool;
    final hasPrevious = fileListData!['hasPrevious'] as bool;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed:
                hasPrevious
                    ? () {
                      setState(() => currentPage--);
                      _loadFileList();
                    }
                    : null,
            child: const Text('이전'),
          ),
          Text('${currentPage + 1} / $totalPages'),
          ElevatedButton(
            onPressed:
                hasNext
                    ? () {
                      setState(() => currentPage++);
                      _loadFileList();
                    }
                    : null,
            child: const Text('다음'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('파일 관리'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadFileList),
        ],
      ),
      body: Column(
        children: [
          _buildFileTypeFilter(),
          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(child: _buildFileList()),
          _buildPagination(),
        ],
      ),
    );
  }
}
