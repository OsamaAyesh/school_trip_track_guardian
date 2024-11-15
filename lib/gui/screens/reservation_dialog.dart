import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReservationDetails extends StatefulWidget {
  final int index;
  final Widget ticketContent;
  const ReservationDetails({
    super.key,
    required this.index,
    required this.ticketContent
  });

  @override
  ReservationDetailsState createState() => ReservationDetailsState();
}

class ReservationDetailsState extends State<ReservationDetails>{
  late int i;
  @override
  void initState() {
    i = widget.index;
    super.initState();
  }
  @override
  Widget build(BuildContext context){
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),

      content: SizedBox(
        height: 350.h,
        child: widget.ticketContent,
      ),
    );
  }
}
