import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/editions.dart';
import 'package:scoreboards/services/championship.dart';
import 'package:scoreboards/widgets/ui/edition_card.dart';
import 'package:go_router/go_router.dart';

class ChampionshipListScreen extends StatefulWidget {
  const ChampionshipListScreen({super.key});

  @override
  ChampionshipListScreenState createState() => ChampionshipListScreenState();
}

class ChampionshipListScreenState extends State<ChampionshipListScreen> {
  late Future<List<Edition>> _editionsFuture;

  @override
  void initState() {
    super.initState();
    _loadChampionships();
  }

  void _loadChampionships() {
    setState(() {
      _editionsFuture = ChampionshipService.getActiveEditions();
    });
  }

  Future<void> _refreshChampionships() async {
    _loadChampionships();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
          child: Text(
            'Competitions',
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Edition>>(
            future: _editionsFuture,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.coral));
              }

              if (snapshot.hasError) {
                return _buildErrorState();
              }

              final editions = snapshot.data ?? [];

              if (editions.isEmpty) {
                return Center(
                  child: Text(
                    'No championships found.',
                    style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary),
                  ),
                );
              }

              final active = editions.where((e) => e.isCurrent).toList();
              final archived = editions.where((e) => !e.isCurrent).toList()
                ..sort((a, b) {
                  final aDate = a.startDate;
                  final bDate = b.startDate;
                  if (aDate == null || bDate == null) return 0;
                  return bDate.compareTo(aDate);
                });

              return RefreshIndicator(
                backgroundColor: AppColors.surface,
                color: AppColors.coral,
                onRefresh: _refreshChampionships,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                  children: [
                    if (active.isNotEmpty) ...[
                      _buildSectionHeader('Live Competitions'),
                      const SizedBox(height: 10),
                      ...active.map((e) => _buildEditionCard(e)),
                      const SizedBox(height: 8),
                    ],
                    if (archived.isNotEmpty) ...[
                      _buildSectionHeader('Archive'),
                      const SizedBox(height: 10),
                      ...archived.map((e) => _buildEditionCard(e)),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 2),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.hankenGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildEditionCard(Edition edition) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: EditionCard(
        edition: edition,
        onTap: () {
          context.push('/championships/${edition.slug}');
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.border, size: 48),
          const SizedBox(height: 16),
          Text(
            'Connection Error',
            style: GoogleFonts.hankenGrotesk(   
                color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          ),
          TextButton(
            onPressed: _refreshChampionships,
            child: Text('RETRY',
                style: GoogleFonts.hankenGrotesk(
                    color: AppColors.coral, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
