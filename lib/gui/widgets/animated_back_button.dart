import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimatedBackButton extends StatefulWidget{
  const AnimatedBackButton({Key? key}) : super(key: key);

  @override
  AnimatedBackButtonState createState() => AnimatedBackButtonState();
}

class AnimatedBackButtonState extends State<AnimatedBackButton> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 7, end: 0).animate(_controller);
    super.initState();
  }
  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return GestureDetector(
            onTapDown: (_) {
              _controller.forward();
            },
            onTapUp: (_) {
              _controller.reverse();
              Future.delayed(const Duration(milliseconds: 180)).then((value){
                Navigator.pop(context);
              });
            },
            onTapCancel: () {
              _controller.reverse();
            },
            child: Container(
              width: 60.w,
              height: 60.h,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: const OvalBorder(),
                shadows: [
                  BoxShadow(
                    color: const Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, _animation.value),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: const Icon(Icons.arrow_back),
            ),
          );
        }
      ),
    );
  }
}
