import 'package:flutter/material.dart';
import 'package:scoreboards/models/match_team.dart';

class TeamLogoName extends StatelessWidget {
  final MatchTeam team;
  final double?
      width;
  final bool isHome;

  const TeamLogoName({
    super.key,
    required this.team,
    this.width,
    required this.isHome,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04), // Subtle glass effect
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: team.logo != null && team.logo!.isNotEmpty
                ? Image.network(
                    team.logo!,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white10,
                      );
                    },
                    errorBuilder: (_, __, ___) => _buildFallbackIcon(),
                  )
                : _buildFallbackIcon(),
          ),

          const SizedBox(height: 14),

          Text(
            team.name.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Lexend',
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Icon(
      Icons.shield_outlined,
      color: Colors.white.withOpacity(0.2),
      size: 32,
    );
  }
}
