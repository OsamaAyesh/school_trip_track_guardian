import 'dart:async';
import 'dart:math';

import 'package:school_trip_track_guardian/model/route_direction.dart';
import 'package:school_trip_track_guardian/services/service_locator.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';
import 'package:school_trip_track_guardian/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../model/constant.dart';
import '../../model/stop.dart';
import '../../utils/tools.dart';
import '../widgets/app_bar.dart';

class StopLocationScreen extends StatefulWidget {
  final Stop? stop;
  const StopLocationScreen({Key? key, this.stop}) : super(key: key);

  @override
  StopLocationScreenState createState() => StopLocationScreenState();
}
class StopLocationScreenState extends State<StopLocationScreen> {
  Completer<GoogleMapController>? mapController = Completer();
  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();

  Marker? marker;
  bool isMapSatellite = false;
  @override
  void initState() {
    marker = createMarker(widget.stop!);
    super.initState();
  }
  Widget displayStopMap() {
    //Get the bounds from markers
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(double.parse(widget.stop!.lat!), double.parse(widget.stop!.lng!)),
            zoom: 15,
          ),
          markers: getMarkers(),
          onMapCreated: (GoogleMapController controller) async {
            mapController?.complete(controller);
          },
          //satellite mode
          mapType: isMapSatellite ? MapType.satellite : MapType.normal,
        ),
        //add icon to switch between normal map and satellite map
        Positioned(
          top: 10.h,
          right: 10.w,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                isMapSatellite = !isMapSatellite;
              });
            },
            backgroundColor: AppTheme.secondary,
            child: Icon(
              isMapSatellite ? Icons.map : Icons.satellite,
              color: AppTheme.primary,
            ),
          ),
        ),
      ],
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
    return Scaffold(
      appBar: buildAppBar(context, widget.stop!.name!),
      body: Consumer<ThisApplicationViewModel>(
          builder: (context, thisAppModel, child) {
            return displayStopMap();
          }),
    );
  }
}
