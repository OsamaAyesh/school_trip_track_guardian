
import 'package:school_trip_track_guardian/services/service_locator.dart';
import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';
import 'package:school_trip_track_guardian/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../model/constant.dart';
import '../widgets/app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RouteTimelineScreen extends StatefulWidget {
  final int? routeId;
  final String? routeName;
  const RouteTimelineScreen({Key? key, this.routeId, this.routeName}) : super(key: key);

  @override
  RouteTimelineScreenState createState() => RouteTimelineScreenState();
}
class RouteTimelineScreenState extends State<RouteTimelineScreen> {
  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        thisAppModel.getRouteDetailsEndpoint(widget.routeId);
      });
    });
  }
  Widget displayRouteTimeline() {
    if (thisAppModel.routeDetailsLoadingState.inLoading()) {
      // loading. display animation
      return loadingScreen();
    }
    else if (thisAppModel.routeDetailsLoadingState.loadingFinished()) {
      if (kDebugMode) {
        print("network call finished");
      }
      //network call finished.
      if (thisAppModel.routeDetailsLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(context,
            thisAppModel.routeDetailsLoadingState.failState);
      }
      else {
        List<dynamic>? stops = thisAppModel.routeDetails?.stops;
        if (stops == null) {
          return failedScreen(context, FailState.GENERAL);
        }
        return Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: //stops
            [
              Expanded(
                child: ListView.builder(
                  itemCount: stops.length,
                  itemBuilder: (context, index) {
                    return TimelineTile(
                      alignment: TimelineAlign.manual,
                      lineXY: 0.1,
                      isFirst: index == 0,
                      isLast: index == stops.length - 1,
                      indicatorStyle: IndicatorStyle(
                        width: 40.w,
                        height: 40.h,
                        indicator: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              (index + 1).toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      beforeLineStyle: const LineStyle(
                        color: Colors.blue,
                        thickness: 6,
                      ),
                      endChild: Container(
                        constraints: BoxConstraints(
                          minHeight: 120.h,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(
                                  stops[index]["name"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                stops[index]["address"],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      }
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, widget.routeName!),
      body: Consumer<ThisApplicationViewModel>(
          builder: (context, thisAppModel, child) {
            return displayRouteTimeline();
          }),
    );
  }
}
