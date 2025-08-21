import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class LogEntryCard extends StatelessWidget {
  final Map<String, dynamic> logEntry;
  final VoidCallback? onTap;
  final VoidCallback? onExport;
  final VoidCallback? onAddToInvestigation;
  final VoidCallback? onMarkAsReviewed;

  const LogEntryCard({
    super.key,
    required this.logEntry,
    this.onTap,
    this.onExport,
    this.onAddToInvestigation,
    this.onMarkAsReviewed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isReviewed = logEntry['isReviewed'] as bool? ?? false;
    final severity = logEntry['severity'] as String? ?? 'low';

    return Dismissible(
      key: Key(logEntry['id'].toString()),
      background: _buildSwipeBackground(context, true),
      secondaryBackground: _buildSwipeBackground(context, false),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onExport?.call();
        } else {
          onAddToInvestigation?.call();
        }
      },
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: isReviewed
                ? colorScheme.surface.withValues(alpha: 0.7)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getSeverityColor(severity, colorScheme)
                  .withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(context, colorScheme),
              _buildContent(context, colorScheme),
              _buildFooter(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, bool isLeft) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeft ? colorScheme.primary : colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: isLeft ? 'file_download' : 'add_circle_outline',
            color: Colors.white,
            size: 24,
          ),
          SizedBox(height: 0.5.h),
          Text(
            isLeft ? 'Export' : 'Investigate',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    final timestamp = logEntry['timestamp'] as DateTime;
    final severity = logEntry['severity'] as String? ?? 'low';

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: _getSeverityColor(severity, colorScheme).withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3.w,
            height: 3.w,
            decoration: BoxDecoration(
              color: _getSeverityColor(severity, colorScheme),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTimestamp(timestamp),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  _getSeverityLabel(severity),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: _getSeverityColor(severity, colorScheme),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (logEntry['isReviewed'] as bool? ?? false)
            CustomIconWidget(
              iconName: 'check_circle',
              color: colorScheme.primary,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme) {
    final protocol = logEntry['protocol'] as String? ?? 'Unknown';
    final sourceIp = logEntry['sourceIp'] as String? ?? 'N/A';
    final destinationIp = logEntry['destinationIp'] as String? ?? 'N/A';
    final activityType = logEntry['activityType'] as String? ?? 'Unknown';

    return Padding(
      padding: EdgeInsets.all(3.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  context,
                  'Protocol',
                  protocol,
                  colorScheme,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildInfoItem(
                  context,
                  'Activity',
                  activityType,
                  colorScheme,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  context,
                  'Source',
                  sourceIp,
                  colorScheme,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildInfoItem(
                  context,
                  'Destination',
                  destinationIp,
                  colorScheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, ColorScheme colorScheme) {
    final packetCount = logEntry['packetCount'] as int? ?? 0;
    final dataSize = logEntry['dataSize'] as String? ?? '0 B';

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'data_usage',
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                size: 16,
              ),
              SizedBox(width: 2.w),
              Text(
                '$packetCount packets',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'storage',
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                size: 16,
              ),
              SizedBox(width: 2.w),
              Text(
                dataSize,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'file_download',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Export Entry'),
              onTap: () {
                Navigator.pop(context);
                onExport?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'add_circle_outline',
                color: Theme.of(context).colorScheme.secondary,
                size: 24,
              ),
              title: const Text('Add to Investigation'),
              onTap: () {
                Navigator.pop(context);
                onAddToInvestigation?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'check_circle',
                color: Theme.of(context).colorScheme.tertiary,
                size: 24,
              ),
              title: const Text('Mark as Reviewed'),
              onTap: () {
                Navigator.pop(context);
                onMarkAsReviewed?.call();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity, ColorScheme colorScheme) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return const Color(0xFFC62828);
      case 'high':
        return const Color(0xFFD32F2F);
      case 'medium':
        return const Color(0xFFF57C00);
      case 'low':
        return const Color(0xFF388E3C);
      default:
        return colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  String _getSeverityLabel(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return 'CRITICAL';
      case 'high':
        return 'HIGH';
      case 'medium':
        return 'MEDIUM';
      case 'low':
        return 'LOW';
      default:
        return 'UNKNOWN';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
