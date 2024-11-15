
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_trip_track_guardian/gui/widgets/direction_positioned.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:school_trip_track_guardian/gui/widgets/form_error.dart';
import 'package:school_trip_track_guardian/gui/widgets/app_bar.dart';
import 'package:school_trip_track_guardian/model/device.dart';
import 'package:school_trip_track_guardian/model/user.dart';
import 'package:school_trip_track_guardian/services/service_locator.dart';
import 'package:school_trip_track_guardian/utils/tools.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';
import 'package:provider/provider.dart';

import '../../connection/utils.dart';
import '../../model/constant.dart';
import '../../model/stop.dart';
import '../../utils/config.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';
import 'choose_stop_screen.dart';

class PickupDropOffStopsScreen extends StatefulWidget {
  const PickupDropOffStopsScreen({Key? key, this.lat, this.lang, this.pickUp, this.student}) : super(key: key);

  final double? lat;
  final double? lang;
  final bool? pickUp;
  final DbUser? student;

  @override
  PickupDropOffStopsScreenState createState() => PickupDropOffStopsScreenState();
}

class PickupDropOffStopsScreenState extends State<PickupDropOffStopsScreen> {
  ThisApplicationViewModel thisAppModel =
      serviceLocator<ThisApplicationViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      thisAppModel.getClosestStopsEndpoint(widget.student?.id,
          widget.lat, widget.lang, widget.pickUp);
    });
  }

  Widget displayAllStops() {
    return Scaffold(
      appBar: buildAppBar(context, translation(context)?.stops ??  'Stops'),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<ThisApplicationViewModel>(
            builder: (context, thisApplicationViewModel, child) {
              return displayAllClosedStops(context)!;
            },
          )),
    );
  }

  Widget? displayAllClosedStops(BuildContext context) {
    if (thisAppModel.closestStopsLoadingState.inLoading()) {
      // loading. display animation
      return loadingStops();
    } else if (thisAppModel.closestStopsLoadingState.loadingFinished()) {
      //network call finished.
      if (thisAppModel.closestStopsLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(
            context, thisAppModel.closestStopsLoadingState.failState!);
      } else {
        return Consumer<ThisApplicationViewModel>(
          builder: (context, thisApplicationViewModel, child) {
            List<Stop> closestStops;
            closestStops = thisAppModel.closestStops;
            if (closestStops.isEmpty) {
              return emptyScreen();
            } else {
              List<Widget> a = [];
              a.addAll(stopsListScreen(closestStops, thisApplicationViewModel));
              return ListView(children: a);
            }
          },
        );
      }
    }
    return null;
  }

  Widget failedScreen(BuildContext context, FailState failState) {
    return Stack(children: [
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
      Container(
        constraints: BoxConstraints(
          minHeight: Tools.getScreenHeight(context) - 150,
        ),
        child: Center(
          child: onFailRequest(context, failState),
        ),
      )
    ]);
  }

  Widget emptyScreen() {
    return Stack(children: [
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
        top: 30.h,
        left: 10,
        right: 10,
        bottom: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/img_no_place.png",
              height:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? 50
                      : 450,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Column(
                children: [
                  Text(
                    "Oops... There aren't stops close to you",
                    style: AppTheme.textPrimaryMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  List<Widget> stopsListScreen(List<Stop> closestStops,
      ThisApplicationViewModel thisApplicationViewModel) {
    return List.generate(closestStops.length, (i) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 1,
            child: ListTile(
              title: Text(
                closestStops[i].name!,
                style: AppTheme.bold20Black,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      closestStops[i].address ?? "",
                      style: AppTheme.coloredSubtitle,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      closestStops[i].distance != null
                          ? "${Tools.formatDouble(closestStops[i].distance)} m"
                          : "",
                      style: AppTheme.coloredSubSubtitle,
                    ),
                  ],
                ),
              ),
              leading: Icon(
                Icons.location_on,
                color: AppTheme.secondary,
                size: 40.w,
              ),
              onTap: () {
                //ChooseStopScreen
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChooseStopScreen(
                          stop: closestStops[i],
                          pickUp: widget.pickUp,
                          student: widget.student,
                        ))
                );
              }
            ),
        ),
      );
    });
  }

  @override
  Widget build(context) {
    return displayAllStops();
  }

  Widget loadingStops() {
    return const Center(
      child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
      ),
    );
  }
}
