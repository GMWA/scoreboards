import 'package:flutter/material.dart';
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
    const Color brandRed = Color(0xFFE64C52);
    const Color surface = Color(0xFF1A1A1A);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "ALL LEAGUES",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white38,
                  letterSpacing: 1.5,
                ),
              ),
              _buildModernDropdown(surface, brandRed),
            ],
          ),
        ),

        Expanded(
          child: FutureBuilder<List<Edition>>(
            future: _editionsFuture,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: brandRed));
              }

              if (snapshot.hasError) {
                return _buildErrorState(brandRed);
              }

              final editions = snapshot.data ?? [];

              if (editions.isEmpty) {
                return const Center(
                  child: Text(
                    "No championships found.",
                    style:
                        TextStyle(color: Colors.white24, fontFamily: 'Lexend'),
                  ),
                );
              }

              return RefreshIndicator(
                backgroundColor: surface,
                color: brandRed,
                onRefresh: _refreshChampionships,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
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

  Widget _buildModernDropdown(Color surface, Color brandRed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedEdition,
          dropdownColor: surface,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.brand, size: 18),
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
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

  Widget _buildErrorState(Color brandRed) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white24, size: 48),
          const SizedBox(height: 16),
          const Text(
            "Connection Error",
            style: TextStyle(
                color: Colors.white70,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: _refreshChampionships,
            child: Text("RETRY",
                style: TextStyle(color: brandRed, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
