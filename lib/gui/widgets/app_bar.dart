import 'package:school_trip_track_guardian/gui/widgets/animated_back_button.dart';
import 'package:school_trip_track_guardian/main.dart';
import 'package:flutter/material.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';

AppBar buildAppBar(BuildContext context, String title, {Widget? left, Widget? right, TextDirection? textDirection}) {
  return AppBar(
    centerTitle: true,
    toolbarHeight: 85,
    leadingWidth: 85,
    backgroundColor: AppTheme.backgroundColor,
    iconTheme: const IconThemeData(
      color: AppTheme.secondary,
    ),
    actions: [
      right ?? Container(),
    ],
    leading: const AnimatedBackButton(),
    elevation: 0,
    title:
    Text(
      title,
      style: AppTheme.title,
      textDirection: textDirection ?? (MainApp.isRtl(context) ? TextDirection.rtl : TextDirection.ltr),
    ),
  );
}