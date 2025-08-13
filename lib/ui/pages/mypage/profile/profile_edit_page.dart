// lib/ui/pages/mypage/profile/profile_edit_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/profile_image_picker.dart';
import 'widgets/profile_name_email_fields.dart';
import '../../../../data/provider/profile_provider.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  // ✅ GlobalKey를 사용해서 자식 위젯의 메서드에 접근
  final GlobalKey<ProfileNameEmailFieldsState> _formKey =
      GlobalKey<ProfileNameEmailFieldsState>();

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 편집'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: profileState.isLoading ? null : _saveProfile,
            child: Text(
              '저장',
              style: TextStyle(
                color:
                    profileState.isLoading
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(profileProvider.notifier).loadProfile();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 프로필 이미지
              const ProfileImagePicker(),
              const SizedBox(height: 32),

              // ✅ key를 전달해서 접근 가능하게 함
              ProfileNameEmailFields(key: _formKey),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: profileState.isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child:
                  profileState.isLoading
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('저장 중...'),
                        ],
                      )
                      : const Text(
                        '저장하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    // ✅ 자식 위젯의 saveProfile 메서드 호출
    if (_formKey.currentState != null) {
      final success = await _formKey.currentState!.saveProfile();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필이 성공적으로 저장되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final error = ref.read(profileProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? '프로필 저장에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
