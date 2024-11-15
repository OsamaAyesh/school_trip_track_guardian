import 'package:school_trip_track_guardian/gui/widgets/direction_positioned.dart';
import 'package:school_trip_track_guardian/main.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TabChoiceWidget extends StatefulWidget{
  final Color color;
  final List<String> choices;
  final PageController? pageController;
  const TabChoiceWidget({Key? key, required this.color, required this.choices, required this.pageController}) : super(key: key);

  @override
  TabChoiceWidgetState createState() => TabChoiceWidgetState();
}

class TabChoiceWidgetState extends State<TabChoiceWidget> with SingleTickerProviderStateMixin{
  int selectedIndex = 0;
  double scrollOffset = 0;
  @override
  void initState() {
    widget.pageController?.addListener(() {
      setState(() {
        scrollOffset = 87.5.w * widget.pageController!.page!;
        selectedIndex = widget.pageController!.page!.round();
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(33),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 5.h,
            bottom: 5.h,
            left: 5.w,
            child: Transform.translate(
              offset: Offset(MainApp.isRtl(context)?87.5.w-scrollOffset:scrollOffset, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                ),
                width: 80.w,
              ),
            ),
          ),
          SizedBox(
            height: 50.h,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: MainApp.isRtl(context)?TextDirection.rtl:TextDirection.ltr,
              children: widget.choices.map((e)   => SizedBox(
                width: 90.w,
                child: TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  onPressed: () {
                    setState(() {
                      widget.pageController!.animateToPage(widget.choices.indexOf(e), duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    });
                  },
                  child: Text(e, style: TextStyle(color: selectedIndex == widget.choices.indexOf(e) ? AppTheme.primary:Colors.white, fontSize: 16))
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
