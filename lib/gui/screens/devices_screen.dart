
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:school_trip_track_guardian/gui/widgets/form_error.dart';
import 'package:school_trip_track_guardian/gui/widgets/app_bar.dart';
import 'package:school_trip_track_guardian/model/constant.dart';
import 'package:school_trip_track_guardian/model/device.dart';
import 'package:school_trip_track_guardian/services/service_locator.dart';
import 'package:school_trip_track_guardian/utils/tools.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../languages/language_constants.dart';
import 'package:school_trip_track_guardian/gui/widgets/direction_positioned.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  DevicesScreenState createState() => DevicesScreenState();
}

class DevicesScreenState extends State<DevicesScreen> {
  ThisApplicationViewModel thisAppModel =
      serviceLocator<ThisApplicationViewModel>();

  final List<String> errors = [];

  void removeAllErrors() {
    setState(() {
      errors.clear();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Widget displayAllDevices() {
    return Scaffold(
      appBar: buildAppBar(context, translation(context)?.devices ?? 'Devices'),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<ThisApplicationViewModel>(
            builder: (context, thisApplicationViewModel, child) {
              return displayDevices(context)!;
            },
          )),
    );
  }

  Widget? displayDevices(BuildContext context) {
    if (thisAppModel.devicesLoadingState.inLoading()) {
      // loading. display animation
      return loadingDevices();
    } else if (thisAppModel.devicesLoadingState.loadingFinished()) {
      if (kDebugMode) {
        print("network call finished");
      }
      //network call finished.
      if (thisAppModel.devicesLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(
            context, thisAppModel.devicesLoadingState.failState!);
      } else {
        return Consumer<ThisApplicationViewModel>(
          builder: (context, thisApplicationViewModel, child) {
            List<Device> allDevices;
            allDevices = thisAppModel.devices;
            if (allDevices.isEmpty) {
              return emptyScreen();
            } else {
              if (thisApplicationViewModel
                  .deviceDeletingState.loadError ==
                  1) {
                errors.add(
                    thisApplicationViewModel.deviceDeletingState.error!);
              }
              List<Widget> a = [];
              a.add(FormError(errors: errors));
              a.addAll(devicesListScreen(allDevices, thisApplicationViewModel));
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
        top: 20.h,
        left: 10.w,
        right: 10.w,
        bottom: 10.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/img_no_connected_dev.png",
              height:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? 50
                      : 150,
            ),
            Padding(
              padding: EdgeInsets.only(top: 30.h),
              child: Column(
                children: [
                  Text(
                    "Oops... There aren't any devices yet.",
                    style: AppTheme.caption,
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

  List<Widget> devicesListScreen(List<Device> allDevices,
      ThisApplicationViewModel thisApplicationViewModel) {
    return List.generate(allDevices.length, (i) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 10,
            child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        allDevices[i].name,
                        style: AppTheme.textPrimaryMedium
                      ),
                      allDevices[i].name == thisAppModel.deviceData["model"]
                          ? Text(
                            translation(context)?.currentDevice ?? 'Current device',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontFamily: 'Open Sans',
                              fontWeight: FontWeight.w400,
                            ),
                          ):Container()
                    ],
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: translation(context)?.lastActive ?? "Last active  ",
                              style: AppTheme.textPrimarySmall,
                            ),
                            TextSpan(
                              text: allDevices[i].lastUsedAt,
                              style: AppTheme.textSecondarySmall,
                            ),
                          ],
                        )
                    ),
                    SizedBox(height: 10.h,),
                    //divider
                    allDevices[i].name != thisAppModel.deviceData["model"] ?
                    const Divider(
                      color: Colors.white,
                      thickness: 1,
                    ) : Container(
                      height: 10.h,
                    ),
                    //check if current device
                    allDevices[i].name != thisAppModel.deviceData["model"] ?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        (thisApplicationViewModel.deviceDeletingState
                            .inLoading() && thisApplicationViewModel.deviceDeletingIdx == i)
                            ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.red),
                        )
                            :
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: AppTheme.secondary,
                          ),
                          onPressed: () {
                            showAlertDialog(
                                context,
                                thisApplicationViewModel,
                                i,
                                allDevices[i].id,
                                allDevices[i].name);
                          },
                        ),
                      ],
                    ) : Container(),
                  ],
                ),
                leading: allDevices[i].name.toLowerCase().contains('iphone') ||
                        allDevices[i].name.toLowerCase().contains('ipad') ||
                        allDevices[i].name.toLowerCase().contains('ios')
                    ? const Icon(
                        FontAwesomeIcons.apple,
                        size: 30,
                        color: AppTheme.secondary,
                      )
                    : const Icon(
                        FontAwesomeIcons.android,
                        size: 30,
                        color: AppTheme.secondary,
                      ),),
        ),
      );
    });
  }

  showAlertDialog(
      BuildContext context,
      ThisApplicationViewModel thisApplicationViewModel,
      int i,
      int id,
      String name) {
    // set up the buttons
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

        removeAllErrors();
        thisApplicationViewModel.deleteDeviceEndpoint(i, id);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(translation(context)?.warning ?? "Warning"),
      content: Text(translation(context)?.areYouSureDeleteDevice ??  "Are you sure to delete this device?"),
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
  }

  @override
  Widget build(context) {
    return displayAllDevices();
  }

  Widget loadingDevices() {
    return Center(
      child: SizedBox(
        width: 30.w,
        height: 30.h,
        child: const CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
      ),
    );
  }
}
