import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:school_trip_track_guardian/utils/icomoon_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RouteStopCard extends StatefulWidget{
  final int icon; // 0 for route and 1 for stop
  final String name;
  final String details;
  final Function onFirstIconPressed;
  final Function onSecondIconPressed;
  final bool? isMorning;
  const RouteStopCard({super.key, required this.icon, required this.name, required this.details, required this.onFirstIconPressed, required this.onSecondIconPressed, this.isMorning});
  @override
  State<StatefulWidget> createState() => _RouteStopCardState();

}

class _RouteStopCardState extends State<RouteStopCard>{
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          ListTile(
            leading: SizedBox(
              width: widget.icon == 0 ? 40:50,
              child: FittedBox(
                child: Icon(
                  widget.icon == 0 ? Icomoon.roadSolid : Icomoon.routeWidgetMarker,
                  shadows: widget.icon == 1 ? <Shadow>[
                    const Shadow(
                        color: AppTheme.darkGrey,
                        blurRadius: 4.0,
                        offset: Offset(0.0, 2))
                  ]:[],
                  color: AppTheme.primary,
                ),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.name,
                style: const TextStyle(
                  color: AppTheme.secondary,
                  fontSize: 16,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            trailing:
            widget.isMorning != null ? (// is morning
            widget.isMorning == true ? const Icon(
              Icons.sunny,
              color: AppTheme.primary,
              size: 25,
            ) : const Icon(
              Icons.nightlight_round,
              color: AppTheme.primary,
              size: 25,
            )) : const SizedBox(),
            subtitle: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: widget.icon == 0? 20:40,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    widget.details,
                    style: AppTheme.textDarkBlueSmallLight,
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 2,
            width: 330.w,
            color: const Color(0xFFB6B6B6),
          ),
          SizedBox(
            width: 350.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  onPressed: (){
                    widget.onFirstIconPressed();
                  },
                  child: Icon(
                    widget.icon == 0 ? Icons.route_outlined : Icomoon.roadSolid,
                    color: AppTheme.secondary,
                    size: widget.icon == 0 ? 30 : 25,
                  ),
                ),
                CupertinoButton(
                  onPressed: (){
                    widget.onSecondIconPressed();
                  },
                  child: const Icon(
                    FontAwesomeIcons.mapMarkedAlt,
                    color: AppTheme.secondary,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}