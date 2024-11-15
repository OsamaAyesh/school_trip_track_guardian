import 'package:school_trip_track_guardian/gui/widgets/RouteWidget/route_widget_child.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:school_trip_track_guardian/utils/icomoon_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_trip_track_guardian/gui/widgets/direction_positioned.dart';
class RouteWidgetMarker extends RouteWidgetChild{
  final Widget leading;
  final Widget trailing;
  const RouteWidgetMarker({super.key, required this.leading, required this.trailing});
  @override
  double get height => 40;
  @override
  Widget build(BuildContext context){
    return SizedBox(
      height: 40.h,
      width: 160.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DirectionPositioned(
            left: 65.w,
            child: const Icon(
              Icomoon.routeWidgetMarker,
              color: AppTheme.secondary,
              size: 35,
              shadows: <Shadow>[
                Shadow(
                    color: AppTheme.normalGrey,
                    blurRadius: 4.0,
                    offset: Offset(0.0, 4.0)
                )
              ],
            ),
          ),
          DirectionPositioned(
              top: 5.h,
              left: 10.w,
              child: leading
          ),
          DirectionPositioned(
              left: 110.w,
              top:5,
              child: trailing
          ),
        ],
      ),
    );
  }
}