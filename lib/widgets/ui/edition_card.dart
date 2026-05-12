import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scoreboards/models/editions.dart';

class EditionCard extends StatelessWidget {
  final Edition edition;
  final VoidCallback? onTap;

  const EditionCard({
    super.key,
    required this.edition,
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
                backgroundImage: edition.championship.logo != null
                    ? CachedNetworkImageProvider(edition.championship.logo!)
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
                      edition.label?? "",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey[900],
                      ),
                    ),
                    Text(
                      edition.championship.country,
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
