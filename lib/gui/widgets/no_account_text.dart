import 'package:flutter/material.dart';
import 'package:school_trip_track_guardian/gui/screens/sign_up_screen.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../languages/language_constants.dart';

class NoAccountText extends StatelessWidget {
  final Widget? nextScreen;

  const NoAccountText(this.nextScreen, {
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          translation(context)?.dontHaveAccount ?? "Don’t have an account? ",
          style: TextStyle(fontSize: 16.w),
        ),
        GestureDetector(
          onTap: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUpScreen(nextScreen)),
              );
            },
          child: Text(
            translation(context)?.signUp ?? "Sign Up",
            style: TextStyle(
                fontSize: 16.w,
                color: AppTheme.primary),
          ),
        ),
      ],
    );
  }
}
