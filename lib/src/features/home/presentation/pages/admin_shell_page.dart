import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/widgets/double_back_to_exit_wrapper.dart';
import '../../../notification/application/providers/notification_providers.dart';

/// Persistent bottom navigation shell for the Kapada Creation Admin app.
/// Wraps all 5 main tabs: Home, Products, Add (FAB), Insights, Profile.
class AdminShellPage extends ConsumerStatefulWidget {
  const AdminShellPage({super.key, required this.child});

  final Widget child;

  // Returns the active tab index from the current router location.
  static int _tabIndex(String location) {
    if (location.startsWith('/admin/products')) return 1;
    if (location.startsWith('/admin/insights')) return 2;
    if (location.startsWith('/admin/profile')) return 3;
    return 0; // home is default
  }

  static const _tabPaths = [
    AppRoutes.adminHome,
    AppRoutes.adminProducts,
    AppRoutes.adminInsights,
    AppRoutes.adminProfile,
  ];

  @override
  ConsumerState<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends ConsumerState<AdminShellPage> {
  String? _initializedAdminFcmId;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(firebaseAuthProvider).currentUser;
    final adminId = (user != null && user.uid.isNotEmpty)
        ? user.uid
        : 'admin_local_actor';
    if (_initializedAdminFcmId != adminId) {
      _initializedAdminFcmId = adminId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(adminFirebaseMessagingServiceProvider)
            .initialize(adminId: adminId, firebaseUid: user?.uid);
      });
    }

    final location = GoRouterState.of(context).uri.toString();
    final activeIndex = AdminShellPage._tabIndex(location);

    return DoubleBackToExitWrapper(
      currentTabIndex: activeIndex,
      child: Scaffold(
        backgroundColor: AppColors.warmIvory,
        body: widget.child,
        bottomNavigationBar: _AdminBottomNavBar(
          activeIndex: activeIndex,
          onTap: (index) {
            if (index == activeIndex) return;
            context.go(AdminShellPage._tabPaths[index]);
          },
          onAddTap: () => context.push(AppRoutes.adminDesignAdd),
        ),
      ),
    );
  }
}

class _AdminBottomNavBar extends StatelessWidget {
  const _AdminBottomNavBar({
    required this.activeIndex,
    required this.onTap,
    required this.onAddTap,
  });

  final int activeIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(top: BorderSide(color: AppColors.borderSoft, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              _NavItem(
                icon: PhosphorIcons.house(),
                activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
                label: 'Home',
                isActive: activeIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: PhosphorIcons.tShirt(),
                activeIcon: PhosphorIcons.tShirt(PhosphorIconsStyle.fill),
                label: 'Products',
                isActive: activeIndex == 1,
                onTap: () => onTap(1),
              ),
              // Centre FAB
              Expanded(
                child: GestureDetector(
                  onTap: onAddTap,
                  child: Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.brandGreen900,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandGreen900.withValues(
                              alpha: 0.35,
                            ),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: PhosphorIcon(
                        PhosphorIcons.plus(),
                        color: AppColors.surfaceWhite,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              _NavItem(
                icon: PhosphorIcons.chartBar(),
                activeIcon: PhosphorIcons.chartBar(PhosphorIconsStyle.fill),
                label: 'Insights',
                isActive: activeIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: PhosphorIcons.user(),
                activeIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
                label: 'Profile',
                isActive: activeIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.brandGreen900 : AppColors.mutedText;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhosphorIcon(isActive ? activeIcon : icon, size: 22, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
