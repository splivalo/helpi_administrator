import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/l10n/locale_notifier.dart';
import 'package:helpi_admin/features/chat/presentation/chat_screen.dart';
import 'package:helpi_admin/features/dashboard/presentation/dashboard_screen.dart';
import 'package:helpi_admin/features/orders/presentation/orders_screen.dart';
import 'package:helpi_admin/features/seniors/presentation/seniors_screen.dart';
import 'package:helpi_admin/features/students/presentation/students_screen.dart';

/// Responsivni shell — sidebar na desktopu, bottom nav na mobitelu.
///
/// Breakpoints:
/// - < 600px  → mobile (BottomNavigationBar)
/// - 600-900  → tablet (NavigationRail, collapsed)
/// - > 900px  → desktop (NavigationRail, extended / Sidebar)
class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({
    super.key,
    required this.localeNotifier,
    required this.onLogout,
  });

  final LocaleNotifier localeNotifier;
  final VoidCallback onLogout;

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  int _currentIndex = 0;

  List<Widget> get _screens {
    // Use locale-based key so screens rebuild on language change
    final locale = AppStrings.currentLocale;
    return <Widget>[
      DashboardScreen(key: ValueKey('dashboard_$locale')),
      AdminOrdersScreen(key: ValueKey('orders_$locale')),
      StudentsScreen(key: ValueKey('students_$locale')),
      SeniorsScreen(key: ValueKey('seniors_$locale')),
      ChatModScreen(key: ValueKey('chat_$locale')),
    ];
  }

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
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
              color: HelpiTheme.surface,
              border: Border(
                right: BorderSide(color: HelpiTheme.border, width: 1),
              ),
            ),
            child: Column(
              children: [
                // ── Logo ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SvgPicture.asset(
                      'assets/images/logo.svg',
                      height: 36,
                    ),
                  ),
                ),
                const Divider(height: 1),

                // ── Nav items ──
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _sidebarItem(
                        0,
                        Icons.dashboard_outlined,
                        Icons.dashboard,
                        AppStrings.navDashboard,
                      ),
                      _sidebarItem(
                        1,
                        Icons.receipt_outlined,
                        Icons.receipt,
                        AppStrings.navOrders,
                      ),
                      _sidebarItem(
                        2,
                        Icons.school_outlined,
                        Icons.school,
                        AppStrings.navStudents,
                      ),
                      _sidebarItem(
                        3,
                        Icons.elderly_outlined,
                        Icons.elderly,
                        AppStrings.navSeniors,
                      ),
                      _sidebarItem(
                        4,
                        Icons.chat_bubble_outline,
                        Icons.chat_bubble,
                        AppStrings.navChat,
                      ),
                    ],
                  ),
                ),

                // ── Bottom actions ──
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.language,
                            color: HelpiTheme.textSecondary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: AppStrings.currentLocale,
                                isExpanded: true,
                                isDense: true,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: HelpiTheme.textPrimary,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'hr',
                                    child: Text('Hrvatski'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'en',
                                    child: Text('English'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    widget.localeNotifier.setLocale(val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _sidebarItem(
                  -2,
                  Icons.logout,
                  Icons.logout,
                  AppStrings.logout,
                  onTap: widget.onLogout,
                ),
                const SizedBox(height: 8),
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
  }) {
    final isSelected = index == _currentIndex && onTap == null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected ? HelpiTheme.pastelTeal : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap ?? () => _onItemTapped(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected
                      ? HelpiTheme.accent
                      : HelpiTheme.textSecondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? HelpiTheme.accent
                        : HelpiTheme.textPrimary,
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
              padding: const EdgeInsets.only(bottom: 16, top: 8),
              child: SvgPicture.asset('assets/images/h_logo.svg', height: 32),
            ),
            trailing: Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: _showSettingsSheet,
                    icon: Text(
                      AppStrings.currentLocale.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: HelpiTheme.textSecondary,
                      ),
                    ),
                    tooltip: AppStrings.navSettings,
                  ),
                  IconButton(
                    onPressed: widget.onLogout,
                    icon: const Icon(Icons.logout),
                    color: HelpiTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: Text(AppStrings.navDashboard),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.receipt_outlined),
                selectedIcon: const Icon(Icons.receipt),
                label: Text(AppStrings.navOrders),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.school_outlined),
                selectedIcon: const Icon(Icons.school),
                label: Text(AppStrings.navStudents),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.elderly_outlined),
                selectedIcon: const Icon(Icons.elderly),
                label: Text(AppStrings.navSeniors),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.chat_bubble_outline),
                selectedIcon: const Icon(Icons.chat_bubble),
                label: Text(AppStrings.navChat),
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
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: HelpiTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined, size: 26),
              activeIcon: const Icon(Icons.dashboard, size: 26),
              label: AppStrings.navDashboard,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_outlined, size: 26),
              activeIcon: const Icon(Icons.receipt, size: 26),
              label: AppStrings.navOrders,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.school_outlined, size: 26),
              activeIcon: const Icon(Icons.school, size: 26),
              label: AppStrings.navStudents,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.elderly_outlined, size: 26),
              activeIcon: const Icon(Icons.elderly, size: 26),
              label: AppStrings.navSeniors,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat_bubble_outline, size: 26),
              activeIcon: const Icon(Icons.chat_bubble, size: 26),
              label: AppStrings.navChat,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  LANGUAGE TOGGLE
  // ═══════════════════════════════════════════════════════════════
  void _showSettingsSheet() {
    final currentLang = AppStrings.currentLocale;
    final newLang = currentLang == 'hr' ? 'en' : 'hr';
    widget.localeNotifier.setLocale(newLang);
  }
}
