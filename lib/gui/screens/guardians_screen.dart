import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
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
import '../widgets/no_animation_page_route.dart';
import '../widgets/shimmers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_trip_track_guardian/gui/widgets/direction_positioned.dart';

class GuardiansScreen extends StatefulWidget {
  const GuardiansScreen({Key? key}) : super(key: key);
  @override
  GuardiansScreenState createState() => GuardiansScreenState();
}

class GuardiansScreenState extends State<GuardiansScreen> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  ThisApplicationViewModel thisApplicationModel = serviceLocator<ThisApplicationViewModel>();
  bool isLoading = false;

  TextEditingController guardianNameController = TextEditingController();
  TextEditingController guardianEmailController = TextEditingController();
  TextEditingController guardianConfirmEmailController = TextEditingController();

  @override
  void initState() {
    thisApplicationModel.allGuardiansLoadingState.loadState = ScreenState.LOADING;
    thisApplicationModel.addNewGuardianLoadingState.error = null;
    thisApplicationModel.deleteGuardianLoadingState.error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      thisApplicationModel.getAllGuardiansEndpoint();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setData(ThisApplicationViewModel thisAppModel) {
    thisAppModel.getAllGuardiansEndpoint();
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
                // row to add text "guardians and button +
                Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        translation(context)?.guardians ?? "Guardians",
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
    a.addAll(_displayGuardians(thisAppModel));
    return Scaffold(
        body: ListView(
          children: a,
        ),
        floatingActionButton:
        thisAppModel.allGuardiansLoadingState.inLoading() ? null :
        ElevatedButton(
          style: floatButtonStyle(),
          onPressed: () async {
            //display modal bottom sheet to add guardian
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext sheetContext) {
                  return Padding(
                    padding: MediaQuery.of(sheetContext).viewInsets,
                    child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery
                                .of(sheetContext)
                                .viewInsets
                                .bottom),
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(10.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      translation(sheetContext)?.addGuardian ?? "Add Guardian",
                                      style: AppTheme.textPrimaryLarge,
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pop(sheetContext);
                                      },
                                      icon: const Icon(
                                        Icons.close,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      translation(sheetContext)?.enterGuardianEmail ?? "Enter name and email address of the guardian.",
                                      style: AppTheme.textDarkBlueSmallLight,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: guardianNameController,
                                    decoration: InputDecoration(
                                      border: const UnderlineInputBorder(),
                                      prefixIcon: const Icon(Icons.person, color: AppTheme.secondary),
                                      hintText: translation(sheetContext)?.name ?? 'Name',
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  TextField(
                                    controller: guardianEmailController,
                                    decoration: InputDecoration(
                                      border: const UnderlineInputBorder(),
                                      prefixIcon: const Icon(Icons.email, color: AppTheme.secondary,),
                                      hintText: translation(sheetContext)
                                          ?.email ?? 'Email',
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  TextField(
                                    controller: guardianConfirmEmailController,
                                    decoration: InputDecoration(
                                      border: const UnderlineInputBorder(),
                                      prefixIcon: const Icon(Icons.email, color: AppTheme.secondary),
                                      hintText: translation(sheetContext)?.confirmEmail ?? 'Confirm Email',
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(10.w),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          style: floatButtonStyle(),
                                          onPressed: () async {
                                            if (guardianEmailController.text
                                                .isNotEmpty &&
                                                guardianConfirmEmailController.text
                                                    .isNotEmpty &&
                                                guardianNameController.text
                                                    .isNotEmpty) {
                                              if (guardianConfirmEmailController.text !=
                                                  guardianEmailController.text) {
                                                //show error
                                                Fluttertoast.showToast(
                                                    msg: "Emails do not match",
                                                    toastLength: Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.BOTTOM,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor: AppTheme.primary,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0
                                                );
                                                return;
                                              }
                                              else {
                                                //add guardian
                                                Navigator.pop(sheetContext);
                                                thisAppModel.addGuardianEndpoint(
                                                    guardianEmailController.text,
                                                    guardianNameController.text,
                                                    context);
                                              }
                                            }
                                            else {
                                              //show error
                                              Fluttertoast.showToast(
                                                  msg: "Please enter the name and email address of the guardian that you want to add.",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: AppTheme.primary,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0
                                              );
                                              return;
                                            }
                                          },
                                          child: Text(
                                            translation(sheetContext)?.add ?? "Add",
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                });
          },
          child: thisAppModel.addNewGuardianLoadingState.inLoading() ?
          const CircularProgressIndicator(
            color: AppTheme.backgroundColor,
          ) :
          floatButtonAddIcon(),
        )
    );
  }

  Widget _buildGuardiansScreen(BuildContext context, ThisApplicationViewModel thisAppModel) {
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
          if(thisAppModel.addNewGuardianLoadingState.loadingFinished() &&
              thisAppModel.addNewGuardianLoadingState.error != null) {
            Fluttertoast.showToast(
                msg: thisAppModel.addNewGuardianLoadingState.error!,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: AppTheme.primary,
                textColor: Colors.white,
                fontSize: 16.0
            );
          }
          if(thisAppModel.deleteGuardianLoadingState.loadingFinished() &&
              thisAppModel.deleteGuardianLoadingState.error != null) {
            Fluttertoast.showToast(
                msg: thisAppModel.deleteGuardianLoadingState.error!,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: AppTheme.primary,
                textColor: Colors.white,
                fontSize: 16.0
            );
          }

          return _buildGuardiansScreen(context, thisAppModel);
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

  List<Widget> _displayGuardians(ThisApplicationViewModel thisAppModel) {
    List<Widget> a = [];
    if (thisAppModel.allGuardiansLoadingState.inLoading()) {
      // loading. display animation
      a.add(loadingScreen());
    }
    else if (thisAppModel.allGuardiansLoadingState.loadingFinished()) {
      //network call finished.
      if (thisAppModel.allGuardiansLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        a.add(failedScreen(
            context,
            thisAppModel.allGuardiansLoadingState.failState));
      }
      else {
        List<DbUser> allGuardians;
        allGuardians = thisAppModel.allGuardians;
        if (allGuardians.isEmpty) {
          a.add(emptyGuardiansScreen());
        }
        else {
          List<Widget> list = guardiansListScreen(allGuardians, thisAppModel);
          a.add(
            Padding(
              padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 5.h, bottom: 80.h),
              child: Column(
                children: list,
              )
            ),
          );
        }
      }
    }
    return a;
  }

  guardiansListScreen(List<DbUser> allGuardians, ThisApplicationViewModel thisAppModel) {
    List<Widget> list = [];
    for (int i = 0; i < allGuardians.length; i++) {
      var guardian = allGuardians[i];
      list.add(
        Padding(
          padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 10.h, bottom: 5.h),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: getBackgroundColor(guardian),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1.r,
                  blurRadius: 2.r,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                                "${Config.serverUrl}${guardian
                                    .avatar}"),
                            backgroundColor: AppTheme.veryLightGrey,
                            radius: 30.w,
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                guardian.name ?? "",
                                style: AppTheme.textPrimaryLarge,
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                guardian.email ?? "",
                                style: AppTheme.textSecondarySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                //status
                displayStatus(guardian, thisAppModel),
              ],
            ),
          ),
        ),
      );
    }
    return list;
  }


  //emptyGuardiansScreen
  Widget emptyGuardiansScreen() {
    return Column(
      children: [
        SizedBox(height: 30.h),
        SizedBox(
          height: 200.h,
          width: 200.w,
          child: Image.asset("assets/images/img_no_guardians.png",
              height: 200.h,
              width: 200.w,
              alignment: Alignment.center),
        ),
        SizedBox(height: 30.h),
        Text(
          translation(context)?.noGuardians ?? "No guardians",
          style: AppTheme.textPrimaryLarge,
        ),
        SizedBox(height: 30.h),
        Text(
          translation(context)?.noGuardiansYet ?? "You have not added any guardians yet.",
          style: AppTheme.textSecondaryMedium,
          textAlign: TextAlign.center
        ),
      ],
    );
  }

  displayStatus(DbUser guardian, ThisApplicationViewModel thisAppModel) {
    String statusStr = "";

    return Padding(
      padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 1.h, bottom: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            statusStr,
            style: AppTheme.subCaptionSecondary,
          ),
          displayActions(guardian, thisAppModel),
        ],
      ),
    );
  }

  displayActions(DbUser guardian, ThisApplicationViewModel thisAppModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            //show dialog
            //are you sure that you want to delete this guardian?
            showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: Text("Delete Guardian"),
                    content: Text(
                        "Are you sure that you want to delete this guardian?"),
                    actions: [
                      TextButton(
                        child: Text("Yes"),
                        onPressed: () {
                          //delete guardian
                          thisAppModel.deleteGuardianEndpoint(guardian.id);
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      TextButton(
                        child: Text("No"),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                    ],
                  );
                }
            );
          },
          icon: isDeletingGuardian(guardian, thisAppModel) ?
          const CircularProgressIndicator(
            color: AppTheme.primary,
          ) :
          Icon(
            FontAwesomeIcons.trashAlt,
            size: 15.r,
            color: AppTheme.primary
          ),
        ),
      ],
    );
  }

  getBackgroundColor(DbUser guardian) {
    if (guardian.status == 4 || guardian.status == 2 || guardian.status == 3) {
      return AppTheme.lightGrey;
    }
    else {
      return Colors.white;
    }
  }

  isDeletingGuardian(DbUser guardian, ThisApplicationViewModel thisAppModel) {
    if(thisAppModel.deleteGuardianLoadingState.inLoading()) {
      for (int i = 0; i < thisAppModel.allGuardians.length; i++) {
        if (thisAppModel.deleteGuardianId == guardian.id) {
          return true;
        }
      }
      return false;
    }
    else {
      return false;
    }
  }
}
