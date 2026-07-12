import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../theme/style_guide.dart';
import '../../../../core/config/profile_field_options.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/app_dropdown_field.dart';
import '../../../../core/presentation/widgets/college_search_field.dart';
import '../../../../core/repository/firestore_repository.dart';
import '../../../../core/utils/app_error_reporter.dart';
import '../../../../core/utils/phone_number_validator.dart';
import '../../../auth/domain/models/user_model.dart';
import '../providers/auth_providers.dart';

class FillProfileScreen extends ConsumerStatefulWidget {
  const FillProfileScreen({super.key});

  @override
  ConsumerState<FillProfileScreen> createState() => _FillProfileScreenState();
}

class _FillProfileScreenState extends ConsumerState<FillProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();
  final Map<String, TextEditingController> _roleControllers = {};

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  // Sections the user chose to skip (fill later from their profile). Skipped
  // sections collapse in the UI and are excluded from the saved profile.
  final Set<String> _skippedSections = {};

  bool _isSkipped(String key) => _skippedSections.contains(key);

  void _toggleSkip(String key) {
    setState(() {
      if (!_skippedSections.remove(key)) _skippedSections.add(key);
    });
  }

  @override
  void initState() {
    super.initState();
    final user = ref.read(authRepositoryProvider).currentUser;
    final email = user?.email ?? '';
    _emailController.text = email;
    _fullNameController.text = user?.displayName ?? '';
    // Default the (required) username to the email's local part, sanitized to
    // the allowed username characters. The user can tap and change it.
    final localPart = email.contains('@') ? email.split('@').first : '';
    _usernameController.text = localPart.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9_]'),
      '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    for (final controller in _roleControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _roleController(String key) {
    return _roleControllers.putIfAbsent(key, TextEditingController.new);
  }

  Map<String, Object?> _setupArgs() {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is Map ? Map<String, Object?>.from(args) : const {};
  }

  Map<String, dynamic> _collectRoleDetails(String role) {
    final details = <String, dynamic>{};
    for (final field in _roleFieldsFor(role)) {
      final value = _roleController(field.key).text.trim();
      if (value.isNotEmpty) details[field.key] = value;
    }
    return details;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _pickedImage = File(image.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final currentUser = authRepo.currentUser;

      if (currentUser == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
        setState(() => _isSubmitting = false);
        return;
      }

      final args = ModalRoute.of(context)?.settings.arguments;
      final setup = args is Map ? args : const <String, Object?>{};
      final role = setup['role'] as String? ?? '';
      final interests = List<String>.from(setup['interests'] as List? ?? []);
      final firestoreRepo = ref.read(firestoreRepositoryProvider);

      // Username is required and unique; other sections are optional and
      // skipped ones are excluded from the save (completed later in profile).
      final username = _usernameController.text.trim();
      final fullName = _fullNameController.text.trim();
      final phone = _isSkipped('contact') ? '' : _phoneController.text.trim();
      final website = _isSkipped('about') ? '' : _websiteController.text.trim();
      final bio = _isSkipped('about') ? '' : _bioController.text.trim();
      final roleDetails = _isSkipped('role')
          ? <String, dynamic>{}
          : _collectRoleDetails(role);

      final available = await firestoreRepo.isUsernameAvailable(
        username,
        currentUser.uid,
      );
      if (!available) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username is already taken.')),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      String avatarUrl = currentUser.photoURL ?? '';
      if (_pickedImage != null) {
        avatarUrl = await firestoreRepo.uploadImage(_pickedImage!.path);
      }

      final updatedUser = UserModel(
        uid: currentUser.uid,
        username: username,
        fullName: fullName,
        email: currentUser.email ?? _emailController.text.trim(),
        phone: phone,
        displayName: fullName.isNotEmpty
            ? fullName
            : (currentUser.displayName ?? ''),
        bio: bio,
        avatarUrl: avatarUrl,
        websiteUrl: website,
        followersCount: 0,
        followingCount: 0,
        newsCount: 0,
        role: role,
        interests: interests,
        roleDetails: roleDetails,
        onboardingCompleted: true,
      );

      await authRepo.updateUserData(updatedUser);

      // Best-effort: follow selected topics. Failure here doesn't block onboarding.
      for (final interest in interests) {
        try {
          await firestoreRepo.followTopic(currentUser.uid, interest);
        } catch (error, stackTrace) {
          AppErrorReporter.record(
            error,
            stackTrace,
            reason: 'Failed to follow onboarding topic',
          );
          // Ignore — user can re-follow topics from settings later.
        }
      }

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final setup = _setupArgs();
    final role = setup['role'] as String? ?? '';

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.grayscaleSecondaryButton,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context, isDark),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          _buildAvatarPicker(isDark),
                          const SizedBox(height: 28),
                          // Identity is not skippable — a unique username is
                          // required. Full name stays optional.
                          _FormSection(
                            label: 'Identity',
                            isDark: isDark,
                            children: [
                              AppTextField(
                                controller: _fullNameController,
                                label: 'Full Name',
                                hintText: 'Your full name',
                              ),
                              const SizedBox(height: 14),
                              AppTextField(
                                controller: _usernameController,
                                label: 'Username*',
                                hintText: 'yourhandle',
                                validator: (val) {
                                  final text = val?.trim() ?? '';
                                  if (text.isEmpty) {
                                    return 'Username is required';
                                  }
                                  if (!RegExp(
                                    r'^[a-zA-Z0-9_]{3,24}$',
                                  ).hasMatch(text)) {
                                    return 'Use 3-24 letters, numbers or _';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _FormSection(
                            label: 'Contact',
                            isDark: isDark,
                            skippable: true,
                            isSkipped: _isSkipped('contact'),
                            onToggleSkip: () => _toggleSkip('contact'),
                            children: [
                              AppTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                hintText: 'example@email.com',
                                keyboardType: TextInputType.emailAddress,
                                readOnly: true,
                                validator: (val) {
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              AppTextField(
                                controller: _phoneController,
                                label: 'Phone Number',
                                hintText: '+91 98765 43210',
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9+\-\s()]'),
                                  ),
                                ],
                                validator: (val) =>
                                    (val == null || val.trim().isEmpty)
                                    ? null
                                    : validatePhoneNumber(val),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _RoleDetailsSection(
                            role: role,
                            isDark: isDark,
                            controllerFor: _roleController,
                            isSkipped: _isSkipped('role'),
                            onToggleSkip: () => _toggleSkip('role'),
                          ),
                          const SizedBox(height: 20),
                          _FormSection(
                            label: 'About',
                            isDark: isDark,
                            skippable: true,
                            isSkipped: _isSkipped('about'),
                            onToggleSkip: () => _toggleSkip('about'),
                            children: [
                              _MultilineField(
                                controller: _bioController,
                                label: 'Bio',
                                hintText: 'Tell people what you are building',
                                isDark: isDark,
                              ),
                              const SizedBox(height: 14),
                              AppTextField(
                                controller: _websiteController,
                                label: 'Website',
                                hintText: 'https://yourstartup.com',
                                keyboardType: TextInputType.url,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildContinueButton(isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, bool isDark) {
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.grayscaleWhite;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.grayscaleLine;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.grayscaleTitleActive;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: _isSubmitting
                ? null
                : () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back_rounded, color: textColor, size: 22),
          ),
          Expanded(
            child: Text(
              'Fill Your Profile',
              textAlign: TextAlign.center,
              style: AppTypography.textSmall.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
          // Invisible spacer to keep title centered
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ── Avatar ──────────────────────────────────────────────────────────────────

  Widget _buildAvatarPicker(bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: _isSubmitting ? null : _pickImage,
        child: SizedBox(
          width: 108,
          height: 108,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 54,
                backgroundColor: isDark
                    ? AppColors.darkSurface
                    : const Color(0xFFEEF1F4),
                backgroundImage: _pickedImage != null
                    ? FileImage(_pickedImage!)
                    : null,
                child: _pickedImage == null
                    ? Icon(
                        Icons.person_rounded,
                        size: 52,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : const Color(0xFFBDBDBD),
                      )
                    : null,
              ),
              Positioned(
                bottom: 2,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDefault,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBackground
                          : AppColors.grayscaleWhite,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Continue button ─────────────────────────────────────────────────────────

  Widget _buildContinueButton(bool isDark) {
    return Container(
      color: isDark
          ? AppColors.darkBackground
          : AppColors.grayscaleSecondaryButton,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: GestureDetector(
        onTap: _isSubmitting ? null : _submit,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: _isSubmitting
                ? AppColors.primaryDefault.withValues(alpha: 0.5)
                : AppColors.primaryDefault,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: _isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Continue',
                  style: AppTypography.textSmall.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

class _RoleField {
  final String key;
  final String label;
  final String hint;
  final TextInputType keyboardType;

  const _RoleField({
    required this.key,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });
}

List<_RoleField> _roleFieldsFor(String role) {
  return switch (role) {
    'student' => const [
      _RoleField(key: 'state', label: 'State', hint: 'Select your state'),
      _RoleField(
        key: 'collegeName',
        label: 'College Name',
        hint: 'Search your college',
      ),
      _RoleField(
        key: 'degreeCourse',
        label: 'Degree / Course',
        hint: 'B.Tech, BBA, MBA',
      ),
      _RoleField(key: 'year', label: 'Year', hint: '1st, 2nd, 3rd, Final'),
      _RoleField(
        key: 'branch',
        label: 'Branch / Specialization',
        hint: 'Computer Science',
      ),
      _RoleField(key: 'skills', label: 'Skills', hint: 'Design, Flutter, AI'),
      _RoleField(
        key: 'lookingFor',
        label: 'Looking For',
        hint: 'Internship, co-founder, learning',
      ),
    ],
    'founder' => const [
      _RoleField(
        key: 'startupName',
        label: 'Startup Name',
        hint: 'Your startup',
      ),
      _RoleField(
        key: 'startupStage',
        label: 'Startup Stage',
        hint: 'Idea, MVP, Revenue, Scaling',
      ),
      _RoleField(key: 'industry', label: 'Industry', hint: 'Fintech, SaaS, AI'),
      _RoleField(
        key: 'startupDescription',
        label: 'Startup Description',
        hint: 'What are you building?',
      ),
      _RoleField(
        key: 'businessNeeds',
        label: 'Looking For',
        hint: 'Funding, mentors, hiring',
      ),
      _RoleField(
        key: 'startupLocation',
        label: 'Startup Location',
        hint: 'City / State',
      ),
      _RoleField(
        key: 'teamSize',
        label: 'Team Size',
        hint: '5',
        keyboardType: TextInputType.number,
      ),
    ],
    'mentor' => const [
      _RoleField(
        key: 'profession',
        label: 'Profession / Designation',
        hint: 'Product Leader',
      ),
      _RoleField(
        key: 'company',
        label: 'Company / Organization',
        hint: 'Company name',
      ),
      _RoleField(
        key: 'expertise',
        label: 'Expertise',
        hint: 'Product, GTM, fundraising',
      ),
      _RoleField(
        key: 'yearsExperience',
        label: 'Years of Experience',
        hint: '10',
        keyboardType: TextInputType.number,
      ),
      _RoleField(key: 'industry', label: 'Industry', hint: 'SaaS, fintech'),
      _RoleField(
        key: 'mentorshipArea',
        label: 'Mentorship Area',
        hint: 'Startup, marketing, finance',
      ),
      _RoleField(
        key: 'availability',
        label: 'Availability',
        hint: 'Free, paid, group session',
      ),
    ],
    'investor' => const [
      _RoleField(
        key: 'investorType',
        label: 'Investor Type',
        hint: 'Angel, VC, family office',
      ),
      _RoleField(key: 'firmName', label: 'Firm Name', hint: 'Firm / fund name'),
      _RoleField(
        key: 'investmentRange',
        label: 'Investment Range',
        hint: '10L - 1Cr',
      ),
      _RoleField(
        key: 'preferredIndustries',
        label: 'Preferred Industries',
        hint: 'AI, SaaS, consumer',
      ),
      _RoleField(
        key: 'preferredStage',
        label: 'Preferred Startup Stage',
        hint: 'Idea, MVP, revenue',
      ),
      _RoleField(
        key: 'portfolioCompanies',
        label: 'Portfolio Companies',
        hint: 'Optional',
      ),
    ],
    'college' => const [
      _RoleField(
        key: 'cityState',
        label: 'City / State',
        hint: 'Bengaluru, Karnataka',
      ),
      _RoleField(
        key: 'collegeName',
        label: 'College Name',
        hint: 'Search your college',
      ),
      _RoleField(
        key: 'collegeType',
        label: 'College Type',
        hint: 'Engineering, MBA, university',
      ),
      _RoleField(
        key: 'contactPersonName',
        label: 'Contact Person Name',
        hint: 'Full name',
      ),
      _RoleField(
        key: 'designation',
        label: 'Designation',
        hint: 'Placement officer',
      ),
      _RoleField(
        key: 'numberOfStudents',
        label: 'Number of Students',
        hint: '1200',
        keyboardType: TextInputType.number,
      ),
      _RoleField(
        key: 'interestedIn',
        label: 'Interested In',
        hint: 'Programs, incubation, events',
      ),
    ],
    _ => const [
      _RoleField(
        key: 'interestArea',
        label: 'Startup Interest Area',
        hint: 'AI, funding, product, community',
      ),
      _RoleField(
        key: 'lookingFor',
        label: 'Looking For',
        hint: 'Learning, networking, events',
      ),
    ],
  };
}

class _RoleDetailsSection extends StatelessWidget {
  final String role;
  final bool isDark;
  final TextEditingController Function(String key) controllerFor;
  final bool isSkipped;
  final VoidCallback onToggleSkip;

  const _RoleDetailsSection({
    required this.role,
    required this.isDark,
    required this.controllerFor,
    required this.isSkipped,
    required this.onToggleSkip,
  });

  @override
  Widget build(BuildContext context) {
    final fields = _roleFieldsFor(role);
    if (fields.isEmpty) return const SizedBox.shrink();

    return _FormSection(
      label: role.isEmpty
          ? 'Role Details'
          : '${role.replaceAll('_', ' ')} Details',
      isDark: isDark,
      skippable: true,
      isSkipped: isSkipped,
      onToggleSkip: onToggleSkip,
      children: [
        for (var i = 0; i < fields.length; i++) ...[
          _buildField(fields[i], controllerFor(fields[i].key)),
          if (i != fields.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildField(_RoleField field, TextEditingController controller) {
    // Student and college roles pick a college from the state-filtered
    // Firestore dataset. Each role's state lives under a different key.
    if (field.key == 'collegeName' &&
        (role == 'student' || role == 'college')) {
      return CollegeSearchField(
        controller: controller,
        stateController: controllerFor(role == 'college' ? 'cityState' : 'state'),
        label: field.label,
      );
    }
    final dropdown = profileDropdownFor(field.key);
    if (dropdown != null) {
      return AppDropdownField(
        controller: controller,
        label: field.label,
        options: dropdown.options,
        allowOther: dropdown.allowOther,
      );
    }
    return AppTextField(
      controller: controller,
      label: field.label,
      hintText: field.hint,
      keyboardType: field.keyboardType,
    );
  }
}

// ── Shared form widgets ────────────────────────────────────────────────────────

class _FormSection extends StatelessWidget {
  final String label;
  final bool isDark;
  final List<Widget> children;
  final bool skippable;
  final bool isSkipped;
  final VoidCallback? onToggleSkip;

  const _FormSection({
    required this.label,
    required this.isDark,
    required this.children,
    this.skippable = false,
    this.isSkipped = false,
    this.onToggleSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: AppTypography.textSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.grayscaleBodyText,
                  ),
                ),
              ),
              if (skippable && onToggleSkip != null)
                _SkipToggle(
                  isDark: isDark,
                  isSkipped: isSkipped,
                  onTap: onToggleSkip!,
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.grayscaleWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.grayscaleLine,
            ),
          ),
          child: isSkipped
              ? _SkippedNote(isDark: isDark)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
        ),
      ],
    );
  }
}

class _SkipToggle extends StatelessWidget {
  final bool isDark;
  final bool isSkipped;
  final VoidCallback onTap;

  const _SkipToggle({
    required this.isDark,
    required this.isSkipped,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSkipped
        ? AppColors.primaryDefault
        : (isDark ? AppColors.darkTextSecondary : AppColors.grayscaleBodyText);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSkipped ? Icons.add_rounded : Icons.arrow_forward_rounded,
              size: 13,
              color: color,
            ),
            const SizedBox(width: 3),
            Text(
              isSkipped ? 'ADD' : 'SKIP',
              style: AppTypography.textSmall.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkippedNote extends StatelessWidget {
  final bool isDark;

  const _SkippedNote({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark
        ? AppColors.darkTextSecondary
        : AppColors.grayscaleBodyText;
    return Row(
      children: [
        Icon(Icons.schedule_rounded, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Skipped — you can add this later from your profile.',
            style: AppTypography.textSmall.copyWith(fontSize: 13, color: color),
          ),
        ),
      ],
    );
  }
}

class _MultilineField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool isDark;

  const _MultilineField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.isDark,
  });

  @override
  State<_MultilineField> createState() => _MultilineFieldState();
}

class _MultilineFieldState extends State<_MultilineField> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _isFocused
        ? AppColors.primaryDefault
        : (widget.isDark ? AppColors.darkBorder : AppColors.grayscaleLine);
    final fillColor = widget.isDark
        ? AppColors.darkInputBackground
        : AppColors.grayscaleWhite;
    final textColor = widget.isDark
        ? AppColors.darkTextPrimary
        : AppColors.grayscaleTitleActive;
    final hintColor = widget.isDark
        ? AppColors.darkTextSecondary.withValues(alpha: 0.55)
        : AppColors.grayscaleButtonText.withValues(alpha: 0.62);
    final labelColor = widget.isDark
        ? AppColors.darkTextSecondary
        : AppColors.grayscaleBodyText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.textSmall.copyWith(
            color: labelColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
              width: _isFocused ? 1.5 : 1.0,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            maxLines: 4,
            minLines: 3,
            style: AppTypography.textSmall.copyWith(
              color: textColor,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTypography.textSmall.copyWith(
                color: hintColor,
                fontSize: 14,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
