import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FilterModalWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterModalWidget({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<FilterModalWidget> createState() => _FilterModalWidgetState();
}

class _FilterModalWidgetState extends State<FilterModalWidget> {
  late Map<String, dynamic> _filters;
  final List<String> _severityLevels = ['Critical', 'High', 'Medium', 'Low'];
  final List<String> _threatTypes = [
    'Malware Detection',
    'Port Scanning',
    'Brute Force Attack',
    'DDoS Attack',
    'Suspicious Traffic',
    'Unauthorized Access',
    'Data Exfiltration',
    'Intrusion Attempt',
  ];
  final List<String> _timeRanges = [
    'Last 15 minutes',
    'Last hour',
    'Last 6 hours',
    'Last 24 hours',
    'Last 7 days',
    'Last 30 days',
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Text(
                  'Filter Alerts',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _filters.clear();
                    });
                  },
                  child: Text(
                    'Clear All',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: colorScheme.outline.withValues(alpha: 0.2),
            height: 1,
          ),
          // Filter content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSeveritySection(theme, colorScheme),
                  SizedBox(height: 3.h),
                  _buildThreatTypeSection(theme, colorScheme),
                  SizedBox(height: 3.h),
                  _buildTimeRangeSection(theme, colorScheme),
                  SizedBox(height: 3.h),
                  _buildIPAddressSection(theme, colorScheme),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          // Action buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        widget.onApplyFilters(_filters);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeveritySection(ThemeData theme, ColorScheme colorScheme) {
    return _buildExpandableSection(
      title: 'Severity Level',
      theme: theme,
      colorScheme: colorScheme,
      child: Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: _severityLevels.map((severity) {
          final isSelected =
              (_filters['severity'] as List<String>?)?.contains(severity) ??
                  false;
          return FilterChip(
            label: Text(severity),
            selected: isSelected,
            onSelected: (selected) {
              HapticFeedback.selectionClick();
              setState(() {
                final severityList =
                    (_filters['severity'] as List<String>?) ?? <String>[];
                if (selected) {
                  severityList.add(severity);
                } else {
                  severityList.remove(severity);
                }
                _filters['severity'] = severityList;
              });
            },
            selectedColor: _getSeverityColor(severity).withValues(alpha: 0.2),
            checkmarkColor: _getSeverityColor(severity),
            side: BorderSide(
              color: isSelected
                  ? _getSeverityColor(severity)
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThreatTypeSection(ThemeData theme, ColorScheme colorScheme) {
    return _buildExpandableSection(
      title: 'Threat Type',
      theme: theme,
      colorScheme: colorScheme,
      child: Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: _threatTypes.map((threatType) {
          final isSelected =
              (_filters['threatType'] as List<String>?)?.contains(threatType) ??
                  false;
          return FilterChip(
            label: Text(threatType),
            selected: isSelected,
            onSelected: (selected) {
              HapticFeedback.selectionClick();
              setState(() {
                final threatTypeList =
                    (_filters['threatType'] as List<String>?) ?? <String>[];
                if (selected) {
                  threatTypeList.add(threatType);
                } else {
                  threatTypeList.remove(threatType);
                }
                _filters['threatType'] = threatTypeList;
              });
            },
            selectedColor: colorScheme.primary.withValues(alpha: 0.2),
            checkmarkColor: colorScheme.primary,
            side: BorderSide(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeRangeSection(ThemeData theme, ColorScheme colorScheme) {
    return _buildExpandableSection(
      title: 'Time Range',
      theme: theme,
      colorScheme: colorScheme,
      child: Column(
        children: _timeRanges.map((timeRange) {
          final isSelected = _filters['timeRange'] == timeRange;
          return RadioListTile<String>(
            title: Text(
              timeRange,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            value: timeRange,
            groupValue: _filters['timeRange'] as String?,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() {
                _filters['timeRange'] = value;
              });
            },
            activeColor: colorScheme.primary,
            contentPadding: EdgeInsets.zero,
            dense: true,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIPAddressSection(ThemeData theme, ColorScheme colorScheme) {
    return _buildExpandableSection(
      title: 'IP Address',
      theme: theme,
      colorScheme: colorScheme,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Enter IP address (e.g., 192.168.1.1)',
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'location_on',
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2,
            ),
          ),
        ),
        onChanged: (value) {
          _filters['ipAddress'] = value.isEmpty ? null : value;
        },
        controller:
            TextEditingController(text: _filters['ipAddress'] as String? ?? ''),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        child,
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
}
