import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:scoreboards/models/match.dart';
import 'package:scoreboards/enums/matchs.dart';

class MatchCard extends StatelessWidget {
  final MatchBase match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    const Color surfaceColor = Color(0xFF1A1A1A);
    const Color brandRed = Color(0xFFE64C52);
    const Color borderSubtle = Color(0xFF2A2A2A);

    final bool isStarted = match.status != MatchStatus.planned;
    final bool isLive = match.status == MatchStatus.inProgress;
    final bool isFinished = match.status == MatchStatus.completed;
    final String matchTime = DateFormat('HH:mm').format(match.date);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSubtle, width: 1),
      ),
      child: InkWell(
        onTap: () {
          context.push('/matchs/details/${match.slug}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              // 1. Home Team
              Expanded(
                child: Column(
                  children: [
                    _buildLogo(match.homeTeam.logo, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      match.homeTeam.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Center Score / Time Area
              Container(
                width: 100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLive) _buildLiveBadge(brandRed),
                    if (isFinished)
                      const Text("FT",
                          style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white38,
                              letterSpacing: 1)),
                    const SizedBox(height: 4),

                    // Score Display
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            isLive ? brandRed.withOpacity(0.1) : Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isStarted
                            ? "${match.scoreFinalHome} - ${match.scoreFinalAway}"
                            : matchTime,
                        style: TextStyle(
                          fontFamily:
                              'Lexend', // Or a Monospace font for "Digital" look
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isLive ? brandRed : Colors.white,
                        ),
                      ),
                    ),

                    if (match.wentToPenalties)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "(${match.scorePsoHome}-${match.scorePsoAway} PEN)",
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white38),
                        ),
                      ),
                  ],
                ),
              ),

              // 3. Away Team
              Expanded(
                child: Column(
                  children: [
                    _buildLogo(match.awayTeam.logo, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      match.awayTeam.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(String? url, {double size = 40}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(6),
      child: Image.network(
        url ?? "",
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.shield, color: Colors.white24),
      ),
    );
  }

  Widget _buildLiveBadge(Color brandRed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: brandRed,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        "LIVE",
        style: TextStyle(
          fontFamily: 'Lexend',
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
