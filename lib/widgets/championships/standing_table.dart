import 'package:flutter/material.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/standing.dart';
import 'package:scoreboards/services/championship.dart';

class StandingsTable extends StatelessWidget {
  final int editionId;

  const StandingsTable({super.key, required this.editionId});

  @override
  Widget build(BuildContext context) {
    const Color brandRed = AppColors.brand;
    const Color surface = AppColors.surface;
    const Color textSecondary = Colors.white60; // Clearly visible grey
    const Color textPrimary = Colors.white; // High contrast white

    return FutureBuilder<List<Standing>>(
      future: ChampionshipService.getStandingsByChampionship(editionId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: brandRed));
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Center(
              child: Text("Error loading standings.",
                  style:
                      TextStyle(color: textSecondary, fontFamily: 'Lexend')));
        }

        final standings = snapshot.data!;

        return Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.white.withOpacity(0.05),
            // This ensures the checkbox/control area doesn't force white backgrounds
            unselectedWidgetColor: textSecondary,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(surface),
              columnSpacing: 20.0,
              horizontalMargin: 16,
              headingRowHeight: 45,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 54,
              columns: [
                _buildHeader("#", color: textSecondary),
                _buildHeader("TEAM", color: textSecondary),
                _buildHeader("P", color: textSecondary),
                _buildHeader("W", color: textSecondary),
                _buildHeader("D", color: textSecondary),
                _buildHeader("L", color: textSecondary),
                _buildHeader("GD", color: textSecondary),
                _buildHeader("PTS", color: brandRed), // Highlighted Points
              ],
              rows: List<DataRow>.generate(standings.length, (index) {
                final item = standings[index];
                final bool isTop = index < 3;

                return DataRow(
                  cells: [
                    // Position
                    DataCell(Text(
                      (index + 1).toString(),
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        color: isTop ? brandRed : textSecondary,
                        fontWeight: isTop ? FontWeight.w900 : FontWeight.w500,
                        fontSize: 12,
                      ),
                    )),
                    // Team Info
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSmallLogo(item.participation.team.logo),
                        const SizedBox(width: 10),
                        Text(
                          item.participation.team.name.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Lexend',
                            color: textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    )),
                    _buildDataCell(item.played.toString(),
                        color: textSecondary),
                    _buildDataCell(item.wins.toString(), color: textSecondary),
                    _buildDataCell(item.drawn.toString(), color: textSecondary),
                    _buildDataCell(item.losses.toString(),
                        color: textSecondary),
                    _buildDataCell(
                      item.goalsDifference > 0
                          ? "+${item.goalsDifference}"
                          : item.goalsDifference.toString(),
                      color: textSecondary,
                    ),
                    // Points Cell
                    DataCell(Text(
                      item.points.toString(),
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        color: textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    )),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }

  DataColumn _buildHeader(String label, {required Color color}) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Lexend',
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  DataCell _buildDataCell(String value, {required Color color}) {
    return DataCell(Text(
      value,
      style: TextStyle(
        fontFamily: 'Lexend',
        color: color, // Fixed: No longer black12
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ));
  }

  Widget _buildSmallLogo(String? url) {
    return Container(
      width: 24,
      height: 24,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: url != null && url.isNotEmpty
          ? Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.shield, size: 14, color: Colors.white24),
            )
          : const Icon(Icons.shield, size: 14, color: Colors.white24),
    );
  }
}
