import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/export_progress_widget.dart';
import './widgets/filter_bottom_sheet.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/log_entry_card.dart';
import './widgets/search_bar_widget.dart';

class NetworkLogs extends StatefulWidget {
  const NetworkLogs({super.key});

  @override
  State<NetworkLogs> createState() => _NetworkLogsState();
}

class _NetworkLogsState extends State<NetworkLogs>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _allLogs = [];
  List<Map<String, dynamic>> _filteredLogs = [];
  Map<String, dynamic> _activeFilters = {};
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _pageSize = 20;
  List<String> _searchHistory = [];
  bool _isExporting = false;
  double _exportProgress = 0.0;
  String _exportStatus = '';
  late AnimationController _refreshAnimationController;

  @override
  void initState() {
    super.initState();
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scrollController.addListener(_onScroll);
    _loadMockData();
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshAnimationController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    final mockLogs = [
      {
        "id": 1,
        "timestamp": DateTime.now().subtract(const Duration(minutes: 5)),
        "protocol": "TCP",
        "sourceIp": "192.168.1.100",
        "destinationIp": "10.0.0.1",
        "activityType": "Port Scan",
        "severity": "high",
        "packetCount": 1247,
        "dataSize": "2.4 MB",
        "isReviewed": false,
      },
      {
        "id": 2,
        "timestamp": DateTime.now().subtract(const Duration(minutes: 12)),
        "protocol": "UDP",
        "sourceIp": "172.16.0.50",
        "destinationIp": "8.8.8.8",
        "activityType": "DNS Query",
        "severity": "low",
        "packetCount": 45,
        "dataSize": "12 KB",
        "isReviewed": true,
      },
      {
        "id": 3,
        "timestamp": DateTime.now().subtract(const Duration(minutes: 18)),
        "protocol": "HTTP",
        "sourceIp": "203.0.113.15",
        "destinationIp": "192.168.1.10",
        "activityType": "Brute Force",
        "severity": "critical",
        "packetCount": 3421,
        "dataSize": "8.7 MB",
        "isReviewed": false,
      },
      {
        "id": 4,
        "timestamp": DateTime.now().subtract(const Duration(hours: 1)),
        "protocol": "HTTPS",
        "sourceIp": "192.168.1.25",
        "destinationIp": "151.101.193.140",
        "activityType": "Normal Activity",
        "severity": "low",
        "packetCount": 892,
        "dataSize": "1.2 MB",
        "isReviewed": true,
      },
      {
        "id": 5,
        "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
        "protocol": "TCP",
        "sourceIp": "10.0.0.25",
        "destinationIp": "192.168.1.1",
        "activityType": "DDoS",
        "severity": "critical",
        "packetCount": 15678,
        "dataSize": "45.2 MB",
        "isReviewed": false,
      },
      {
        "id": 6,
        "timestamp": DateTime.now().subtract(const Duration(hours: 3)),
        "protocol": "SSH",
        "sourceIp": "198.51.100.42",
        "destinationIp": "192.168.1.5",
        "activityType": "Unauthorized Access",
        "severity": "high",
        "packetCount": 234,
        "dataSize": "156 KB",
        "isReviewed": false,
      },
      {
        "id": 7,
        "timestamp": DateTime.now().subtract(const Duration(hours: 4)),
        "protocol": "FTP",
        "sourceIp": "192.168.1.15",
        "destinationIp": "203.0.113.25",
        "activityType": "Data Exfiltration",
        "severity": "high",
        "packetCount": 5432,
        "dataSize": "23.8 MB",
        "isReviewed": true,
      },
      {
        "id": 8,
        "timestamp": DateTime.now().subtract(const Duration(hours: 6)),
        "protocol": "ICMP",
        "sourceIp": "172.16.0.100",
        "destinationIp": "8.8.4.4",
        "activityType": "Ping Sweep",
        "severity": "medium",
        "packetCount": 128,
        "dataSize": "8 KB",
        "isReviewed": false,
      },
      {
        "id": 9,
        "timestamp": DateTime.now().subtract(const Duration(days: 1)),
        "protocol": "UDP",
        "sourceIp": "10.0.0.75",
        "destinationIp": "224.0.0.1",
        "activityType": "Suspicious Traffic",
        "severity": "medium",
        "packetCount": 678,
        "dataSize": "445 KB",
        "isReviewed": true,
      },
      {
        "id": 10,
        "timestamp": DateTime.now().subtract(const Duration(days: 2)),
        "protocol": "TCP",
        "sourceIp": "192.168.1.200",
        "destinationIp": "104.16.249.249",
        "activityType": "Malware",
        "severity": "critical",
        "packetCount": 2156,
        "dataSize": "12.4 MB",
        "isReviewed": false,
      },
    ];

    _allLogs.addAll(mockLogs);
    _filteredLogs = List.from(_allLogs);
  }

  void _loadInitialData() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        final additionalLogs = _generateAdditionalLogs();
        setState(() {
          _allLogs.addAll(additionalLogs);
          _applyFilters();
          _isLoading = false;
          _currentPage++;
          if (_currentPage > 5) {
            _hasMoreData = false;
          }
        });
      }
    });
  }

  List<Map<String, dynamic>> _generateAdditionalLogs() {
    final protocols = ['TCP', 'UDP', 'HTTP', 'HTTPS', 'SSH', 'FTP'];
    final activities = [
      'Port Scan',
      'Normal Activity',
      'Suspicious Traffic',
      'Brute Force'
    ];
    final severities = ['low', 'medium', 'high', 'critical'];

    return List.generate(10, (index) {
      final id = _allLogs.length + index + 1;
      return {
        "id": id,
        "timestamp": DateTime.now().subtract(Duration(hours: id)),
        "protocol": protocols[index % protocols.length],
        "sourceIp": "192.168.1.${100 + index}",
        "destinationIp": "10.0.0.${index + 1}",
        "activityType": activities[index % activities.length],
        "severity": severities[index % severities.length],
        "packetCount": 100 + (index * 50),
        "dataSize": "${(index + 1) * 0.5} MB",
        "isReviewed": index % 3 == 0,
      };
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    _refreshAnimationController.repeat();

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _currentPage = 1;
        _hasMoreData = true;
      });
      _refreshAnimationController.stop();
      _refreshAnimationController.reset();
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allLogs);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((log) {
        final query = _searchQuery.toLowerCase();
        return (log['sourceIp'] as String).toLowerCase().contains(query) ||
            (log['destinationIp'] as String).toLowerCase().contains(query) ||
            (log['protocol'] as String).toLowerCase().contains(query) ||
            (log['activityType'] as String).toLowerCase().contains(query);
      }).toList();
    }

    if (_activeFilters['dateRange'] != null) {
      final dateRange = _activeFilters['dateRange'] as Map<String, DateTime>;
      final start = dateRange['start']!;
      final end = dateRange['end']!;
      filtered = filtered.where((log) {
        final timestamp = log['timestamp'] as DateTime;
        return timestamp.isAfter(start) &&
            timestamp.isBefore(end.add(const Duration(days: 1)));
      }).toList();
    }

    if (_activeFilters['protocols'] != null) {
      final protocols = _activeFilters['protocols'] as List<String>;
      if (protocols.isNotEmpty) {
        filtered = filtered
            .where((log) => protocols.contains(log['protocol'] as String))
            .toList();
      }
    }

    if (_activeFilters['ipAddress'] != null &&
        (_activeFilters['ipAddress'] as String).isNotEmpty) {
      final ip = (_activeFilters['ipAddress'] as String).toLowerCase();
      filtered = filtered
          .where((log) =>
              (log['sourceIp'] as String).toLowerCase().contains(ip) ||
              (log['destinationIp'] as String).toLowerCase().contains(ip))
          .toList();
    }

    if (_activeFilters['activityTypes'] != null) {
      final types = _activeFilters['activityTypes'] as List<String>;
      if (types.isNotEmpty) {
        filtered = filtered
            .where((log) => types.contains(log['activityType'] as String))
            .toList();
      }
    }

    setState(() {
      _filteredLogs = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();

    if (query.isNotEmpty && !_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
      });
    }
  }

  void _onFiltersChanged(Map<String, dynamic> filters) {
    setState(() {
      _activeFilters = filters;
    });
    _applyFilters();
  }

  void _removeFilter(String key, dynamic value) {
    setState(() {
      if (value == null) {
        _activeFilters.remove(key);
      } else {
        if (_activeFilters[key] is List) {
          (_activeFilters[key] as List).remove(value);
          if ((_activeFilters[key] as List).isEmpty) {
            _activeFilters.remove(key);
          }
        }
      }
    });
    _applyFilters();
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
      _searchQuery = '';
    });
    _applyFilters();
  }

  Future<void> _exportLogs({DateTimeRange? dateRange}) async {
    setState(() {
      _isExporting = true;
      _exportProgress = 0.0;
      _exportStatus = 'Preparing export...';
    });

    final logsToExport = dateRange != null
        ? _filteredLogs.where((log) {
            final timestamp = log['timestamp'] as DateTime;
            return timestamp.isAfter(dateRange.start) &&
                timestamp.isBefore(dateRange.end.add(const Duration(days: 1)));
          }).toList()
        : _filteredLogs;

    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() {
          _exportProgress = i / 100;
          if (i < 30) {
            _exportStatus = 'Collecting log entries...';
          } else if (i < 60) {
            _exportStatus = 'Processing data...';
          } else if (i < 90) {
            _exportStatus = 'Generating CSV file...';
          } else {
            _exportStatus = 'Finalizing export...';
          }
        });
      }
    }

    final csvContent = _generateCSV(logsToExport);
    final filename =
        'network_logs_${DateTime.now().millisecondsSinceEpoch}.csv';

    try {
      await _downloadFile(csvContent, filename);

      if (mounted) {
        setState(() {
          _exportProgress = 1.0;
          _exportStatus = 'Export completed successfully!';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _exportProgress = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _generateCSV(List<Map<String, dynamic>> logs) {
    final buffer = StringBuffer();
    buffer.writeln(
        'Timestamp,Protocol,Source IP,Destination IP,Activity Type,Severity,Packet Count,Data Size,Reviewed');

    for (final log in logs) {
      final timestamp = log['timestamp'] as DateTime;
      buffer.writeln([
        timestamp.toIso8601String(),
        log['protocol'],
        log['sourceIp'],
        log['destinationIp'],
        log['activityType'],
        log['severity'],
        log['packetCount'],
        log['dataSize'],
        log['isReviewed'],
      ].join(','));
    }

    return buffer.toString();
  }

  Future<void> _downloadFile(String content, String filename) async {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        currentFilters: _activeFilters,
        onFiltersChanged: _onFiltersChanged,
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Network Logs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose export options:'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Export All Logs'),
              subtitle: Text('${_filteredLogs.length} entries'),
              onTap: () {
                Navigator.pop(context);
                _exportLogs();
              },
            ),
            ListTile(
              title: const Text('Export Date Range'),
              subtitle: const Text('Select specific date range'),
              onTap: () async {
                Navigator.pop(context);
                final dateRange = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (dateRange != null) {
                  _exportLogs(dateRange: dateRange);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  EmptyStateType _getEmptyStateType() {
    if (_allLogs.isEmpty) {
      return EmptyStateType.freshInstall;
    } else if (_filteredLogs.isEmpty &&
        (_searchQuery.isNotEmpty || _activeFilters.isNotEmpty)) {
      return EmptyStateType.noResults;
    } else if (_filteredLogs.isEmpty) {
      return EmptyStateType.noLogs;
    }
    return EmptyStateType.noLogs;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Network Logs'),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'file_download',
              color: colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _filteredLogs.isNotEmpty ? _showExportDialog : null,
            tooltip: 'Export Logs',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SearchBarWidget(
                initialQuery: _searchQuery,
                onSearchChanged: _onSearchChanged,
                onFilterTap: _showFilterBottomSheet,
                searchHistory: _searchHistory,
                onHistoryItemTap: _onSearchChanged,
                showFilterBadge: _activeFilters.isNotEmpty,
              ),
              FilterChipsWidget(
                activeFilters: _activeFilters,
                onRemoveFilter: _removeFilter,
                onClearAll: _clearAllFilters,
              ),
              Expanded(
                child: _buildContent(context, colorScheme),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ExportProgressWidget(
              isVisible: _isExporting,
              progress: _exportProgress,
              status: _exportStatus,
              onCancel: () {
                setState(() {
                  _isExporting = false;
                  _exportProgress = 0.0;
                });
              },
              onComplete: () {
                setState(() {
                  _isExporting = false;
                  _exportProgress = 0.0;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme) {
    if (_filteredLogs.isEmpty && !_isLoading) {
      return EmptyStateWidget(
        type: _getEmptyStateType(),
        onStartMonitoring: () => Navigator.pushNamed(context, '/dashboard'),
        onClearFilters: _clearAllFilters,
        onRetry: _refreshData,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _filteredLogs.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _filteredLogs.length) {
            return _buildLoadingIndicator(colorScheme);
          }

          final log = _filteredLogs[index];
          return LogEntryCard(
            logEntry: log,
            onTap: () => _showLogDetails(context, log),
            onExport: () => _exportSingleLog(log),
            onAddToInvestigation: () => _addToInvestigation(log),
            onMarkAsReviewed: () => _markAsReviewed(log),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
      ),
    );
  }

  void _showLogDetails(BuildContext context, Map<String, dynamic> log) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
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
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Log Details',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    _buildDetailItem(
                        'Timestamp', (log['timestamp'] as DateTime).toString()),
                    _buildDetailItem('Protocol', log['protocol'] as String),
                    _buildDetailItem('Source IP', log['sourceIp'] as String),
                    _buildDetailItem(
                        'Destination IP', log['destinationIp'] as String),
                    _buildDetailItem(
                        'Activity Type', log['activityType'] as String),
                    _buildDetailItem('Severity', log['severity'] as String),
                    _buildDetailItem(
                        'Packet Count', log['packetCount'].toString()),
                    _buildDetailItem('Data Size', log['dataSize'] as String),
                    _buildDetailItem(
                        'Reviewed', (log['isReviewed'] as bool) ? 'Yes' : 'No'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _exportSingleLog(Map<String, dynamic> log) {
    final csvContent = _generateCSV([log]);
    final filename =
        'log_${log['id']}_${DateTime.now().millisecondsSinceEpoch}.csv';
    _downloadFile(csvContent, filename);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Log entry exported successfully'),
      ),
    );
  }

  void _addToInvestigation(Map<String, dynamic> log) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Log ${log['id']} added to investigation'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Navigate to investigation screen
          },
        ),
      ),
    );
  }

  void _markAsReviewed(Map<String, dynamic> log) {
    setState(() {
      log['isReviewed'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Log ${log['id']} marked as reviewed'),
      ),
    );
  }
}
