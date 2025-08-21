import 'package:flutter/material.dart';
import '../presentation/settings/settings.dart';
import '../presentation/permission_setup/permission_setup.dart';
import '../presentation/network_logs/network_logs.dart';
import '../presentation/dashboard/dashboard.dart';
import '../presentation/real_time_alerts/real_time_alerts.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/signup_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String settings = '/settings';
  static const String permissionSetup = '/permission-setup';
  static const String networkLogs = '/network-logs';
  static const String dashboard = '/dashboard';
  static const String realTimeAlerts = '/real-time-alerts';
  static const String login = '/login';
  static const String signup = '/signup';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const Dashboard(),
    settings: (context) => const Settings(),
    permissionSetup: (context) => const PermissionSetup(),
    networkLogs: (context) => const NetworkLogs(),
    dashboard: (context) => const Dashboard(),
    realTimeAlerts: (context) => const RealTimeAlerts(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignUpScreen(),
    // TODO: Add your other routes here
  };
}
