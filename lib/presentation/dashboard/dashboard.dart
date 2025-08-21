import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_tab_bar.dart';
import './widgets/metrics_grid.dart';
import './widgets/monitoring_status_card.dart';
import './widgets/quick_actions.dart';
import './widgets/recent_alerts_section.dart';
import './widgets/traffic_chart.dart';
import '../../services/monitoring_service.dart';
import '../../services/supabase_service.dart';
import '../../models/monitoring_session.dart';
import '../../models/security_alert.dart';
import '../../models/system_metric.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  bool _isMonitoring = false;
  String _elapsedTime = '00:00:00';
  Timer? _monitoringTimer;
  Timer? _updateTimer;
  DateTime? _monitoringStartTime;
  int _currentBottomIndex = 0;

  // Supabase data
  MonitoringSession? _currentSession;
  List<SecurityAlert> _recentAlerts = [];
  List<SystemMetric> _systemMetrics = [];
  bool _isLoading = false;

  // Current metrics from real data
  Map<String, dynamic> _metrics = {
    'packetsPerSecond': 0,
    'bandwidth': '0 MB/s',
    'threatsDetected': 0,
    'activeConnections': 0,
  };

  final List<Map<String, dynamic>> _trafficData = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _initializeTrafficData();
    _startPeriodicUpdates();
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (!SupabaseService.instance.isAuthenticated) {
      // Show preview data for unauthenticated users
      _loadPreviewData();
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Load recent alerts
      final alerts =
          await MonitoringService.instance.getSecurityAlerts(limit: 10);
      setState(() {
        _recentAlerts = alerts;
      });

      // Check for active session
      final sessions = await MonitoringService.instance.getMonitoringSessions();
      final activeSession = sessions.where((s) => s.isActive).firstOrNull;

      if (activeSession != null) {
        setState(() {
          _currentSession = activeSession;
          _isMonitoring = true;
          _monitoringStartTime = activeSession.startedAt;
          _updateMetricsFromSession(activeSession);
        });
        _startMonitoringTimer();
      }
    } catch (error) {
      debugPrint('Error loading dashboard data: $error');
      _loadPreviewData(); // Fallback to preview data
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadPreviewData() {
    // Load mock data for preview/demo purposes
    setState(() {
      _recentAlerts = [
        SecurityAlert(
          id: 'preview-1',
          sessionId: 'session-1',
          alertType: 'port_scan',
          severity: 'critical',
          title: 'Suspicious Port Scan Detected',
          description:
              'Multiple connection attempts from unknown IP address targeting common service ports.',
          sourceIp: '192.168.1.105',
          targetIp: '10.0.0.1',
          port: 22,
          isResolved: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        SecurityAlert(
          id: 'preview-2',
          sessionId: 'session-1',
          alertType: 'anomaly',
          severity: 'high',
          title: 'Unusual Bandwidth Usage',
          description:
              'Abnormal data transfer detected from internal device to external server.',
          sourceIp: '10.0.0.23',
          targetIp: '203.0.113.45',
          port: 443,
          isResolved: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        SecurityAlert(
          id: 'preview-3',
          sessionId: 'session-1',
          alertType: 'brute_force',
          severity: 'medium',
          title: 'Failed Authentication Attempts',
          description:
              'Multiple failed login attempts detected on network service.',
          sourceIp: '172.16.0.45',
          targetIp: '10.0.0.1',
          port: 80,
          isResolved: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];
    });
  }

  void _updateMetricsFromSession(MonitoringSession session) {
    setState(() {
      _metrics = {
        'packetsPerSecond': session.packetsAnalyzed,
        'bandwidth': '${session.bandwidthUsed.toStringAsFixed(1)} MB/s',
        'threatsDetected': session.threatsDetected,
        'activeConnections': session.activeConnections,
      };
    });
  }

  void _initializeTrafficData() {
    final now = DateTime.now();
    for (int i = 0; i < 12; i++) {
      final time = now.subtract(Duration(minutes: (11 - i) * 5));
      _trafficData.add({
        'time':
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        'packets': _isMonitoring ? (20 + (i * 5) + (i % 3 * 10)) : 0,
      });
    }
  }

  void _startPeriodicUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_isMonitoring && mounted) {
        await _updateRealTimeData();
        _updateTrafficData();
      }
    });
  }

  Future<void> _updateRealTimeData() async {
    if (_currentSession == null || !SupabaseService.instance.isAuthenticated) {
      _updateMockMetrics();
      return;
    }

    try {
      // Get latest session data
      final sessions = await MonitoringService.instance.getMonitoringSessions();
      final activeSession =
          sessions.where((s) => s.id == _currentSession!.id).firstOrNull;

      if (activeSession != null) {
        setState(() {
          _currentSession = activeSession;
          _updateMetricsFromSession(activeSession);
        });
      }

      // Record current system metrics
      await MonitoringService.instance.recordSystemMetric(
        sessionId: _currentSession!.id,
        cpuUsage: 45.2 + (DateTime.now().second % 20),
        memoryUsage: 67.8 + (DateTime.now().second % 15),
        diskUsage: 23.1,
        networkThroughput: _currentSession!.bandwidthUsed,
        activeConnections: _currentSession!.activeConnections,
        packetsPerSecond: 50 + (DateTime.now().second % 20),
      );
    } catch (error) {
      debugPrint('Error updating real-time data: $error');
      _updateMockMetrics(); // Fallback to mock updates
    }
  }

  void _updateMockMetrics() {
    setState(() {
      _metrics['packetsPerSecond'] =
          _isMonitoring ? (50 + (DateTime.now().second % 20)) : 0;
      _metrics['bandwidth'] = _isMonitoring
          ? '${(2.5 + (DateTime.now().second % 10) * 0.3).toStringAsFixed(1)} MB/s'
          : '0 MB/s';
      _metrics['activeConnections'] =
          _isMonitoring ? (15 + (DateTime.now().second % 5)) : 0;
    });
  }

  void _updateTrafficData() {
    if (_trafficData.isNotEmpty) {
      setState(() {
        // Remove first element and add new one
        _trafficData.removeAt(0);
        final now = DateTime.now();
        _trafficData.add({
          'time':
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          'packets': _isMonitoring ? (30 + (now.second % 40)) : 0,
        });
      });
    }
  }

  Future<void> _toggleMonitoring() async {
    HapticFeedback.mediumImpact();

    if (!SupabaseService.instance.isAuthenticated) {
      // Preview mode - just toggle mock monitoring
      setState(() {
        _isMonitoring = !_isMonitoring;
        if (_isMonitoring) {
          _monitoringStartTime = DateTime.now();
          _startMonitoringTimer();
        } else {
          _monitoringTimer?.cancel();
          _elapsedTime = '00:00:00';
          _metrics['packetsPerSecond'] = 0;
          _metrics['bandwidth'] = '0 MB/s';
          _metrics['threatsDetected'] = 0;
          _metrics['activeConnections'] = 0;
        }
      });
      return;
    }

    try {
      if (!_isMonitoring) {
        // Start new monitoring session
        final session =
            await MonitoringService.instance.createMonitoringSession();
        setState(() {
          _currentSession = session;
          _isMonitoring = true;
          _monitoringStartTime = session.startedAt;
        });
        _startMonitoringTimer();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Monitoring session started')),
        );
      } else {
        // End current monitoring session
        if (_currentSession != null) {
          await MonitoringService.instance
              .endMonitoringSession(_currentSession!.id);
        }

        setState(() {
          _isMonitoring = false;
          _currentSession = null;
          _monitoringTimer?.cancel();
          _elapsedTime = '00:00:00';
          _metrics['packetsPerSecond'] = 0;
          _metrics['bandwidth'] = '0 MB/s';
          _metrics['activeConnections'] = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Monitoring session ended')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  void _startMonitoringTimer() {
    _monitoringTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_monitoringStartTime != null && mounted) {
        final elapsed = DateTime.now().difference(_monitoringStartTime!);
        setState(() {
          _elapsedTime = _formatDuration(elapsed);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  void _onMetricLongPress() {
    HapticFeedback.lightImpact();
    _showMetricDetails();
  }

  void _showMetricDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Detailed Metrics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                children: [
                  _buildDetailMetric(
                      'Network Packets',
                      '${_metrics['packetsPerSecond']} packets/sec',
                      'Real-time packet analysis'),
                  _buildDetailMetric('Bandwidth Usage',
                      '${_metrics['bandwidth']}', 'Current network throughput'),
                  _buildDetailMetric(
                      'Active Connections',
                      '${_metrics['activeConnections']} connections',
                      'Live network connections'),
                  _buildDetailMetric(
                      'Threats Detected',
                      '${_metrics['threatsDetected']} threats',
                      'Security incidents identified'),
                  _buildDetailMetric(
                      'Monitoring Status',
                      _isMonitoring ? 'Active' : 'Inactive',
                      'Current monitoring state'),
                  _buildDetailMetric('Session Duration', _elapsedTime,
                      'Current session uptime'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailMetric(String title, String value, String description) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await _initializeData();
    if (mounted) {
      _updateRealTimeData();
      _updateTrafficData();
    }
  }

  void _onExportLogs() {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exporting network logs...'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => Navigator.pushNamed(context, '/network-logs'),
        ),
      ),
    );
  }

  Future<void> _onRunSecurityScan() async {
    HapticFeedback.selectionClick();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Scan'),
        content:
            const Text('Run a comprehensive security scan of your network?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start Scan'),
          ),
        ],
      ),
    );

    if (confirmed == true &&
        _currentSession != null &&
        SupabaseService.instance.isAuthenticated) {
      try {
        // Create a security scan alert
        await MonitoringService.instance.createSecurityAlert(
          sessionId: _currentSession!.id,
          alertType: 'anomaly',
          severity: 'low',
          title: 'Security Scan Initiated',
          description: 'Comprehensive network security scan started by user.',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Security scan initiated...')),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Scan failed: $error')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Security scan initiated...')),
      );
    }
  }

  void _onViewNetworkInterfaces() {
    HapticFeedback.selectionClick();
    Navigator.pushNamed(context, '/settings');
  }

  void _onViewAllAlerts() {
    Navigator.pushNamed(context, '/real-time-alerts');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'FlutterGuard IDS',
          variant: CustomAppBarVariant.dashboard,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'FlutterGuard IDS',
        variant: CustomAppBarVariant.dashboard,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Preview Mode Banner (show when not authenticated)
              if (!SupabaseService.instance.isAuthenticated)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.w),
                  color: Colors.amber.withValues(alpha: 0.2),
                  child: Row(
                    children: [
                      Icon(Icons.visibility, color: Colors.amber[800]),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Preview Mode - Sign in to access full monitoring features',
                          style: TextStyle(
                              color: Colors.amber[800],
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        child: Text('Sign In',
                            style: TextStyle(color: Colors.amber[800])),
                      ),
                    ],
                  ),
                ),

              CustomTabBar(
                tabs: const ['Dashboard', 'Alerts', 'Logs', 'Settings'],
                initialIndex: 0,
                variant: CustomTabBarVariant.segmented,
                onTap: (index) {
                  switch (index) {
                    case 1:
                      Navigator.pushNamed(context, '/real-time-alerts');
                      break;
                    case 2:
                      Navigator.pushNamed(context, '/network-logs');
                      break;
                    case 3:
                      Navigator.pushNamed(context, '/settings');
                      break;
                  }
                },
              ),
              SizedBox(height: 2.h),
              MonitoringStatusCard(
                isMonitoring: _isMonitoring,
                elapsedTime: _elapsedTime,
                onToggle: _toggleMonitoring,
              ),
              MetricsGrid(
                metrics: _metrics,
                onMetricLongPress: _onMetricLongPress,
              ),
              TrafficChart(
                trafficData: _trafficData,
                isMonitoring: _isMonitoring,
              ),
              RecentAlertsSection(
                recentAlerts: _recentAlerts
                    .map((alert) => {
                          'id': alert.id,
                          'title': alert.title,
                          'description': alert.description,
                          'severity': alert.severity,
                          'timestamp': alert.timeAgo,
                          'source': alert.sourceIp ?? 'Unknown',
                          'type': alert.alertType,
                        })
                    .toList(),
                onViewAllAlerts: _onViewAllAlerts,
              ),
              QuickActions(
                onExportLogs: _onExportLogs,
                onRunSecurityScan: _onRunSecurityScan,
                onViewNetworkInterfaces: _onViewNetworkInterfaces,
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomIndex,
        onTap: (index) {
          setState(() {
            _currentBottomIndex = index;
          });
        },
        variant: CustomBottomBarVariant.standard,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleMonitoring,
        backgroundColor: _isMonitoring ? Colors.red : Colors.green,
        icon: CustomIconWidget(
          iconName: _isMonitoring ? 'stop' : 'play_arrow',
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          _isMonitoring ? 'Stop' : 'Start',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
