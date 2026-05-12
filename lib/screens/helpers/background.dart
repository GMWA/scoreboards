import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scoreboards/constants/commons.dart';

class TransparentBackground extends StatelessWidget {
  const TransparentBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            height: size.width * 0.7,
            child: SvgPicture.asset(iMGBG),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            color: Color.fromRGBO(255, 255, 255, 0.9),
          ),
        ),
      ],
    );
  }
}
