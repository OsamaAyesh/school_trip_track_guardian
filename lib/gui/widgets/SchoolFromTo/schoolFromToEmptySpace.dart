import 'package:dotted_line/dotted_line.dart';
import 'package:school_trip_track_guardian/gui/widgets/SchoolFromTo/schoolFromToWidgetChild.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SchoolFromToEmptySpace extends SchoolFromToWidgetChild{
  final double widthParam;
  const SchoolFromToEmptySpace({Key? key, required this.widthParam}) : super(key: key);
  @override
  double get width => widthParam;
  @override
  Widget build(BuildContext context){
    return SizedBox(
      width: widthParam.w,
    );
  }
}