import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scoreboards/models/championship.dart';

class LeagueCard extends StatelessWidget {
  final Championship championship;
  final VoidCallback? onTap;

  const LeagueCard({
    super.key,
    required this.championship,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap, // <-- this now receives the function
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blueGrey[100],
                backgroundImage: championship.logo != null
                    ? CachedNetworkImageProvider(championship.logo!)
                    : null,
                onBackgroundImageError: (exception, stackTrace) {
                  debugPrint('Error loading image: $exception');
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      championship.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey[900],
                      ),
                    ),
                    Text(
                      championship.country,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.blueGrey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
