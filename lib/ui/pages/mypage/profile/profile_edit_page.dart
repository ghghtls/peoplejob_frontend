import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/profile_image_picker.dart';
import 'widgets/profile_name_email_fields.dart';
import '../../../../data/provider/profile_provider.dart';
import '../../../widgets/app_bar.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  static const Color _blue = Color(0xFF0B5FFF);
  static const Color _label = Color(0xFF0B1220);
  static const Color _secondary = Color(0xFF8E8E93);
  static const Color _green = Color(0xFF0FA958);
  static const Color _red = Color(0xFFE5342F);

  final GlobalKey<ProfileNameEmailFieldsState> _formKey =
      GlobalKey<ProfileNameEmailFieldsState>();

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    // 프로필 미로드 + 에러 상태
    final hasError = profileState.error != null && profileState.userProfile == null;
    // 최초 로딩 중 (프로필 없고, 에러 없음)
    final isInitialLoading = profileState.isLoading && profileState.userProfile == null;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: buildCommonAppBar(
        title: '프로필 편집',
        actions: [
          TextButton(
            onPressed: (profileState.isLoading || isInitialLoading) ? null : _saveProfile,
            style: TextButton.styleFrom(
              foregroundColor: _blue, minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: Text(
              '저장',
              style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600,
                color: profileState.isLoading ? _secondary : _blue,
              ),
            ),
          ),
        ],
      ),
      body: isInitialLoading
          ? const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5))
          : hasError
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: _red, size: 48),
                        const SizedBox(height: 16),
                        const Text('프로필을 불러오지 못했습니다',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _label)),
                        const SizedBox(height: 8),
                        Text(profileState.error ?? '',
                            style: const TextStyle(fontSize: 13, color: _secondary),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => ref.read(profileProvider.notifier).loadProfile(),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('다시 시도'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _blue, elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
        children: [
          Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(profileProvider.notifier).loadProfile(),
                color: _blue,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  child: Column(
                    children: [
                      const ProfileImagePicker(),
                      const SizedBox(height: 24),
                      ProfileNameEmailFields(key: _formKey),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      bottomSheet: (isInitialLoading || hasError) ? null : Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: profileState.isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                disabledBackgroundColor: _secondary.withValues(alpha: 0.3),
              ),
              child: profileState.isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                        SizedBox(width: 10),
                        Text('저장 중...', style: TextStyle(fontSize: 15, color: Colors.white)),
                      ],
                    )
                  : const Text('저장하기',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState == null) return;
    final success = await _formKey.currentState!.saveProfile();
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('프로필이 성공적으로 저장되었습니다.'),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } else {
      final error = ref.read(profileProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error ?? '프로필 저장에 실패했습니다.'),
        backgroundColor: _red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }
}
