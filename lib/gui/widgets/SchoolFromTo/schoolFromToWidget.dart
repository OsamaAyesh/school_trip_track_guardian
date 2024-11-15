import 'package:dotted_line/dotted_line.dart';
import 'package:school_trip_track_guardian/gui/widgets/SchoolFromTo/schoolFromToWidgetChild.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../utils/size_config.dart';

class SchoolFromToWidget extends StatelessWidget{
  final List<SchoolFromToWidgetChild> children;
  const SchoolFromToWidget({superKey, required this.children}) : super(key: superKey);

  @override
  Widget build(BuildContext context){
    double distanceFromLeft = 0;
    return SizedBox(
      height: 80.h,
      width: SizeConfig.screenWidth,
      child: Stack(
          children: List.generate(
            children.length,
            (i){
              distanceFromLeft += i==0 ? 10:children[i-1].width;
              return Positioned(
                left: distanceFromLeft.w,
                child: children[i]
              );
            }
      ),),
    );
  }
}