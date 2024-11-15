import 'package:school_trip_track_guardian/gui/widgets/RouteWidget/route_widget_child.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:school_trip_track_guardian/utils/icomoon_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_trip_track_guardian/gui/widgets/direction_positioned.dart';
class RouteWidgetRoad extends RouteWidgetChild{
  final Widget leading;
  final Widget trailing;
  const RouteWidgetRoad({super.key, required this.leading, required this.trailing});
  @override
  double get height => 35;
  @override
  Widget build(BuildContext context){
    return SizedBox(
      height: 40.h,
      width: 260.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DirectionPositioned(
            left: 64.w,
            child: const Icon(
              Icomoon.roadSolid,
              color: AppTheme.primary,
              size: 30,
            ),
          ),
          DirectionPositioned(
              top: 5.h,
              left: 10.w,
              child: leading
          ),
          DirectionPositioned(
              left: 115.w,
              top:5,
              child: trailing
          ),
        ],
      ),
    );
  }
}