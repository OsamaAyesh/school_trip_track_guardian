import 'package:dotted_line/dotted_line.dart';
import 'package:school_trip_track_guardian/gui/widgets/SchoolFromTo/schoolFromToWidgetChild.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SchoolFromToDashedLine extends SchoolFromToWidgetChild{
  final double widthParam;
  final Widget top;
  const SchoolFromToDashedLine({Key? key, this.widthParam=70, this.top=const SizedBox()}) : super(key: key);
  @override
  double get width => widthParam-10;
  @override
  Widget build(BuildContext context){
    return Container(
      height: 40.h,
      width: widthParam.w,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: (widthParam-25)/2,
            child: top,
          ),
          Positioned(
            top: 20.h,
            child: DottedLine(
              direction: Axis.horizontal,
              lineLength: widthParam.w,
              lineThickness: 1.0,
              dashLength: 2.0,
              dashColor: AppTheme.normalGrey,
              dashRadius: 0.0,
              dashGapLength: 2.0,
              dashGapColor: Colors.transparent,
              dashGapRadius: 0.0,
            ),
          ),
        ],
      ),
    );
  }
}