import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/standing.dart';
import 'package:scoreboards/services/championship.dart';

class StandingsTable extends StatelessWidget {
  final int editionId;

  const StandingsTable({super.key, required this.editionId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Standing>>(
      future: ChampionshipService.getStandingsByChampionship(editionId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.coral));
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Text('Error loading standings.',
                style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary)),
          );
        }

        final standings = snapshot.data!;

        return Theme(
          data: Theme.of(context).copyWith(
            dividerColor: AppColors.divider,
            unselectedWidgetColor: AppColors.textSecondary,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.surface),
                columnSpacing: 20.0,
                horizontalMargin: 16,
                headingRowHeight: 45,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 54,
                columns: [
                  _buildHeader('#', color: AppColors.textSecondary),
                  _buildHeader('TEAM', color: AppColors.textSecondary),
                  _buildHeader('PTS', color: AppColors.coral),
                  _buildHeader('P', color: AppColors.textSecondary),
                  _buildHeader('W', color: AppColors.textSecondary),
                  _buildHeader('D', color: AppColors.textSecondary),
                  _buildHeader('L', color: AppColors.textSecondary),
                  _buildHeader('GD', color: AppColors.textSecondary),
                ],
                rows: List<DataRow>.generate(standings.length, (index) {
                  final item = standings[index];
                  final bool isTop = index < 3;

                  return DataRow(
                    cells: [
                      DataCell(Text(
                        (index + 1).toString(),
                        style: GoogleFonts.hankenGrotesk(
                          color: isTop ? AppColors.mint : AppColors.textSecondary,
                          fontWeight: isTop ? FontWeight.w800 : FontWeight.w500,
                          fontSize: 12,
                        ),
                      )),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSmallLogo(item.participation.team.logo),
                          const SizedBox(width: 10),
                          Text(
                            item.participation.team.name,
                            style: GoogleFonts.hankenGrotesk(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )),
                      DataCell(Text(
                        item.points.toString(),
                        style: GoogleFonts.archivo(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      )),
                      _buildDataCell(item.played.toString()),
                      _buildDataCell(item.wins.toString()),
                      _buildDataCell(item.drawn.toString()),
                      _buildDataCell(item.losses.toString()),
                      _buildDataCell(
                        item.goalsDifference > 0
                            ? '+${item.goalsDifference}'
                            : item.goalsDifference.toString(),
                      ),
                    ],
                  );
                }),
              ),
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
        style: GoogleFonts.hankenGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  DataCell _buildDataCell(String value) {
    return DataCell(Text(
      value,
      style: GoogleFonts.hankenGrotesk(
        color: AppColors.textSecondary,
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
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(4),
      ),
      child: url != null && url.isNotEmpty
          ? Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.shield, size: 14, color: AppColors.textSecondary),
            )
          : const Icon(Icons.shield, size: 14, color: AppColors.textSecondary),
    );
  }
}
