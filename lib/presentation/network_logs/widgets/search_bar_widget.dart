import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SearchBarWidget extends StatefulWidget {
  final String? initialQuery;
  final Function(String) onSearchChanged;
  final VoidCallback? onFilterTap;
  final List<String> searchHistory;
  final Function(String)? onHistoryItemTap;
  final bool showFilterBadge;

  const SearchBarWidget({
    super.key,
    this.initialQuery,
    required this.onSearchChanged,
    this.onFilterTap,
    this.searchHistory = const [],
    this.onHistoryItemTap,
    this.showFilterBadge = false,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showSuggestions = false;

  final List<String> _suggestions = [
    '192.168.1.1',
    '10.0.0.1',
    'TCP',
    'UDP',
    'HTTP',
    'Port Scan',
    'Brute Force',
    'DDoS',
    'Malware',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus &&
            (_controller.text.isNotEmpty || widget.searchHistory.isNotEmpty);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: _focusNode.hasFocus ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search logs by IP, protocol, or activity...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'search',
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 20,
                      ),
                    ),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: CustomIconWidget(
                              iconName: 'clear',
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                              size: 20,
                            ),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 3.w,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _showSuggestions =
                          value.isNotEmpty || widget.searchHistory.isNotEmpty;
                    });
                    widget.onSearchChanged(value);
                  },
                  onSubmitted: (value) {
                    _focusNode.unfocus();
                    widget.onSearchChanged(value);
                  },
                ),
              ),
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: GestureDetector(
                      onTapDown: (_) => _animationController.forward(),
                      onTapUp: (_) => _animationController.reverse(),
                      onTapCancel: () => _animationController.reverse(),
                      onTap: widget.onFilterTap,
                      child: Container(
                        margin: EdgeInsets.all(2.w),
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: widget.showFilterBadge
                              ? colorScheme.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            CustomIconWidget(
                              iconName: 'filter_list',
                              color: widget.showFilterBadge
                                  ? colorScheme.primary
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                              size: 24,
                            ),
                            if (widget.showFilterBadge)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 2.w,
                                  height: 2.w,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        if (_showSuggestions) _buildSuggestions(context, colorScheme),
      ],
    );
  }

  Widget _buildSuggestions(BuildContext context, ColorScheme colorScheme) {
    final filteredSuggestions = _suggestions
        .where((suggestion) =>
            suggestion.toLowerCase().contains(_controller.text.toLowerCase()))
        .take(5)
        .toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.searchHistory.isNotEmpty) ...[
            _buildSectionHeader(context, colorScheme, 'Recent Searches'),
            ...widget.searchHistory
                .take(3)
                .map(
                  (query) => _buildSuggestionItem(
                    context,
                    colorScheme,
                    query,
                    'history',
                    () => _selectHistoryItem(query),
                  ),
                )
                .toList(),
          ],
          if (filteredSuggestions.isNotEmpty &&
              _controller.text.isNotEmpty) ...[
            _buildSectionHeader(context, colorScheme, 'Suggestions'),
            ...filteredSuggestions
                .map(
                  (suggestion) => _buildSuggestionItem(
                    context,
                    colorScheme,
                    suggestion,
                    'search',
                    () => _selectSuggestion(suggestion),
                  ),
                )
                .toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    ColorScheme colorScheme,
    String title,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 3.w, 4.w, 1.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    ColorScheme colorScheme,
    String text,
    String iconName,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            CustomIconWidget(
              iconName: 'north_west',
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearchChanged('');
    setState(() {
      _showSuggestions = widget.searchHistory.isNotEmpty;
    });
  }

  void _selectSuggestion(String suggestion) {
    _controller.text = suggestion;
    _focusNode.unfocus();
    widget.onSearchChanged(suggestion);
    setState(() {
      _showSuggestions = false;
    });
  }

  void _selectHistoryItem(String query) {
    _controller.text = query;
    _focusNode.unfocus();
    widget.onHistoryItemTap?.call(query);
    setState(() {
      _showSuggestions = false;
    });
  }
}
