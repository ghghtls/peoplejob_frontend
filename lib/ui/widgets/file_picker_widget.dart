import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/provider/file_upload_provider.dart';

class FilePickerWidget extends ConsumerStatefulWidget {
  final String? initialFileName;
  final String? initialFileUrl;
  final Function(File?) onFileSelected;
  final List<String>? allowedExtensions;
  final FileType fileType;
  final String buttonText;
  final String? helpText;
  final double maxSizeMB;

  const FilePickerWidget({
    super.key,
    this.initialFileName,
    this.initialFileUrl,
    required this.onFileSelected,
    this.allowedExtensions,
    this.fileType = FileType.any,
    this.buttonText = '파일 선택',
    this.helpText,
    this.maxSizeMB = 10.0,
  });

  @override
  ConsumerState<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends ConsumerState<FilePickerWidget> {
  File? _selectedFile;
  String? _currentFileName;
  String? _currentFileUrl;

  @override
  void initState() {
    super.initState();
    _currentFileName = widget.initialFileName;
    _currentFileUrl = widget.initialFileUrl;
  }

  Future<void> _pickFile() async {
    final fileUploadService = ref.read(fileUploadServiceProvider);
    final file = await fileUploadService.pickFile(
      allowedExtensions: widget.allowedExtensions,
      type: widget.fileType,
    );

    if (file != null) {
      // 파일 크기 체크
      if (!fileUploadService.isFileSizeValid(
        file,
        maxSizeMB: widget.maxSizeMB,
      )) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('파일 크기는 ${widget.maxSizeMB}MB 이하여야 합니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // 확장자 체크 (allowedExtensions가 있는 경우)
      if (widget.allowedExtensions != null) {
        if (!fileUploadService.isFileExtensionValid(
          file,
          widget.allowedExtensions!,
        )) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '허용된 파일 형식: ${widget.allowedExtensions!.join(', ')}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      setState(() {
        _selectedFile = file;
        _currentFileName = file.path.split('/').last;
        _currentFileUrl = null; // 새 파일 선택시 기존 URL 제거
      });
      widget.onFileSelected(file);
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _currentFileName = null;
      _currentFileUrl = null;
    });
    widget.onFileSelected(null);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  IconData _getFileIcon() {
    if (_currentFileName == null) return Icons.description;

    final extension = _currentFileName!.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'hwp':
        return Icons.article;
      case 'txt':
        return Icons.text_snippet;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 파일 선택 버튼
        OutlinedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.attach_file),
          label: Text(widget.buttonText),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),

        // 도움말 텍스트
        if (widget.helpText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helpText!,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],

        // 선택된 파일 정보
        if (_hasFile()) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(_getFileIcon(), color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentFileName ?? '파일',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_selectedFile != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          _formatFileSize(_selectedFile!.lengthSync()),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _removeFile,
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  bool _hasFile() {
    return _selectedFile != null ||
        (_currentFileName != null && _currentFileName!.isNotEmpty);
  }
}
