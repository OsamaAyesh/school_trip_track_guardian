import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:school_trip_track_guardian/gui/screens/add_edit_student_screen.dart';
import 'package:flutter/material.dart';
import 'package:school_trip_track_guardian/gui/screens/student_details_screen.dart';
import 'package:school_trip_track_guardian/gui/widgets/SchoolFromTo/schoolFromToDashedLine.dart';
import 'package:school_trip_track_guardian/gui/widgets/SchoolFromTo/schoolFromToEmptySpace.dart';
import 'package:school_trip_track_guardian/gui/widgets/SchoolFromTo/schoolFromToMarker.dart';
import 'package:school_trip_track_guardian/gui/widgets/SchoolFromTo/schoolFromToSchool.dart';
import 'package:school_trip_track_guardian/gui/widgets/SchoolFromTo/schoolFromToWidget.dart';
import 'package:school_trip_track_guardian/gui/screens/track_school_bus_screen.dart';
import 'package:school_trip_track_guardian/services/service_locator.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:school_trip_track_guardian/utils/size_config.dart';
import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../../connection/utils.dart';
import '../../model/constant.dart';
import '../../model/place.dart';
import '../../model/reservation.dart';
import '../../model/user.dart';
import '../../utils/config.dart';
import '../../utils/tools.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';
import '../widgets/my_interstitial_ad.dart';
import '../widgets/no_animation_page_route.dart';
import '../widgets/shimmers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_trip_track_guardian/gui/widgets/direction_positioned.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);
  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  ThisApplicationViewModel thisApplicationModel = serviceLocator<ThisApplicationViewModel>();
  bool isLoading = false;
  bool activePostsFound = false;

  bool serviceStatus = false;
  bool hasPermission = false;

  Position? currentGPSLocation;
  bool? locationServiceStatus;

  @override
  void initState() {
    thisApplicationModel.allStudentsLoadingState.loadState = ScreenState.LOADING;
    MyInterstitialAd.createInterstitialAd();
    checkLocationService(context).then((LocationServicesStatus value) {
      locationServiceStatus = value == LocationServicesStatus.enabled;
      if(locationServiceStatus!= null && locationServiceStatus!) {
        getLocation().then((value) {
        currentGPSLocation = value;
      });
      }
    });
    if(thisApplicationModel.isLoggedIn != true) {
      thisApplicationModel.clearAllUserData();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      thisApplicationModel.getAllStudentsEndpoint();
      //get notifications
      thisApplicationModel.getNotificationsEndpoint();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    MyInterstitialAd.dispose();
  }

  void _setData(ThisApplicationViewModel thisAppModel) {
    thisAppModel.getAllStudentsEndpoint();
    //get notifications
    thisAppModel.getNotificationsEndpoint();
  }

  Future<void> _refreshData(ThisApplicationViewModel thisAppModel) {
    return Future(
            () {
          _setData(thisAppModel);
        }
    );
  }

  Widget _displayTop(ThisApplicationViewModel thisAppModel) {
    // widget with rounded corner image and a card on it
    return SafeArea(
      minimum: const EdgeInsets.only(top: 25),
      child: Padding(
          padding: EdgeInsets.only(bottom: 40.h),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // row to add text "students and button +
                Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        translation(context)?.students ?? "Students",
                        style: AppTheme.headlineBig,
                      ),
                    ],
                  ),
                ),
              ])
      ),
    );
  }

  Widget _displayAllSections(ThisApplicationViewModel thisAppModel) {
    List<Widget> a = [];
    a.add(_displayTop(thisAppModel));
    a.addAll(_displayStudents(thisAppModel));
    return Scaffold(
        body: ListView(
          children: a,
        ),
        floatingActionButton: thisAppModel.currentUser?.role == 4 && !thisAppModel.allStudentsLoadingState.inLoading() ?
        ElevatedButton(
          style: floatButtonStyle(),
          onPressed: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddEditStudentScreen()
                )
            );
          },
          child: floatButtonAddIcon(),
        ) : null
    );
  }

  Widget _buildHomeTab(BuildContext context, ThisApplicationViewModel thisAppModel) {
    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: ()=>_refreshData(thisAppModel),
      child: _displayAllSections(thisAppModel),
    );
  }

  @override
  Widget build(context) {
    return Consumer<ThisApplicationViewModel>(
        builder: (context, thisAppModel,  child) {
          return _buildHomeTab(context, thisAppModel);
        });
  }

  Widget loadingScreen() {
    // loading. display animation
    Shimmers shimmer = Shimmers(
      options: ShimmerOptions().vListOptions(4),
    );
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        height: Tools.getScreenHeight(context) * 0.65,
        child:shimmer
    );
  }

  Future pushWithoutAnimation<T extends Object>(Widget page, BuildContext context) {
    Route route = NoAnimationPageRoute(builder: (BuildContext context) => page);
    return Navigator.push(context, route);
  }

  List<Widget> _displayStudents(ThisApplicationViewModel thisAppModel) {
    List<Widget> a = [];
    if (thisAppModel.allStudentsLoadingState.inLoading()) {
      // loading. display animation
      a.add(loadingScreen());
    }
    else if (thisAppModel.allStudentsLoadingState.loadingFinished()) {
      //network call finished.
      if (thisAppModel.allStudentsLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        a.add(failedScreen(
            context,
            thisAppModel.allStudentsLoadingState.failState));
      }
      else {
        List<DbUser> allStudents;
        allStudents = thisAppModel.allStudents;
        if (allStudents.isEmpty) {
          a.add(emptyStudentsScreen());
        }
        else {
          List<Widget> studentsList = studentsListScreen(allStudents, thisAppModel);
          a.add(
            Padding(padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 5.h, bottom: 70.h),
              child: Column(
                children: studentsList,
              ),
            ),
          );
        }
      }
    }
    return a;
  }

  studentsListScreen(List<DbUser> allStudents, ThisApplicationViewModel thisAppModel) {
    Map<String, List<DbUser>> studentsMap = {};
    //group based on school
    for (int i = 0; i < allStudents.length; i++) {
      if (studentsMap.containsKey(allStudents[i].school?.name ?? "")) {
        studentsMap[allStudents[i].school?.name ?? ""]!.add(allStudents[i]);
      }
      else {
        studentsMap[allStudents[i].school?.name ?? ""] = [allStudents[i]];
      }
    }

    List<Widget> list = [];
    for (int j = 0; j < studentsMap.length; j++) {
      //add school name
      list.add(
        Padding(
          padding: EdgeInsets.only(
              left: 10.w, right: 10.w, top: 10.h, bottom: 10.h),
          child: Row(
            children: [
              const Icon(
                Icons.school,
                color: AppTheme.secondary,
              ),
              SizedBox(width: 10.w),
              Text(
                studentsMap.keys.elementAt(j),
                style: AppTheme.textPrimaryLarge,
              ),
            ],
          ),
        ),
      );
      for (int i = 0; i < studentsMap.values
          .elementAt(j)
          .length; i++) {
        var student = studentsMap.values.elementAt(j)[i];
        String statusStr = "";
        if (student.status == 4) {
          list.add(childInReviewRejected(student));
        }
        else if (student.status == 2) {
          list.add(
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AddEditStudentScreen(
                                student: student,
                              )));
                },
                child: childInReviewRejected(student, rejected: true),
              ));
        }
        else if (student.status == 3) {
          list.add(childInReviewRejected(student, suspended: true));
        }
        else if (student.status == 5) {
          list.add(childInReviewRejected(student, outOfCredit: true));
        }
        else {
          list.add(
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    MyInterstitialAd.showInterstitialAd();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                StudentDetails(
                                  studentId: student.id!,
                                )));
                  },
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13.0),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30.w,
                                backgroundColor: Colors.transparent,
                                backgroundImage: NetworkImage(
                                    "${Config.serverUrl}${student
                                        .avatar}"),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                student.name ?? "",
                                style: AppTheme.textPrimaryLarge,
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  MyInterstitialAd.showInterstitialAd();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              StudentDetails(
                                                studentId: student.id!,
                                              )));
                                },
                                icon: const Icon(
                                  Icons.info_outline,
                                  color: AppTheme.primary,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        thisAppModel.settings?.simpleMode == false ?
                        SchoolFromToWidget(
                          children: [
                            SchoolFromToMarker(
                              color: AppTheme.secondary,
                              bottom: Text(
                                Tools.formatTime(
                                    student.studentDetails
                                        ?.pickupPickTime ?? ""),
                                style: AppTheme.textPrimarySmall,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SchoolFromToDashedLine(),
                            SchoolFromToSchool(
                              color: AppTheme.secondary,
                              bottom: Text(
                                Tools.formatTime(
                                    student.studentDetails
                                        ?.pickupDropTime ?? ""),
                                style: AppTheme.textPrimarySmall,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SchoolFromToEmptySpace(
                              widthParam: 20.w,
                            ),
                            SchoolFromToSchool(
                              color: AppTheme.secondary,
                              bottom: Text(
                                Tools.formatTime(
                                    student.studentDetails
                                        ?.dropOffPickTime ?? ""),
                                style: AppTheme.textPrimarySmall,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SchoolFromToDashedLine(),
                            SchoolFromToMarker(
                              color: AppTheme.secondary,
                              bottom: Text(
                                Tools.formatTime(
                                    student.studentDetails
                                        ?.dropOffDropTime ?? ""),
                                style: AppTheme.textPrimarySmall,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ) : Container(),
                        Builder(
                            builder: (context) {
                              if (student.status == 1) {
                                if (student.studentDetails?.absentOn !=
                                    null && student.studentDetails
                                    ?.absentOn != "") {
                                  String statusStr = "";
                                  statusStr =
                                  "Absent on ${student.studentDetails
                                      ?.absentOn}";
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: 10.w, right: 10.w, top: 1.h,
                                        bottom: 10.h),
                                    child: Text(
                                      'Absent until ${statusStr}',
                                      style: AppTheme.textPrimaryMedium
                                          .copyWith(
                                        color: Colors.red,
                                      ),
                                    ),
                                  );
                                }
                              }
                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    SizedBox(width: 1.w),
                                    OutlinedButton(
                                      onPressed: () {
                                        MyInterstitialAd.showInterstitialAd();
                                        if (checkIfNoTracking(student, thisAppModel, true)) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    translation(context)?.morningBusNotAssigned ?? "Morning bus is not assigned to the student."),
                                                duration: const Duration(seconds: 3),
                                              ));
                                        }
                                        else {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TrackSchoolBusScreen(
                                                        student: student,
                                                        morning: true,
                                                      )));
                                        }
                                      },
                                      //outline
                                      style:
                                      // checkIfNoTracking(student, thisAppModel, true) ?
                                      // ElevatedButton.styleFrom(
                                      //   primary: AppTheme.normalGrey,
                                      //   shape: RoundedRectangleBorder(
                                      //     borderRadius: BorderRadius.circular(
                                      //         10.r),
                                      //   ),
                                      // )
                                      //     :
                                      OutlinedButton.styleFrom(
                                        side: BorderSide(
                                            color: AppTheme.secondary,
                                            width: 1.w),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10.r),
                                        ),
                                      ),
                                      child: Wrap(
                                        crossAxisAlignment: WrapCrossAlignment
                                            .center,
                                        children: [
                                          Text(
                                            translation(context)?.morning ?? "Morning",
                                            style: AppTheme.textPrimarySmall,
                                          ),
                                          SizedBox(width: 5.w),
                                          const Icon(
                                            FontAwesomeIcons.bus,
                                            color: AppTheme.primary,
                                            size: 25,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 5.w),
                                    OutlinedButton(
                                      onPressed: () {
                                        MyInterstitialAd.showInterstitialAd();
                                        if (checkIfNoTracking(student, thisAppModel, false)) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    translation(context)?.afternoonBusNotAssigned ?? "Afternoon bus is not assigned to the student."),
                                                duration: const Duration(seconds: 3),
                                              ));
                                        }
                                        else {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TrackSchoolBusScreen(
                                                        student: student,
                                                        morning: false,
                                                      )));
                                        }
                                      },
                                      //outline
                                      style:
                                      // checkIfNoTracking(student, thisAppModel, false) ?
                                      // ElevatedButton.styleFrom(
                                      //   primary: AppTheme.normalGrey,
                                      //   shape: RoundedRectangleBorder(
                                      //     borderRadius: BorderRadius.circular(
                                      //         10.r),
                                      //   ),
                                      // ) :
                                      OutlinedButton.styleFrom(
                                        side: BorderSide(
                                            color: AppTheme.secondary,
                                            width: 1.w),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10.r),
                                        ),
                                      ),
                                      child: Wrap(
                                        crossAxisAlignment: WrapCrossAlignment
                                            .center,
                                        children: [
                                          Text(
                                            translation(context)?.afternoon ?? "Afternoon",
                                            style: AppTheme.textPrimarySmall,
                                          ),
                                          SizedBox(width: 5.w),
                                          const Icon(
                                            FontAwesomeIcons.bus,
                                            color: AppTheme.primary,
                                            size: 25,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 1.w),
                                  ],
                                ),
                              );
                            }
                        ),
                      ],
                    ),
                  ),
                ),
              )
          );
        }
      }
    }
    return list;
  }

  checkIfNoTracking(student, thisAppModel, pickup) {
    if (thisAppModel.settings?.simpleMode == true) {
      if (pickup) {
        return (student?.studentDetails == null ||
            student?.studentDetails.pickupLat == null ||
            student?.studentDetails.pickupLat == "" ||
            student?.studentDetails.pickupLng == null ||
            student?.studentDetails.pickupLng == "" ||
            student?.studentDetails.morningBusId == null ||
            student?.studentDetails.morningBusId == "");
      }
      else {
        return (student?.studentDetails == null ||
            student?.studentDetails.dropOffLat == null ||
            student?.studentDetails.dropOffLat == "" ||
            student?.studentDetails.dropOffLng == null ||
            student?.studentDetails.dropOffLng == "" ||
            student?.studentDetails.afternoonBusId == null ||
            student?.studentDetails.afternoonBusId == "");
      }
    }
    else {
      if (pickup) {
        return (student?.studentDetails
            ?.pickupPickTime == null ||
            student?.studentDetails
                ?.pickupPickTime == "" ||
            student?.studentDetails
                ?.pickupDropTime == null ||
            student?.studentDetails
                ?.pickupDropTime == "");
      }
      else {
        return (student?.studentDetails
            ?.dropOffPickTime == null ||
            student?.studentDetails
                ?.dropOffPickTime == "" ||
            student?.studentDetails
                ?.dropOffDropTime == null ||
            student?.studentDetails
                ?.dropOffDropTime == "");
      }
    }
  }

  Widget childInReviewRejected(DbUser student, {bool rejected=false, bool suspended=false, bool outOfCredit=false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.r),
          ),
          color: AppTheme.lightGrey,
          child: SizedBox(
              width: SizeConfig.screenWidth,
              height: 130.h,
              child:Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 10.h,
                    left: 10.w,
                    child: CircleAvatar(
                      radius: 30.w,
                      backgroundColor: AppTheme.lightGrey,
                      backgroundImage: student.avatar != null ? NetworkImage(
                          "${Config.serverUrl}${student.avatar}") : null,
                    ),
                  ),
                  Positioned(
                    top: 10.h+20.w,
                    left: 80.w,
                    child: Text(
                      student.name ?? "",
                      style: AppTheme.textPrimaryLarge,
                    ),
                  ),
                  Positioned(
                    bottom: 10.h,
                    left: 10.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              (rejected || suspended || outOfCredit)?Icons.cancel_outlined:Icons.info_outline,
                              color: rejected||outOfCredit?Colors.red:AppTheme.lightPrimary,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              getStatusText(rejected, suspended, outOfCredit),
                              style: AppTheme.textPrimaryMedium.copyWith(
                                color: rejected||outOfCredit?Colors.red:AppTheme.lightPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.h),
                        rejected ? Text(
                          student.registrationResponse ?? "",
                          style: AppTheme.textPrimarySmall,
                        ) : Container(),
                      ],
                    ),
                  )
                ],
              )
          )
      ),
    );
  }

  //emptyStudentsScreen
  Widget emptyStudentsScreen() {
    return Center(
      // image
      child: Column(
        children: [
          SizedBox(height: 30.h),
          SizedBox(
            height: 250.h,
            width: 250.w,
            child: Image.asset("assets/images/img_no_students.png",
                alignment: Alignment.center),
          ),
          SizedBox(height: 30.h),
          Text(
            translation(context)?.noStudents ?? "No students found",
            style: AppTheme.textPrimaryLarge,
          ),
          SizedBox(height: 30.h),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              translation(context)?.noStudentsYet ?? "No students found. Please add students to your account.",
              style: AppTheme.textSecondaryMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String getStatusText(bool rejected, bool suspended, bool outOfCredit) {
    //rejected?'Rejected':(suspended?'Suspended':outOfCredit?'Out of credit':'Under review'),
    if (rejected) {
      return translation(context)?.rejected ?? 'Rejected';
    }
    else if (suspended) {
      return translation(context)?.suspended ?? 'Suspended';
    }
    else if (outOfCredit) {
      return translation(context)?.outOfCredit ?? 'Out of credit';
    }
    else {
      return translation(context)?.underReview ?? 'Under review';
    }
  }
}
