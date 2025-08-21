import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RecentAlertsSection extends StatelessWidget {
  final List<Map<String, dynamic>> recentAlerts;
  final VoidCallback onViewAllAlerts;

  const RecentAlertsSection({
    super.key,
    required this.recentAlerts,
    required this.onViewAllAlerts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Alerts',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onViewAllAlerts,
                child: Text(
                  'View All',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          recentAlerts.isNotEmpty
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentAlerts.length > 3 ? 3 : recentAlerts.length,
                  separatorBuilder: (context, index) => SizedBox(height: 1.h),
                  itemBuilder: (context, index) {
                    final alert = recentAlerts[index];
                    return _buildAlertCard(context, alert, theme, colorScheme);
                  },
                )
              : _buildEmptyState(context, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    Map<String, dynamic> alert,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final severity = alert['severity'] as String;
    Color severityColor;
    IconData severityIcon;

    switch (severity.toLowerCase()) {
      case 'critical':
        severityColor = Colors.red;
        severityIcon = Icons.error;
        break;
      case 'high':
        severityColor = Colors.orange;
        severityIcon = Icons.warning;
        break;
      case 'medium':
        severityColor = Colors.yellow.shade700;
        severityIcon = Icons.info;
        break;
      default:
        severityColor = Colors.blue;
        severityIcon = Icons.info_outline;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/real-time-alerts');
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: severityColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: severityIcon == Icons.error
                        ? 'error'
                        : severityIcon == Icons.warning
                            ? 'warning'
                            : severityIcon == Icons.info
                                ? 'info'
                                : 'info_outline',
                    color: severityColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['title'] as String,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        alert['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    severity.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: severityColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'access_time',
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  alert['timestamp'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const Spacer(),
                CustomIconWidget(
                  iconName: 'location_on',
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  alert['source'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'security',
            color: Colors.green,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Recent Threats',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Your network is secure. No threats detected in the last 24 hours.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
