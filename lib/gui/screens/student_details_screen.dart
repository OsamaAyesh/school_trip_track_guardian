import 'dart:async';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice_ex/places.dart';
import 'package:school_trip_track_guardian/gui/screens/add_edit_student_screen.dart';
import 'package:school_trip_track_guardian/gui/screens/pickup_dropoff_stops_screen.dart';
import 'package:school_trip_track_guardian/gui/screens/route_timeline_screen.dart';
import 'package:flutter/material.dart';
import 'package:school_trip_track_guardian/gui/screens/stop_location_screen.dart';
import 'package:school_trip_track_guardian/gui/screens/stops_screen.dart';
import 'package:school_trip_track_guardian/gui/screens/trip_timeline_screen.dart';
import 'package:school_trip_track_guardian/gui/widgets/animated_back_button.dart';
import 'package:school_trip_track_guardian/gui/widgets/student_detail_card.dart';
import 'package:school_trip_track_guardian/services/service_locator.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:school_trip_track_guardian/utils/size_config.dart';
import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../../model/loading_state.dart';
import '../../model/student_details_info.dart';
import '../../connection/utils.dart';
import '../../model/place.dart';
import '../../model/reservation.dart';
import '../../model/user.dart';
import '../../utils/config.dart';
import '../../utils/tools.dart';
import '../../utils/util.dart';
import '../../widgets.dart';
import '../../model/stop.dart' as MyStop;
import '../languages/language_constants.dart';
import '../widgets/app_bar.dart';
import '../widgets/shimmers.dart';
import 'choose_location_screen.dart';
import 'choose_stop_screen.dart';
import 'notifications_settings_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_trip_track_guardian/gui/widgets/direction_positioned.dart';

class StudentDetails extends StatefulWidget {
  final int? studentId;
  const StudentDetails({Key? key, this.studentId}) : super(key: key);
  @override
  StudentDetailsState createState() => StudentDetailsState();
}

class StudentDetailsState extends State<StudentDetails> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  bool shareLoading = false;
  ThisApplicationViewModel thisApplicationModel =
  serviceLocator<ThisApplicationViewModel>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      thisApplicationModel.setAbsentStudentLoadingState.loadError != null;
      thisApplicationModel.setAbsentStudentLoadingState.error != null;
      thisApplicationModel.printStudentCardLoadingState.loadError != null;
      thisApplicationModel.printStudentCardLoadingState.error != null;
      thisApplicationModel.getStudentDetailsEndpoint(widget.studentId);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setData(ThisApplicationViewModel thisAppModel) {
    thisAppModel.getStudentDetailsEndpoint(widget.studentId);
  }

  Future<void> _refreshData(ThisApplicationViewModel thisAppModel) {
    return Future(() {
      _setData(thisAppModel);
    });
  }

  Widget _displayTop(ThisApplicationViewModel thisAppModel) {
    if (thisAppModel.studentDetailsLoadingState.inLoading()) {
      // loading. display animation
      return loadingStudentBasicCard();
    } else {
      // widget with rounded corner image and a card on it
      return Padding(
          padding: EdgeInsets.all(10.w),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: AppTheme.veryLightGrey,
              ),
              child: Column(
                children: [
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10.w),
                      const Icon(
                        Icons.school,
                        color: AppTheme.secondary,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        thisAppModel.student?.school?.name ?? "",
                        style: AppTheme.textPrimaryMedium,
                      ),
                    ],
                  ),
                  // image
                  Container(
                    height: 210.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: AppTheme.veryLightGrey,
                    ),
                    child: Stack(
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
                          top: 5.h,
                          left: 10.w,
                          right: 10.w,
                          bottom: 10.h,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                    "${Config.serverUrl}${thisAppModel.student?.avatar}"),
                                backgroundColor: AppTheme.veryLightGrey,
                                radius: 30.w,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10.h),
                                child: Column(
                                  children: [
                                    Text(
                                      thisAppModel.student?.name ?? "",
                                      style: AppTheme.textPrimaryLarge,
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      thisAppModel.student?.studentIdentifier ??
                                          "",
                                      style: AppTheme.textDarkBlueSmallLight,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Widget cancelButton = TextButton(
                            child: Text(translation(context)?.cancel ?? "Cancel"),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                          );
                          Widget continueButton = TextButton(
                            child: Text(translation(context)?.continueText ?? "Continue"),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
                              thisAppModel.printStudentCardEndpoint(thisAppModel.student?.id, context);
                            },
                          );
                          AlertDialog alert = AlertDialog(
                            title: Text(translation(context)?.printStudentCard ?? "Print Student Card"),
                            content: Text(translation(context)?.printStudentCardMessage ?? ""),
                            actions: [
                              cancelButton,
                              continueButton,
                            ],
                          );
                          // show the dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return alert;
                            },
                          );
                        },
                        //print
                        icon: thisAppModel.printStudentCardLoadingState.inLoading()
                            ? const CircularProgressIndicator(
                          color: AppTheme.primary,
                          strokeWidth: 2,
                        )
                            :
                        Icon(
                          Icons.print,
                          color: AppTheme.primary,
                          size: 30.sp,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0.w),
                        child: IconButton(
                          onPressed: () {
                            //show QR code in a dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Container(
                                    height: 410.h,
                                    width: 250.w,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 80.h,
                                          width: 80.w,
                                          child: Image.network(
                                              "${Config.serverUrl}${thisAppModel.student?.avatar}"),
                                        ),
                                        SizedBox(height: 10.h),
                                        //name
                                        Text(
                                          thisAppModel.student?.name ?? "",
                                          style: AppTheme.textPrimaryLarge,
                                        ),
                                        SizedBox(height: 10.h),
                                        //school
                                        Text(
                                          thisAppModel.student?.school?.name ?? "",
                                          style: AppTheme.textDarkBlueSmallLight,
                                        ),
                                        SizedBox(height: 20.h),
                                        BarcodeWidget(
                                          barcode: Barcode.qrCode(),
                                          data: '${thisAppModel.student?.studentIdentifier}',
                                          width: 150.w,
                                          height: 150.w,
                                        ),
                                        SizedBox(height: 20.h),
                                        //divider
                                        Divider(
                                          height: 1,
                                          thickness: 1.h,
                                          color: AppTheme.lightGrey,
                                        ),
                                        SizedBox(height: 10.h),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            CupertinoButton(
                                              onPressed: () {
                                                setState(() {
                                                  shareLoading = true;
                                                });
                                                getQrCode(
                                                    "${thisAppModel.student?.studentIdentifier}")
                                                    .then((path) {
                                                  setState(() {
                                                    shareLoading = false;
                                                  });
                                                  Share.shareXFiles([XFile(path)],
                                                      text: "Student QR Code" +
                                                          ' \n' +
                                                          "Name: ${thisAppModel.student?.name}\n" +
                                                          "School: ${thisAppModel.student?.school?.name}\n" +
                                                          "Student ID: ${thisAppModel.student?.studentIdentifier}",
                                                      subject: "Details");
                                                });
                                              },
                                              child: Builder(builder: (context) {
                                                if (!shareLoading) {
                                                  return const Icon(
                                                    Icons.share,
                                                    color: AppTheme.primaryDark,
                                                    size: 25,
                                                  );
                                                } else {
                                                  return const SizedBox(
                                                    height: 25,
                                                    width: 25,
                                                    child: CircularProgressIndicator(
                                                      color: AppTheme.primaryDark,
                                                      strokeWidth: 2,
                                                    ),
                                                  );
                                                }
                                              }),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          icon: Icon(
                            Icons.qr_code_scanner,
                            color: AppTheme.primary,
                            size: 30.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  //status
                ],
              ),
            ),
          ));
    }
  }

  Widget _displayStudentDetails(ThisApplicationViewModel thisAppModel) {
    if (thisAppModel.studentDetailsLoadingState.inLoading()) {
      // loading. display animation
      return loadingScreen(4);
    }
    else {
      // widget with rounded corner image and a card on it
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: 10.w, right: 10.w, top: 10.h, bottom: 5.h),
            child: Text(
              translation(context)?.settings ?? "Settings",
              style: AppTheme.textPrimaryLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  displayAbsence(thisAppModel),
                  SizedBox(height: 10.h),
                  displayNotificationSetting(thisAppModel),
                ]
            ),
          ),
        ],
      );
    }
  }

  Widget _displayAllSections(ThisApplicationViewModel thisAppModel) {
    List<Widget> a = [];
    a.add(_displayTop(thisAppModel));
    a.add(_displayStudentDetails(thisAppModel));
    a.addAll(_displayStudentPickupDropOff(thisAppModel));
    a.add(displayDeleteStudent(thisAppModel));
    return Scaffold(
      appBar: buildAppBar(context, ""),
      body: ListView(
        children: a,
      ),
    );
  }

  void handleNotificationAction(String actionType, ThisApplicationViewModel thisAppModel) {
    LoadingState loadingState;
    switch (actionType) {
      case 'setAbsentStudent':
        loadingState = thisAppModel.setAbsentStudentLoadingState;
        break;
      case 'printStudentCard':
        loadingState = thisAppModel.printStudentCardLoadingState;
        break;
      default:
        return; // Optionally handle unknown action type
    }

    if (loadingState.loadingFinished() && loadingState.loadError != null && loadingState.error != null) {
      Fluttertoast.showToast(
          msg: loadingState.error ?? "",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: AppTheme.primary,
          textColor: Colors.white,
          fontSize: 16.0
      );
      loadingState.loadError = null;
      loadingState.error = null;
    }
  }

  Widget _buildStudentDetailsScreen(
      BuildContext context, ThisApplicationViewModel thisAppModel) {
    handleNotificationAction('setAbsentStudent', thisAppModel);
    handleNotificationAction('printStudentCard', thisAppModel);
    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: () => _refreshData(thisAppModel),
      child: _displayAllSections(thisAppModel),
    );
  }

  @override
  Widget build(context) {
    return Consumer<ThisApplicationViewModel>(
        builder: (context, thisAppModel, child) {
          return _buildStudentDetailsScreen(context, thisAppModel);
        });
  }

  Widget loadingStudentBasicCard() {
    // loading. display animation
    Shimmers shimmer = Shimmers(
      options: ShimmerOptions().basicStudentCardOptions(0.7, 0.5),
    );
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: SizedBox(height: 250.h, child: shimmer),
    );
  }

  Widget loadingScreen(int listLength) {
    // loading. display animation
    Shimmers shimmer = Shimmers(
      options: ShimmerOptions().vListOptions(listLength),
    );
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        height: Tools.getScreenHeight(context) * 0.65,
        child: shimmer);
  }

  List<Widget> _displayStudentPickupDropOff(ThisApplicationViewModel thisAppModel) {
    List<Widget> a = [];
    if (thisAppModel.studentDetailsLoadingState.inLoading()) {
      // loading. display animation
      a.add(loadingScreen(4));
    } else if (thisAppModel.studentDetailsLoadingState.loadingFinished()) {
      //network call finished.
      if (thisAppModel.studentDetailsLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        a.add(failedScreen(
            context, thisAppModel.studentDetailsLoadingState.failState));
      } else {
        DbUser? student;
        student = thisAppModel.student;
        //gui to select pickup stop and drop off stop.
        // the pickup stop must from a morning route.
        // then the system displays to the guardian the available pickup times
        // according to the routes and trips that the pickup stop is in.
        a.addAll(studentPickupDropOffDetails(
            student?.studentDetails, thisAppModel, true));
        a.addAll(studentPickupDropOffDetails(
            student?.studentDetails, thisAppModel, false));
      }
    }
    return a;
  }

  bool checkIfStopIsSet(ThisApplicationViewModel thisAppModel,
      StudentDetailsInfo? studentDetails, bool pickUp) {
    if (thisAppModel.settings?.simpleMode == true) {
      if (pickUp) {
        return (studentDetails?.pickupLat != null &&
            studentDetails?.pickupLng != null);
      }
      else {
        return (studentDetails?.dropOffLat != null &&
            studentDetails?.dropOffLng != null);
      }
    }
    else {
      MyStop.Stop? stop;
      stop = pickUp ? studentDetails?.pickupStop : studentDetails?.dropOffStop;
      if (stop == null) {
        return false;
      }
      return true;
    }
  }

  studentPickupDropOffDetails(StudentDetailsInfo? studentDetails,
      ThisApplicationViewModel thisAppModel, bool pickUp) {
    List<Widget> a = [];

    MyStop.Stop? stop;
    if(thisAppModel.settings?.simpleMode == true) {
      stop = MyStop.Stop();
      if(checkIfStopIsSet(thisAppModel, studentDetails, pickUp)) {
        stop.name =
        pickUp ? studentDetails?.pickupAddress : studentDetails?.dropOffAddress;
        double? lat = pickUp ? studentDetails?.pickupLat : studentDetails
            ?.dropOffLat;
        double? lng = pickUp ? studentDetails?.pickupLng : studentDetails
            ?.dropOffLng;
        stop.address = "Lat: ${Tools.formatDouble(lat, fractionDigits: 5)}, Lng: ${Tools.formatDouble(lng, fractionDigits: 5)}";
        stop.lat = lat.toString();
        stop.lng = lng.toString();
      }
      else {
        if (pickUp) {
          stop.name =
              translation(context)?.selectPickupStop ?? "Select Pickup Stop";
        }
        else {
          stop.name = translation(context)?.selectDropOffStop;
        }
        stop.address = translation(context)?.selectStopForStudent ??
            "Select stop for this student.";
      }
    }
    else {
      stop = pickUp ? studentDetails?.pickupStop : studentDetails?.dropOffStop;
    }
    // add pickup title
    a.add(
      Padding(
        padding:
        EdgeInsets.only(left: 10.w, right: 10.w, top: 10.h, bottom: 5.h),
        child: Text(
          pickUp ? translation(context)?.pickup ?? "Pick Up"
              : translation(context)?.dropOff ?? "Drop Off",
          style: AppTheme.textDarkBlueLarge,
        ),
      ),
    );

    //add card to select pickup stop
    a.add(
      Padding(
        padding:
        EdgeInsets.only(left: 10.w, right: 10.w, top: 10.h, bottom: 5.h),
        child: InkWell(
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // icon
                    Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Icon(
                        Icons.location_on,
                        color: checkIfStopIsSet(
                            thisAppModel, studentDetails, pickUp)
                            ? AppTheme.secondary
                            : AppTheme.normalGrey,
                        size: 40.w,
                      ),
                    ),
                    // text
                    Expanded(
                      child: Padding(
                          padding: EdgeInsets.all(10.w),
                          child: checkIfStopIsSet(
                              thisAppModel, studentDetails, pickUp)
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stop?.name ?? "",
                                style: AppTheme.textDarkBlueMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                stop?.address ?? "",
                                style: AppTheme.textDarkBlueSmallLight,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ):Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pickUp
                                    ? (translation(context)?.selectPickupStop ?? "Select Pickup Stop")
                                    : (translation(context)?.selectDropOffStop ?? "Select Drop Off Stop"),
                                style: AppTheme.textGreyMedium,
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                pickUp
                                    ? (translation(context)?.selectPickupStopStudent ?? "Select pickup stop for this student.")
                                    : (translation(context)?.selectDropOffStopStudent ?? "Select drop off stop for this student."),
                                style: AppTheme.textGreySmall,
                              ),
                            ],
                          )
                      ),
                    ),
                  ],
                ),
                //divider
                checkIfStopIsSet(thisAppModel, studentDetails, pickUp)
                    ? Divider(
                  height: 5,
                  thickness: 1.h,
                  color: AppTheme.lightGrey,
                )
                    : Container(),
                //actions
                checkIfStopIsSet(thisAppModel, studentDetails, pickUp) ?
                Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      thisAppModel.settings?.simpleMode == false ?
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TripTimelineScreen(
                                        tripID: pickUp
                                            ? studentDetails
                                            ?.pickupTrip?.id
                                            : studentDetails
                                            ?.dropOffTrip?.id,
                                        startStopID: pickUp
                                            ? studentDetails
                                            ?.pickupStop?.id
                                            : null,
                                        endStopID: pickUp
                                            ? null
                                            : studentDetails
                                            ?.dropOffStop?.id,
                                        pickUp: pickUp,
                                      )));
                        },
                        icon: const Icon(
                          Icons.route,
                          color: AppTheme.primary,
                        ),
                      ) : Container(),
                      IconButton(
                        onPressed: () {
                          if(checkIfStopIsSet(thisAppModel, studentDetails, pickUp)) {
                            // go to stop screen
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        StopLocationScreen(
                                          stop: stop,
                                        )));
                          }
                        },
                        icon: Icon(
                          Icons.location_on,
                          color:checkIfStopIsSet(thisAppModel, studentDetails, pickUp)
                              ? AppTheme.primary
                              : AppTheme.normalGrey,
                        ),
                      ),
                    ],
                  ),
                )
                    : Container(),
              ],
            ),
          ),
          onTap: () async {
            if (exitIfNotParent(thisAppModel)) {
              return;
            }
            // var prediction = await PlacesAutocomplete
            //     .show(
            //   context: context,
            //   apiKey: Config.googleApikey,
            //   mode: Mode.overlay,
            //   types: [],
            //   strictbounds: false,
            //   components: [],
            //   //google_map_webservice package
            //   onError: (err) {
            //     if (kDebugMode) {
            //       print(err);
            //     }
            //   },
            // );

            // if (prediction != null) {
            //   setState(() {
            //     setState(() {
            //       thisAppModel.mapData?.currentAddress =
            //           prediction.description.toString();
            //     });
            //   });
              //form google_maps_webservice package
              // final plist = GoogleMapsPlaces(
              //   apiKey: Config.googleApikey,
              //   apiHeaders: await const GoogleApiHeaders().getHeaders(),
              //   //from google_api_headers package
              // );
              // String placeId = prediction.placeId ?? "0";
              // final detail = await plist.getDetailsByPlaceId(placeId);
              // final geometry = detail.result?.geometry;
              // final double? lat = geometry?.location.lat;
              // final double? lang = geometry?.location.lng;
              // final String? address = detail.result?.formattedAddress;
              // setState(() {
              //   thisAppModel.mapData?.currentLatLng =
              //       LatLng(lat!, lang!);
              // });

              // if (kDebugMode) {
              //   print("lat: $lat, lang: $lang");
              // }
          //     if (thisAppModel.settings?.simpleMode == true) {
          //       Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //               builder: (context) =>
          //                   ChooseLocationScreen(
          //                     lat: lat,
          //                     lng: lang,
          //                     pickUp: pickUp,
          //                     address: address,
          //                     student: thisAppModel.student,
          //                   ))
          //       );
          //     } else {
          //       Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //               builder: (builderContext) =>
          //                   PickupDropOffStopsScreen(
          //                     lat: lat,
          //                     lang: lang,
          //                     pickUp: pickUp,
          //                     student: thisAppModel.student,
          //                   )));
          //     }
          //   }
          },
        ),
      ),
    );
    return a;
  }

  Widget displayQrCode(ThisApplicationViewModel thisAppModel) {
    // widget with rounded corner image and a card on it
    if (thisAppModel.studentDetailsLoadingState.loadingFinished()) {
      return StudentDetailCard(
        icon: FontAwesomeIcons.qrcode,
        title: 'QR Code',
        onTap: () {
          //show QR code in a dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Container(
                  height: 410.h,
                  width: 250.w,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 60.h,
                        width: 60.w,
                        child: Image.network(
                            "${Config.serverUrl}${thisAppModel.student?.avatar}"),
                      ),
                      SizedBox(height: 10.h),
                      //name
                      Text(
                        thisAppModel.student?.name ?? "",
                        style: AppTheme.textDarkBlueLarge,
                      ),
                      SizedBox(height: 10.h),
                      //school
                      Text(
                        thisAppModel.student?.school?.name ?? "",
                        style: AppTheme.textDarkBlueSmallLight,
                      ),
                      SizedBox(height: 20.h),
                      BarcodeWidget(
                        barcode: Barcode.qrCode(),
                        data: '${thisAppModel.student?.studentIdentifier}',
                        width: 150.w,
                        height: 150.h,
                      ),
                      SizedBox(height: 20.h),
                      //divider
                      Divider(
                        height: 1,
                        thickness: 1.h,
                        color: AppTheme.lightGrey,
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CupertinoButton(
                            onPressed: () {
                              setState(() {
                                shareLoading = true;
                              });
                              getQrCode(
                                  "${thisAppModel.student?.studentIdentifier}")
                                  .then((path) {
                                setState(() {
                                  shareLoading = false;
                                });
                                Share.shareXFiles([XFile(path)],
                                    text: "Student QR Code" +
                                        ' \n' +
                                        "Name: ${thisAppModel.student?.name}\n" +
                                        "School: ${thisAppModel.student?.school?.name}\n" +
                                        "Student ID: ${thisAppModel.student?.studentIdentifier}",
                                    subject: "Details");
                              });
                            },
                            child: Builder(builder: (context) {
                              if (!shareLoading) {
                                return const Icon(
                                  Icons.share,
                                  color: AppTheme.primaryDark,
                                  size: 25,
                                );
                              } else {
                                return const SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                    color: AppTheme.primaryDark,
                                    strokeWidth: 2,
                                  ),
                                );
                              }
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        tapAnimation: true,
      );
    } else {
      return Container();
    }
  }
  Widget displayDeleteStudent(ThisApplicationViewModel thisAppModel) {
    if (thisAppModel.studentDetailsLoadingState.loadingFinished()) {
      // delete student button
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          // style: ElevatedButton.styleFrom(
          //   primary: Colors.red,
          //   onPrimary: Colors.white,
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(10.0),
          //   ),
          // ),
          onPressed: () {
            if(exitIfNotParent(thisAppModel)) {
              return;
            }
            Widget cancelButton = TextButton(
              child: Text(translation(context)?.cancel ?? "Cancel"),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            );
            Widget continueButton = TextButton(
              child: Text(translation(context)?.continueText ?? "Continue"),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                thisAppModel.deleteStudentEndpoint(thisAppModel.student?.id, context);
              },
            );
            AlertDialog alert = AlertDialog(
              title: Text(translation(context)?.warning ?? "Warning"),
              content: Text(translation(context)?.deleteStudentWarning ?? "Are you sure that you want to delete this student?"),
              actions: [
                cancelButton,
                continueButton,
              ],
            );
            // show the dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return alert;
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(translation(context)?.deleteStudent ?? "Delete Student", style: AppTheme.textWhiteMedium),
                SizedBox(width: 10.w),
                thisAppModel.deleteStudentLoadingState.inLoading() ?
                SizedBox(
                  height: 20.h,
                  width: 20.w,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 4,
                  ),
                ) : const Icon(Icons.delete, color: Colors.white),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
  Widget displayNotificationSetting(ThisApplicationViewModel thisAppModel) {
    if (thisAppModel.studentDetailsLoadingState.loadingFinished()) {
      return StudentDetailCard(
        icon: FontAwesomeIcons.solidBell,
        title: translation(context)?.notificationSettings ?? "Notification Settings",
        subtitle: translation(context)?.adjustNotificationSettings ?? "Set notification settings for this student",
        onTap: () {
          if(exitIfNotParent(thisAppModel)) {
            return;
          }
          // go to notification settings screen
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      NotificationSettingsScreen(
                        student: thisAppModel.student,
                      )));
        },
        tapAnimation: true,
      );
    } else {
      return Container();
    }
  }

  Widget displayAbsence(ThisApplicationViewModel thisAppModel) {
    if (thisAppModel.studentDetailsLoadingState.loadingFinished()) {
      return StudentDetailCard(
        icon: FontAwesomeIcons.userTimes,
        title: thisAppModel.setAbsentStudentLoadingState.inLoading() ?
        (translation(context)?.updatingStatus ?? "Updating status...") :
        (thisAppModel.student?.studentDetails?.absentOn != null ?
        (translation(context)?.absent ?? "Absent") :
        (translation(context)?.notAbsent ?? "Not Absent")),
        subtitle: thisAppModel.setAbsentStudentLoadingState.inLoading() ? ("Please wait...") :
        (thisAppModel.student?.studentDetails?.absentOn != null ?
        thisAppModel.student?.studentDetails?.absentOn??"": ("${translation(context)?.studentIsNotAbsent ?? "studentIsNotAbsent"}:${DateTime.now().toString().substring(0,10)}")),
        titleStyle: thisAppModel.setAbsentStudentLoadingState.inLoading() ? AppTheme.subCaptionSecondary : (thisAppModel.student?.studentDetails?.absentOn != null ? AppTheme.textRedMedium : AppTheme.textDarkBlueMedium),
        onTap: () {
          if(exitIfNotParent(thisAppModel)) {
            return;
          }
          Widget cancelButton = TextButton(
            child: Text(translation(context)?.cancel ?? "Cancel"),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          );
          Widget continueButton = TextButton(
            child: Text(translation(context)?.continueText ?? "Continue"),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              thisAppModel.setAbsentStudentEndpoint(thisAppModel.student?.id);
            },
          );
          AlertDialog alert = AlertDialog(
            title: Text(translation(context)?.warning ?? "Warning"),
            content: Text(
                thisAppModel.student?.studentDetails?.absentOn != null ?
                translation(context)?.areYouSureNotAbsent ?? "Are you sure that you want to mark this student as not absent?"
                    : translation(context)?.areYouSureAbsent ?? "Are you sure that you want to mark this student as absent?"),
            actions: [
              cancelButton,
              continueButton,
            ],
          );
          // show the dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        },
        tapAnimation: true,
      );
    } else {
      return Container();
    }
  }

  bool exitIfNotParent(thisAppModel) {
    if(thisAppModel.currentUser?.role == 5) {
      Fluttertoast.showToast(
          msg: "You are not allowed to change this setting. Please contact the parent.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: AppTheme.primary,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return true;
    }
    else {
      return false;
    }
  }
}
