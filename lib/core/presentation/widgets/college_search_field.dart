import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repository/college_repository.dart';
import '../../../theme/style_guide.dart';

/// A select-style field for picking a college from the Firestore `colleges`
/// collection, filtered by the student's selected state.
///
/// Like [AppDropdownField] it writes the chosen value into [controller] (so the
/// fill/edit profile save logic is unchanged) and offers an "Other" option that
/// reveals an inline text field for a college not in the dataset. The state to
/// filter by is read live from [stateController] each time the picker opens.
class CollegeSearchField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final TextEditingController stateController;
  final String label;
  final String hintText;

  const CollegeSearchField({
    super.key,
    required this.controller,
    required this.stateController,
    this.label = 'College Name',
    this.hintText = 'Search your college',
  });

  @override
  ConsumerState<CollegeSearchField> createState() => _CollegeSearchFieldState();
}

class _CollegeSearchFieldState extends ConsumerState<CollegeSearchField> {
  bool _isOther = false;
  bool _otherFocused = false;
  final FocusNode _otherFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _otherFocus.addListener(
      () => setState(() => _otherFocused = _otherFocus.hasFocus),
    );
  }

  @override
  void dispose() {
    _otherFocus.dispose();
    super.dispose();
  }

  Future<void> _openSearch(bool isDark) async {
    FocusScope.of(context).unfocus();
    final result = await showModalBottomSheet<(bool, String)>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CollegeSearchSheet(
        isDark: isDark,
        state: widget.stateController.text.trim(),
        initialQuery: _isOther ? '' : widget.controller.text.trim(),
      ),
    );
    if (result == null || !mounted) return;

    final (isOther, name) = result;
    setState(() {
      if (isOther) {
        _isOther = true;
      } else {
        _isOther = false;
        widget.controller.text = name;
      }
    });

    if (_isOther) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _otherFocus.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final value = widget.controller.text.trim();
    final displayText = _isOther
        ? 'Other'
        : (value.isEmpty ? widget.hintText : value);
    final showingPlaceholder = !_isOther && value.isEmpty;

    final labelColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.grayscaleBodyText;
    final fillColor = isDark
        ? AppColors.darkInputBackground
        : AppColors.grayscaleWhite;
    final idleBorder = isDark ? AppColors.darkBorder : AppColors.grayscaleLine;
    final valueColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.grayscaleTitleActive;
    final hintColor = isDark
        ? AppColors.darkTextSecondary.withValues(alpha: 0.55)
        : AppColors.grayscaleButtonText.withValues(alpha: 0.62);

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
        InkWell(
          onTap: () => _openSearch(isDark),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: idleBorder),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: AppTypography.textSmall.copyWith(
                      color: showingPlaceholder ? hintColor : valueColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.grayscaleButtonText,
                ),
              ],
            ),
          ),
        ),
        if (_isOther) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _otherFocused ? AppColors.primaryDefault : idleBorder,
                width: _otherFocused ? 1.5 : 1.0,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _otherFocus,
              style: AppTypography.textSmall.copyWith(
                color: valueColor,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Type your college name',
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
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Bottom sheet that live-searches the `colleges` collection by prefix, scoped
/// to [state]. Pops `(isOther, collegeName)`.
class _CollegeSearchSheet extends ConsumerStatefulWidget {
  final bool isDark;
  final String state;
  final String initialQuery;

  const _CollegeSearchSheet({
    required this.isDark,
    required this.state,
    required this.initialQuery,
  });

  @override
  ConsumerState<_CollegeSearchSheet> createState() =>
      _CollegeSearchSheetState();
}

class _CollegeSearchSheetState extends ConsumerState<_CollegeSearchSheet> {
  late final TextEditingController _queryController;
  Timer? _debounce;
  List<String> _results = const [];
  bool _loading = false;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initialQuery);
    _runSearch(widget.initialQuery);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _runSearch(value),
    );
  }

  Future<void> _runSearch(String value) async {
    final requestId = ++_requestId;
    setState(() => _loading = true);
    final results = await ref
        .read(collegeRepositoryProvider)
        .searchColleges(state: widget.state, query: value);
    // Ignore out-of-order responses from earlier keystrokes.
    if (!mounted || requestId != _requestId) return;
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final surface = isDark ? AppColors.darkSurface : AppColors.grayscaleWhite;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.grayscaleTitleActive;
    final subColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.grayscaleBodyText;
    final divider = isDark ? AppColors.darkBorder : AppColors.grayscaleLine;
    final hasState = widget.state.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select your college',
                    style: AppTypography.textSmall.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    hasState
                        ? 'Showing colleges in ${widget.state}'
                        : 'Tip: pick your state first for better results',
                    style: AppTypography.textSmall.copyWith(
                      fontSize: 12,
                      color: subColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkInputBackground
                        : AppColors.grayscaleSecondaryButton,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: divider),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 6),
                        child: Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: subColor,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _queryController,
                          autofocus: true,
                          onChanged: _onQueryChanged,
                          style: AppTypography.textSmall.copyWith(
                            color: titleColor,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search college name',
                            hintStyle: AppTypography.textSmall.copyWith(
                              color: subColor,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(child: _buildResults(isDark, titleColor, subColor)),
              Divider(height: 1, color: divider),
              InkWell(
                onTap: () => Navigator.of(context).pop((true, '')),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18, color: subColor),
                      const SizedBox(width: 10),
                      Text(
                        "Can't find it? Enter manually",
                        style: AppTypography.textSmall.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDefault,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(bool isDark, Color titleColor, Color subColor) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.primaryDefault,
            ),
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Center(
          child: Text(
            _queryController.text.trim().isEmpty
                ? 'Start typing to search colleges'
                : 'No colleges found. You can enter it manually below.',
            textAlign: TextAlign.center,
            style: AppTypography.textSmall.copyWith(
              fontSize: 13,
              color: subColor,
            ),
          ),
        ),
      );
    }

    final divider = isDark ? AppColors.darkBorder : AppColors.grayscaleLine;
    return ListView.separated(
      shrinkWrap: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: _results.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, indent: 20, endIndent: 20, color: divider),
      itemBuilder: (context, index) {
        final name = _results[index];
        return InkWell(
          onTap: () => Navigator.of(context).pop((false, name)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Text(
              name,
              style: AppTypography.textSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: titleColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
