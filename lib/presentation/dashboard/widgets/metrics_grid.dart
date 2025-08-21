import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class MetricsGrid extends StatelessWidget {
  final Map<String, dynamic> metrics;
  final VoidCallback onMetricLongPress;

  const MetricsGrid({
    super.key,
    required this.metrics,
    required this.onMetricLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 1.2,
        children: [
          _buildMetricCard(
            context,
            'Packets/sec',
            '${metrics['packetsPerSecond'] ?? 0}',
            'network_check',
            Colors.blue,
            theme,
            colorScheme,
          ),
          _buildMetricCard(
            context,
            'Bandwidth',
            '${metrics['bandwidth'] ?? '0 MB/s'}',
            'speed',
            Colors.orange,
            theme,
            colorScheme,
          ),
          _buildMetricCard(
            context,
            'Threats',
            '${metrics['threatsDetected'] ?? 0}',
            'security',
            Colors.red,
            theme,
            colorScheme,
          ),
          _buildMetricCard(
            context,
            'Connections',
            '${metrics['activeConnections'] ?? 0}',
            'device_hub',
            Colors.green,
            theme,
            colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String iconName,
    Color iconColor,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onLongPress: onMetricLongPress,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: iconName,
                  color: iconColor,
                  size: 24,
                ),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
