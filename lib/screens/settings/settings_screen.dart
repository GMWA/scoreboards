import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/services/favorites_service.dart';

/// Temporarily off until there's an actual account system to back it —
/// the profile card, account settings, and sign out are kept in place
/// (not deleted) so they're ready to flip back on once sign-in ships.
const bool kEnableAccountSettings = false;

/// Settings screen, matching the "Scoreboards mobile" v2 design: profile
/// card, account settings list, preference toggles, sign out.
///
/// "Favorite Teams" / "Favorite Competitions" open the real management
/// screens backed by FavoritesService. The notification toggles below are
/// built and persisted now (per-category prefs, disabled until the master
/// toggle is on) even though push delivery isn't wired up yet — the UI is
/// ready for when it ships, and the note under the section says so plainly
/// rather than implying it already works. Same idea for dark mode: the
/// toggle is saved but the app is dark-only today, so it doesn't re-skin
/// anything yet.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _kMaster = 'notif_master';
  static const _kKickoff = 'notif_kickoff';
  static const _kGoals = 'notif_goals';
  static const _kFullTime = 'notif_fulltime';
  static const _kLineups = 'notif_lineups';
  static const _kDarkMode = 'dark_mode';

  bool _notifMaster = false;
  bool _notifKickoff = true;
  bool _notifGoals = true;
  bool _notifFullTime = true;
  bool _notifLineups = false;
  bool _darkMode = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPrefs();
  }

  Future<void> _loadNotificationPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notifMaster = prefs.getBool(_kMaster) ?? false;
      _notifKickoff = prefs.getBool(_kKickoff) ?? true;
      _notifGoals = prefs.getBool(_kGoals) ?? true;
      _notifFullTime = prefs.getBool(_kFullTime) ?? true;
      _notifLineups = prefs.getBool(_kLineups) ?? false;
      _darkMode = prefs.getBool(_kDarkMode) ?? true;
    });
  }

  Future<void> _setPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      // bottom: false — AppLayout's bottom nav bar already reserves the
      // device's bottom safe inset.
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kEnableAccountSettings) ...[
                _buildProfileCard(),
                const SizedBox(height: 22),
                _sectionLabel('ACCOUNT SETTINGS'),
                const SizedBox(height: 10),
                _buildGroup([
                  _SettingsRow(
                    icon: Icons.person_outline,
                    iconColor: AppColors.coral,
                    title: 'Personal Information',
                    subtitle: 'Update name, email, phone',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.shield_outlined,
                    iconColor: AppColors.coral,
                    title: 'Security & Password',
                    subtitle: '2FA, active sessions',
                    onTap: () {},
                    showDivider: false,
                  ),
                ]),
                const SizedBox(height: 22),
              ],
              _sectionLabel('PREFERENCES'),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: FavoritesService.instance,
                builder: (context, _) {
                  final teamCount = FavoritesService.instance.followedTeams.length;
                  final compCount = FavoritesService.instance.followedCompetitions.length;
                  return _buildGroup([
                    _SettingsRow(
                      icon: Icons.star_border,
                      iconColor: AppColors.textPrimary,
                      title: 'Favorite Teams',
                      subtitle: teamCount == 0
                          ? 'Manage your followed squads'
                          : '$teamCount followed',
                      onTap: () => context.push('/settings/favorites/teams'),
                    ),
                    _SettingsRow(
                      icon: Icons.emoji_events_outlined,
                      iconColor: AppColors.textPrimary,
                      title: 'Favorite Competitions',
                      subtitle: compCount == 0
                          ? 'Manage your followed leagues'
                          : '$compCount followed',
                      onTap: () => context.push('/settings/favorites/competitions'),
                    ),
                    _SettingsRow(
                      icon: _darkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                      iconColor: AppColors.textPrimary,
                      title: 'Dark Mode',
                      subtitle: _darkMode ? 'On' : 'Off',
                      trailing: _ToggleSwitch(
                        value: _darkMode,
                        onChanged: (v) {
                          setState(() => _darkMode = v);
                          _setPref(_kDarkMode, v);
                        },
                      ),
                    ),
                    _SettingsRow(
                      icon: Icons.public,
                      iconColor: AppColors.textPrimary,
                      title: 'Language',
                      subtitle: 'English (US)',
                      onTap: () {},
                    ),
                    _SettingsRow(
                      icon: Icons.info_outline,
                      iconColor: AppColors.textPrimary,
                      title: 'About',
                      subtitle: 'Version 1.0.0',
                      onTap: () {},
                      showDivider: false,
                    ),
                  ]);
                },
              ),
              const SizedBox(height: 22),
              _sectionLabel('NOTIFICATIONS'),
              const SizedBox(height: 10),
              _buildGroup([
                _SettingsRow(
                  icon: Icons.notifications_none,
                  iconColor: AppColors.mint,
                  title: 'Match Notifications',
                  subtitle: 'Alerts for teams and competitions you follow',
                  trailing: _ToggleSwitch(
                    value: _notifMaster,
                    onChanged: (v) {
                      setState(() => _notifMaster = v);
                      _setPref(_kMaster, v);
                    },
                  ),
                ),
                _notificationSubRow(
                  icon: Icons.sports_outlined,
                  title: 'Kickoff reminders',
                  value: _notifKickoff,
                  onChanged: (v) {
                    setState(() => _notifKickoff = v);
                    _setPref(_kKickoff, v);
                  },
                ),
                _notificationSubRow(
                  icon: Icons.sports_soccer,
                  title: 'Goals',
                  value: _notifGoals,
                  onChanged: (v) {
                    setState(() => _notifGoals = v);
                    _setPref(_kGoals, v);
                  },
                ),
                _notificationSubRow(
                  icon: Icons.flag_outlined,
                  title: 'Full-time results',
                  value: _notifFullTime,
                  onChanged: (v) {
                    setState(() => _notifFullTime = v);
                    _setPref(_kFullTime, v);
                  },
                ),
                _notificationSubRow(
                  icon: Icons.groups_outlined,
                  title: 'Lineup announcements',
                  value: _notifLineups,
                  onChanged: (v) {
                    setState(() => _notifLineups = v);
                    _setPref(_kLineups, v);
                  },
                  showDivider: false,
                ),
              ]),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Notifications are prepared here now and will start working once push delivery ships.',
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              if (kEnableAccountSettings) ...[
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Sign Out',
                      style: GoogleFonts.hankenGrotesk(
                        color: AppColors.coral,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.coral, width: 2),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2A3138), Color(0xFF161A1E)],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'AW',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 26,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Alex',
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'manager@scoreboards.cm',
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              'Edit Profile',
              style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  _SettingsRow _notificationSubRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showDivider = true,
  }) {
    return _SettingsRow(
      icon: icon,
      iconColor: _notifMaster ? AppColors.textPrimary : AppColors.textSecondary,
      title: title,
      subtitle: _notifMaster ? 'On' : 'Enable Match Notifications above',
      showDivider: showDivider,
      trailing: _ToggleSwitch(
        value: value,
        onChanged: _notifMaster ? onChanged : (_) {},
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: GoogleFonts.hankenGrotesk(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildGroup(List<_SettingsRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: rows),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showDivider;

  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: AppColors.divider))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.hankenGrotesk(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.hankenGrotesk(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 27,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: value ? AppColors.toggleOn : AppColors.toggleOff,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
