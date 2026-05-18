import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/file_upload_service.dart';
import '../../widgets/app_bar.dart';

class AdminFileManagePage extends ConsumerStatefulWidget {
  const AdminFileManagePage({super.key});

  @override
  ConsumerState<AdminFileManagePage> createState() => _AdminFileManagePageState();
}

class _AdminFileManagePageState extends ConsumerState<AdminFileManagePage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFF2F2F7);
  static const Color _green = Color(0xFF0FA958);
  static const Color _red = Color(0xFFE5342F);

  final FileUploadService _fileService = FileUploadService();
  Map<String, dynamic>? fileListData;
  bool isLoading = false;
  String? selectedType;
  int currentPage = 0;
  static const int _pageSize = 20;

  static const List<String> _fileTypes = ['all', 'resume', 'job', 'board', 'image', 'document'];

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
        page: currentPage, size: _pageSize,
      );
      setState(() { fileListData = data; isLoading = false; });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('파일 목록 로드 실패: $e'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  Future<void> _downloadFile(Map<String, dynamic> file) async {
    try {
      final savePath = await _fileService.downloadFile(file['fileUrl'] as String, fileName: file['fileName'] as String);
      if (savePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('파일 다운로드 완료: $savePath'),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('다운로드 실패: $e'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  Future<void> _deleteFile(Map<String, dynamic> file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('파일 삭제', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('정말로 "${file['fileName']}" 파일을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소', style: TextStyle(color: _secondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('삭제', style: TextStyle(color: _red, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        final success = await _fileService.deleteFile(file['fileUrl'] as String);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('파일이 삭제되었습니다.'),
            backgroundColor: _green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
          _loadFileList();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('삭제 실패: $e'),
            backgroundColor: _red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
      }
    }
  }

  void _showFileDetails(Map<String, dynamic> file) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('파일 정보', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _detailRow('파일명', file['fileName']),
            _detailRow('크기', _fileService.formatFileSize(file['fileSize'])),
            _detailRow('분류', _categoryName(file['category'])),
            _detailRow('경로', file['filePath']),
            _detailRow('수정일', _formatDate(file['lastModified'])),
            _detailRow('이미지', file['isImage'] == true ? '예' : '아니오'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('닫기', style: TextStyle(color: _secondary))),
          TextButton(
            onPressed: () { Navigator.pop(ctx); _downloadFile(file); },
            child: const Text('다운로드', style: TextStyle(color: _blue, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 56, child: Text(label, style: const TextStyle(fontSize: 12, color: _secondary))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12, color: _label, fontWeight: FontWeight.w500))),
      ]),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'all': return '전체';
      case 'resume': return '이력서';
      case 'job': return '채용공고';
      case 'board': return '게시판';
      case 'image': return '이미지';
      case 'document': return '문서';
      default: return type;
    }
  }

  String _categoryName(String cat) {
    switch (cat) {
      case 'resume': return '이력서';
      case 'job': return '채용공고';
      case 'board': return '게시판';
      default: return '기타';
    }
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'resume': return _blue;
      case 'job': return _green;
      case 'board': return const Color(0xFFFF9500);
      default: return _secondary;
    }
  }

  String _formatDate(String s) {
    try {
      final d = DateTime.parse(s);
      return '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')} '
          '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
    } catch (_) { return s; }
  }

  @override
  Widget build(BuildContext context) {
    final files = (fileListData?['content'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final totalPages = fileListData?['totalPages'] as int? ?? 1;
    final hasNext = fileListData?['hasNext'] as bool? ?? false;
    final hasPrevious = fileListData?['hasPrevious'] as bool? ?? false;

    return Scaffold(
      backgroundColor: _bg,
      appBar: buildCommonAppBar(
        title: '파일 관리',
        showHomeButton: false,
        actions: [
          IconButton(
            onPressed: _loadFileList,
            icon: const Icon(Icons.refresh_rounded, size: 20, color: _secondary),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
            // 타입 필터
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                itemCount: _fileTypes.length,
                itemBuilder: (context, index) {
                  final type = _fileTypes[index];
                  final isSelected = selectedType == type || (selectedType == null && type == 'all');
                  return GestureDetector(
                    onTap: () {
                      setState(() { selectedType = type == 'all' ? null : type; currentPage = 0; });
                      _loadFileList();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? _blue : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
                      ),
                      child: Text(_typeLabel(type),
                          style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : _secondary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // 목록
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5))
                  : files.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 72, height: 72,
                          decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
                          child: const Icon(Icons.folder_open_rounded, size: 36, color: _secondary)),
                      const SizedBox(height: 16),
                      const Text('파일이 없습니다', style: TextStyle(fontSize: 15, color: _secondary)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        final file = files[index];
                        final isImage = file['isImage'] as bool? ?? false;
                        final color = _categoryColor(file['category'] as String);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
                          ),
                          child: Material(
                            color: Colors.transparent, borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => _showFileDetails(file),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40, height: 40,
                                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                                      child: Icon(isImage ? Icons.image_rounded : Icons.insert_drive_file_rounded,
                                          size: 20, color: color),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(file['fileName'] as String,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _label),
                                            maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 3),
                                        Text('${_fileService.formatFileSize(file['fileSize'])} · ${_categoryName(file['category'])} · ${_formatDate(file['lastModified'])}',
                                            style: const TextStyle(fontSize: 11, color: _secondary)),
                                      ]),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => _downloadFile(file),
                                      icon: const Icon(Icons.download_rounded, size: 18, color: _blue),
                                      style: IconButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.all(6)),
                                    ),
                                    IconButton(
                                      onPressed: () => _deleteFile(file),
                                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: _red),
                                      style: IconButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.all(6)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // 페이지네이션
            if (fileListData != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  IconButton(
                    onPressed: hasPrevious ? () { setState(() => currentPage--); _loadFileList(); } : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: hasPrevious ? Colors.white : const Color(0xFFF2F2F7),
                      foregroundColor: hasPrevious ? _label : _secondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  Text('${currentPage + 1} / $totalPages',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _label)),
                  IconButton(
                    onPressed: hasNext ? () { setState(() => currentPage++); _loadFileList(); } : null,
                    icon: const Icon(Icons.chevron_right_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: hasNext ? Colors.white : const Color(0xFFF2F2F7),
                      foregroundColor: hasNext ? _label : _secondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ]),
              ),
          ],
      ),
    );
  }
}
