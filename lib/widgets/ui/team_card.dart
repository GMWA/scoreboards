import 'package:flutter/material.dart';
import 'package:scoreboards/models/team.dart';
import 'package:go_router/go_router.dart';

class TeamCard extends StatelessWidget {
  final Team team;

  const TeamCard({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    const Color surfaceColor = Color(0xFF1A1A1A);
    const Color brandRed = Color(0xFFE64C52);
    const Color borderSubtle = Color(0xFF2A2A2A);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSubtle, width: 1),
      ),
      child: InkWell(
        onTap: () {
          context.push('/teams/${team.slug}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: team.logo != null && team.logo!.isNotEmpty
                    ? Image.network(
                        team.logo!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _buildFallback(),
                      )
                    : _buildFallback(),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (team.stadium != null)
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: brandRed, size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              team.stadium!.name,
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.4),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.1),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Icon(
      Icons.shield_outlined,
      size: 32,
      color: Colors.white.withOpacity(0.1),
    );
  }
}
