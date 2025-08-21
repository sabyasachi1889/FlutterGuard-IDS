import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AlertCardWidget extends StatelessWidget {
  final Map<String, dynamic> alert;
  final VoidCallback? onTap;
  final VoidCallback? onMarkSafe;
  final VoidCallback? onBlockIP;
  final VoidCallback? onLongPress;
  final bool isUnread;

  const AlertCardWidget({
    super.key,
    required this.alert,
    this.onTap,
    this.onMarkSafe,
    this.onBlockIP,
    this.onLongPress,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final severity = (alert["severity"] as String).toLowerCase();
    final severityColor =
        _getSeverityColor(severity, theme.brightness == Brightness.light);

    return Dismissible(
      key: Key(alert["id"].toString()),
      background: _buildSwipeBackground(
        context,
        colorScheme,
        isLeft: false,
        icon: 'check_circle',
        label: 'Mark Safe',
        color: AppTheme.lightTheme.colorScheme.tertiary,
      ),
      secondaryBackground: _buildSwipeBackground(
        context,
        colorScheme,
        isLeft: true,
        icon: 'block',
        label: 'Block IP',
        color: AppTheme.lightTheme.colorScheme.error,
      ),
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        if (direction == DismissDirection.startToEnd) {
          onMarkSafe?.call();
        } else {
          onBlockIP?.call();
        }
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        onLongPress: () {
          HapticFeedback.heavyImpact();
          onLongPress?.call();
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnread
                  ? severityColor.withValues(alpha: 0.3)
                  : colorScheme.outline.withValues(alpha: 0.1),
              width: isUnread ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Severity color bar
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: severityColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Threat type icon
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: severityColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CustomIconWidget(
                                iconName: _getThreatIcon(
                                    alert["threatType"] as String),
                                color: severityColor,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          alert["threatType"] as String,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onSurface,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isUnread)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: severityColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    _formatTimestamp(
                                        alert["timestamp"] as DateTime),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Severity badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: severityColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: severityColor.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                severity.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: severityColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        // Source IP and description
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'location_on',
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                              size: 16,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                alert["sourceIP"] as String,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          alert["description"] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (alert["protocol"] != null) ...[
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  alert["protocol"] as String,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (alert["port"] != null) ...[
                                SizedBox(width: 2.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2.w, vertical: 0.5.h),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Port ${alert["port"]}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(
    BuildContext context,
    ColorScheme colorScheme, {
    required bool isLeft,
    required String icon,
    required String label,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: icon,
                color: color,
                size: 24,
              ),
              SizedBox(height: 0.5.h),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity, bool isLight) {
    switch (severity) {
      case 'critical':
        return isLight
            ? AppTheme.lightTheme.colorScheme.error
            : AppTheme.darkTheme.colorScheme.error;
      case 'high':
        return const Color(0xFFFF5722);
      case 'medium':
        return isLight ? const Color(0xFFF57C00) : const Color(0xFFFF9800);
      case 'low':
        return isLight
            ? AppTheme.lightTheme.colorScheme.tertiary
            : AppTheme.darkTheme.colorScheme.tertiary;
      default:
        return isLight
            ? AppTheme.lightTheme.colorScheme.outline
            : AppTheme.darkTheme.colorScheme.outline;
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
