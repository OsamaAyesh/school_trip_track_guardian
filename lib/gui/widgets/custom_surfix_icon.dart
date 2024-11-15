import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSuffixIcon extends StatelessWidget {
  const CustomSuffixIcon({
    Key? key,
    this.svgIcon,
  }) : super(key: key);

  final Icon? svgIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        10.w,
        10.w,
        10.w,
        10.w,
      ),
      child: IconButton(icon: svgIcon!,
        iconSize: 18.w,
        onPressed: () {  },
      ),
    );
  }
}
