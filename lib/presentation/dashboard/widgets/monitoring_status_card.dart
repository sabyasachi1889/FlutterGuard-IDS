import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class MonitoringStatusCard extends StatelessWidget {
  final bool isMonitoring;
  final String elapsedTime;
  final VoidCallback onToggle;

  const MonitoringStatusCard({
    super.key,
    required this.isMonitoring,
    required this.elapsedTime,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isMonitoring ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                isMonitoring ? 'Monitoring Active' : 'Monitoring Inactive',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              CustomIconWidget(
                iconName: 'battery_charging_full',
                color: Colors.green,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: double.infinity,
              height: 15.h,
              decoration: BoxDecoration(
                color: isMonitoring
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isMonitoring ? Colors.red : Colors.green,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: isMonitoring ? 'stop' : 'play_arrow',
                    color: isMonitoring ? Colors.red : Colors.green,
                    size: 48,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    isMonitoring ? 'Stop Monitoring' : 'Start Monitoring',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isMonitoring ? Colors.red : Colors.green,
                    ),
                  ),
                  if (isMonitoring) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      'Elapsed: $elapsedTime',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
