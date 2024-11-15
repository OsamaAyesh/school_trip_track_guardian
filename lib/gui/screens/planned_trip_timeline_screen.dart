
import 'package:school_trip_track_guardian/services/service_locator.dart';
import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';
import 'package:school_trip_track_guardian/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../model/constant.dart';
import '../languages/language_constants.dart';
import '../widgets/app_bar.dart';
import '../widgets/trip_time_line.dart';

class PlannedTripTimelineScreen extends StatefulWidget {
  final int? tripID, startStopID, endStopID;

  const PlannedTripTimelineScreen({Key? key, this.tripID, this.startStopID, this.endStopID}) : super(key: key);

  @override
  PlannedTripTimelineScreenState createState() => PlannedTripTimelineScreenState();
}
class PlannedTripTimelineScreenState extends State<PlannedTripTimelineScreen> {
  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        thisAppModel.getPlannedTripDetailsEndpoint(widget.tripID);
      });
    });
  }
  Widget displayTripTimeline() {
    if (thisAppModel.plannedTripDetailsLoadingState.inLoading()) {
      // loading. display animation
      return loadingScreen();
    }
    else if (thisAppModel.plannedTripDetailsLoadingState.loadingFinished()) {
      if (kDebugMode) {
        print("network call finished");
      }
      //network call finished.
      if (thisAppModel.plannedTripDetailsLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(context,
            thisAppModel.plannedTripDetailsLoadingState.failState);
      }
      else {
        List<dynamic>? plannedTripDetails  = thisAppModel.plannedTrip?.plannedTripDetail;
        if (plannedTripDetails == null) {
          return failedScreen(context, FailState.GENERAL);
        }
        int endStopIndex = 0;
        for (int i = 0; i < plannedTripDetails.length; i++) {
          if (plannedTripDetails[i].stopId == widget.endStopID) {
            endStopIndex = i;
            break;
          }
        }
        int startStopIndex = -1;
        if(widget.startStopID != null) {
          for (int i = 0; i < plannedTripDetails.length; i++) {
            if (plannedTripDetails[i].stopId == widget.startStopID) {
              startStopIndex = i;
              break;
            }
          }
        }
        return Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(top: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: //stops
              [
                TripTimeLine(plannedTripDetails: plannedTripDetails,
                    endStopIndex : endStopIndex,
                startStopIndex: startStopIndex),
              ],
            ),
          ),
        );
      }
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, translation(context)?.tripTimeline ?? "Trip Timeline"),
      body: Consumer<ThisApplicationViewModel>(
          builder: (context, thisAppModel, child) {
            return displayTripTimeline();
          }),
    );
  }

}
