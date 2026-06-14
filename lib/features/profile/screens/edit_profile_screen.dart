import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/utils/custom_snackbars.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDate;
  String _userEmail = '';
  bool _isLoadingProfile = true;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null) {
        _showErrorMessage('User not found');
        return;
      }

      final profileData = await SupabaseService.getUserProfile(userId);

      if (profileData != null) {
        setState(() {
          _fullNameController.text = profileData['full_name'] ?? '';
          _addressController.text = profileData['address'] ?? '';
          _selectedGender = profileData['gender'];
          _userEmail = profileData['email'] ?? '';

          if (profileData['dob'] != null) {
            _selectedDate = DateTime.parse(profileData['dob']);
          }

          _isLoadingProfile = false;
        });
      } else {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoadingProfile = false;
      });
      _showErrorMessage('Failed to load profile: $error');
    }
  }

  Future<void> _saveProfile() async {
    try {
      // Validate inputs
      final fullName = _fullNameController.text.trim();

      if (fullName.isEmpty) {
        CustomSnackbars.showError(
          context: context,
          message: 'Please enter your full name',
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
        ),
      );

      // Get user ID
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorMessage('User not found');
        return;
      }

      // Update profile in Supabase
      await SupabaseService.updateUserProfile(
        userId: userId,
        fullName: fullName,
        dateOfBirth: _selectedDate,
        gender: _selectedGender,
        address: _addressController.text.trim(),
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Show success message
        CustomSnackbars.showSuccess(
          context: context,
          message: 'Profile updated successfully',
        );

        // Go back to previous screen
        Navigator.of(context).pop();
      }
    } catch (error) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.of(context).pop();
        _showErrorMessage('Failed to update profile: $error');
      }
    }
  }

  void _showErrorMessage(String message) {
    CustomSnackbars.showError(
      context: context,
      message: message,
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.darkGray,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: CustomAppBar(
        title: 'Edit Profile',
        automaticallyImplyLeading: true,
      ),
      body: _isLoadingProfile
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            )
          : Padding(
              padding: EdgeInsets.all(AppDimensions.spacingMd),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildProfileForm(),
                    ),
                    SizedBox(height: AppDimensions.spacingMd),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileForm() {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Email Field (Read-only)
                    _buildEmailField(),
                    SizedBox(height: AppDimensions.spacingMd),

                    // Full Name Field
                    _buildFullNameField(),
                    SizedBox(height: AppDimensions.spacingMd),

                    // Date of Birth Field
                    _buildDateOfBirthField(),
                    SizedBox(height: AppDimensions.spacingMd),

                    // Gender Field
                    _buildGenderField(),
                    SizedBox(height: AppDimensions.spacingMd),

                    // Address Field
                    _buildAddressField(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        SizedBox(height: AppDimensions.spacingSm),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingLg,
          ),
          decoration: BoxDecoration(
            color: AppColors.lightGray.withValues(alpha: 0.5),
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusMedium),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: AppColors.mediumGray,
                size: 20,
              ),
              SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Text(
                  _userEmail.isEmpty ? 'No email available' : _userEmail,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mediumGray,
                  ),
                ),
              ),
              Icon(
                Icons.lock_outline,
                color: AppColors.mediumGray,
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Name',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        SizedBox(height: AppDimensions.spacingSm),
        TextFormField(
          controller: _fullNameController,
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            prefixIcon: const Icon(Icons.badge_outlined),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
            filled: true,
            fillColor: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDateOfBirthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        SizedBox(height: AppDimensions.spacingSm),
        InkWell(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingLg,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusMedium),
              border: Border.all(color: AppColors.lightGray),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.mediumGray,
                  size: 20,
                ),
                SizedBox(width: AppDimensions.spacingMd),
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select your date of birth',
                  style: AppTypography.bodyMedium.copyWith(
                    color: _selectedDate != null
                        ? AppColors.darkGray
                        : AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        SizedBox(height: AppDimensions.spacingSm),
        DropdownButtonFormField<String>(
          initialValue: _selectedGender,
          decoration: InputDecoration(
            hintText: 'Select your gender',
            prefixIcon: const Icon(Icons.people_outline),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
            filled: true,
            fillColor: AppColors.white,
          ),
          items: _genderOptions.map((String gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(gender),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Address',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        SizedBox(height: AppDimensions.spacingSm),
        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(
            hintText: 'Enter your address',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
            filled: true,
            fillColor: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return CustomButton(
      text: 'Save Changes',
      onPressed: _saveProfile,
      type: ButtonType.primary,
    );
  }
}
