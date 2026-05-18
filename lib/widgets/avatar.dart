import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final double radius;
  final String url;
  const Avatar({super.key, required this.radius, required this.url});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
      child: url.isEmpty ? FlutterLogo(size: radius) : null,
    );
  }
}
