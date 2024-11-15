
import 'package:flutter/material.dart';
import 'package:school_trip_track_guardian/gui/widgets/app_bar.dart';
import 'package:school_trip_track_guardian/gui/widgets/forget_password_widget.dart';
import 'package:school_trip_track_guardian/gui/widgets/form_error.dart';
import 'package:school_trip_track_guardian/services/service_locator.dart';
import 'package:school_trip_track_guardian/utils/size_config.dart';
import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../languages/language_constants.dart';

class ForgetPasswordScreen extends StatefulWidget {
  final Widget? nextScreen;
  const ForgetPasswordScreen(this.nextScreen, {super.key});

  @override
  ForgetPasswordScreenState createState() => ForgetPasswordScreenState();
}

class ForgetPasswordScreenState extends State<ForgetPasswordScreen> {

  ThisApplicationViewModel thisAppModel =
      serviceLocator<ThisApplicationViewModel>();

  List<bool> isLoading = [false, false, false, false];

  final List<String> errors = [];


  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error!);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, translation(context)?.forgetOrChangePassword ?? 'Forget Password'),
      body: bodyContent(widget.nextScreen),
    );
  }

  bodyContent(Widget? nextScreen) {
    return SafeArea(
      child: Center(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: SizeConfig.screenHeight! * 0.1),
                ForgetPasswordWidget(nextScreen),
                SizedBox(height: SizeConfig.screenHeight! * 0.02),
                FormError(errors: errors),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
