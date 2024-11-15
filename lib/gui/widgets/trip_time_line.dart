import 'package:school_trip_track_guardian/utils/tools.dart';
import 'package:flutter/material.dart';

import 'package:timeline_tile/timeline_tile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TripTimeLine extends StatelessWidget {
  const TripTimeLine({
    Key? key,
    required this.plannedTripDetails,
    required this.endStopIndex,
    this.startStopIndex,
  }) : super(key: key);
  final List<dynamic> plannedTripDetails;
  final int endStopIndex;
  final int? startStopIndex;

  @override
  Widget build(BuildContext context) {
    double spacingMax = 100;
    double spacingMin = 50;
    return Expanded(
      child: ListView.builder(
        itemCount: plannedTripDetails.length + 1,
        itemBuilder: (context, index) {
          return TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.3,
            isFirst: index == 0,
            isLast: index == plannedTripDetails.length,
            indicatorStyle: endStopIndex == index ?
            IndicatorStyle(
              width: 20.h,
              height: 20.h,
              indicatorXY: 0.15,
              indicator: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(""),
                ),
              ),
            ) :
            IndicatorStyle(
              width: 40.w,
              height: 40.h,
              indicatorXY: 0.15,
              indicator: Container(
                decoration: BoxDecoration(
                  color: (index >= startStopIndex! && endStopIndex >= index + 1) ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    ((index > endStopIndex) ? index : index + 1).toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            beforeLineStyle: LineStyle(
              color: startStopIndex != null ? ((index >= startStopIndex! && endStopIndex >= index + 1) ? Colors.green : Colors.grey) : (Colors.grey),
              thickness: 6,
            ),
            startChild: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    endStopIndex == index ? "Drop-off" : Tools.formatTime(plannedTripDetails[(index > endStopIndex) ? index - 1 : index].plannedTimeStamp),
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                index == plannedTripDetails.length ?
                Container():
                Container(
                  height: (endStopIndex == index || endStopIndex == index + 1) ? spacingMin : spacingMax,
                ),
              ],
            ),
            endChild: Padding(
              padding: EdgeInsets.only(left: 8.w, right: 8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      endStopIndex == index ? "" : plannedTripDetails[(index > endStopIndex) ? index - 1 : index].stop?.name ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  //address
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      endStopIndex == index ? "" : plannedTripDetails[(index > endStopIndex) ? index - 1 : index].stop?.address ?? "",
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                  index == plannedTripDetails.length ?
                  Container():
                  Container(
                    height: (endStopIndex == index || endStopIndex == index + 1) ? spacingMin : spacingMax,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
