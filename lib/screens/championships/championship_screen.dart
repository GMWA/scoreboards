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
  int _selectedEdition = 2026; // Match current year context

  final List<int> _editions = [2024, 2025, 2026];

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Competitions',
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _buildModernDropdown(),
            ],
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

              return RefreshIndicator(
                backgroundColor: AppColors.surface,
                color: AppColors.coral,
                onRefresh: _refreshChampionships,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                  itemCount: editions.length,
                  itemBuilder: (context, index) {
                    final championship = editions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: EditionCard(
                        edition: championship,
                        onTap: () {
                          context.push('/championships/${championship.slug}');
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedEdition,
          dropdownColor: AppColors.surface,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.coral, size: 18),
          style: GoogleFonts.hankenGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          items: _editions
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.toString()),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedEdition = value);
              _loadChampionships();
            }
          },
        ),
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
