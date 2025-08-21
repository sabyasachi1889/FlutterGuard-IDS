import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PermissionCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final String iconName;
  final bool isGranted;
  final bool isRequired;
  final VoidCallback onTap;

  const PermissionCardWidget({
    super.key,
    required this.title,
    required this.description,
    required this.iconName,
    required this.isGranted,
    required this.isRequired,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isGranted
                ? AppTheme.successLight
                : isRequired
                    ? colorScheme.primary.withValues(alpha: 0.3)
                    : colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: isGranted ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: isGranted
                        ? AppTheme.successLight.withValues(alpha: 0.1)
                        : isRequired
                            ? colorScheme.primary.withValues(alpha: 0.1)
                            : colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isGranted
                          ? AppTheme.successLight
                          : isRequired
                              ? colorScheme.primary
                              : colorScheme.outline.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: isGranted
                        ? CustomIconWidget(
                            iconName: 'check',
                            color: AppTheme.successLight,
                            size: 6.w,
                          )
                        : CustomIconWidget(
                            iconName: iconName,
                            color: isRequired
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.6),
                            size: 6.w,
                          ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isGranted
                                    ? AppTheme.successLight
                                    : colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isRequired)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.5.h,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.errorLight.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Required',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppTheme.errorLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!isGranted)
                  CustomIconWidget(
                    iconName: 'chevron_right',
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 5.w,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
