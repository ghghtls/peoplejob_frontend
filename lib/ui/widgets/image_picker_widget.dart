import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/provider/file_upload_provider.dart';

class ImagePickerWidget extends ConsumerStatefulWidget {
  final String? initialImageUrl;
  final Function(String?) onImageSelected;
  final double size;
  final bool showEditButton;
  final String placeholderText;

  const ImagePickerWidget({
    super.key,
    this.initialImageUrl,
    required this.onImageSelected,
    this.size = 120,
    this.showEditButton = true,
    this.placeholderText = '사진 추가',
  });

  @override
  ConsumerState<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends ConsumerState<ImagePickerWidget> {
  String? _currentImageUrl;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.initialImageUrl;
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('갤러리에서 선택'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('카메라로 촬영'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (_currentImageUrl != null || _selectedImageFile != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('사진 제거'),
                    onTap: () {
                      Navigator.pop(context);
                      _removeImage();
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('취소'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final fileUploadService = ref.read(fileUploadServiceProvider);
    final imageFile = await fileUploadService.pickImage(source: source);

    if (imageFile != null) {
      setState(() {
        _selectedImageFile = imageFile;
        _currentImageUrl = null;
      });
      widget.onImageSelected(imageFile.path);
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageFile = null;
      _currentImageUrl = null;
    });
    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: widget.showEditButton ? _showImageSourceDialog : null,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: ClipOval(child: _buildImageContent()),
          ),
        ),
        if (widget.showEditButton) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _showImageSourceDialog,
            icon: Icon(_hasImage() ? Icons.edit : Icons.add_a_photo, size: 16),
            label: Text(
              _hasImage() ? '사진 변경' : widget.placeholderText,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageContent() {
    if (_selectedImageFile != null) {
      return Image.file(_selectedImageFile!, fit: BoxFit.cover);
    } else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      return Image.network(
        _currentImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
            ),
          );
        },
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade100,
      ),
      child: Icon(
        Icons.person,
        size: widget.size * 0.5,
        color: Colors.grey.shade400,
      ),
    );
  }

  bool _hasImage() {
    return _selectedImageFile != null ||
        (_currentImageUrl != null && _currentImageUrl!.isNotEmpty);
  }
}
