import 'package:school_trip_track_guardian/model/my_notification.dart';

class NotificationsResponse {
  List<MyNotification>? items = [];

  NotificationsResponse({this.items});

  factory NotificationsResponse.fromJson(List<dynamic> list) {
    return NotificationsResponse(
        items: list.map((p) => MyNotification.fromJson(p)).toList()
    );
  }
}