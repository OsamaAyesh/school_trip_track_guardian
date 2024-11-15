import 'dart:async';
import 'dart:math';

import 'package:school_trip_track_guardian/model/route_direction.dart';
import 'package:school_trip_track_guardian/services/service_locator.dart';
import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';
import 'package:school_trip_track_guardian/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../model/constant.dart';
import '../../utils/tools.dart';
import '../widgets/app_bar.dart';

class RouteDetailsScreen extends StatefulWidget {
  final int? routeId;
  final String? routeName;
  const RouteDetailsScreen({Key? key, this.routeId, this.routeName}) : super(key: key);

  @override
  RouteDetailsScreenState createState() => RouteDetailsScreenState();
}
class RouteDetailsScreenState extends State<RouteDetailsScreen> {
  Completer<GoogleMapController>? mapController = Completer();
  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();

  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        thisAppModel.getRouteDetailsEndpoint(widget.routeId);
      });
    });
  }
  Widget displayRouteMap() {
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
        Set<Polyline> polyLines = {};
        List<RouteDirection>? routeDirections = thisAppModel.routeDetails
            ?.routeDirections!;
        List<dynamic>? stops = thisAppModel.routeDetails?.stops;
        if (routeDirections == null || stops == null) {
          return failedScreen(context, FailState.GENERAL);
        }
        markers = [];
        //Change colors for polyline randomly
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
        for (var i = 0; i < stops.length; i++) {
          Marker marker = createMarker(stops[i]);
          markers.add(marker);
        }
        bool isMapAdjusted = false;
        //Get the bounds from markers
        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: calculateCenterPoint(markers),
          ),
          polylines: polyLines,
          markers: getMarkers(),
          onMapCreated: (GoogleMapController controller) async {
            mapController?.complete(controller);
            await adjustBounds();
          },
          onCameraIdle: () async {
            if(!isMapAdjusted) {
              await adjustBounds();
              isMapAdjusted = true;
            }
          },
        );
      }
    }
    return Container();
  }

  Marker createMarker(dynamic stop) {
    return Marker(
      markerId: MarkerId(stop["name"]),
      position: LatLng(
          double.parse(stop["lat"]), double.parse(stop["lng"])),
      infoWindow: InfoWindow(
        title: stop["name"],
        snippet: stop["address"],
      ),
      icon: BitmapDescriptor.defaultMarker,
      // consumeTapEvents: true,
    );
  }

  Set<Marker> getMarkers() {
    //convert _markers to set
    Set<Marker> markers_ = {};
    for (var i = 0; i < markers.length; i++) {
      markers_.add(markers[i]);
    }
    return markers_;
  }

  Future<void> adjustBounds() async {

    // if(mapController == null) {
    //   await Future.delayed(const Duration(milliseconds: 1000));
    //   if(mapController == null) {
    //     return;
    //   }
    // }

    LatLngBounds? boundss = getBoundsMarker();
    if(boundss != null) {
      mapController?.future.then((value) => value.animateCamera(CameraUpdate.newLatLngBounds(boundss, 50)));
    }

    // setState(() {
    //
    // });
  }

  LatLngBounds? getBoundsMarker(){
    if(mapController==null) {
      return null;
    }
    if(markers.isEmpty || markers.length==1){
      return null;
    }

    return Tools.createBounds(markers.map((m) => m.position).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, widget.routeName!),
      body: Consumer<ThisApplicationViewModel>(
          builder: (context, thisAppModel, child) {
            return displayRouteMap();
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
}
