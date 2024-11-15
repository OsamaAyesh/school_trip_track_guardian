import 'package:dotted_line/dotted_line.dart';
import 'package:school_trip_track_guardian/gui/widgets/RouteWidget/route_widget_child.dart';
import 'package:school_trip_track_guardian/main.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RouteWidgetDashedLine extends RouteWidgetChild{
  final bool walking;
  final Widget trailing;
  final double heightParam;
  const RouteWidgetDashedLine({Key? key, required this.trailing, this.walking = false, this.heightParam=50}) : super(key: key);
  @override
  double get height => heightParam;
  @override
  Widget build(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        walking ? SizedBox(
          width: 80.w,
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: MainApp.isRtl(context)? EdgeInsets.only(left: 8.0) : EdgeInsets.only(right: 8.0),
              child: Icon(
                FontAwesomeIcons.walking,
                color: AppTheme.normalGrey,
              ),
            ),
          ),
        ) : SizedBox(width: 80.w,),
        DottedLine(
          direction: Axis.vertical,
          lineLength: heightParam,
          lineThickness: 1.0,
          dashLength: 2.0,
          dashColor: AppTheme.lightGrey,
          dashRadius: 0.0,
          dashGapLength: 2.0,
          dashGapColor: Colors.transparent,
          dashGapRadius: 0.0,
        ),
        SizedBox(width: 10.w,),
        SizedBox(
          width: 70.w,
          child: trailing
        ),
      ],
    );
  }
}