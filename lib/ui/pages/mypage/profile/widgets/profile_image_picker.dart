import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../data/provider/profile_provider.dart';

class ProfileImagePicker extends ConsumerWidget {
  const ProfileImagePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          GestureDetector(
            onTap: () => _showImageOptions(context, ref),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(child: _buildProfileImage(profileState)),
            ),
          ),

          // 편집 버튼
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
              onPressed: () => _showImageOptions(context, ref),
            ),
          ),

          // 로딩 오버레이
          if (profileState.isLoading)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(ProfileState state) {
    // 선택된 이미지가 있으면 표시
    if (state.selectedImage != null) {
      return Image.file(
        state.selectedImage!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
      );
    }

    // 기존 프로필 이미지가 있으면 표시
    if (state.userProfile?['profileImageUrl'] != null) {
      return Image.network(
        state.userProfile!['profileImageUrl'],
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
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
    }

    // 기본 아바타
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(Icons.person, size: 60, color: Colors.grey.shade400),
    );
  }

  void _showImageOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    '프로필 이미지 변경',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('카메라로 촬영'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera, ref);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('갤러리에서 선택'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery, ref);
                  },
                ),
                // 기존 이미지가 있으면 삭제 옵션 표시
                if (ref.read(profileProvider).userProfile?['profileImageUrl'] !=
                    null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      '이미지 삭제',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _deleteImage(context, ref);
                    },
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Future<void> _pickImage(ImageSource source, WidgetRef ref) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        ref.read(profileProvider.notifier).selectImage(imageFile);

        // 자동 업로드
        final success =
            await ref.read(profileProvider.notifier).uploadProfileImage();

        if (success) {
          ScaffoldMessenger.of(ref.context).showSnackBar(
            const SnackBar(
              content: Text('프로필 이미지가 업데이트되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(content: Text('이미지 선택 실패: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteImage(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('프로필 이미지 삭제'),
            content: const Text('프로필 이미지를 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('삭제'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final success =
          await ref.read(profileProvider.notifier).deleteProfileImage();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필 이미지가 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
