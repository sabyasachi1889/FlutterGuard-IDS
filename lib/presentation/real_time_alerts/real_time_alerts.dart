import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/security_alert.dart';
import '../../services/monitoring_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_tab_bar.dart';
import './widgets/alert_card_widget.dart';
import './widgets/context_menu_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/filter_modal_widget.dart';
import './widgets/search_bar_widget.dart';

class RealTimeAlerts extends StatefulWidget {
  const RealTimeAlerts({super.key});

  @override
  State<RealTimeAlerts> createState() => _RealTimeAlertsState();
}

class _RealTimeAlertsState extends State<RealTimeAlerts>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedSeverity = 'All';
  String _selectedType = 'All';
  int _currentBottomIndex = 1;
  bool _isLoading = false;

  // Real data from Supabase
  List<SecurityAlert> _allAlerts = [];
  List<SecurityAlert> _filteredAlerts = [];

  final List<String> _severityFilters = [
    'All',
    'Critical',
    'High',
    'Medium',
    'Low'
  ];
  final List<String> _typeFilters = [
    'All',
    'Port Scan',
    'Brute Force',
    'Anomaly',
    'Malware',
    'DDoS',
    'Intrusion'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.index = 1; // Start on Alerts tab
    _loadAlerts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAlerts() async {
    if (!SupabaseService.instance.isAuthenticated) {
      _loadPreviewAlerts();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final alerts =
          await MonitoringService.instance.getSecurityAlerts(limit: 100);
      setState(() {
        _allAlerts = alerts;
        _filteredAlerts = alerts;
      });
    } catch (error) {
      debugPrint('Error loading alerts: $error');
      _loadPreviewAlerts(); // Fallback to preview data
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadPreviewAlerts() {
    setState(() {
      _allAlerts = [
        SecurityAlert(
            id: 'preview-1',
            sessionId: 'session-1',
            alertType: 'port_scan',
            severity: 'critical',
            title: 'Suspicious Port Scan Detected',
            description:
                'Multiple connection attempts from unknown IP address targeting common service ports including SSH (22), HTTP (80), and HTTPS (443).',
            sourceIp: '192.168.1.105',
            targetIp: '10.0.0.1',
            port: 22,
            isResolved: false,
            createdAt: DateTime.now().subtract(const Duration(minutes: 2))),
        SecurityAlert(
            id: 'preview-2',
            sessionId: 'session-1',
            alertType: 'anomaly',
            severity: 'high',
            title: 'Unusual Bandwidth Usage',
            description:
                'Abnormal data transfer detected from internal device to external server. Data volume exceeds normal patterns by 300%.',
            sourceIp: '10.0.0.23',
            targetIp: '203.0.113.45',
            port: 443,
            isResolved: false,
            createdAt: DateTime.now().subtract(const Duration(minutes: 15))),
        SecurityAlert(
            id: 'preview-3',
            sessionId: 'session-1',
            alertType: 'brute_force',
            severity: 'medium',
            title: 'Failed Authentication Attempts',
            description:
                'Multiple failed login attempts detected on network service. 15 attempts in the last 5 minutes.',
            sourceIp: '172.16.0.45',
            targetIp: '10.0.0.1',
            port: 80,
            isResolved: true,
            resolvedAt: DateTime.now().subtract(const Duration(minutes: 30)),
            resolutionNotes: 'IP blocked automatically',
            createdAt: DateTime.now().subtract(const Duration(hours: 1))),
        SecurityAlert(
            id: 'preview-4',
            sessionId: 'session-2',
            alertType: 'ddos',
            severity: 'critical',
            title: 'DDoS Attack Detected',
            description:
                'Distributed Denial of Service attack targeting web server. Traffic volume increased by 1000%.',
            sourceIp: '203.0.113.100',
            targetIp: '10.0.0.1',
            port: 80,
            isResolved: false,
            createdAt: DateTime.now().subtract(const Duration(hours: 2))),
        SecurityAlert(
            id: 'preview-5',
            sessionId: 'session-2',
            alertType: 'malware',
            severity: 'high',
            title: 'Malware Communication',
            description:
                'Suspicious outbound communication detected. Device may be compromised and communicating with C&C server.',
            sourceIp: '10.0.0.15',
            targetIp: '198.51.100.42',
            port: 8080,
            isResolved: false,
            createdAt: DateTime.now().subtract(const Duration(hours: 3))),
      ];
      _filteredAlerts = _allAlerts;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredAlerts = _allAlerts.where((alert) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          if (!alert.title.toLowerCase().contains(query) &&
              !alert.description.toLowerCase().contains(query) &&
              !(alert.sourceIp?.toLowerCase().contains(query) ?? false)) {
            return false;
          }
        }

        // Severity filter
        if (_selectedSeverity != 'All') {
          if (alert.severity.toLowerCase() != _selectedSeverity.toLowerCase()) {
            return false;
          }
        }

        // Type filter
        if (_selectedType != 'All') {
          final alertTypeMap = {
            'port_scan': 'Port Scan',
            'brute_force': 'Brute Force',
            'anomaly': 'Anomaly',
            'malware': 'Malware',
            'ddos': 'DDoS',
            'intrusion': 'Intrusion',
          };
          final mappedType = alertTypeMap[alert.alertType] ?? alert.alertType;
          if (mappedType != _selectedType) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  Future<void> _resolveAlert(SecurityAlert alert) async {
    if (!SupabaseService.instance.isAuthenticated) {
      // Preview mode - just update local state
      setState(() {
        final index = _allAlerts.indexWhere((a) => a.id == alert.id);
        if (index != -1) {
          // Create a new resolved alert (since SecurityAlert fields are final)
          _allAlerts[index] = SecurityAlert(
              id: alert.id,
              sessionId: alert.sessionId,
              alertType: alert.alertType,
              severity: alert.severity,
              title: alert.title,
              description: alert.description,
              sourceIp: alert.sourceIp,
              targetIp: alert.targetIp,
              port: alert.port,
              isResolved: true,
              resolvedBy: 'preview-user',
              resolvedAt: DateTime.now(),
              resolutionNotes: 'Manually resolved in preview mode',
              createdAt: alert.createdAt);
        }
        _applyFilters();
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert resolved (Preview Mode)')));
      return;
    }

    try {
      await MonitoringService.instance
          .resolveSecurityAlert(alert.id, 'Manually resolved by user');

      // Reload alerts to get updated data
      await _loadAlerts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alert resolved successfully')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to resolve alert: $error')));
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _onSeverityFilterChanged(String severity) {
    setState(() {
      _selectedSeverity = severity;
    });
    _applyFilters();
  }

  void _onTypeFilterChanged(String type) {
    setState(() {
      _selectedType = type;
    });
    _applyFilters();
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await _loadAlerts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
            title: 'Security Alerts',
            variant: CustomAppBarVariant.primary,
            onBackPressed: () => Navigator.pop(context)),
        body: Column(children: [
          // Preview Mode Banner (show when not authenticated)
          if (!SupabaseService.instance.isAuthenticated)
            Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                color: Colors.amber.withValues(alpha: 0.2),
                child: Row(children: [
                  Icon(Icons.visibility, color: Colors.amber[800]),
                  SizedBox(width: 2.w),
                  Expanded(
                      child: Text(
                          'Preview Mode - Showing sample security alerts',
                          style: TextStyle(
                              color: Colors.amber[800],
                              fontWeight: FontWeight.w500))),
                ])),

          CustomTabBar(
              tabs: const ['Dashboard', 'Alerts', 'Logs', 'Settings'],
              initialIndex: 1,
              variant: CustomTabBarVariant.segmented,
              onTap: (index) {
                switch (index) {
                  case 0:
                    Navigator.pushReplacementNamed(context, '/dashboard');
                    break;
                  case 2:
                    Navigator.pushReplacementNamed(context, '/network-logs');
                    break;
                  case 3:
                    Navigator.pushReplacementNamed(context, '/settings');
                    break;
                }
              }),

          // Search bar
          SearchBarWidget(
              initialValue: _searchQuery,
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                _applyFilters();
              },
              onClear: () {
                setState(() {
                  _searchQuery = '';
                });
                _applyFilters();
              },
              hintText: 'Search by IP, threat type, or description...'),

          Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: _filteredAlerts.isEmpty
                          ? EmptyStateWidget(
                              title: _searchQuery.isNotEmpty ||
                                      _selectedSeverity != 'All' ||
                                      _selectedType != 'All'
                                  ? 'No alerts match your filters'
                                  : 'No security alerts',
                              subtitle: _searchQuery.isNotEmpty ||
                                      _selectedSeverity != 'All' ||
                                      _selectedType != 'All'
                                  ? 'Try adjusting your search criteria'
                                  : 'Your network is secure',
                              actionText: _searchQuery.isNotEmpty ||
                                      _selectedSeverity != 'All' ||
                                      _selectedType != 'All'
                                  ? 'Clear Filters'
                                  : null,
                              onActionPressed: _searchQuery.isNotEmpty ||
                                      _selectedSeverity != 'All' ||
                                      _selectedType != 'All'
                                  ? () {
                                      setState(() {
                                        _searchQuery = '';
                                        _selectedSeverity = 'All';
                                        _selectedType = 'All';
                                      });
                                      _applyFilters();
                                    }
                                  : null)
                          : ListView.builder(
                              padding: EdgeInsets.all(4.w),
                              itemCount: _filteredAlerts.length,
                              itemBuilder: (context, index) {
                                final alert = _filteredAlerts[index];
                                return AlertCardWidget(alert: {
                                  'id': alert.id,
                                  'title': alert.title,
                                  'description': alert.description,
                                  'severity': alert.severity,
                                  'timestamp': alert.timeAgo,
                                  'source': alert.sourceIp ?? 'Unknown',
                                  'type': alert.alertType,
                                  'isResolved': alert.isResolved,
                                  'port': alert.port?.toString(),
                                }, onTap: () => _showAlertDetails(alert));
                              }))),
        ]),
        bottomNavigationBar: CustomBottomBar(
            currentIndex: _currentBottomIndex,
            onTap: (index) {
              setState(() {
                _currentBottomIndex = index;
              });
            },
            variant: CustomBottomBarVariant.standard));
  }

  void _showAlertDetails(SecurityAlert alert) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => Container(
            height: 70.h,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(children: [
              // Handle bar
              Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: 2.h),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: BorderRadius.circular(2))),

              // Header
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(children: [
                    Expanded(
                        child: Text(alert.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600))),
                    Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                            color: _getSeverityColor(alert.severity)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(alert.severity.toUpperCase(),
                            style: TextStyle(
                                color: _getSeverityColor(alert.severity),
                                fontWeight: FontWeight.w600,
                                fontSize: 10.sp))),
                  ])),

              SizedBox(height: 2.h),

              // Content
              Expanded(
                  child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                                'Type', _formatAlertType(alert.alertType)),
                            _buildDetailRow(
                                'Source IP', alert.sourceIp ?? 'Unknown'),
                            _buildDetailRow(
                                'Target IP', alert.targetIp ?? 'Unknown'),
                            if (alert.port != null)
                              _buildDetailRow('Port', alert.port.toString()),
                            _buildDetailRow('Detected', alert.timeAgo),
                            _buildDetailRow('Status',
                                alert.isResolved ? 'Resolved' : 'Active'),
                            if (alert.isResolved) ...[
                              SizedBox(height: 2.h),
                              Text('Resolution Details',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              SizedBox(height: 1.h),
                              if (alert.resolvedAt != null)
                                _buildDetailRow('Resolved At',
                                    _formatDateTime(alert.resolvedAt!)),
                              if (alert.resolutionNotes != null)
                                _buildDetailRow(
                                    'Notes', alert.resolutionNotes!),
                            ],
                            SizedBox(height: 2.h),
                            Text('Description',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            SizedBox(height: 1.h),
                            Text(alert.description,
                                style: Theme.of(context).textTheme.bodyMedium),
                            SizedBox(height: 4.h),
                          ]))),

              // Actions
              if (!alert.isResolved)
                Container(
                    padding: EdgeInsets.all(4.w),
                    child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _resolveAlert(alert);
                            },
                            child: const Text('Resolve Alert')))),
            ])));
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
        padding: EdgeInsets.only(bottom: 1.h),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 25.w,
              child: Text(label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7)))),
          Expanded(
              child:
                  Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ]));
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatAlertType(String type) {
    final typeMap = {
      'port_scan': 'Port Scan',
      'brute_force': 'Brute Force',
      'anomaly': 'Anomaly',
      'malware': 'Malware',
      'ddos': 'DDoS Attack',
      'intrusion': 'Intrusion',
    };
    return typeMap[type] ?? type;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
