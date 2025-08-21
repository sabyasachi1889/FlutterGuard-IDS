import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomAppBarVariant {
  primary,
  secondary,
  transparent,
  dashboard,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = CustomAppBarVariant.primary,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Determine colors based on variant
    Color? appBarBackgroundColor;
    Color? appBarForegroundColor;
    double appBarElevation;
    SystemUiOverlayStyle overlayStyle;

    switch (variant) {
      case CustomAppBarVariant.primary:
        appBarBackgroundColor = backgroundColor ?? colorScheme.primary;
        appBarForegroundColor = foregroundColor ?? colorScheme.onPrimary;
        appBarElevation = elevation ?? 2.0;
        overlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        );
        break;
      case CustomAppBarVariant.secondary:
        appBarBackgroundColor = backgroundColor ?? colorScheme.surface;
        appBarForegroundColor = foregroundColor ?? colorScheme.onSurface;
        appBarElevation = elevation ?? 1.0;
        overlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        );
        break;
      case CustomAppBarVariant.transparent:
        appBarBackgroundColor = backgroundColor ?? Colors.transparent;
        appBarForegroundColor = foregroundColor ?? colorScheme.onSurface;
        appBarElevation = elevation ?? 0.0;
        overlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        );
        break;
      case CustomAppBarVariant.dashboard:
        appBarBackgroundColor = backgroundColor ?? colorScheme.surface;
        appBarForegroundColor = foregroundColor ?? colorScheme.onSurface;
        appBarElevation = elevation ?? 0.0;
        overlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        );
        break;
    }

    return AppBar(
      systemOverlayStyle: overlayStyle,
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: appBarForegroundColor,
        ),
      ),
      backgroundColor: appBarBackgroundColor,
      foregroundColor: appBarForegroundColor,
      elevation: appBarElevation,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading && !showBackButton,
      leading: _buildLeading(context, appBarForegroundColor),
      actions: _buildActions(context, appBarForegroundColor),
      bottom: bottom,
      shape: variant == CustomAppBarVariant.dashboard
          ? const Border(
              bottom: BorderSide(
                color: Color(0xFFE0E0E0),
                width: 0.5,
              ),
            )
          : null,
    );
  }

  Widget? _buildLeading(BuildContext context, Color? foregroundColor) {
    if (leading != null) return leading;

    if (showBackButton) {
      return IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: foregroundColor,
        ),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'Back',
      );
    }

    // For dashboard variant, show menu icon
    if (variant == CustomAppBarVariant.dashboard) {
      return IconButton(
        icon: Icon(
          Icons.menu,
          color: foregroundColor,
        ),
        onPressed: () {
          // Open drawer if available
          final scaffoldState = Scaffold.maybeOf(context);
          if (scaffoldState?.hasDrawer == true) {
            scaffoldState!.openDrawer();
          }
        },
        tooltip: 'Menu',
      );
    }

    return null;
  }

  List<Widget>? _buildActions(BuildContext context, Color? foregroundColor) {
    if (actions != null) return actions;

    // Default actions based on variant
    switch (variant) {
      case CustomAppBarVariant.dashboard:
        return [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: foregroundColor,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/real-time-alerts');
            },
            tooltip: 'Alerts',
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: foregroundColor,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            tooltip: 'Settings',
          ),
        ];
      case CustomAppBarVariant.primary:
      case CustomAppBarVariant.secondary:
      case CustomAppBarVariant.transparent:
        return [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: foregroundColor,
            ),
            onPressed: () {
              _showAppBarMenu(context);
            },
            tooltip: 'More options',
          ),
        ];
    }
  }

  void _showAppBarMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.security_outlined),
              title: const Text('Real-time Alerts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/real-time-alerts');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_outlined),
              title: const Text('Network Logs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/network-logs');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
