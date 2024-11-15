import 'package:flutter/material.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class AnimatedAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool? addPadding;
  /// Title of the [AnimatedAppBar].
  /// Will be shown on top of the planet.
  final String? title, subTitle;
  final bool? putBackIcon;
  final Widget? right;

  const AnimatedAppBar(this.title, this.putBackIcon,
      {super.key, this.subTitle, this.addPadding, this.right});

  @override
  AnimatedAppBarState createState() => AnimatedAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(addPadding != null && addPadding!
      ? 130
      : subTitle != null
          ? 130
          : 90.h);
}

class AnimatedAppBarState extends State<AnimatedAppBar>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThisApplicationViewModel>(
        builder: (context, thisAppModel, child) {
      return Container(
        color: AppTheme.backgroundColor,
        padding: EdgeInsets.only(top: 10.0.h),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  left: 16.w,
                  top: (widget.addPadding != null && widget.addPadding!)
                      ? 20.h
                      : 16.h,
                  right: 8.w),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: widget.addPadding != null && widget.addPadding!
                            ? 30
                            : 0,
                      ),
                      widget.putBackIcon!
                          ? Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      AppTheme.primary.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  minimumSize: Size.zero,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_outlined,
                                  color: AppTheme.primary,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            )
                          : Container(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title!,
                            style: AppTheme.headlineBig,
                          ),
                          SizedBox(
                            height:
                                widget.addPadding != null && widget.addPadding!
                                    ? 20
                                    : 1,
                          ),
                          widget.subTitle != null
                              ? Text(
                                  widget.subTitle!,
                                  style: AppTheme.bold14Grey60,
                                )
                              : Container()
                        ],
                      ),
                      Spacer(),
                      widget.right ?? Container(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
