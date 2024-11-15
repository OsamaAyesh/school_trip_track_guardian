import 'dart:async';
import 'dart:math';

import 'package:flutter_dash/flutter_dash.dart';
import 'package:school_trip_track_guardian/model/route_direction.dart';
import 'package:school_trip_track_guardian/services/service_locator.dart';
import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';
import 'package:school_trip_track_guardian/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../model/constant.dart';
import '../../model/loading_state.dart';
import '../../model/reservation.dart';
import '../../model/user.dart';
import '../../utils/app_theme.dart';
import '../../utils/size_config.dart';
import '../../utils/tools.dart';
import '../languages/language_constants.dart';
import '../widgets/app_bar.dart';
import 'dart:ui' as ui;

class TrackSchoolBusScreen extends StatefulWidget {
  final DbUser? student;
  final bool? morning;
  const TrackSchoolBusScreen({Key? key, this.student, this.morning}) : super(key: key);

  @override
  TrackSchoolBusScreenState createState() => TrackSchoolBusScreenState();
}
class TrackSchoolBusScreenState extends State<TrackSchoolBusScreen> {
  Completer<GoogleMapController>? mapController = Completer();
  ThisApplicationViewModel thisApplicationViewModel = serviceLocator<ThisApplicationViewModel>();

  List<Marker> markers = [];
  Marker? busMarker, userMarker;

  bool isMapAdjusted = false;

  double? distanceToStop;

  InfoWindow busInfoWindow = InfoWindow(title: 'Bus', snippet: '');

  @override
  void dispose() {
    thisApplicationViewModel.reservationDetailsLoadingState = LoadingState();
    String channelId = thisApplicationViewModel.reservationDetails?.trip?.channel ?? "";
    thisApplicationViewModel.reservationDetails = null;
    thisApplicationViewModel.leaveChannel(channelId);
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    busMarker = Marker(
      markerId: const MarkerId('bus'),
      infoWindow: busInfoWindow,
    );
    getIcons();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        thisApplicationViewModel.getReservationDetailsEndpoint(
            widget.student?.id, widget.morning, context);
      });
    });
  }
  Widget displayRouteMap(ThisApplicationViewModel thisAppModel) {
    if (thisAppModel.reservationDetailsLoadingState.inLoading()) {
      // loading. display animation
      return loadingScreen();
    }
    else if (thisAppModel.reservationDetailsLoadingState.loadingFinished()) {
      if (kDebugMode) {
        print("network call finished");
      }
      //network call finished.
      if (thisAppModel.reservationDetailsLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(context,
            thisAppModel.reservationDetailsLoadingState.failState);
      }
      else {
        Reservation? reservation = thisAppModel.reservationDetails;
        Position? reservationGPSLocation = thisAppModel.reservationGPSLocation;
        if(reservation == null) {
          return tripNotStartedScreen(reservation);
        }

        if(!thisAppModel.echoConnected) {
          double? busLat = reservation.trip?.lastPositionLat;
          double? busLng = reservation.trip?.lastPositionLng;
          updateBusMarkerPosition(busLat, busLng, 0);
        }
        else {
          updateBusMarkerPosition(thisAppModel.busLat, thisAppModel.busLng, thisAppModel.busSpeed);
        }

        // userMarker = createMarker(0, reservationGPSLocation?.latitude,
        //     reservationGPSLocation?.longitude,
        //     BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        //     "You", "Your current location");

        Set<Polyline> polyLines = {};
        List<RouteDirection>? routeDirections = reservation.routeDetails
            ?.routeDirections;
        List<dynamic>? stops = reservation.routeDetails?.stops;
        if (routeDirections == null || stops == null) {
          return failedScreen(context, FailState.GENERAL);
        }
        for (var i = 0; i < routeDirections.length; i++) {
          Color color = Color((Random().nextDouble() * 0xFFFFFF).toInt())
              .withOpacity(1.0);
          Polyline polyline = Polyline(
            polylineId: const PolylineId('route'),
            color: color, //Random color
            width: 5.w.toInt(),
            points: routeDirections[i].pathPoints,
          );
          polyLines.add(polyline);
        }
        if(markers.isEmpty) {
          if (busMarker != null) {
            markers.add(busMarker!);
          }
          // if (userMarker != null) {
          //   markers.add(userMarker!);
          // }
          for (var i = 0; i < stops.length; i++) {
            double? stopLat = double.parse(stops[i]['lat'].toString());
            double? stopLng = double.parse(stops[i]['lng'].toString());
            Marker? marker = createMarker(stops[i]['id'], stopLat, stopLng,
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                stops[i]['name'], stops[i]['address']);
            if (marker != null) {
              markers.add(marker);
            }
          }
        }
        //Get the bounds from markers
        if (reservation.trip?.startedAt != null && reservation.trip?.endedAt == null) {
          return Stack(
            children: [
              SizedBox(
                height: 0.75*SizeConfig.screenHeight!,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: calculateCenterPoint(markers),
                  ),
                  markers: getMarkers(),
                  polylines: polyLines,
                  onMapCreated: (GoogleMapController controller) async {
                    mapController?.complete(controller);
                    await adjustBounds();
                  },
                  onCameraIdle: () async {
                    if (!isMapAdjusted) {
                      await adjustBounds();
                      if(markers[0].markerId.value == "bus" && markers[0].position.latitude == 0 && markers[0].position.longitude == 0) {
                        isMapAdjusted = false;
                      }
                      else {
                        isMapAdjusted = true;
                      }
                    }
                  },
                ),
              ),
              !thisAppModel.echoConnected ? Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Text(
                    "Error tracking bus location",
                    style: AppTheme.textWhiteMedium,
                  ),
                ),
              ) : Container(),
              Positioned(
                //card for stop details
                bottom: 0,
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Container(
                    width: SizeConfig.screenWidth,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(0),
                      boxShadow: const [
                        BoxShadow(
                          color: AppTheme.darkGrey,
                          blurRadius: 4,
                          offset: Offset(4, 4),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.directions_bus, color: AppTheme.primary,),
                            SizedBox(width: 40.w,),
                            Dash(
                                direction: Axis.vertical,
                                length: SizeConfig.screenHeight! * 0.02,
                                dashColor: Colors.grey),
                            SizedBox(width: 10.w,),
                            distanceToStop != null ? Text("${Tools.formatDouble(distanceToStop)} km"
                              , style: AppTheme.bold14Grey60,) : Container(),
                          ],
                        ),
                        Row(
                          children: [
                            widget.morning! ?
                            Text(widget.student?.studentDetails?.pickupPickTime??"", style: AppTheme.textDarkBlueSmall,)
                                :
                            Text(widget.student?.studentDetails?.dropOffDropTime??"", style: AppTheme.textDarkBlueSmall,),
                            SizedBox(width: 5.w,),
                            const Icon(Icons.location_on_outlined, color: AppTheme.secondary,),
                            SizedBox(
                              width: SizeConfig.screenWidth! * 0.7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5.h,),
                                  widget.morning! ?
                                  Text(widget.student?.studentDetails?.pickupStop?.name ?? "", style: AppTheme.textDarkBlueMedium, overflow: TextOverflow.ellipsis,)
                                      :
                                  Text(widget.student?.studentDetails?.dropOffStop?.name ?? "", style: AppTheme.textDarkBlueMedium, overflow: TextOverflow.ellipsis,),
                                  SizedBox(height: 5.h,),
                                  widget.morning! ?
                                  Text(widget.student?.studentDetails?.pickupStop?.address ?? "", style: AppTheme.textGreySmall, overflow: TextOverflow.ellipsis,)
                                      :
                                  Text(widget.student?.studentDetails?.dropOffStop?.address ?? "", style: AppTheme.bold14Grey60, overflow: TextOverflow.ellipsis,)
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 10.h,),
                        const Divider(color: AppTheme.darkGrey,),
                        //button to call driver
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     TextButton(
                        //       onPressed: () {},
                        //       child: Row(
                        //         children: [
                        //           const Icon(Icons.call, color: AppTheme.secondary,),
                        //           SizedBox(width: 5.w,),
                        //           Text("Call Driver", style: AppTheme.bold14Secondary,),
                        //         ],
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     Text(
                    //       "Next stop",
                    //       style: AppTheme.textGreyMedium,
                    //     ),
                    //     SizedBox(height: 5.h,),
                    //     Text(
                    //       reservation.firstStop?.name ?? "",
                    //       style: AppTheme.textDarkBlueMedium,
                    //     ),
                    //     SizedBox(height: 5.h,),
                    //     Text(
                    //       reservation.firstStop?.address ?? "",
                    //       style: AppTheme.textGreyMedium,
                    //     ),
                    //   ],
                    // ),
                  ),
                )
              ),
            ],
          );
        }
        else {
          return tripNotStartedScreen(reservation);
        }
      }
    }
    return Container();
  }

  Marker? createMarker(int? id, double? lat, double? lng, BitmapDescriptor? icon,
      String? title, String? snippet) {
    if (id == null || lat == null || lng == null) {
      return null;
    }
    return Marker(
      markerId: MarkerId(id.toString()),
      position: LatLng(
          lat, lng),
      icon: icon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
      // consumeTapEvents: true,
    );
  }

  Set<Marker> getMarkers() {
    //convert _markers to set
    Set<Marker> markers_ = {};
    for (var i = 0; i < markers.length; i++) {
      if(markers[i].position.latitude == 0 && markers[i].position.longitude == 0) {
        continue;
      }
      markers_.add(markers[i]);
    }
    return markers_;
  }

  Future<void> adjustBounds() async {
    LatLngBounds? boundss = getBoundsMarker();
    if(boundss != null) {
      mapController?.future.then((value) => value.animateCamera(CameraUpdate.newLatLngBounds(boundss, 50)));
    }
  }

  LatLngBounds? getBoundsMarker(){
    if(mapController==null) {
      return null;
    }
    if(markers.isEmpty || markers.length==1){
      return null;
    }

    List<LatLng> positions = [];
    for (var i = 0; i < markers.length; i++) {
      if(markers[i].position.latitude == 0 && markers[i].position.longitude == 0) {
        continue;
      }
      positions.add(markers[i].position);
    }

    return Tools.createBounds(positions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, widget.morning! ?
      (translation(context)?.trackMorningBus ?? "Track Morning Bus") :
      (translation(context)?.trackAfternoonBus ?? "Track Afternoon Bus"),
          textDirection: TextDirection.ltr),
      body: Consumer<ThisApplicationViewModel>(
          builder: (context, thisAppModel, child) {
            return displayRouteMap(thisAppModel);
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await adjustBounds();
        },
        child: const Icon(Icons.zoom_out_map),
      ),
    );
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

  Future<Uint8List?> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))?.buffer
        .asUint8List();
  }

  getIcons() async {
    int iconSize = (SizeConfig.screenWidth! * SizeConfig.devicePixelRatio! / 10)
        .round();
    final Uint8List? markerIcon = await getBytesFromAsset(
        'assets/images/school_bus.png', iconSize);
    // make sure to initialize before map loading
    BitmapDescriptor customIcon = BitmapDescriptor.fromBytes(markerIcon!);
    setState(() {
      updateBusMarkerIcon(customIcon);
    });
  }

  void updateBusMarkerPosition(double? lat, double? lng, double? speed) {
    if (markers.isNotEmpty && busMarker != null && lat != null && lng != null) {
      markers[0] = markers[0].copyWith(
        positionParam: LatLng(lat, lng),
          infoWindowParam: busInfoWindow.copyWith(
            snippetParam: speed != null ? "${speed.toStringAsFixed(2)} km/h" : "",
          ),
      );
      String? stopLat, stopLng;
      widget.morning! ?
      stopLat = widget.student?.studentDetails?.pickupStop?.lat
          :
      stopLat = widget.student?.studentDetails?.dropOffStop?.lat;

      widget.morning! ?
      stopLng = widget.student?.studentDetails?.pickupStop?.lng
          :
      stopLng = widget.student?.studentDetails?.dropOffStop?.lng;

      if (stopLat != null && stopLng != null) {
        double distance = Tools.calculateDistance(
            lat, lng,
            double.parse(stopLat), double.parse(stopLng));
        distanceToStop = distance;
      }
      else {
        distanceToStop = null;
      }
    }
  }

  void updateBusMarkerIcon(BitmapDescriptor customIcon) {
    if (busMarker != null) {
      //update icon
      busMarker = busMarker!.copyWith(
        iconParam: customIcon,
      );
    }
  }

  textBanner(String message, {Color? backgroundColor}) {
    return MaterialBanner(
      content: Text(message),
      leading: const Icon(Icons.info),
      backgroundColor: backgroundColor ?? Colors.yellow,
      actions: const [],
    );
  }

  Widget tripNotStartedScreen(Reservation? reservation) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 60.h),
          Image.asset("assets/images/no_bus.png", height: MediaQuery
              .of(context)
              .orientation == Orientation.landscape ? 150 : 250,),
          Padding(
            padding: EdgeInsets.only(top: 30.h),
            child: Column(
              children: [
                Text( (reservation != null && reservation.trip?.startedAt != null) ?
                (translation(context)?.tripHasEnded ?? "Trip has ended") :
                (reservation == null ? (translation(context)?.noTripIsAvailable ?? "Trip is not available") : (translation(context)?.tripNotStartedYet ?? "Trip has not started yet")),
                  style: AppTheme.textGreyLarge,
                  textAlign: TextAlign.center,),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
