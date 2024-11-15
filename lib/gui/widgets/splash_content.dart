import 'package:flutter/material.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/config.dart';

class SplashContent extends StatelessWidget {
  const SplashContent({
    Key? key,
    this.text,
    this.image,
  }) : super(key: key);
  final String? text, image;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Spacer(),
        Text(
          Config.systemName,
          style: AppTheme.headlineBig,
        ),
        SizedBox(height: 20.h,),
        Text(
          text!,
          textAlign: TextAlign.center,
          style: AppTheme.subtitle
        ),
        SizedBox(height: 20.h,),
        Image.asset(
          image!,
          height: 300.h,
          width: 300.w,
        ),
      ],
    );
  }
}
