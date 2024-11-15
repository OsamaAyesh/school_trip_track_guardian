import 'package:dotted_line/dotted_line.dart';
import 'package:school_trip_track_guardian/gui/widgets/SchoolFromTo/schoolFromToWidgetChild.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:school_trip_track_guardian/utils/icomoon_icons.dart';

class SchoolFromToMarker extends SchoolFromToWidgetChild{
  const SchoolFromToMarker({super.key, this.bottom=const SizedBox(), this.color});
  final Widget bottom;
  final Color? color;
  @override
  double get width => 30;
  @override
  Widget build(BuildContext context){
    return SizedBox(
      height: 90.h,
      width: 40.w,
      child: Column(
        children: [
          Container(
            width: 27.w,
            child: FittedBox(
              child: Icon(
                Icomoon.routeWidgetMarker,
                color: color,
                shadows: <Shadow>[Shadow(color: Color.fromARGB(64, 0, 0, 0), blurRadius: 4.0, offset: Offset(0.0, 3.0))],
              ),
            ),
          ),
          const SizedBox(height: 10,),
          bottom
        ],
      ),
    );
  }
}