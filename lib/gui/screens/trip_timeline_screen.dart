
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
import '../widgets/full_trip_time_line.dart';
import '../widgets/trip_time_line.dart';

class TripTimelineScreen extends StatefulWidget {
  final int? tripID, startStopID, endStopID;
  final bool? pickUp;
  const TripTimelineScreen({Key? key, this.tripID, this.startStopID, this.endStopID, this.pickUp}) : super(key: key);

  @override
  TripTimelineScreenState createState() => TripTimelineScreenState();
}
class TripTimelineScreenState extends State<TripTimelineScreen> {
  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        thisAppModel.getTripDetailsEndpoint(widget.tripID);
      });
    });
  }
  Widget displayTripTimeline() {
    if (thisAppModel.tripDetailsLoadingState.inLoading()) {
      // loading. display animation
      return loadingScreen();
    }
    else if (thisAppModel.tripDetailsLoadingState.loadingFinished()) {
      if (kDebugMode) {
        print("network call finished");
      }
      //network call finished.
      if (thisAppModel.tripDetailsLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(context,
            thisAppModel.tripDetailsLoadingState.failState);
      }
      else {
        List<dynamic>? tripDetails = thisAppModel.trip?.tripDetail;
        if (tripDetails == null) {
          return failedScreen(context, FailState.GENERAL);
        }
        int endStopIndex = 0;
        if (widget.pickUp == true) {
          endStopIndex = tripDetails.length;
        }
        else {
          for (int i = 0; i < tripDetails.length; i++) {
            if (tripDetails[i].stopId == widget.endStopID) {
              endStopIndex = i;
              break;
            }
          }
        }
        int startStopIndex = -1;

        if (widget.pickUp == true) {
          if (widget.startStopID != null) {
            for (int i = 0; i < tripDetails.length; i++) {
              if (tripDetails[i].stopId == widget.startStopID) {
                startStopIndex = i;
                break;
              }
            }
          }
        }
        else {
          startStopIndex = 0;
        }
        return Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(top: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: //stops
              [
                FullTripTimeLine(plannedTripDetails: tripDetails,
                    endStopIndex: endStopIndex,
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
