import 'package:flutter/material.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key? key,
    this.text,
    this.icon,
    this.press,
    this.backColor,
  }) : super(key: key);

  final String? text;
  final Icon? icon;
  final VoidCallback? press;
  final Color? backColor;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Padding(
        padding: EdgeInsets.only(left: 16.w, right: 8.w, top: 12.h, bottom: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: 30.w, height: 30.h,
                decoration: BoxDecoration(
                  color: backColor ?? AppTheme.lightGrey,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: icon
            ),
            SizedBox(width: 20.w),
            Expanded(child: Text(text!, style: AppTheme.menu,)),
            //Icon(Icons.arrow_forward_ios, color: AppTheme.normalGrey,),
          ],
        ),
      ),
    );
  }
}
