import 'dart:async';
import 'dart:math';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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

import '../../connection/utils.dart';
import '../../model/constant.dart';
import '../../model/stop.dart';
import '../../model/trip.dart';
import '../../utils/app_theme.dart';
import '../../utils/tools.dart';
import '../widgets/app_bar.dart';

class ChooseLocationScreen extends StatefulWidget {
  final double? lat;
  final double? lng;
  final bool? pickUp;
  final DbUser? student;
  final String? address;
  const ChooseLocationScreen({Key? key, this.lat, this.lng, this.address, this.pickUp, this.student}) : super(key: key);

  @override
  ChooseLocationScreenState createState() => ChooseLocationScreenState();
}
class ChooseLocationScreenState extends State<ChooseLocationScreen> {
  Completer<GoogleMapController>? mapController = Completer();
  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();

  Marker? marker;
  String? address = "";
  double? lat;
  double? lng;
  bool isMapSatellite = false;
  Position? currentGPSLocation;
  bool? gpsLoading = false;
  @override
  void initState() {
    address = widget.address;
    lat = widget.lat;
    lng = widget.lng;
    thisAppModel.setPickupDropOffLocationLoadingState.setError(null);
    marker = createMarker(lat, lng, "Your Location", address);
    super.initState();
  }
  Widget displayStopMap() {
    return Column(
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
                        address!,
                        style: AppTheme.textPrimarySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.02.sh),
              ],
            ),
          ),
        ),
        Expanded(
          child: gpsLoading! ? const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primary,
            ),
          ) :
          displayMap(),
        ),
      ],
    );
  }

  Widget displayMap() {
    return Stack(
      children: [
        GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(lat!, lng!),
              zoom: 15,
            ),
            markers: getMarkers(),
            onMapCreated: (GoogleMapController controller) async {
              mapController?.complete(controller);
            },
            //satellite mode
            mapType: isMapSatellite ? MapType.satellite : MapType.normal,
            onTap: (LatLng latLng) {
              changeCurrentLocation(latLng);
            }
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
            backgroundColor: AppTheme.primary,
            child: Icon(
              isMapSatellite ? Icons.map : Icons.satellite,
              color: AppTheme.secondary,
            ),
          ),
        ),
        Positioned(
          top: 80.h,
          right: 10.w,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                gpsLoading = true;
              });
              checkLocationService(context).then((
                  LocationServicesStatus value) {
                bool? locationServiceStatus = (value ==
                    LocationServicesStatus.enabled);
                if (locationServiceStatus) {
                  getLocation().then((value) {
                    setState(() {
                      currentGPSLocation = value;
                      changeCurrentLocation(LatLng(
                          currentGPSLocation!.latitude,
                          currentGPSLocation!.longitude));
                      gpsLoading = false;
                    });
                  });
                }
                else {
                  setState(() {
                    gpsLoading = false;
                  });
                  Fluttertoast.showToast(
                      msg: "Please enable location service",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: AppTheme.primary,
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                }
              });
            },
            backgroundColor: AppTheme.primary,
            child: const Icon(
              Icons.gps_fixed,
              color: AppTheme.secondary,
            ),
          ),
        ),
      ],
    );
  }

  getAddressFromLatLng(double lat, double lng) async {
    var addresses = await placemarkFromCoordinates(lat, lng);
    var first = addresses.first;
    var address = "${first.name}, ${first.street}, ${first.locality}, ${first.postalCode}, ${first.country}";
    print(address);
    return address;
  }

  Marker createMarker(lat, lng, name, address) {
    return Marker(
      markerId: MarkerId(name),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(
        title: name,
        snippet: address,
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
          // if(thisAppModel.setPickupDropOffLocationLoadingState.loadingFinished()
          //     && thisAppModel.setPickupDropOffLocationLoadingState.loadError == null){
          //   Navigator.pop(context);
          //   Navigator.pop(context);
          // }
          if(thisAppModel.setPickupDropOffLocationLoadingState.loadingFinished() &&
              thisAppModel.setPickupDropOffLocationLoadingState.loadError != null){
            Fluttertoast.showToast(
                msg: thisAppModel.setPickupDropOffLocationLoadingState.error!,
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
                if (address == "Please wait..." || address == "" || address == null) {
                  Fluttertoast.showToast(
                      msg: "Please select an address on the map",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: AppTheme.primary,
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                  return;
                }
                thisAppModel.setPickupDropOffLocationEndpoint(
                    widget.student?.id, lat, lng, address,
                    widget.pickUp, context);
              },
              backgroundColor: AppTheme.secondary,
              child: (thisAppModel.setPickupDropOffLocationLoadingState.inLoading())
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

  void changeCurrentLocation(LatLng latLng) {
    setState(() {
      address = "Please wait...";
      lat = latLng.latitude;
      lng = latLng.longitude;
    });
    marker = createMarker(
        lat, lng, "Your Location", "");
    //center the map to the selected location
    mapController?.future.then((value) {
      value.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 15)));
    });

    //get the address of the selected location
    getAddressFromLatLng(latLng.latitude, latLng.longitude)
        .then((value) {
      setState(() {
        address = value;
      });
    });
  }
}
