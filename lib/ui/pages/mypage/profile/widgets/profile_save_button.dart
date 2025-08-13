// lib/ui/pages/mypage/profile/widgets/profile_save_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/provider/profile_provider.dart';
import 'profile_name_email_fields.dart';

class ProfileSaveButton extends ConsumerWidget {
  const ProfileSaveButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    return Container(
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
            onPressed:
                profileState.isLoading
                    ? null
                    : () => _saveProfile(context, ref),
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
    );
  }

  Future<void> _saveProfile(BuildContext context, WidgetRef ref) async {
    try {
      // ProfileNameEmailFields에서 저장 메서드 호출
      // 이를 위해 GlobalKey를 사용하거나 다른 방법으로 접근해야 함
      // 여기서는 간단하게 현재 상태의 값들을 사용

      final profileState = ref.read(profileProvider);
      if (profileState.userProfile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필 정보를 불러오는 중입니다.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // 실제 구현에서는 form validation과 함께 처리되어야 함
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('저장 기능은 폼과 함께 처리됩니다.'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
