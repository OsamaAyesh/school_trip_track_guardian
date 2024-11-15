import 'package:dotted_line/dotted_line.dart';
import 'package:school_trip_track_guardian/gui/widgets/SchoolFromTo/schoolFromToWidgetChild.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class SchoolFromToSchool extends SchoolFromToWidgetChild{
  const SchoolFromToSchool({super.key, this.bottom=const SizedBox(), this.color});
  final Widget bottom;
  final Color? color;
  @override
  double get width => 40;
  @override
  Widget build(BuildContext context){
    return SizedBox(
      height: 80.h,
      width: 40.w,
      child: Column(
        children: [
          SizedBox(height: 5.h,),
          SizedBox(
            width: 20.w,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Icon(
                FontAwesomeIcons.school,
                color: color,
              ),
            ),
          ),
          SizedBox(height: 12.h,),
          Align(alignment: Alignment.bottomRight, child: bottom)
        ],
      ),
    );
  }
}