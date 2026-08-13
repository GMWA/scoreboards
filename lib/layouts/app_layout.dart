import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/constants/app_colors.dart';

/// Bottom navigation destinations: Scores (home) / Leagues / Teams / Blogs / Settings.
///
/// Match Center and Player Profile are intentionally NOT nav destinations —
/// they're detail screens reached by tapping through from a match card or a
/// player row, same as they were in the design's prototype interactions.
class _NavItem {
  final String path;
  final String label;
  final IconData icon;

  const _NavItem({required this.path, required this.label, required this.icon});
}

const List<_NavItem> _navItems = [
  _NavItem(path: '/home', label: 'Scores', icon: Icons.adjust_outlined),
  _NavItem(
      path: '/championships', label: 'Leagues', icon: Icons.emoji_events_outlined),
  _NavItem(path: '/teams', label: 'Teams', icon: Icons.groups_outlined),
  _NavItem(path: '/blogs', label: 'Blogs', icon: Icons.article_outlined),
  _NavItem(path: '/settings', label: 'Settings', icon: Icons.settings_outlined),
];

class AppLayout extends StatelessWidget {
  final Widget body;
  const AppLayout({super.key, required this.body});

  int _selectedIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/championships')) return 1;
    if (location.startsWith('/teams')) return 2;
    if (location.startsWith('/blogs')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final int selected = _selectedIndex(location);
    final double bottomSafeInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: false,
      // Android is edge-to-edge by default now, so this Scaffold's body
      // draws under the status bar unless something inserts the top inset.
      // Screens with their own AppBar/SliverAppBar already do this
      // themselves (and will just see a zero top inset here, so no double
      // padding); screens with plain content (e.g. the Competitions tab and
      // championship details) had nothing accounting for it, so their
      // header content was rendering behind the status bar. Bottom is left
      // alone — the nav bar below already reserves the bottom safe inset
      // via its own padding.
      body: SafeArea(bottom: false, child: body),
      bottomNavigationBar: Container(
        // Intentionally no fixed height — sized to its content (icon + label
        // + padding) so it can't overflow if font metrics differ slightly
        // across platforms. Bottom padding accounts for the device safe area.
        padding: EdgeInsets.fromLTRB(6, 8, 6, bottomSafeInset > 0 ? bottomSafeInset : 10),
        decoration: const BoxDecoration(
          color: Color(0xFF111316),
          border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            final item = _navItems[index];
            final bool active = index == selected;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (!active) context.go(item.path);
                },
                child: Center(
                  heightFactor: 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? AppColors.coral : Colors.transparent,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 21,
                          color: active ? Colors.white : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
