import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ContextMenuWidget extends StatelessWidget {
  final Map<String, dynamic> alert;
  final VoidCallback? onWhitelistIP;
  final VoidCallback? onExportDetails;
  final VoidCallback? onShareAlert;
  final VoidCallback? onBlockIP;
  final VoidCallback? onViewDetails;

  const ContextMenuWidget({
    super.key,
    required this.alert,
    this.onWhitelistIP,
    this.onExportDetails,
    this.onShareAlert,
    this.onBlockIP,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Alert info header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(alert["severity"] as String)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: _getThreatIcon(alert["threatType"] as String),
                    color: _getSeverityColor(alert["severity"] as String),
                    size: 20,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert["threatType"] as String,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        alert["sourceIP"] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          // Menu items
          _buildMenuItem(
            context,
            icon: 'visibility',
            title: 'View Details',
            subtitle: 'See full alert information',
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
              onViewDetails?.call();
            },
            theme: theme,
            colorScheme: colorScheme,
          ),
          _buildMenuItem(
            context,
            icon: 'check_circle',
            title: 'Whitelist IP',
            subtitle: 'Add ${alert["sourceIP"]} to safe list',
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              onWhitelistIP?.call();
            },
            theme: theme,
            colorScheme: colorScheme,
            iconColor: AppTheme.lightTheme.colorScheme.tertiary,
          ),
          _buildMenuItem(
            context,
            icon: 'block',
            title: 'Block IP',
            subtitle: 'Block all traffic from this IP',
            onTap: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
              onBlockIP?.call();
            },
            theme: theme,
            colorScheme: colorScheme,
            iconColor: colorScheme.error,
          ),
          _buildMenuItem(
            context,
            icon: 'file_download',
            title: 'Export Details',
            subtitle: 'Save alert data to file',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              onExportDetails?.call();
            },
            theme: theme,
            colorScheme: colorScheme,
          ),
          _buildMenuItem(
            context,
            icon: 'share',
            title: 'Share Alert',
            subtitle: 'Share with security team',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              onShareAlert?.call();
            },
            theme: theme,
            colorScheme: colorScheme,
            showDivider: false,
          ),
          SizedBox(height: 2.h),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
    required ColorScheme colorScheme,
    Color? iconColor,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: (iconColor ?? colorScheme.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: iconColor ?? colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          onTap: onTap,
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
        ),
        if (showDivider)
          Divider(
            color: colorScheme.outline.withValues(alpha: 0.1),
            height: 1,
            indent: 4.w,
            endIndent: 4.w,
          ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return const Color(0xFFC62828);
      case 'high':
        return const Color(0xFFFF5722);
      case 'medium':
        return const Color(0xFFF57C00);
      case 'low':
        return const Color(0xFF1565C0);
      default:
        return const Color(0xFF757575);
    }
  }

  String _getThreatIcon(String threatType) {
    switch (threatType.toLowerCase()) {
      case 'malware detection':
        return 'bug_report';
      case 'port scanning':
        return 'scanner';
      case 'brute force attack':
        return 'security';
      case 'ddos attack':
        return 'traffic';
      case 'suspicious traffic':
        return 'warning';
      case 'unauthorized access':
        return 'lock_open';
      case 'data exfiltration':
        return 'cloud_download';
      case 'intrusion attempt':
        return 'shield';
      default:
        return 'security';
    }
  }
}
