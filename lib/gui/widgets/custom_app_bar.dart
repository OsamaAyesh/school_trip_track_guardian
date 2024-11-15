import 'package:flutter/material.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {

  /// Preferred size of this widget for Scaffold
  final double _preferredHeight = 1.0;

  const CustomAppBar({super.key});

  @override
  CustomAppBarState createState() => CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(_preferredHeight);
}

class CustomAppBarState extends State<CustomAppBar> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor,
    );
  }
}