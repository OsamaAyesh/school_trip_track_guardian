import 'package:flutter/material.dart';
import 'package:school_trip_track_guardian/gui/widgets/app_bar.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/config.dart';
import '../languages/language_constants.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  AboutScreenState createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, translation(context)?.aboutApp ?? 'About App'),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 60.h,),
            Image.asset("assets/images/splash.png", height: MediaQuery
                .of(context)
                .orientation == Orientation.landscape ? 150.w : 200.w,),
            SizedBox(height: 20.h,),
            Text(Config.systemName,
              style: AppTheme.headlineBig,
              textAlign: TextAlign.center,),
            Text("Version: ${Config.systemVersion}",
              style: AppTheme.subCaption2,
              textAlign: TextAlign.center,),
            SizedBox(height: 40.h,),
            Text(Config.developerInfo,
              style: AppTheme.coloredSubtitle,
              textAlign: TextAlign.center,),
            SizedBox(height: 40.h,),
            Text("Credits: ${Config.credits}",
              style: AppTheme.coloredSubtitle,
              textAlign: TextAlign.center,),
          ],
        ),
      ),
    );
  }
}