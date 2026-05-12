// import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoreboards/constants/app_colors.dart';

class AppLayout extends StatelessWidget {
  final Widget body;
  const AppLayout({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    // Better way to handle location in GoRouter 13+
    final String location = GoRouterState.of(context).uri.toString();

    int getSelectedIndex() {
      if (location.startsWith('/home')) return 0;
      if (location.startsWith('/championships')) return 1;
      if (location.startsWith('/teams')) return 2;
      if (location.startsWith('/settings')) return 3;
      return 0;
    }

    const Color brandRed = AppColors.brand;
    const Color darkBg = AppColors.darkBg;
    // const Color surface = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: darkBg,
      body: body,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF222222), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: darkBg,
          type: BottomNavigationBarType.fixed,
          currentIndex: getSelectedIndex(),
          selectedItemColor: brandRed,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontFamily: 'Lexend',
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontFamily: 'Lexend',
          ),
          onTap: (index) {
            final paths = ['/home', '/championships', '/teams', '/settings'];
            context.go(paths[index]);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.sports_soccer_outlined, size: 22),
              ),
              activeIcon: Icon(Icons.sports_soccer, size: 22),
              label: 'GAMES',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: FaIcon(FontAwesomeIcons.trophy, size: 18),
              ),
              label: 'LEAGUES',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.group_outlined, size: 22),
              ),
              activeIcon: Icon(Icons.group, size: 22),
              label: 'TEAMS',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.settings_outlined, size: 22),
              ),
              activeIcon: Icon(Icons.settings, size: 22),
              label: 'SETTINGS',
            ),
          ],
        ),
      ),
    );
  }
}
