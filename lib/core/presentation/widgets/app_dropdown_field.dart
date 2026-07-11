import 'package:flutter/material.dart';
import '../../../theme/style_guide.dart';

/// A select-style form field that writes its chosen value into [controller].
///
/// Screens that already collect data from a [TextEditingController] (fill /
/// edit profile) can swap an `AppTextField` for this widget with no change to
/// their save logic — the selected value lives in the same controller.
///
/// When [allowOther] is true an "Other" choice reveals an inline text field so
/// the user can type a custom value, keeping the field flexible. Any existing
/// controller value that is not one of [options] is treated as a custom entry,
/// which keeps profiles saved before a field became a dropdown working
/// unchanged.
class AppDropdownField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final List<String> options;
  final String hintText;
  final bool allowOther;
  final String otherLabel;

  const AppDropdownField({
    super.key,
    required this.controller,
    required this.label,
    required this.options,
    this.hintText = 'Select',
    this.allowOther = true,
    this.otherLabel = 'Other',
  });

  @override
  State<AppDropdownField> createState() => _AppDropdownFieldState();
}

class _AppDropdownFieldState extends State<AppDropdownField> {
  late bool _isOther;
  bool _otherFocused = false;
  final FocusNode _otherFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final value = widget.controller.text.trim();
    _isOther =
        widget.allowOther &&
        value.isNotEmpty &&
        !widget.options.contains(value);
    _otherFocus.addListener(
      () => setState(() => _otherFocused = _otherFocus.hasFocus),
    );
  }

  @override
  void dispose() {
    _otherFocus.dispose();
    super.dispose();
  }

  Future<void> _openSheet(bool isDark) async {
    FocusScope.of(context).unfocus();
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _OptionsSheet(
        isDark: isDark,
        title: widget.label,
        options: widget.options,
        current: _isOther ? widget.otherLabel : widget.controller.text.trim(),
        allowOther: widget.allowOther,
        otherLabel: widget.otherLabel,
      ),
    );
    if (selected == null || !mounted) return;

    setState(() {
      if (selected == widget.otherLabel) {
        _isOther = true;
        // Clear a previously-chosen preset so the custom field starts empty.
        if (widget.options.contains(widget.controller.text.trim())) {
          widget.controller.clear();
        }
      } else {
        _isOther = false;
        widget.controller.text = selected;
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
        ? widget.otherLabel
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
          onTap: () => _openSheet(isDark),
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
                  Icons.keyboard_arrow_down_rounded,
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
                hintText: 'Type your ${widget.label.toLowerCase()}',
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

/// Bottom sheet listing the selectable [options] (plus an optional "Other" row).
class _OptionsSheet extends StatelessWidget {
  final bool isDark;
  final String title;
  final List<String> options;
  final String current;
  final bool allowOther;
  final String otherLabel;

  const _OptionsSheet({
    required this.isDark,
    required this.title,
    required this.options,
    required this.current,
    required this.allowOther,
    required this.otherLabel,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.grayscaleWhite;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.grayscaleTitleActive;
    final divider = isDark ? AppColors.darkBorder : AppColors.grayscaleLine;

    final rows = <String>[...options, if (allowOther) otherLabel];

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Text(
                    'Select $title',
                    style: AppTypography.textSmall.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: divider),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: rows.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, indent: 20, endIndent: 20, color: divider),
                itemBuilder: (context, index) {
                  final option = rows[index];
                  final isOther = allowOther && option == otherLabel;
                  final isSelected = option == current;
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Row(
                        children: [
                          if (isOther)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.grayscaleButtonText,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              isOther ? 'Other (type your own)' : option,
                              style: AppTypography.textSmall.copyWith(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primaryDefault
                                    : titleColor,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_rounded,
                              size: 20,
                              color: AppColors.primaryDefault,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
