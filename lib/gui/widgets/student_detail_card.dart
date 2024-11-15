import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';

class StudentDetailCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool bottom;
  final Function onTap;
  final bool tapAnimation;
  final IconData? bottomLeftIcon;
  final IconData? bottomRightIcon;
  final TextStyle? titleStyle, subTitleStyle;
  final Color? iconColor;
  const StudentDetailCard({Key? key, required this.icon, required this.title, required this.onTap, this.tapAnimation=true, this.bottom=false, this.bottomLeftIcon, this.bottomRightIcon, this.subtitle, this.titleStyle, this.subTitleStyle, this.iconColor}) : super(key: key);

  @override
  State<StudentDetailCard> createState() => _StudentDetailCardState();
}

class _StudentDetailCardState extends State<StudentDetailCard> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _animation;
  bool finished = false;
  bool pressedDown = false;
  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _animation = Tween<double>(begin: 7, end: 2).animate(_controller);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) {
            _controller.forward().whenComplete((){
              pressedDown = true;
            });
          },
          onTapUp: (_) {
            if(!pressedDown) {
              _controller.forward(from: 4).whenComplete(() {
                pressedDown = false;
                finished = true;
                _controller.reverse().whenComplete(() {
                  finished = false;
                  pressedDown = false;
                  widget.onTap();
                });
              });
            }
            if(!finished){
              finished = true;
              _controller.reverse().whenComplete(() {
                finished = false;
                pressedDown = false;
                widget.onTap();
              });
            }
          },
          onTapCancel: (){
            if(!pressedDown){
              _controller.forward(from: 4).whenComplete((){
                pressedDown = false;
                finished = true;
                _controller.reverse().whenComplete(() {
                  finished = false;
                  pressedDown = false;
                });
              });
            }
            if(!finished){
              finished = true;
              _controller.reverse().whenComplete(() {
                finished = false;
                pressedDown = false;
              });
            }
          },
          child: Card(
            elevation: widget.tapAnimation?_animation.value:7,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13.0),
            ),
            child: Column(
              children: List.generate(3, (index) {
                if(index==0){
                  return ListTile(
                    minLeadingWidth: 20.w,
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.icon,
                          color: widget.iconColor??AppTheme.secondary,
                        ),
                      ],
                    ),
                    title: Text(
                      widget.title,
                      style: widget.titleStyle??AppTheme.textPrimaryMedium,
                    ),
                    subtitle: widget.subtitle!=null?Text(
                      widget.subtitle!,
                      style: widget.subTitleStyle??AppTheme.textDarkBlueSmallLight,
                    ):null,
                  );
                }
                else if(index==1 && widget.bottom){
                  return Container(
                    height: 2,
                    width: 330.w,
                    color: const Color(0xFFB6B6B6),
                  );
                }
                else if(index==2 && widget.bottom){
                  return SizedBox(
                    width: 350.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          onPressed: (){
                            widget.onTap();
                          },
                          child: Icon(
                            widget.bottomLeftIcon,
                            color: AppTheme.primary,
                            size: 20.sp,
                          ),
                        ),
                        CupertinoButton(
                          onPressed: (){
                            widget.onTap();
                          },
                          child: Icon(
                            widget.bottomRightIcon,
                            color: AppTheme.primary,
                            size: 20.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                else{
                  return Container();
                }
              }),
            ),
          ),
        );
      }
    );
  }
}
