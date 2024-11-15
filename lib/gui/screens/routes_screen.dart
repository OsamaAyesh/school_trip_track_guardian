
import 'package:school_trip_track_guardian/gui/screens/route_details_screen.dart';
import 'package:school_trip_track_guardian/gui/screens/route_timeline_screen.dart';
import 'package:school_trip_track_guardian/gui/widgets/route_stop_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:school_trip_track_guardian/gui/widgets/app_bar.dart';
import 'package:school_trip_track_guardian/services/service_locator.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';
import 'package:school_trip_track_guardian/widgets.dart';
import 'package:provider/provider.dart';

import '../languages/language_constants.dart';
import '../widgets/shimmers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_trip_track_guardian/gui/widgets/direction_positioned.dart';
class RoutesScreen extends StatefulWidget {

  const RoutesScreen({Key? key}): super(key: key);
  @override
  RoutesScreenState createState() => RoutesScreenState();
}

class RoutesScreenState extends State<RoutesScreen> {
  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        thisAppModel.getRoutesEndpoint();
      });
    });
  }

  Future<void> _refreshData() {
    return Future(
            () {
          thisAppModel.getRoutesEndpoint();
        }
    );
  }


  Widget displayAllRoutes() {
    return Scaffold(
        appBar: buildAppBar(context, translation(context)?.routes ?? 'Routes'),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: displayRoutes(),
        ),
    );
  }

  List<Widget> routesListScreen() {
    return List.generate(thisAppModel.routes.length, (i) {
      return RouteStopCard(
          icon: 0,
          name: thisAppModel.routes[i].name!,
          details: thisAppModel.routes[i].stopsCount.toString() + (translation(context)?.stops ?? ' stops'),
          onFirstIconPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RouteTimelineScreen(routeId: thisAppModel.routes[i].id,
                        routeName: thisAppModel.routes[i].name)
                )
            );
          },
          onSecondIconPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RouteDetailsScreen(routeId: thisAppModel.routes[i].id,
                        routeName: thisAppModel.routes[i].name)
                )
            );
          },
          isMorning: thisAppModel.routes[i].isMorning,
      );
    });
  }

  Widget? displayRoutes() {
    if (thisAppModel.routesLoadingState.inLoading()) {
      // loading. display animation
      Shimmers shimmer = Shimmers(
        options: ShimmerOptions().vListOptions(2),
      );
      return shimmer; //loadingScreen();
    }
    else if (thisAppModel.routesLoadingState.loadingFinished()) {
      if (kDebugMode) {
        print("network call finished");
      }
      //network call finished.
      if (thisAppModel.routesLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(context,
            thisAppModel.routesLoadingState.failState);
      }
      else {
        List<Widget> a = [];
        if (kDebugMode) {
          print(thisAppModel.routes.length);
        }
        if (thisAppModel.routes.isNotEmpty) {
          a.addAll(routesListScreen());
          //print(a[0].)
        }
        else {

          return Stack(
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        Container(),
                      ],
                    ),
                  ),
                ),
                DirectionPositioned(
                  top: 20.h,
                  left: 10.w,
                  right: 10.w,
                  bottom: 10.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/no_bus.png", height: MediaQuery
                          .of(context)
                          .orientation == Orientation.landscape ? 150.h : 250.w,),
                      Padding(
                        padding: EdgeInsets.only(top: 30.h),
                        child: Column(
                          children: [
                            Text(translation(context)?.noRoutes ?? "Oops... No routes found.",
                              style: AppTheme.caption,
                              textAlign: TextAlign.center,),
                            SizedBox(height: 30.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]
          );
          //}
        }
        return ListView(
            children: a
        );
      }
    }
    return null;
  }





  @override
  Widget build(context) {
    return Consumer<ThisApplicationViewModel>(
        builder: (context, thisAppModel, child) {
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: displayAllRoutes(),
          );
        });
  }


}


