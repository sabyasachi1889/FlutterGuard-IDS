import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, dynamic> _filters;
  final TextEditingController _ipController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  final List<String> _protocols = [
    'TCP',
    'UDP',
    'HTTP',
    'HTTPS',
    'FTP',
    'SSH',
    'DNS',
    'ICMP'
  ];

  final List<String> _activityTypes = [
    'Port Scan',
    'Brute Force',
    'DDoS',
    'Malware',
    'Suspicious Traffic',
    'Data Exfiltration',
    'Unauthorized Access',
    'Normal Activity'
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
    _ipController.text = _filters['ipAddress'] as String? ?? '';

    if (_filters['dateRange'] != null) {
      final range = _filters['dateRange'] as Map<String, DateTime>;
      _selectedDateRange = DateTimeRange(
        start: range['start']!,
        end: range['end']!,
      );
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context, colorScheme),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeRangeSection(context, colorScheme),
                  SizedBox(height: 3.h),
                  _buildProtocolSection(context, colorScheme),
                  SizedBox(height: 3.h),
                  _buildIpAddressSection(context, colorScheme),
                  SizedBox(height: 3.h),
                  _buildActivityTypeSection(context, colorScheme),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          _buildActionButtons(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'filter_list',
            color: colorScheme.primary,
            size: 24,
          ),
          SizedBox(width: 3.w),
          Text(
            'Filter Logs',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _clearAllFilters,
            child: Text(
              'Clear All',
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSection(BuildContext context, ColorScheme colorScheme) {
    return _buildExpandableSection(
      context,
      colorScheme,
      'Time Range',
      'date_range',
      _selectedDateRange != null,
      Column(
        children: [
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  context,
                  colorScheme,
                  'Start Date',
                  _selectedDateRange?.start,
                  () => _selectStartDate(context),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildDateButton(
                  context,
                  colorScheme,
                  'End Date',
                  _selectedDateRange?.end,
                  () => _selectEndDate(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              _buildQuickDateButton('Last 24h', () => _setQuickDateRange(1)),
              SizedBox(width: 2.w),
              _buildQuickDateButton('Last 7d', () => _setQuickDateRange(7)),
              SizedBox(width: 2.w),
              _buildQuickDateButton('Last 30d', () => _setQuickDateRange(30)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolSection(BuildContext context, ColorScheme colorScheme) {
    final selectedProtocols = _filters['protocols'] as List<String>? ?? [];

    return _buildExpandableSection(
      context,
      colorScheme,
      'Protocol',
      'router',
      selectedProtocols.isNotEmpty,
      Column(
        children: [
          SizedBox(height: 2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _protocols.map((protocol) {
              final isSelected = selectedProtocols.contains(protocol);
              return FilterChip(
                label: Text(protocol),
                selected: isSelected,
                onSelected: (selected) => _toggleProtocol(protocol, selected),
                selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                checkmarkColor: colorScheme.primary,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIpAddressSection(BuildContext context, ColorScheme colorScheme) {
    return _buildExpandableSection(
      context,
      colorScheme,
      'IP Address',
      'computer',
      _ipController.text.isNotEmpty,
      Column(
        children: [
          SizedBox(height: 2.h),
          TextField(
            controller: _ipController,
            decoration: InputDecoration(
              hintText: 'Enter IP address (e.g., 192.168.1.1)',
              prefixIcon: CustomIconWidget(
                iconName: 'search',
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
              suffixIcon: _ipController.text.isNotEmpty
                  ? IconButton(
                      icon: CustomIconWidget(
                        iconName: 'clear',
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 20,
                      ),
                      onPressed: () {
                        _ipController.clear();
                        _updateIpFilter('');
                      },
                    )
                  : null,
            ),
            onChanged: _updateIpFilter,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTypeSection(
      BuildContext context, ColorScheme colorScheme) {
    final selectedTypes = _filters['activityTypes'] as List<String>? ?? [];

    return _buildExpandableSection(
      context,
      colorScheme,
      'Activity Type',
      'security',
      selectedTypes.isNotEmpty,
      Column(
        children: [
          SizedBox(height: 2.h),
          ..._activityTypes.map((type) {
            final isSelected = selectedTypes.contains(type);
            return CheckboxListTile(
              title: Text(
                type,
                style: TextStyle(fontSize: 14.sp),
              ),
              value: isSelected,
              onChanged: (selected) =>
                  _toggleActivityType(type, selected ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(
    BuildContext context,
    ColorScheme colorScheme,
    String title,
    String iconName,
    bool hasActiveFilters,
    Widget content,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CustomIconWidget(
          iconName: iconName,
          color: hasActiveFilters
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha: 0.6),
          size: 24,
        ),
        title: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            if (hasActiveFilters) ...[
              SizedBox(width: 2.w),
              Container(
                width: 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(
    BuildContext context,
    ColorScheme colorScheme,
    String label,
    DateTime? date,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              date != null
                  ? '${date.month}/${date.day}/${date.year}'
                  : 'Select date',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: date != null
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateButton(String label, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 1.h),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12.sp),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  void _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateRange?.start ??
          DateTime.now().subtract(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDateRange = DateTimeRange(
          start: date,
          end: _selectedDateRange?.end ?? DateTime.now(),
        );
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateRange?.end ?? DateTime.now(),
      firstDate: _selectedDateRange?.start ??
          DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDateRange = DateTimeRange(
          start: _selectedDateRange?.start ??
              DateTime.now().subtract(const Duration(days: 7)),
          end: date,
        );
      });
    }
  }

  void _setQuickDateRange(int days) {
    setState(() {
      _selectedDateRange = DateTimeRange(
        start: DateTime.now().subtract(Duration(days: days)),
        end: DateTime.now(),
      );
    });
  }

  void _toggleProtocol(String protocol, bool selected) {
    setState(() {
      final protocols = _filters['protocols'] as List<String>? ?? <String>[];
      if (selected) {
        protocols.add(protocol);
      } else {
        protocols.remove(protocol);
      }
      _filters['protocols'] = protocols;
    });
  }

  void _toggleActivityType(String type, bool selected) {
    setState(() {
      final types = _filters['activityTypes'] as List<String>? ?? <String>[];
      if (selected) {
        types.add(type);
      } else {
        types.remove(type);
      }
      _filters['activityTypes'] = types;
    });
  }

  void _updateIpFilter(String value) {
    setState(() {
      _filters['ipAddress'] = value;
    });
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
      _ipController.clear();
      _selectedDateRange = null;
    });
  }

  void _applyFilters() {
    if (_selectedDateRange != null) {
      _filters['dateRange'] = {
        'start': _selectedDateRange!.start,
        'end': _selectedDateRange!.end,
      };
    }

    widget.onFiltersChanged(_filters);
    Navigator.pop(context);
  }
}
