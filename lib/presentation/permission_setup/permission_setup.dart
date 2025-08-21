import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/educational_modal_widget.dart';
import './widgets/permission_card_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/security_benefits_widget.dart';
import './widgets/warning_modal_widget.dart';

class PermissionSetup extends StatefulWidget {
  const PermissionSetup({super.key});

  @override
  State<PermissionSetup> createState() => _PermissionSetupState();
}

class _PermissionSetupState extends State<PermissionSetup>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStep = 0;
  bool _showTechnicalDetails = false;

  final List<String> _stepLabels = [
    'Network',
    'Notifications',
    'Background',
    'Complete'
  ];

  final List<Map<String, dynamic>> _permissions = [
    {
      'id': 'network',
      'title': 'Network Monitoring',
      'description':
          'Monitor network traffic for threat detection and analysis',
      'icon': 'network_check',
      'isGranted': false,
      'isRequired': true,
      'technicalDetails': [
        'VPN service overlay for deep packet inspection',
        'Network interface access for traffic analysis',
        'Protocol-level monitoring capabilities',
        'Real-time packet filtering and analysis'
      ],
      'privacyProtections': [
        'No personal data is collected or stored',
        'Traffic analysis is performed locally on device',
        'Only security-relevant metadata is logged',
        'All data remains encrypted and private'
      ]
    },
    {
      'id': 'notifications',
      'title': 'Security Notifications',
      'description': 'Receive instant alerts when threats are detected',
      'icon': 'notifications_active',
      'isGranted': false,
      'isRequired': true,
      'technicalDetails': [
        'Push notification service integration',
        'Real-time alert delivery system',
        'Critical threat notification priority',
        'Background notification processing'
      ],
      'privacyProtections': [
        'Notifications contain no sensitive data',
        'Alert content is anonymized',
        'No notification data is shared externally',
        'User controls notification preferences'
      ]
    },
    {
      'id': 'background',
      'title': 'Background Processing',
      'description': 'Continuous monitoring even when app is not active',
      'icon': 'schedule',
      'isGranted': false,
      'isRequired': true,
      'technicalDetails': [
        'Background service for continuous monitoring',
        'Battery optimization whitelist inclusion',
        'Efficient resource usage algorithms',
        'Automatic threat response capabilities'
      ],
      'privacyProtections': [
        'Background processing is security-focused only',
        'No user activity tracking or monitoring',
        'Minimal resource consumption design',
        'User can disable background monitoring anytime'
      ]
    },
    {
      'id': 'storage',
      'title': 'Secure Storage',
      'description': 'Store security logs and threat data locally',
      'icon': 'storage',
      'isGranted': false,
      'isRequired': false,
      'technicalDetails': [
        'Encrypted local database storage',
        'Secure log file management',
        'Automatic data retention policies',
        'Export capabilities for analysis'
      ],
      'privacyProtections': [
        'All stored data is encrypted at rest',
        'No cloud storage or external sharing',
        'User controls data retention periods',
        'Secure deletion when data expires'
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkInitialPermissions();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _checkInitialPermissions() {
    // Simulate checking current permission status
    // In a real app, this would check actual system permissions
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          // Mock some permissions as already granted for demo
          _permissions[3]['isGranted'] = true; // Storage permission
        });
        _updateCurrentStep();
      }
    });
  }

  void _updateCurrentStep() {
    int grantedRequired = 0;
    for (var permission in _permissions) {
      if (permission['isRequired'] && permission['isGranted']) {
        grantedRequired++;
      }
    }

    setState(() {
      _currentStep = grantedRequired >= 3 ? 3 : grantedRequired;
    });
  }

  Future<void> _requestPermission(String permissionId) async {
    HapticFeedback.mediumImpact();

    // Show educational modal first
    final permission = _permissions.firstWhere((p) => p['id'] == permissionId);
    await _showEducationalModal(permission);

    // Simulate permission request
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() {
        permission['isGranted'] = true;
      });
      _updateCurrentStep();

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${permission['title']} permission granted'),
          backgroundColor: AppTheme.successLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _showEducationalModal(Map<String, dynamic> permission) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EducationalModalWidget(
        title: permission['title'],
        description: permission['description'],
        technicalDetails: List<String>.from(permission['technicalDetails']),
        privacyProtections: List<String>.from(permission['privacyProtections']),
      ),
    );
  }

  void _showWarningModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WarningModalWidget(
        onContinue: () {
          Navigator.pop(context);
          _navigateToDashboard();
        },
        onGoBack: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _navigateToDashboard() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  bool get _allRequiredPermissionsGranted {
    return _permissions
        .where((p) => p['isRequired'])
        .every((p) => p['isGranted']);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Progress Indicator
                ProgressIndicatorWidget(
                  currentStep: _currentStep,
                  totalSteps: 4,
                  stepLabels: _stepLabels,
                ),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Column(
                      children: [
                        // Header Section
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Column(
                            children: [
                              Container(
                                width: 20.w,
                                height: 20.w,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: CustomIconWidget(
                                    iconName: 'security',
                                    color: colorScheme.primary,
                                    size: 10.w,
                                  ),
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                'Secure Your Network',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Grant essential permissions to enable comprehensive network monitoring and threat detection',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 4.h),

                        // Security Benefits
                        const SecurityBenefitsWidget(),

                        SizedBox(height: 3.h),

                        // Permission Cards
                        ..._permissions
                            .map((permission) => PermissionCardWidget(
                                  title: permission['title'],
                                  description: permission['description'],
                                  iconName: permission['icon'],
                                  isGranted: permission['isGranted'],
                                  isRequired: permission['isRequired'],
                                  onTap: () =>
                                      _requestPermission(permission['id']),
                                )),

                        SizedBox(height: 2.h),

                        // Technical Details Expandable
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          child: ExpansionTile(
                            title: Text(
                              'Why do we need these permissions?',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            leading: CustomIconWidget(
                              iconName: 'help_outline',
                              color: colorScheme.primary,
                              size: 5.w,
                            ),
                            children: [
                              Container(
                                padding: EdgeInsets.all(4.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'FlutterGuard IDS requires these permissions to provide comprehensive network security monitoring:',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurface
                                            .withValues(alpha: 0.8),
                                        height: 1.4,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    _buildTechnicalPoint(
                                      context,
                                      'Network Access',
                                      'Monitor traffic patterns and detect suspicious activities in real-time',
                                    ),
                                    _buildTechnicalPoint(
                                      context,
                                      'Background Processing',
                                      'Continuous protection even when the app is not actively used',
                                    ),
                                    _buildTechnicalPoint(
                                      context,
                                      'Notifications',
                                      'Immediate alerts for critical security events and threats',
                                    ),
                                    _buildTechnicalPoint(
                                      context,
                                      'Local Storage',
                                      'Secure logging of security events for analysis and reporting',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Buttons
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _allRequiredPermissionsGranted
                              ? _navigateToDashboard
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            _allRequiredPermissionsGranted
                                ? 'Start Monitoring'
                                : 'Grant Required Permissions',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _allRequiredPermissionsGranted
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextButton(
                        onPressed: _showWarningModal,
                        child: Text(
                          'Skip Setup (Limited Functionality)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicalPoint(
    BuildContext context,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 1.5.w,
            height: 1.5.w,
            margin: EdgeInsets.only(top: 1.h, right: 3.w),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
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
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
