import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FilterChipsWidget extends StatelessWidget {
  final Map<String, dynamic> activeFilters;
  final Function(String, dynamic) onRemoveFilter;
  final VoidCallback? onClearAll;

  const FilterChipsWidget({
    super.key,
    required this.activeFilters,
    required this.onRemoveFilter,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (activeFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    final chips = _buildFilterChips(context, colorScheme);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Active Filters',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_getTotalFilterCount()}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onClearAll,
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: chips,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilterChips(
      BuildContext context, ColorScheme colorScheme) {
    final List<Widget> chips = [];

    // Date range chip
    if (activeFilters['dateRange'] != null) {
      final dateRange = activeFilters['dateRange'] as Map<String, DateTime>;
      final start = dateRange['start']!;
      final end = dateRange['end']!;
      final label = _formatDateRange(start, end);

      chips.add(_buildChip(
        context,
        colorScheme,
        label,
        'date_range',
        () => onRemoveFilter('dateRange', null),
      ));
    }

    // Protocol chips
    if (activeFilters['protocols'] != null) {
      final protocols = activeFilters['protocols'] as List<String>;
      for (final protocol in protocols) {
        chips.add(_buildChip(
          context,
          colorScheme,
          protocol,
          'router',
          () => onRemoveFilter('protocols', protocol),
        ));
      }
    }

    // IP address chip
    if (activeFilters['ipAddress'] != null &&
        (activeFilters['ipAddress'] as String).isNotEmpty) {
      chips.add(_buildChip(
        context,
        colorScheme,
        activeFilters['ipAddress'] as String,
        'computer',
        () => onRemoveFilter('ipAddress', null),
      ));
    }

    // Activity type chips
    if (activeFilters['activityTypes'] != null) {
      final activityTypes = activeFilters['activityTypes'] as List<String>;
      for (final type in activityTypes) {
        chips.add(_buildChip(
          context,
          colorScheme,
          type,
          'security',
          () => onRemoveFilter('activityTypes', type),
        ));
      }
    }

    return chips;
  }

  Widget _buildChip(
    BuildContext context,
    ColorScheme colorScheme,
    String label,
    String iconName,
    VoidCallback onRemove,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 3.w),
              child: CustomIconWidget(
                iconName: iconName,
                color: colorScheme.primary,
                size: 16,
              ),
            ),
            SizedBox(width: 2.w),
            Flexible(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: EdgeInsets.all(1.w),
                margin: EdgeInsets.only(left: 1.w, right: 2.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'close',
                  color: colorScheme.primary,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final now = DateTime.now();
    final startDiff = now.difference(start).inDays;
    final endDiff = now.difference(end).inDays;

    if (startDiff == 1 && endDiff == 0) {
      return 'Last 24h';
    } else if (startDiff == 7 && endDiff == 0) {
      return 'Last 7d';
    } else if (startDiff == 30 && endDiff == 0) {
      return 'Last 30d';
    } else {
      return '${start.month}/${start.day} - ${end.month}/${end.day}';
    }
  }

  int _getTotalFilterCount() {
    int count = 0;

    if (activeFilters['dateRange'] != null) count++;
    if (activeFilters['protocols'] != null) {
      count += (activeFilters['protocols'] as List).length;
    }
    if (activeFilters['ipAddress'] != null &&
        (activeFilters['ipAddress'] as String).isNotEmpty) count++;
    if (activeFilters['activityTypes'] != null) {
      count += (activeFilters['activityTypes'] as List).length;
    }

    return count;
  }
}
