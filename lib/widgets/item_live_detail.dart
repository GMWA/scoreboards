import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scoreboards/constants/commons.dart';

class LiveDetailItem extends StatelessWidget {
  final String? image;
  final String title;
  final String subTitle;
  final String subTitle2;
  const LiveDetailItem(
      {super.key,
      this.image,
      required this.title,
      this.subTitle = "",
      this.subTitle2 = ""});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: marginStandard, horizontal: marginLarge),
      padding: const EdgeInsets.symmetric(
          vertical: marginStandard, horizontal: marginLarge),
      decoration: BoxDecoration(
        color: Color(0x555075F0),
        borderRadius: BorderRadius.all(
          Radius.circular(radiusStandard),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: SvgPicture.asset(image ?? iMGBG),
          ),
          SizedBox(width: marginLarge),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: marginStandard),
              Text(
                subTitle,
                style: TextStyle(color: Colors.black45),
              ),
              Visibility(
                visible: subTitle2.isNotEmpty,
                child: Container(
                  margin: const EdgeInsets.only(top: marginStandard),
                  child: Text(
                    subTitle2,
                    style: TextStyle(color: Colors.black45),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
