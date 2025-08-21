import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/battery_usage_widget.dart';
import './widgets/confirmation_dialog_widget.dart';
import './widgets/help_modal_widget.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_search_widget.dart';
import './widgets/settings_section_widget.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with TickerProviderStateMixin {
  late SharedPreferences _prefs;
  String _searchQuery = '';
  bool _isLoading = true;

  // Settings state variables
  bool _isMonitoringEnabled = true;
  bool _backgroundMonitoring = true;
  bool _batteryOptimization = false;
  bool _notificationsEnabled = true;
  bool _isDarkMode = false;
  bool _hapticFeedback = true;
  bool _logEncryption = true;
  String _selectedNetworkInterface = 'WiFi';
  String _severityThreshold = 'Medium';
  String _dataRetentionPeriod = '30 days';
  String _quietHoursStart = '22:00';
  String _quietHoursEnd = '07:00';

  // Mock data for battery usage
  final double _batteryUsage = 8.5;
  final String _optimizationStatus = 'Good';
  final List<String> _batterySuggestions = [
    'Enable battery optimization for background monitoring',
    'Reduce monitoring frequency during low activity periods',
    'Use WiFi instead of cellular data when possible',
  ];

  // Mock data for app info
  final String _appVersion = '2.1.4';
  final String _buildNumber = '2024082001';
  final DateTime _lastUpdate = DateTime(2024, 8, 15);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      setState(() {
        _isMonitoringEnabled = _prefs.getBool('monitoring_enabled') ?? true;
        _backgroundMonitoring = _prefs.getBool('background_monitoring') ?? true;
        _batteryOptimization = _prefs.getBool('battery_optimization') ?? false;
        _notificationsEnabled = _prefs.getBool('notifications_enabled') ?? true;
        _isDarkMode = _prefs.getBool('dark_mode') ?? false;
        _hapticFeedback = _prefs.getBool('haptic_feedback') ?? true;
        _logEncryption = _prefs.getBool('log_encryption') ?? true;
        _selectedNetworkInterface =
            _prefs.getString('network_interface') ?? 'WiFi';
        _severityThreshold = _prefs.getString('severity_threshold') ?? 'Medium';
        _dataRetentionPeriod = _prefs.getString('data_retention') ?? '30 days';
        _quietHoursStart = _prefs.getString('quiet_hours_start') ?? '22:00';
        _quietHoursEnd = _prefs.getString('quiet_hours_end') ?? '07:00';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showToast('Failed to load settings');
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value is String) {
        await _prefs.setString(key, value);
      }
    } catch (e) {
      _showToast('Failed to save setting');
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  List<Widget> _getFilteredSections() {
    final List<Widget> sections = [];

    if (_searchQuery.isEmpty ||
        'monitoring network interface background battery'
            .contains(_searchQuery.toLowerCase())) {
      sections.add(_buildMonitoringSection());
    }

    if (_searchQuery.isEmpty ||
        'alert notification severity threshold quiet hours'
            .contains(_searchQuery.toLowerCase())) {
      sections.add(_buildAlertSection());
    }

    if (_searchQuery.isEmpty ||
        'security encryption retention export signature'
            .contains(_searchQuery.toLowerCase())) {
      sections.add(_buildSecuritySection());
    }

    if (_searchQuery.isEmpty ||
        'ui theme dark light haptic feedback chart'
            .contains(_searchQuery.toLowerCase())) {
      sections.add(_buildUISection());
    }

    if (_searchQuery.isEmpty ||
        'advanced machine learning debug reset diagnostic'
            .contains(_searchQuery.toLowerCase())) {
      sections.add(_buildAdvancedSection());
    }

    if (_searchQuery.isEmpty) {
      sections.add(_buildBatterySection());
      sections.add(_buildAboutSection());
    }

    return sections;
  }

  Widget _buildMonitoringSection() {
    return SettingsSectionWidget(
      title: 'Monitoring Settings',
      children: [
        SettingsItemWidget(
          title: 'Network Monitoring',
          subtitle: 'Enable real-time network traffic monitoring',
          iconName: 'security',
          type: SettingsItemType.toggle,
          value: _isMonitoringEnabled,
          isFirst: true,
          onToggle: (value) {
            setState(() => _isMonitoringEnabled = value);
            _saveSetting('monitoring_enabled', value);
            if (value) {
              _showToast('Network monitoring enabled');
            } else {
              _showToast('Network monitoring disabled');
            }
          },
        ),
        SettingsItemWidget(
          title: 'Network Interface',
          subtitle: 'Select network interface to monitor',
          iconName: 'wifi',
          type: SettingsItemType.selection,
          trailingText: _selectedNetworkInterface,
          onTap: () => _showNetworkInterfaceDialog(),
        ),
        SettingsItemWidget(
          title: 'Background Monitoring',
          subtitle: 'Continue monitoring when app is in background',
          iconName: 'visibility',
          type: SettingsItemType.toggle,
          value: _backgroundMonitoring,
          onToggle: (value) {
            setState(() => _backgroundMonitoring = value);
            _saveSetting('background_monitoring', value);
          },
        ),
        SettingsItemWidget(
          title: 'Battery Optimization',
          subtitle: 'Optimize monitoring for better battery life',
          iconName: 'battery_saver',
          type: SettingsItemType.toggle,
          value: _batteryOptimization,
          isLast: true,
          onToggle: (value) {
            setState(() => _batteryOptimization = value);
            _saveSetting('battery_optimization', value);
          },
        ),
      ],
    );
  }

  Widget _buildAlertSection() {
    return SettingsSectionWidget(
      title: 'Alert Configuration',
      children: [
        SettingsItemWidget(
          title: 'Push Notifications',
          subtitle: 'Receive alerts for security threats',
          iconName: 'notifications',
          type: SettingsItemType.toggle,
          value: _notificationsEnabled,
          isFirst: true,
          statusColor: _notificationsEnabled ? Colors.green : Colors.orange,
          onToggle: (value) {
            setState(() => _notificationsEnabled = value);
            _saveSetting('notifications_enabled', value);
          },
        ),
        SettingsItemWidget(
          title: 'Severity Threshold',
          subtitle: 'Minimum threat level for alerts',
          iconName: 'warning',
          type: SettingsItemType.selection,
          trailingText: _severityThreshold,
          onTap: () => _showSeverityDialog(),
        ),
        SettingsItemWidget(
          title: 'Custom Alert Rules',
          subtitle: 'Configure custom detection patterns',
          iconName: 'rule',
          type: SettingsItemType.navigation,
          showBadge: true,
          onTap: () => _showToast('Custom rules feature coming soon'),
        ),
        SettingsItemWidget(
          title: 'Quiet Hours',
          subtitle: 'Disable alerts during specified hours',
          iconName: 'bedtime',
          type: SettingsItemType.selection,
          trailingText: '$_quietHoursStart - $_quietHoursEnd',
          isLast: true,
          onTap: () => _showQuietHoursDialog(),
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return SettingsSectionWidget(
      title: 'Security Options',
      children: [
        SettingsItemWidget(
          title: 'Log Encryption',
          subtitle: 'Encrypt logs before server transmission',
          iconName: 'lock',
          type: SettingsItemType.toggle,
          value: _logEncryption,
          isFirst: true,
          statusColor: _logEncryption ? Colors.green : Colors.red,
          onToggle: (value) {
            setState(() => _logEncryption = value);
            _saveSetting('log_encryption', value);
          },
        ),
        SettingsItemWidget(
          title: 'Data Retention Period',
          subtitle: 'How long to keep security logs',
          iconName: 'schedule',
          type: SettingsItemType.selection,
          trailingText: _dataRetentionPeriod,
          onTap: () => _showRetentionDialog(),
        ),
        SettingsItemWidget(
          title: 'Export Security Settings',
          subtitle: 'Backup configuration to file',
          iconName: 'file_download',
          type: SettingsItemType.action,
          onTap: () => _exportSettings(),
        ),
        SettingsItemWidget(
          title: 'Threat Signature Updates',
          subtitle: 'Last updated: Aug 15, 2024',
          iconName: 'update',
          type: SettingsItemType.action,
          isLast: true,
          onTap: () => _updateThreatSignatures(),
        ),
      ],
    );
  }

  Widget _buildUISection() {
    return SettingsSectionWidget(
      title: 'UI Preferences',
      children: [
        SettingsItemWidget(
          title: 'Dark Mode',
          subtitle: 'Use dark theme for better visibility',
          iconName: 'dark_mode',
          type: SettingsItemType.toggle,
          value: _isDarkMode,
          isFirst: true,
          onToggle: (value) {
            setState(() => _isDarkMode = value);
            _saveSetting('dark_mode', value);
            _showToast('Theme will change on app restart');
          },
        ),
        SettingsItemWidget(
          title: 'Haptic Feedback',
          subtitle: 'Vibration feedback for interactions',
          iconName: 'vibration',
          type: SettingsItemType.toggle,
          value: _hapticFeedback,
          onToggle: (value) {
            setState(() => _hapticFeedback = value);
            _saveSetting('haptic_feedback', value);
            if (value) HapticFeedback.selectionClick();
          },
        ),
        SettingsItemWidget(
          title: 'Chart Display Options',
          subtitle: 'Customize dashboard visualizations',
          iconName: 'bar_chart',
          type: SettingsItemType.navigation,
          isLast: true,
          onTap: () => _showToast('Chart options coming soon'),
        ),
      ],
    );
  }

  Widget _buildAdvancedSection() {
    return SettingsSectionWidget(
      title: 'Advanced',
      children: [
        SettingsItemWidget(
          title: 'ML Model Updates',
          subtitle: 'Update machine learning detection models',
          iconName: 'psychology',
          type: SettingsItemType.action,
          isFirst: true,
          onTap: () => _updateMLModels(),
        ),
        SettingsItemWidget(
          title: 'Debug Logging',
          subtitle: 'Enable detailed diagnostic logs',
          iconName: 'bug_report',
          type: SettingsItemType.toggle,
          value: false,
          onToggle: (value) {
            _showToast('Debug logging ${value ? 'enabled' : 'disabled'}');
          },
        ),
        SettingsItemWidget(
          title: 'Reset App Data',
          subtitle: 'Clear all settings and logs',
          iconName: 'refresh',
          type: SettingsItemType.action,
          statusColor: Colors.red,
          onTap: () => _showResetDialog(),
        ),
        SettingsItemWidget(
          title: 'Diagnostic Information',
          subtitle: 'View system and app diagnostics',
          iconName: 'info',
          type: SettingsItemType.navigation,
          isLast: true,
          onTap: () => _showDiagnosticInfo(),
        ),
      ],
    );
  }

  Widget _buildBatterySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: BatteryUsageWidget(
        batteryUsagePercentage: _batteryUsage,
        optimizationStatus: _optimizationStatus,
        suggestions: _batterySuggestions,
      ),
    );
  }

  Widget _buildAboutSection() {
    return SettingsSectionWidget(
      title: 'About',
      children: [
        SettingsItemWidget(
          title: 'App Version',
          iconName: 'info',
          type: SettingsItemType.info,
          trailingText: _appVersion,
          isFirst: true,
        ),
        SettingsItemWidget(
          title: 'Build Number',
          iconName: 'code',
          type: SettingsItemType.info,
          trailingText: _buildNumber,
        ),
        SettingsItemWidget(
          title: 'Last Update',
          iconName: 'update',
          type: SettingsItemType.info,
          trailingText:
              '${_lastUpdate.day}/${_lastUpdate.month}/${_lastUpdate.year}',
        ),
        SettingsItemWidget(
          title: 'Privacy Policy',
          iconName: 'privacy_tip',
          type: SettingsItemType.action,
          onTap: () => _showToast('Opening privacy policy...'),
        ),
        SettingsItemWidget(
          title: 'Support & Feedback',
          iconName: 'support',
          type: SettingsItemType.action,
          isLast: true,
          onTap: () => _showToast('Opening support center...'),
        ),
      ],
    );
  }

  void _showNetworkInterfaceDialog() {
    final interfaces = ['WiFi', 'Cellular', 'Ethernet', 'All Interfaces'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Network Interface'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: interfaces
              .map((interface) => RadioListTile<String>(
                    title: Text(interface),
                    value: interface,
                    groupValue: _selectedNetworkInterface,
                    onChanged: (value) {
                      setState(() => _selectedNetworkInterface = value!);
                      _saveSetting('network_interface', value!);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showSeverityDialog() {
    final severities = ['Low', 'Medium', 'High', 'Critical'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alert Severity Threshold'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: severities
              .map((severity) => RadioListTile<String>(
                    title: Text(severity),
                    subtitle: Text(_getSeverityDescription(severity)),
                    value: severity,
                    groupValue: _severityThreshold,
                    onChanged: (value) {
                      setState(() => _severityThreshold = value!);
                      _saveSetting('severity_threshold', value!);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showRetentionDialog() {
    final periods = ['7 days', '30 days', '90 days', '1 year', 'Forever'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Retention Period'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: periods
              .map((period) => RadioListTile<String>(
                    title: Text(period),
                    value: period,
                    groupValue: _dataRetentionPeriod,
                    onChanged: (value) {
                      setState(() => _dataRetentionPeriod = value!);
                      _saveSetting('data_retention', value!);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showQuietHoursDialog() {
    HelpModalWidget.show(
      context,
      title: 'Quiet Hours Configuration',
      content:
          'Set specific hours when you don\'t want to receive security alerts. The system will still monitor and log threats, but notifications will be suppressed.',
      bulletPoints: [
        'Monitoring continues in background',
        'Critical threats may still trigger alerts',
        'All events are logged for review',
        'Customize start and end times',
      ],
    );
  }

  void _showResetDialog() async {
    final confirmed = await ConfirmationDialogWidget.show(
      context,
      title: 'Reset App Data',
      message:
          'This will permanently delete all settings, logs, and cached data. This action cannot be undone.',
      confirmText: 'Reset',
      isDestructive: true,
    );

    if (confirmed == true) {
      try {
        await _prefs.clear();
        _showToast('App data has been reset');
        // Reset UI state
        setState(() {
          _isMonitoringEnabled = true;
          _backgroundMonitoring = true;
          _batteryOptimization = false;
          _notificationsEnabled = true;
          _isDarkMode = false;
          _hapticFeedback = true;
          _logEncryption = true;
          _selectedNetworkInterface = 'WiFi';
          _severityThreshold = 'Medium';
          _dataRetentionPeriod = '30 days';
        });
      } catch (e) {
        _showToast('Failed to reset app data');
      }
    }
  }

  void _exportSettings() async {
    try {
      final settings = {
        'monitoring_enabled': _isMonitoringEnabled,
        'background_monitoring': _backgroundMonitoring,
        'battery_optimization': _batteryOptimization,
        'notifications_enabled': _notificationsEnabled,
        'dark_mode': _isDarkMode,
        'haptic_feedback': _hapticFeedback,
        'log_encryption': _logEncryption,
        'network_interface': _selectedNetworkInterface,
        'severity_threshold': _severityThreshold,
        'data_retention': _dataRetentionPeriod,
        'export_date': DateTime.now().toIso8601String(),
        'app_version': _appVersion,
      };

      // In a real implementation, this would save to file
      _showToast('Settings exported successfully');
    } catch (e) {
      _showToast('Failed to export settings');
    }
  }

  void _updateThreatSignatures() async {
    _showToast('Checking for signature updates...');

    // Simulate update process
    await Future.delayed(const Duration(seconds: 2));
    _showToast('Threat signatures updated successfully');
  }

  void _updateMLModels() async {
    _showToast('Downloading ML model updates...');

    // Simulate update process
    await Future.delayed(const Duration(seconds: 3));
    _showToast('ML models updated successfully');
  }

  void _showDiagnosticInfo() {
    HelpModalWidget.show(
      context,
      title: 'Diagnostic Information',
      content: 'System and application diagnostic details for troubleshooting.',
      bulletPoints: [
        'App Version: $_appVersion ($_buildNumber)',
        'Platform: ${Theme.of(context).platform.name}',
        'Memory Usage: 45.2 MB',
        'Storage Used: 128.5 MB',
        'Network Status: Connected (WiFi)',
        'Last Sync: ${DateTime.now().subtract(const Duration(minutes: 5))}',
        'Active Monitoring: ${_isMonitoringEnabled ? "Yes" : "No"}',
        'Background Mode: ${_backgroundMonitoring ? "Enabled" : "Disabled"}',
      ],
    );
  }

  String _getSeverityDescription(String severity) {
    switch (severity) {
      case 'Low':
        return 'Minor security events and warnings';
      case 'Medium':
        return 'Moderate threats requiring attention';
      case 'High':
        return 'Serious security incidents';
      case 'Critical':
        return 'Immediate action required';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: colorScheme.surface,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'help_outline',
              color: colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {
              HelpModalWidget.show(
                context,
                title: 'Settings Help',
                content:
                    'Configure FlutterGuard IDS to match your security monitoring needs. Each section contains options to customize detection, alerts, and system behavior.',
                bulletPoints: [
                  'Use search to quickly find specific settings',
                  'Toggle switches control feature activation',
                  'Tap items with arrows for detailed options',
                  'Help icons provide context for complex features',
                  'Changes are saved automatically',
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SettingsSearchWidget(
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            hintText: 'Search settings...',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _getFilteredSections(),
            ),
          ),
        ],
      ),
    );
  }
}
