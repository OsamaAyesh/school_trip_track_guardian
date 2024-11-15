
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
import '../../utils/config.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({this.student, Key? key}) : super(key: key);
  final DbUser? student;
  @override
  NotificationSettingsScreenState createState() => NotificationSettingsScreenState();
}

class NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  ThisApplicationViewModel thisAppModel =
      serviceLocator<ThisApplicationViewModel>();

  List<Map<String, dynamic>> allNotificationsSettings = [];

  bool? nextStopIsYourPickupLocationNotificationOnOff, studentIsPickedUpNotificationOnOff,
      studentIsMissedPickupNotificationOnOff, busNearDropOffLocationNotificationOnOff,
      busArrivedAtPickupLocationNotificationOnOff, busArrivedAtDropOffLocationNotificationOnOff,
      busArrivedAtSchoolNotificationOnOff;
  int? busNearPickupLocationNotificationByDistance;

  @override
  void initState() {
    super.initState();
    thisAppModel.updateStudentNotificationSettingsLoadingState.error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadNotificationSettings();
    });
  }

  Widget displayAllNotificationSettings() {
    return Consumer<ThisApplicationViewModel>(
      builder: (context, thisApplicationViewModel, child) {
        if (thisApplicationViewModel
            .updateStudentNotificationSettingsLoadingState.loadState ==
            ScreenState.FINISH
            && thisApplicationViewModel
                .updateStudentNotificationSettingsLoadingState.error != null) {
          Fluttertoast.showToast(
              msg: thisApplicationViewModel
                  .updateStudentNotificationSettingsLoadingState.error
                  .toString(),
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: AppTheme.primary,
              textColor: Colors.white,
              fontSize: 16.0
          );
          thisAppModel.updateStudentNotificationSettingsLoadingState.error =
          null;
        }
        return Scaffold(
          appBar: buildAppBar(
              context, translation(context)?.notificationSettings ??
              'Notification Settings'),
          body: Padding(
            padding: EdgeInsets.only(bottom: 36.0.h),
            child: ListView.builder(
              itemCount: allNotificationsSettings.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          allNotificationsSettings[i]["title"],
                          style: AppTheme.textPrimaryMedium,
                        ),
                        subtitle: allNotificationsSettings[i]["type"] == "int" ?
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            allNotificationsSettings[i]["value"] == null
                                ? "Off"
                                : "${allNotificationsSettings[i]["value"]} m",
                            style: AppTheme.coloredSubtitle,
                          ),
                        ) : null,
                        trailing: //switch
                        allNotificationsSettings[i]["type"] == "int"
                            ? const Icon(Icons.arrow_forward_ios_outlined) : Switch(
                          value: allNotificationsSettings[i]["value"] ?? false,
                          onChanged: (value) {
                            setState(() {
                              allNotificationsSettings[i]["value"] = value;
                            });
                          },
                          activeTrackColor: AppTheme.grey_40,
                          activeColor: AppTheme.primary,
                        ),
                        onTap: () {
                          if (allNotificationsSettings[i]["type"] == "int") {
                            //show dialog with distances
                            showDialog(
                                context: context,
                                builder: (dialogContext) {
                                  return AlertDialog(
                                    title: Text(
                                      translation(context)
                                          ?.busNearPickupLocationNotificationByDistance ??
                                          'Bus Near Pickup Location Notification By Distance',
                                      style: AppTheme.bold20Black,
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            busNearPickLocationSelection("Off", () {
                                              allNotificationsSettings[i]["value"] =
                                              null;
                                            },
                                                allNotificationsSettings[i]["value"] ==
                                                    null, dialogContext),
                                            busNearPickLocationSelection(
                                                "100 m", () {
                                              allNotificationsSettings[i]["value"] =
                                              100;
                                            },
                                                allNotificationsSettings[i]["value"] ==
                                                    100, dialogContext),
                                            busNearPickLocationSelection(
                                                "500 m", () {
                                              allNotificationsSettings[i]["value"] =
                                              500;
                                            },
                                                allNotificationsSettings[i]["value"] ==
                                                    500, dialogContext),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            busNearPickLocationSelection(
                                                "1000 m", () {
                                              allNotificationsSettings[i]["value"] =
                                              1000;
                                            },
                                                allNotificationsSettings[i]["value"] ==
                                                    1000, dialogContext),
                                            busNearPickLocationSelection(
                                                "1500 m", () {
                                              allNotificationsSettings[i]["value"] =
                                              1500;
                                            },
                                                allNotificationsSettings[i]["value"] ==
                                                    1500, dialogContext),
                                            busNearPickLocationSelection(
                                                "2000 m", () {
                                              allNotificationsSettings[i]["value"] =
                                              2000;
                                            },
                                                allNotificationsSettings[i]["value"] ==
                                                    2000, dialogContext),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          floatingActionButton: ElevatedButton(
            style: floatButtonStyle(),
            onPressed: () {
              //save notification settings
              thisApplicationViewModel
                  .updateStudentNotificationSettingsEndpoint(
                  widget.student?.id,
                  allNotificationsSettings, context);
            },
            child: thisApplicationViewModel
                .updateStudentNotificationSettingsLoadingState.inLoading()
                ? const CircularProgressIndicator(
              color: Colors.white,
            )
                : Container(
              width: 30.w,
              height: 30.h,
                  child: Icon(Icons.save, color: AppTheme.backgroundColor,
              size: 25.w,),
                ),
          ),
        );
      },
    );
  }

  @override
  Widget build(context) {
    return displayAllNotificationSettings();
  }

  Widget busNearPickLocationSelection(text, setNotificationValue, selected, BuildContext context)
  {
    return TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(AppTheme.primary),
        backgroundColor: selected ? MaterialStateProperty.all<Color>(AppTheme.lightGrey) : null,
      ),
      onPressed: () {
        setState(setNotificationValue);
        Navigator.pop(context);
      },
      child: Text(
        text,
        style: AppTheme.textPrimaryMedium,
      ),
    );
  }

  void loadNotificationSettings() {
    busArrivedAtPickupLocationNotificationOnOff = widget.student?.studentDetails?.busArrivedAtPickupLocationNotificationOnOff;
    busArrivedAtDropOffLocationNotificationOnOff = widget.student?.studentDetails?.busArrivedAtDropOffLocationNotificationOnOff;
    nextStopIsYourPickupLocationNotificationOnOff = widget.student?.studentDetails?.nextStopIsYourPickupLocationNotificationOnOff;
    studentIsPickedUpNotificationOnOff = widget.student?.studentDetails?.studentIsPickedUpNotificationOnOff;
    busArrivedAtSchoolNotificationOnOff = widget.student?.studentDetails?.busArrivedAtSchoolNotificationOnOff;
    studentIsMissedPickupNotificationOnOff = widget.student?.studentDetails?.studentIsMissedPickupNotificationOnOff;
    busNearPickupLocationNotificationByDistance = widget.student?.studentDetails?.busNearPickupLocationNotificationByDistance;
    busNearDropOffLocationNotificationOnOff = widget.student?.studentDetails?.busNearDropOffLocationNotificationOnOff;
    setState(() {
      if(thisAppModel.settings?.simpleMode == true)
        {
          allNotificationsSettings = [
            {
              "title": translation(context)
                  ?.studentIsPickedUpNotification ??
                  "Student is picked up Notification",
              "value": studentIsPickedUpNotificationOnOff,
              "key_name": "student_is_picked_up_notification_on_off",
              "type": "bool"
            },
            {
              "title": translation(context)?.studentIsMissedPickupNotification ??
                  'Student is missed pickup Notification',
              "value": studentIsMissedPickupNotificationOnOff,
              "key_name": "student_is_missed_pickup_notification_on_off",
              "type": "bool"
            },
            {
              "title": translation(context)
                  ?.busArrivedAtPickupLocationNotification ??
                  'Bus Arrived At Pickup Location Notification',
              "value": busArrivedAtPickupLocationNotificationOnOff,
              "key_name": "bus_arrived_at_pickup_location_notification_on_off",
              "type": "bool"
            },
            {
              "title": translation(context)
                  ?.busArrivedAtDropOffLocationNotification ??
                  'Bus Arrived At Drop Off Location Notification',
              "value": busArrivedAtDropOffLocationNotificationOnOff,
              "key_name": "bus_arrived_at_drop_off_location_notification_on_off",
              "type": "bool"
            },
          ];
        }
      else {
        allNotificationsSettings = [
          {
            "title": translation(context)
                ?.busNearPickupLocationNotificationByDistance ??
                'Bus Near Pickup Location Notification By Distance',
            "value": busNearPickupLocationNotificationByDistance,
            "key_name": "bus_near_pickup_location_notification_by_distance",
            "type": "int"
          },
          {
            "title": translation(context)
                ?.nextStopIsYourPickupLocationNotification ??
                'Next Stop Is Your Pickup Location Notification',
            "value": nextStopIsYourPickupLocationNotificationOnOff,
            "key_name": "next_stop_is_your_pickup_location_notification_on_off",
            "type": "bool"
          },
          {
            "title": translation(context)
                ?.busArrivedAtPickupLocationNotification ??
                'Bus Arrived At Pickup Location Notification',
            "value": busArrivedAtPickupLocationNotificationOnOff,
            "key_name": "bus_arrived_at_pickup_location_notification_on_off",
            "type": "bool"
          },
          {
            "title": translation(context)
                ?.studentIsPickedUpNotification ??
                "Student is picked up Notification",
            "value": studentIsPickedUpNotificationOnOff,
            "key_name": "student_is_picked_up_notification_on_off",
            "type": "bool"
          },
          {
            "title": translation(context)?.studentIsMissedPickupNotification ??
                'Student is missed pickup Notification',
            "value": studentIsMissedPickupNotificationOnOff,
            "key_name": "student_is_missed_pickup_notification_on_off",
            "type": "bool"
          },
          // {
          //   "title": translation(context)
          //       ?.busArrivedAtSchoolNotification ??
          //       'Bus Arrived At School Notification',
          //   "value": busArrivedAtSchoolNotificationOnOff,
          //   "key_name": "bus_arrived_at_school_notification_on_off",
          //   "type": "bool"
          // },
          {
            //busNearDropOffLocationNotificationOnOff
            "title": translation(context)
                ?.busNearDropOffLocationNotification ??
                'Bus Near Drop Off Location Notification',
            "value": busNearDropOffLocationNotificationOnOff,
            "key_name": "bus_near_drop_off_location_notification_on_off",
            "type": "bool"
          },
          {
            "title": translation(context)
                ?.busArrivedAtDropOffLocationNotification ??
                'Bus Arrived At Drop Off Location Notification',
            "value": busArrivedAtDropOffLocationNotificationOnOff,
            "key_name": "bus_arrived_at_drop_off_location_notification_on_off",
            "type": "bool"
          },
        ];
      }
    });

  }
}
