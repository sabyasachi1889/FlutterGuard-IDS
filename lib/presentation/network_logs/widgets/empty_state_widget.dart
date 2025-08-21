import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum EmptyStateType {
  noLogs,
  noResults,
  noConnection,
  freshInstall,
}

class EmptyStateWidget extends StatelessWidget {
  final EmptyStateType type;
  final VoidCallback? onRetry;
  final VoidCallback? onStartMonitoring;
  final VoidCallback? onClearFilters;

  const EmptyStateWidget({
    super.key,
    required this.type,
    this.onRetry,
    this.onStartMonitoring,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(colorScheme),
            SizedBox(height: 4.h),
            _buildTitle(colorScheme),
            SizedBox(height: 2.h),
            _buildDescription(colorScheme),
            SizedBox(height: 4.h),
            _buildActionButton(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(ColorScheme colorScheme) {
    String iconName;
    Color iconColor;

    switch (type) {
      case EmptyStateType.noLogs:
        iconName = 'list_alt';
        iconColor = colorScheme.onSurface.withValues(alpha: 0.4);
        break;
      case EmptyStateType.noResults:
        iconName = 'search_off';
        iconColor = colorScheme.onSurface.withValues(alpha: 0.4);
        break;
      case EmptyStateType.noConnection:
        iconName = 'wifi_off';
        iconColor = colorScheme.error;
        break;
      case EmptyStateType.freshInstall:
        iconName = 'security';
        iconColor = colorScheme.primary;
        break;
    }

    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: iconName,
          color: iconColor,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildTitle(ColorScheme colorScheme) {
    String title;

    switch (type) {
      case EmptyStateType.noLogs:
        title = 'No Network Activity';
        break;
      case EmptyStateType.noResults:
        title = 'No Results Found';
        break;
      case EmptyStateType.noConnection:
        title = 'Connection Lost';
        break;
      case EmptyStateType.freshInstall:
        title = 'Welcome to FlutterGuard';
        break;
    }

    return Text(
      title,
      style: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(ColorScheme colorScheme) {
    String description;

    switch (type) {
      case EmptyStateType.noLogs:
        description =
            'No network logs have been recorded yet. Start monitoring to see network activity and security events.';
        break;
      case EmptyStateType.noResults:
        description =
            'We couldn\'t find any logs matching your search criteria. Try adjusting your filters or search terms.';
        break;
      case EmptyStateType.noConnection:
        description =
            'Unable to sync network logs. Check your internet connection and try again.';
        break;
      case EmptyStateType.freshInstall:
        description =
            'Start monitoring your network to detect intrusions, suspicious activities, and security threats in real-time.';
        break;
    }

    return Text(
      description,
      style: TextStyle(
        fontSize: 14.sp,
        color: colorScheme.onSurface.withValues(alpha: 0.7),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton(BuildContext context, ColorScheme colorScheme) {
    String buttonText;
    VoidCallback? onPressed;
    bool isPrimary = true;

    switch (type) {
      case EmptyStateType.noLogs:
        buttonText = 'Start Monitoring';
        onPressed = onStartMonitoring;
        break;
      case EmptyStateType.noResults:
        buttonText = 'Clear Filters';
        onPressed = onClearFilters;
        isPrimary = false;
        break;
      case EmptyStateType.noConnection:
        buttonText = 'Retry';
        onPressed = onRetry;
        break;
      case EmptyStateType.freshInstall:
        buttonText = 'Begin Monitoring';
        onPressed = onStartMonitoring;
        break;
    }

    if (onPressed == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: isPrimary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 3.h),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 3.h),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}
