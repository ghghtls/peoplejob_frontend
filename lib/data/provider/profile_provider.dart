import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../services/auth_service.dart';

// 프로필 정보 상태
class ProfileState {
  final Map<String, dynamic>? userProfile;
  final bool isLoading;
  final String? error;
  final File? selectedImage;

  ProfileState({
    this.userProfile,
    this.isLoading = false,
    this.error,
    this.selectedImage,
  });

  ProfileState copyWith({
    Map<String, dynamic>? userProfile,
    bool? isLoading,
    String? error,
    File? selectedImage,
  }) {
    return ProfileState(
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}

// 프로필 Provider
class ProfileNotifier extends StateNotifier<ProfileState> {
  final AuthService _authService = AuthService();

  ProfileNotifier() : super(ProfileState());

  // 프로필 정보 로드
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await _authService.getUserProfile();
      state = state.copyWith(userProfile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 프로필 이미지 선택
  void selectImage(File image) {
    state = state.copyWith(selectedImage: image);
  }

  // 프로필 이미지 업로드
  Future<bool> uploadProfileImage() async {
    if (state.selectedImage == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final imageUrl = await _authService.uploadProfileImage(
        state.selectedImage!,
      );

      if (imageUrl != null) {
        // 프로필 정보 업데이트
        final updatedProfile = Map<String, dynamic>.from(
          state.userProfile ?? {},
        );
        updatedProfile['profileImageUrl'] = imageUrl;

        state = state.copyWith(
          userProfile: updatedProfile,
          isLoading: false,
          selectedImage: null,
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // 프로필 이미지 삭제
  Future<bool> deleteProfileImage() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _authService.deleteProfileImage();

      if (success) {
        final updatedProfile = Map<String, dynamic>.from(
          state.userProfile ?? {},
        );
        updatedProfile.remove('profileImageUrl');

        state = state.copyWith(userProfile: updatedProfile, isLoading: false);
      }

      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // 프로필 정보 업데이트
  Future<bool> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? address,
    String? detailAddress,
    String? zipcode,
    // 기업회원 전용
    String? companyName,
    String? businessNumber,
    String? companyPhone,
    String? companyAddress,
    String? ceoName,
    String? companyType,
    int? employeeCount,
    String? establishedYear,
    String? website,
    String? companyDescription,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.updateUserProfile(
        name: name,
        email: email,
        phone: phone,
        address: address,
        detailAddress: detailAddress,
        zipcode: zipcode,
        companyName: companyName,
        businessNumber: businessNumber,
        companyPhone: companyPhone,
        companyAddress: companyAddress,
        ceoName: ceoName,
        companyType: companyType,
        employeeCount: employeeCount,
        establishedYear: establishedYear,
        website: website,
        companyDescription: companyDescription,
      );

      if (result != null && result['user'] != null) {
        state = state.copyWith(userProfile: result['user'], isLoading: false);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // 비밀번호 변경
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);
