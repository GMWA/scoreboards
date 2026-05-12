import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Logo extends StatelessWidget {
  final String? url;

  const Logo({this.url, super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundImage: url != null ? CachedNetworkImageProvider(url!) : null,
      child: url == null ? Icon(Icons.sports_soccer) : null,
    );
  }
}
