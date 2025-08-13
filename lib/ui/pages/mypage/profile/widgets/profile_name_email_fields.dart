// lib/ui/pages/mypage/profile/widgets/profile_name_email_fields.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/provider/profile_provider.dart';

class ProfileNameEmailFields extends ConsumerStatefulWidget {
  const ProfileNameEmailFields({super.key});

  @override
  ConsumerState<ProfileNameEmailFields> createState() =>
      ProfileNameEmailFieldsState();
}

class ProfileNameEmailFieldsState
    extends ConsumerState<ProfileNameEmailFields> {
  final _formKey = GlobalKey<FormState>();

  // 기본 정보 컨트롤러
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _detailAddressController;
  late final TextEditingController _zipcodeController;

  // 기업 정보 컨트롤러
  late final TextEditingController _companyNameController;
  late final TextEditingController _businessNumberController;
  late final TextEditingController _companyPhoneController;
  late final TextEditingController _companyAddressController;
  late final TextEditingController _ceoNameController;
  late final TextEditingController _companyTypeController;
  late final TextEditingController _employeeCountController;
  late final TextEditingController _establishedYearController;
  late final TextEditingController _websiteController;
  late final TextEditingController _companyDescriptionController;

  // 한 번만 채우기 위한 플래그
  bool _filledOnce = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // 프로필 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
    });

    // 상태가 바뀔 때만 컨트롤러 채우기
    ref.listen(profileProvider, (prev, next) {
      final profile = next.userProfile;
      if (profile != null && !_filledOnce) {
        _updateControllers(profile);
        _filledOnce = true;
      }
    });
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _detailAddressController = TextEditingController();
    _zipcodeController = TextEditingController();

    _companyNameController = TextEditingController();
    _businessNumberController = TextEditingController();
    _companyPhoneController = TextEditingController();
    _companyAddressController = TextEditingController();
    _ceoNameController = TextEditingController();
    _companyTypeController = TextEditingController();
    _employeeCountController = TextEditingController();
    _establishedYearController = TextEditingController();
    _websiteController = TextEditingController();
    _companyDescriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    _zipcodeController.dispose();

    _companyNameController.dispose();
    _businessNumberController.dispose();
    _companyPhoneController.dispose();
    _companyAddressController.dispose();
    _ceoNameController.dispose();
    _companyTypeController.dispose();
    _employeeCountController.dispose();
    _establishedYearController.dispose();
    _websiteController.dispose();
    _companyDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기본 정보 섹션
          _buildSectionTitle('기본 정보'),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _nameController,
            label: '이름',
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '이름을 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _emailController,
            label: '이메일',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '이메일을 입력해주세요';
              }
              if (!RegExp(
                r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
              ).hasMatch(value)) {
                return '올바른 이메일 형식을 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _phoneController,
            label: '전화번호',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // 주소 입력
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _zipcodeController,
                  label: '우편번호',
                  icon: Icons.location_on,
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _searchAddress,
                child: const Text('주소 검색'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          _buildTextField(
            controller: _addressController,
            label: '주소',
            readOnly: true,
          ),
          const SizedBox(height: 8),

          _buildTextField(controller: _detailAddressController, label: '상세주소'),

          // 기업 정보 섹션 (기업회원인 경우에만 표시)
          if (_isCompanyUser(profileState.userProfile)) ...[
            const SizedBox(height: 32),
            _buildSectionTitle('기업 정보'),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _companyNameController,
              label: '회사명',
              icon: Icons.business,
              validator: (value) {
                if (_isCompanyUser(profileState.userProfile) &&
                    (value == null || value.trim().isEmpty)) {
                  return '회사명을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _businessNumberController,
              label: '사업자번호',
              icon: Icons.numbers,
              validator: (value) {
                if (_isCompanyUser(profileState.userProfile) &&
                    (value == null || value.trim().isEmpty)) {
                  return '사업자번호를 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _ceoNameController,
              label: '대표자명',
              icon: Icons.person_outline,
              validator: (value) {
                if (_isCompanyUser(profileState.userProfile) &&
                    (value == null || value.trim().isEmpty)) {
                  return '대표자명을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _companyPhoneController,
              label: '회사 전화번호',
              icon: Icons.phone_in_talk,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _companyAddressController,
              label: '회사 주소',
              icon: Icons.location_city,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _companyTypeController,
              label: '업종',
              icon: Icons.category,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _employeeCountController,
                    label: '직원 수',
                    icon: Icons.people,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _establishedYearController,
                    label: '설립년도',
                    icon: Icons.calendar_today,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _websiteController,
              label: '홈페이지',
              icon: Icons.web,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _companyDescriptionController,
              label: '회사 소개',
              icon: Icons.description,
              maxLines: 4,
            ),
          ],

          const SizedBox(height: 32),

          // 비밀번호 변경 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showPasswordChangeDialog,
              icon: const Icon(Icons.lock),
              label: const Text('비밀번호 변경'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 100), // 하단 버튼 공간 확보
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade100 : null,
      ),
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
      validator: validator,
    );
  }

  void _updateControllers(Map<String, dynamic> profile) {
    _nameController.text = profile['name'] ?? '';
    _emailController.text = profile['email'] ?? '';
    _phoneController.text = profile['phone'] ?? '';
    _addressController.text = profile['address'] ?? '';
    _detailAddressController.text = profile['detailAddress'] ?? '';
    _zipcodeController.text = profile['zipcode'] ?? '';

    // 기업 정보
    _companyNameController.text = profile['companyName'] ?? '';
    _businessNumberController.text = profile['businessNumber'] ?? '';
    _companyPhoneController.text = profile['companyPhone'] ?? '';
    _companyAddressController.text = profile['companyAddress'] ?? '';
    _ceoNameController.text = profile['ceoName'] ?? '';
    _companyTypeController.text = profile['companyType'] ?? '';
    _employeeCountController.text = profile['employeeCount']?.toString() ?? '';
    _establishedYearController.text = profile['establishedYear'] ?? '';
    _websiteController.text = profile['website'] ?? '';
    _companyDescriptionController.text = profile['companyDescription'] ?? '';
  }

  bool _isCompanyUser(Map<String, dynamic>? profile) {
    return profile?['userType'] == 'COMPANY';
  }

  void _searchAddress() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('주소 검색 기능은 준비 중입니다.')));
  }

  void _showPasswordChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => const PasswordChangeDialog(),
    );
  }

  Future<bool> saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    final profileState = ref.read(profileProvider);
    final isCompany = _isCompanyUser(profileState.userProfile);

    return await ref
        .read(profileProvider.notifier)
        .updateProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone:
              _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
          address:
              _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
          detailAddress:
              _detailAddressController.text.trim().isEmpty
                  ? null
                  : _detailAddressController.text.trim(),
          zipcode:
              _zipcodeController.text.trim().isEmpty
                  ? null
                  : _zipcodeController.text.trim(),

          // 기업 정보 (기업회원만)
          companyName: isCompany ? _companyNameController.text.trim() : null,
          businessNumber:
              isCompany ? _businessNumberController.text.trim() : null,
          companyPhone:
              isCompany && _companyPhoneController.text.trim().isNotEmpty
                  ? _companyPhoneController.text.trim()
                  : null,
          companyAddress:
              isCompany && _companyAddressController.text.trim().isNotEmpty
                  ? _companyAddressController.text.trim()
                  : null,
          ceoName: isCompany ? _ceoNameController.text.trim() : null,
          companyType:
              isCompany && _companyTypeController.text.trim().isNotEmpty
                  ? _companyTypeController.text.trim()
                  : null,
          employeeCount:
              isCompany && _employeeCountController.text.trim().isNotEmpty
                  ? int.tryParse(_employeeCountController.text.trim())
                  : null,
          establishedYear:
              isCompany && _establishedYearController.text.trim().isNotEmpty
                  ? _establishedYearController.text.trim()
                  : null,
          website:
              isCompany && _websiteController.text.trim().isNotEmpty
                  ? _websiteController.text.trim()
                  : null,
          companyDescription:
              isCompany && _companyDescriptionController.text.trim().isNotEmpty
                  ? _companyDescriptionController.text.trim()
                  : null,
        );
  }
}

// ✅ 비밀번호 변경 다이얼로그
class PasswordChangeDialog extends ConsumerStatefulWidget {
  const PasswordChangeDialog({super.key});

  @override
  ConsumerState<PasswordChangeDialog> createState() =>
      _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends ConsumerState<PasswordChangeDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    // ★ 정규식: raw triple-quoted string으로 이스케이프 문제 해결
    const passwordPattern =
        r"""^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-\[\]{};'" :\\|,.<>\/?]).{8,}$""";

    return AlertDialog(
      title: const Text('비밀번호 변경'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 현재 비밀번호
              TextFormField(
                controller: currentPasswordController,
                obscureText: obscureCurrentPassword,
                decoration: InputDecoration(
                  labelText: '현재 비밀번호',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureCurrentPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed:
                        () => setState(
                          () =>
                              obscureCurrentPassword = !obscureCurrentPassword,
                        ),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? '현재 비밀번호를 입력해주세요'
                            : null,
              ),
              const SizedBox(height: 16),

              // 새 비밀번호
              TextFormField(
                controller: newPasswordController,
                obscureText: obscureNewPassword,
                decoration: InputDecoration(
                  labelText: '새 비밀번호',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed:
                        () => setState(
                          () => obscureNewPassword = !obscureNewPassword,
                        ),
                  ),
                  border: const OutlineInputBorder(),
                  helperText: '8자 이상, 대소문자, 숫자, 특수문자 포함',
                  helperMaxLines: 2,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '새 비밀번호를 입력해주세요';
                  }
                  if (value.length < 8) {
                    return '비밀번호는 최소 8자 이상이어야 합니다';
                  }
                  if (!RegExp(passwordPattern).hasMatch(value)) {
                    return '대소문자, 숫자, 특수문자를 모두 포함해야 합니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 비밀번호 확인
              TextFormField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed:
                        () => setState(
                          () =>
                              obscureConfirmPassword = !obscureConfirmPassword,
                        ),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호 확인을 입력해주세요';
                  }
                  if (value != newPasswordController.text) {
                    return '비밀번호가 일치하지 않습니다';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: profileState.isLoading ? null : _changePassword,
          child:
              profileState.isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('변경'),
        ),
      ],
    );
  }

  Future<void> _changePassword() async {
    if (!formKey.currentState!.validate()) return;

    final success = await ref
        .read(profileProvider.notifier)
        .changePassword(
          currentPassword: currentPasswordController.text,
          newPassword: newPasswordController.text,
        );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('비밀번호가 성공적으로 변경되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = ref.read(profileProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? '비밀번호 변경에 실패했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
