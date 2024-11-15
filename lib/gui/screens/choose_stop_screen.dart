import 'dart:async';
import 'dart:math';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:school_trip_track_guardian/model/route_direction.dart';
import 'package:school_trip_track_guardian/model/user.dart';
import 'package:school_trip_track_guardian/services/service_locator.dart';
import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';
import 'package:school_trip_track_guardian/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../model/constant.dart';
import '../../model/stop.dart';
import '../../model/trip.dart';
import '../../utils/app_theme.dart';
import '../../utils/tools.dart';
import '../languages/language_constants.dart';
import '../widgets/app_bar.dart';

class ChooseStopScreen extends StatefulWidget {
  final Stop? stop;
  final bool? pickUp;
  final DbUser? student;
  const ChooseStopScreen({Key? key, this.stop, this.pickUp, this.student}) : super(key: key);

  @override
  ChooseStopScreenState createState() => ChooseStopScreenState();
}
class ChooseStopScreenState extends State<ChooseStopScreen> {
  Completer<GoogleMapController>? mapController = Completer();
  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();

  Marker? marker;
  int? selectedRouteId;
  int? selectedTripId;
  int? selectedStopId;

  @override
  void initState() {
    thisAppModel.setPickupDropOffLoadingState.setError(null);
    marker = createMarker(widget.stop!);
    super.initState();
  }
  Widget displayStopMap() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            width: 0.99.sw,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin: EdgeInsets.all(10),
              elevation: 0,
              child: Column(
                children: [
                  Text(
                    widget.stop!.name!,
                    style: AppTheme.textPrimaryLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 30.h),
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          Icons.location_on,
                          color: AppTheme.secondary,
                        ),
                      ),
                      SizedBox(
                        width: 0.8.sw,
                        child: Text(
                          widget.stop!.address!,
                          style: AppTheme.textPrimarySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.02.sh),
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          Icons.directions_walk,
                          color: AppTheme.secondary,
                        ),
                      ),
                      Text(
                        widget.stop!.distance != null
                            ? '${widget.stop!.distance!.toStringAsFixed(2)} ${'km'}'
                            : '',
                        style: AppTheme.textPrimarySmall,
                      ),
                    ],
                  ),
                  SizedBox(height: 0.02.sh),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 0.4.sh,
            child: displayMap(),
          ),
          SizedBox(height: 0.02.sh),
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.access_time,
                  color: AppTheme.secondary,
                ),
              ),
              Text(
                translation(context)?.selectTime ?? 'Select Time',
                style: AppTheme.textPrimaryLarge,
              ),
            ],
          ),
          SizedBox(height: 0.02.sh),
          // list start times and end times and routes
          SizedBox(
            height: 0.28.sh,
            child: getStopTimesDetails(),
          ),
        ],
      ),
    );
  }

  Widget displayMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(double.parse(widget.stop!.lat!), double.parse(widget.stop!.lng!)),
        zoom: 15,
      ),
      markers: getMarkers(),
      onMapCreated: (GoogleMapController controller) async {
        mapController?.complete(controller);
      },
    );
  }

  Marker createMarker(Stop stop) {
    return Marker(
      markerId: MarkerId(stop.name!),
      position: LatLng(
          double.parse(stop.lat!), double.parse(stop.lng!)),
      infoWindow: InfoWindow(
        title: stop.name!,
        snippet: stop.address,
      ),
      icon: BitmapDescriptor.defaultMarker,
      // consumeTapEvents: true,
    );
  }

  Set<Marker> getMarkers() {
    //convert _markers to set
    Set<Marker> markers_ = {};
    markers_.add(marker!);
    return markers_;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThisApplicationViewModel>(
        builder: (context, thisAppModel, child) {
          // if(thisAppModel.setPickupDropOffLoadingState.loadingFinished()
          //     && thisAppModel.setPickupDropOffLoadingState.loadError == null){
          //   Navigator.pop(context);
          //   Navigator.pop(context);
          // }
          if(thisAppModel.setPickupDropOffLoadingState.loadingFinished() &&
              thisAppModel.setPickupDropOffLoadingState.loadError != null){
            Fluttertoast.showToast(
                msg: thisAppModel.setPickupDropOffLoadingState.error!,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: AppTheme.primary,
                textColor: Colors.white,
                fontSize: 16.0
            );
          }
          return Scaffold(
            appBar: buildAppBar(context, ""),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (selectedRouteId == null || selectedTripId == null ||
                    selectedStopId == null) {
                  Fluttertoast.showToast(
                      msg: "Please select a time",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: AppTheme.primary,
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                  return;
                }
                thisAppModel.setPickupDropOffEndpoint(
                    widget.student?.id, selectedStopId,
                    selectedRouteId, selectedTripId,
                    widget.pickUp, context);
              },
              backgroundColor: AppTheme.secondary,
              child: thisAppModel.setPickupDropOffLoadingState.inLoading()
                  ? const CircularProgressIndicator(
                color: Colors.white,
              ) :
              SizedBox(
                width: 30.w,
                height: 30.h,
                child: Icon(Icons.save, color: Colors.white,
                  size: 25.w,),
              ),
            ),
            body: displayStopMap(),
          );
        });
  }

  calculateCenterPoint(List<Marker> markers) {
    double x = 0;
    double y = 0;
    double z = 0;
    for (var i = 0; i < markers.length; i++) {
      double latitude = markers.elementAt(i).position.latitude * pi / 180;
      double longitude = markers.elementAt(i).position.longitude * pi / 180;
      x += cos(latitude) * cos(longitude);
      y += cos(latitude) * sin(longitude);
      z += sin(latitude);
    }
    double total = markers.length.toDouble();
    x = x / total;
    y = y / total;
    z = z / total;
    double centralLongitude = atan2(y, x);
    double centralSquareRoot = sqrt(x * x + y * y);
    double centralLatitude = atan2(z, centralSquareRoot);
    return LatLng(centralLatitude * 180 / pi, centralLongitude * 180 / pi);
  }

  getStopTimesDetails() {
    List<Widget> a = [];
    if (widget.stop!.pickTimes == null || widget.stop!.pickTimes!.isEmpty) {
      return Container();
    }

    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: widget.stop!.pickTimes!.length,
      itemBuilder: (context, index) {
        return InkWell(
          child: SizedBox(
            width: 0.45.sw,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin: const EdgeInsets.all(4),
              elevation: 2,
              child: Column(
                children: [
                  SizedBox(height: 0.01.sh),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: widget.pickUp!
                            ? const Icon(
                          Icons.bus_alert,
                          color: AppTheme.secondary,
                        )
                            : const Icon(
                          Icons.school,
                          color: AppTheme.secondary,
                        ),
                      ),
                      Text(
                        Tools.formatTime(widget.stop!.pickTimes!.elementAt(
                            index)),
                        style: AppTheme.textPrimaryMedium,
                      )
                    ],
                  ),
                  SizedBox(height: 0.02.sh),
                  Row(
                    children: [
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            Icons.route,
                            color: AppTheme.secondary,
                          )
                      ),
                      SizedBox(
                        width: 0.3.sw,
                        child: Text(
                          widget.stop!.routes!.elementAt(index).name!,
                          style: AppTheme.textPrimarySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.02.sh),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: widget.pickUp!
                            ? const Icon(
                          Icons.school,
                          color: AppTheme.secondary,
                        )
                            : const Icon(
                          Icons.home_sharp,
                          color: AppTheme.secondary,
                        ),
                      ),
                      Text(
                        Tools.formatTime(widget.stop!.dropTimes!.elementAt(
                            index)),
                        style: AppTheme.textPrimaryMedium,
                      )
                    ],
                  ),
                  SizedBox(height: 0.02.sh),
                  Text(
                    widget.stop!.availableSeats!.elementAt(index) == 0
                        ? "No seats available"
                        : "${widget.stop!.availableSeats!.elementAt(index)} seats available",
                    style: widget.stop!.availableSeats!.elementAt(index) == 0
                        ? AppTheme.subCaptionSecondary
                        : AppTheme.coloredGreenSubTitle,
                  ),
                  SizedBox(height: 0.02.sh),
                  widget.stop!.availableSeats!.elementAt(index) != 0?
                  Column(
                    children: [
                      const Divider(
                        height: 3,
                        color: AppTheme.grey_40,
                      ),
                      SizedBox(height: 0.02.sh),
                      SizedBox(
                        child: selectedStopId == widget.stop!.id &&
                            selectedTripId ==
                                widget.stop!.tripsIds!.elementAt(index) &&
                            selectedRouteId ==
                                widget.stop!.routes!.elementAt(index).id
                            ? const Icon(
                          Icons.check_box_outlined,
                          color: AppTheme.primary,
                        )
                            : const Icon(
                          Icons.check_box_outline_blank,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ):Container(),
                ],
              ),
            ),
          ),
          onTap: () {
            setState(() {
              selectedRouteId = widget.stop!.routes!.elementAt(index).id;
              selectedTripId = widget.stop!.tripsIds!.elementAt(index);
              selectedStopId = widget.stop!.id;
            });
          },
        );
      },
    );
  }
}
