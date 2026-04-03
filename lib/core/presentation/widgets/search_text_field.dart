import 'package:flutter/material.dart';
import '../../../theme/style_guide.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final bool autofocus;

  const SearchTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.hintText = 'Search',
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.grayscaleInputBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grayscaleLine),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        style: AppTypography.textSmall.copyWith(
          color: AppColors.grayscaleTitleActive,
        ),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.textSmall.copyWith(
            color: AppColors.grayscaleButtonText,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.grayscaleBodyText,
            size: 20,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                controller.clear();
                onChanged?.call('');
              }
            },
            icon: Icon(
              controller.text.isEmpty
                  ? Icons.tune_rounded
                  : Icons.close_rounded,
              color: AppColors.grayscaleBodyText,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
