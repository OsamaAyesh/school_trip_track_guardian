
import 'package:school_trip_track_guardian/gui/screens/route_details_screen.dart';
import 'package:school_trip_track_guardian/gui/screens/stop_location_screen.dart';
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
class StopsScreen extends StatefulWidget {

  const StopsScreen({Key? key}): super(key: key);
  @override
  StopsScreenState createState() => StopsScreenState();
}

class StopsScreenState extends State<StopsScreen> {
  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        thisAppModel.getStopsEndpoint();
      });
    });
  }

  Future<void> _refreshData() {
    return Future(
            () {
          thisAppModel.getStopsEndpoint();
        }
    );
  }


  Widget displayAllStops() {
    return Scaffold(
        appBar: buildAppBar(context, translation(context)?.stops ?? 'Stops'),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          // child: RefreshIndicator(
          //   key: _refreshKey,
          //   onRefresh: _refreshData,
          child: displayStops(),
        ),
    );
  }

  List<Widget> stopsListScreen() {
    return List.generate(thisAppModel.stops.length, (i) {
      return RouteStopCard(
          icon: 1,
          name: thisAppModel.stops[i].name!,
          details: thisAppModel.stops[i].address!,
          onFirstIconPressed: () {
            //open button sheet that displays the routes
            if (thisAppModel.stops[i].routes!.length > 1) {
              displayBottomSheet(
                  context, thisAppModel.stops[i].routes!);
            }
            else {
              //goto route details screen
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RouteDetailsScreen(
                          routeId: thisAppModel.stops[i].routes![0]
                              .id!,
                          routeName: thisAppModel.stops[i].routes![0]
                              .name!)));
            }
          },
          onSecondIconPressed: (){
            //goto StopLocationScreen
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StopLocationScreen(stop: thisAppModel.stops[i])));

          },
      );
    });
  }

  Widget? displayStops() {
    if (thisAppModel.stopsLoadingState.inLoading()) {
      // loading. display animation
      Shimmers shimmer = Shimmers(
        options: ShimmerOptions().vListOptions(2),
      );
      return shimmer; //loadingScreen();
    }
    else if (thisAppModel.stopsLoadingState.loadingFinished()) {
      if (kDebugMode) {
        print("network call finished");
      }
      //network call finished.
      if (thisAppModel.stopsLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(context,
            thisAppModel.stopsLoadingState.failState);
      }
      else {
        List<Widget> a = [];
        if (kDebugMode) {
          print(thisAppModel.stops.length);
        }
        if (thisAppModel.stops.isNotEmpty) {
          a.addAll(stopsListScreen());
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
                          .orientation == Orientation.landscape ? 50.h : 200.w,),
                      Padding(
                        padding: EdgeInsets.only(top: 30.h),
                        child: Column(
                          children: [
                            Text(translation(context)?.noStops?? "Oops... No stops found.",
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
            child: displayAllStops(),
          );
        });
  }

  void displayBottomSheet(BuildContext context, List routes) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SingleChildScrollView(
            child: SizedBox(
              height: routes.length > 4 ? MediaQuery.of(context).size.height * .60: routes.length * 120.h,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'Routes',
                      style: AppTheme.bold14DarkBlue,
                    ),
                    SizedBox(height: 10.h),
                    Expanded(
                      child: ListView.builder(
                          itemCount: routes.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  elevation: 1,
                                  child: Column(
                                    children: [
                                      ListTile(
                                          title: Text(
                                            routes[index].name!,
                                            style: AppTheme.bold14Grey60,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          leading: const Icon(
                                            Icons.route,
                                            size: 30,
                                            color: Colors.grey,
                                          ),
                                          onTap: () {
                                            //open button sheet that displays the routes
                                            Navigator.pop(context);
                                            //goto route details screen
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => RouteDetailsScreen(routeId: routes[index].id!, routeName: routes[index].name!)));

                                          }
                                      ),
                                    ],
                                  )),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }


}


