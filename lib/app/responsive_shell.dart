import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/l10n/locale_notifier.dart';
import 'package:helpi_admin/core/l10n/theme_notifier.dart';
import 'package:helpi_admin/core/providers/data_providers.dart';
import 'package:helpi_admin/features/analytics/presentation/analytics_screen.dart';
import 'package:helpi_admin/features/chat/presentation/chat_screen.dart';
import 'package:helpi_admin/features/coupons/presentation/coupons_screen.dart';
import 'package:helpi_admin/features/seniors/presentation/seniors_screen.dart';
import 'package:helpi_admin/features/settings/presentation/settings_screen.dart';
import 'package:helpi_admin/features/students/presentation/students_screen.dart';

/// Responsivni shell — sidebar na desktopu, bottom nav na mobitelu.
///
/// Breakpoints:
/// - < 600px  → mobile (BottomNavigationBar)
/// - 600-900  → tablet (NavigationRail, collapsed)
/// - > 900px  → desktop (NavigationRail, extended / Sidebar)
class ResponsiveShell extends ConsumerStatefulWidget {
  const ResponsiveShell({
    super.key,
    required this.localeNotifier,
    required this.themeNotifier,
    required this.onLogout,
  });

  final LocaleNotifier localeNotifier;
  final ThemeNotifier themeNotifier;
  final VoidCallback onLogout;

  @override
  ConsumerState<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends ConsumerState<ResponsiveShell> {
  int _currentIndex = 0;

  List<Widget> get _screens {
    // Use locale-based key so screens rebuild on language change
    final locale = AppStrings.currentLocale;
    return <Widget>[
      SeniorsScreen(key: ValueKey('seniors_$locale')),
      StudentsScreen(key: ValueKey('students_$locale')),
      ChatModScreen(key: ValueKey('chat_$locale')),
      CouponsScreen(key: ValueKey('coupons_$locale')),
      AnalyticsScreen(key: ValueKey('analytics_$locale')),
      SettingsScreen(
        key: ValueKey('settings_$locale'),
        localeNotifier: widget.localeNotifier,
        themeNotifier: widget.themeNotifier,
      ),
    ];
  }

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  Widget _badgedIcon(Widget icon) {
    final count = ref.watch(unreadMessagesProvider);
    if (count == 0) return icon;
    return Badge.count(count: count, child: icon);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    // Desktop: ≥900px → extended NavigationRail (sidebar)
    if (width >= 900) {
      return _buildDesktopLayout();
    }
    // Tablet: 600–899px → collapsed NavigationRail
    if (width >= 600) {
      return _buildTabletLayout();
    }
    // Mobile: <600px → BottomNavigationBar
    return _buildMobileLayout();
  }

  // ═══════════════════════════════════════════════════════════════
  //  DESKTOP — Extended sidebar
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ──
          Container(
            width: HelpiTheme.sidebarWidth,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color:
                      Theme.of(context).dividerTheme.color ??
                      HelpiColors.of(context).border,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // ── Logo (height matches appBarHeight so divider
                //    aligns with AppBar bottom border) ──
                SizedBox(
                  height: HelpiTheme.appBarHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: const Alignment(-1.0, 0.25),
                      child: SvgPicture.asset(
                        'assets/images/logo.svg',
                        height: 28,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1),

                // ── Nav items ──
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      _sidebarItem(
                        0,
                        Icons.elderly_outlined,
                        Icons.elderly,
                        AppStrings.navSeniors,
                      ),
                      _sidebarItem(
                        1,
                        Icons.school_outlined,
                        Icons.school,
                        AppStrings.navStudents,
                      ),
                      _sidebarItem(
                        2,
                        Icons.chat_bubble_outline,
                        Icons.chat_bubble,
                        AppStrings.navChat,
                        badgeCount: ref.watch(unreadMessagesProvider),
                      ),
                      _sidebarItem(
                        3,
                        Icons.confirmation_number_outlined,
                        Icons.confirmation_number,
                        AppStrings.navCoupons,
                      ),
                      _sidebarItem(
                        4,
                        Icons.analytics_outlined,
                        Icons.analytics,
                        AppStrings.navDashboard,
                      ),
                      _sidebarItem(
                        5,
                        Icons.settings_outlined,
                        Icons.settings,
                        AppStrings.navSettings,
                      ),
                    ],
                  ),
                ),

                // ── Bottom actions ──
                const Divider(height: 8),
                _sidebarItem(
                  -2,
                  Icons.logout,
                  Icons.logout,
                  AppStrings.logout,
                  onTap: widget.onLogout,
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),

          // ── Content ──
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label, {
    VoidCallback? onTap,
    int badgeCount = 0,
  }) {
    final isSelected = index == _currentIndex && onTap == null;
    Widget iconWidget = Icon(
      isSelected ? activeIcon : icon,
      color: isSelected
          ? HelpiTheme.accent
          : HelpiColors.of(context).textSecondary,
      size: 24,
    );
    if (badgeCount > 0) {
      iconWidget = Badge.count(count: badgeCount, child: iconWidget);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected
            ? HelpiColors.of(context).pastelTeal
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap ?? () => _onItemTapped(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                iconWidget,
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? HelpiTheme.accent
                        : HelpiColors.of(context).textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TABLET — Collapsed NavigationRail
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 6),
              child: SvgPicture.asset('assets/images/h_logo.svg', height: 26),
            ),
            trailing: Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: widget.onLogout,
                    icon: const Icon(Icons.logout),
                    color: HelpiColors.of(context).textSecondary,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.elderly_outlined),
                selectedIcon: const Icon(Icons.elderly),
                label: Text(AppStrings.navSeniors),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.school_outlined),
                selectedIcon: const Icon(Icons.school),
                label: Text(AppStrings.navStudents),
              ),
              NavigationRailDestination(
                icon: _badgedIcon(const Icon(Icons.chat_bubble_outline)),
                selectedIcon: _badgedIcon(const Icon(Icons.chat_bubble)),
                label: Text(AppStrings.navChat),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.confirmation_number_outlined),
                selectedIcon: const Icon(Icons.confirmation_number),
                label: Text(AppStrings.navCoupons),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.analytics_outlined),
                selectedIcon: const Icon(Icons.analytics),
                label: Text(AppStrings.navDashboard),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: Text(AppStrings.navSettings),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  MOBILE — BottomNavigationBar
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMobileLayout() {
    // Mobile shows 3 primary tabs + "More" overflow.
    // _currentIndex 0-2 map directly; 3+ are behind the More sheet.
    final bottomIndex = _currentIndex <= 2 ? _currentIndex : 3;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: HelpiColors.of(context).surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: bottomIndex,
          onTap: (i) {
            if (i < 3) {
              _onItemTapped(i);
            } else {
              _showMoreSheet();
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.elderly_outlined, size: 26),
              activeIcon: const Icon(Icons.elderly, size: 26),
              label: AppStrings.navSeniors,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.school_outlined, size: 26),
              activeIcon: const Icon(Icons.school, size: 26),
              label: AppStrings.navStudents,
            ),
            BottomNavigationBarItem(
              icon: _badgedIcon(
                const Icon(Icons.chat_bubble_outline, size: 26),
              ),
              activeIcon: _badgedIcon(const Icon(Icons.chat_bubble, size: 26)),
              label: AppStrings.navChat,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.more_horiz,
                size: 26,
                color: _currentIndex >= 3
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              activeIcon: const Icon(Icons.more_horiz, size: 26),
              label: AppStrings.navMore,
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  _currentIndex == 3
                      ? Icons.confirmation_number
                      : Icons.confirmation_number_outlined,
                ),
                title: Text(AppStrings.navCoupons),
                selected: _currentIndex == 3,
                onTap: () {
                  Navigator.pop(ctx);
                  _onItemTapped(3);
                },
              ),
              ListTile(
                leading: Icon(
                  _currentIndex == 4
                      ? Icons.analytics
                      : Icons.analytics_outlined,
                ),
                title: Text(AppStrings.navDashboard),
                selected: _currentIndex == 4,
                onTap: () {
                  Navigator.pop(ctx);
                  _onItemTapped(4);
                },
              ),
              ListTile(
                leading: Icon(
                  _currentIndex == 5 ? Icons.settings : Icons.settings_outlined,
                ),
                title: Text(AppStrings.navSettings),
                selected: _currentIndex == 5,
                onTap: () {
                  Navigator.pop(ctx);
                  _onItemTapped(5);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
