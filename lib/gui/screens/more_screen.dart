
import 'package:school_trip_track_guardian/gui/screens/routes_screen.dart';
import 'package:school_trip_track_guardian/gui/screens/sign_in_screen.dart';
import 'package:school_trip_track_guardian/gui/screens/stops_screen.dart';
import 'package:flutter/material.dart';
import 'package:school_trip_track_guardian/connection/utils.dart';
import 'package:school_trip_track_guardian/gui/widgets/profile_menu.dart';
import 'package:school_trip_track_guardian/services/service_locator.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';
import 'package:provider/provider.dart';
// import 'package:share_extend/share_extend.dart';

import '../../utils/config.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';
import '../widgets/profile_pic.dart';
import 'about_screen.dart';
import 'change_language_screen.dart';
import 'terms_conditions_screen.dart';
import 'devices_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'my_profile_screen.dart';


class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}): super(key: key);
  @override
  ProfileScreen createState() => ProfileScreen();
}

class ProfileScreen extends State<MoreScreen> {
  bool isLoading = true;
  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThisApplicationViewModel>(
      builder: (context, thisApplicationViewModel, child) {
        if (isLoading) {
          thisApplicationViewModel.isUserLoggedIn().then((_) {
            setState(() {
              isLoading = false;
            });
          });
          return const Center(
              child: CircularProgressIndicator()
          );
        }
        else {
          return allProfileEntries(thisApplicationViewModel);
        }
      },
    );
  }

  Widget allProfileEntries(ThisApplicationViewModel thisApplicationViewModel) {
    return Stack(
      children: [
        Container(
          color: AppTheme.backgroundColor,
        ),
        SingleChildScrollView(
          //padding: EdgeInsets.symmetric(vertical: 5),
          child:
          Column(
            children: [
              SizedBox(height: 20.h),
              ProfilePic(thisApplicationViewModel: thisApplicationViewModel),
              SizedBox(height: 20.h),
              Container(
                decoration: const BoxDecoration(color: AppTheme.veryLightGrey),
                child:
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: Column(
                          children: [
                            ProfileMenu(
                              backColor: AppTheme.secondary,
                              text: translation(context)?.myProfile ?? 'My Profile',
                              icon: const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white
                              ),
                              press: () {
                                goToScreen(
                                    context, thisAppModel, const MyProfileScreen());
                              },
                            ),
                            thisAppModel.settings?.simpleMode == false ?
                            const Divider(thickness: 1,) : Container(),
                            thisAppModel.settings?.simpleMode == false ?
                            ProfileMenu(
                              backColor: AppTheme.primary,
                              text: translation(context)?.stops ?? "Stops",
                              icon: const Icon(
                                  Icons.bus_alert,
                                  color: Colors.white
                              ),
                              press: () {
                                goToScreen(
                                    context, thisAppModel, const StopsScreen());
                              },
                            ) : Container(),
                            thisAppModel.settings?.simpleMode == false ?
                            const Divider(thickness: 1,) : Container(),
                            thisAppModel.settings?.simpleMode == false ?
                            ProfileMenu(
                              text: translation(context)?.routes ?? "Routes",
                              backColor: const Color(0xff2c3033),
                              icon: const Icon(
                                Icons.route_outlined,
                                color: Colors.white,
                              ),
                              press: () {
                                goToScreen(context, thisAppModel,
                                    const RoutesScreen());
                              },
                            ) : Container(),
                            const Divider(thickness: 1,),
                            ProfileMenu(
                              text: translation(context)?.linkedDevices ?? "Linked devices",
                              backColor: const Color(0xff3c45fe),
                              icon: const Icon(
                                Icons.devices,
                                color: Colors.white,
                              ),
                              press: () {
                                thisAppModel.getDevicesEndpoint();
                                goToScreen(context, thisAppModel,
                                    const DevicesScreen());
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Column(
                    children: [
                      ProfileMenu(
                        text: translation(context)?.changeLanguage ?? 'Change Language',
                        backColor: Colors.deepOrange,
                        icon: const Icon(
                          Icons.language,
                          color: Colors.white,
                        ),
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const ChangeLanguageScreen();
                              },
                            ),
                          );
                        },
                      ),
                      const Divider(thickness: 1,),
                      ProfileMenu(
                        text: translation(context)?.shareApp ??  "Share this App",
                        backColor: Colors.deepPurpleAccent,
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                        press: () {
                          _shareContent();
                        },
                      ),
                      const Divider(thickness: 1,),
                      ProfileMenu(
                        text: translation(context)?.aboutApp ?? "About App",
                        backColor: Colors.lime,
                        icon: const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.white,
                        ),
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const AboutScreen();
                              },
                            ),
                          );
                        },

                      ),
                      const Divider(thickness: 1,),
                      ProfileMenu(
                        text: translation(context)?.termsConditions ?? "Terms and Conditions",
                        backColor: Colors.lightBlue,
                        icon: const Icon(
                          Icons.help_outline,
                          color: Colors.white,
                        ),
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const TermsConditionsScreen();
                              },
                            ),
                          );
                        },
                      ),
                      const Divider(thickness: 1,),
                      ProfileMenu(
                        text: thisApplicationViewModel.isLoggedIn == true
                            ? (translation(context)?.logout ?? "Logout")
                            : (translation(context)?.login ?? "Login"),
                        backColor: thisApplicationViewModel.isLoggedIn == true
                            ? Colors.redAccent
                            : Colors.green,
                        icon: thisApplicationViewModel.isLoggedIn == true ?
                        const Icon(
                          Icons.logout,
                          color: Colors.white,
                        ) : const Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                        press: () {
                          if (thisApplicationViewModel.isLoggedIn == true) {
                            showAlertLogoutDialog(
                                context, thisApplicationViewModel);
                          }
                          else {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInScreen(widget),
                              ),
                                  (Route<dynamic> route) => false,
                            );
                          }
                        },
                      ),
                      const Divider(thickness: 1,),
                      ProfileMenu(
                        text: thisApplicationViewModel.requestDeleteAccountLoadingState.inLoading() == true
                            ? ("Requesting ...")
                            : (translation(context)?.requestDelete ?? "Delete Account"),
                        backColor: Colors.red,
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                        press: () {
                          //display are you sure dialog
                          showAlertDeleteDialog(context, thisApplicationViewModel);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _shareContent() {
    // ShareExtend.share(Config.shareText, "text");
  }

  void goToScreen(BuildContext context, ThisApplicationViewModel thisAppModel, Widget screen) {
    if(thisAppModel.isLoggedIn == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => screen,
        ),
      );
    }
    else
    {
      showLoginDialog(context, widget);
    }
  }

  void showAlertDeleteDialog(BuildContext mainContext, ThisApplicationViewModel thisApplicationViewModel) {
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translation(mainContext)?.requestDelete ?? "Request Account"),
          content: Text(translation(mainContext)?.requestDeleteAccountMessage ?? "Are you sure you want to delete your account?"),
          actions: <Widget>[
            TextButton(
              child: Text(translation(mainContext)?.no ?? "No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(translation(mainContext)?.yes ?? "Yes"),
              onPressed: () {
                thisApplicationViewModel.requestDeleteAccountEndpoint();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}


