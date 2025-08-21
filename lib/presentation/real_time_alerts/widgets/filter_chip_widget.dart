import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback? onRemove;
  final Color? backgroundColor;
  final Color? textColor;

  const FilterChipWidget({
    super.key,
    required this.label,
    this.value,
    this.onRemove,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(right: 2.w),
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value != null ? '$label: $value' : label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: textColor ?? colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onRemove != null) ...[
              SizedBox(width: 1.w),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onRemove?.call();
                },
                child: CustomIconWidget(
                  iconName: 'close',
                  color:
                      textColor ?? colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 16,
                ),
              ),
            ],
          ],
        ),
        backgroundColor: backgroundColor ?? colorScheme.surfaceContainerHighest,
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
