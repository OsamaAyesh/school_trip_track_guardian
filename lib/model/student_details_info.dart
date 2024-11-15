

import 'package:school_trip_track_guardian/model/user.dart';

import 'route_info.dart';
import 'stop.dart';
import 'trip.dart';

class StudentDetailsInfo {

  RouteInfo? pickupRoute;
  RouteInfo? dropOffRoute;
  Stop? pickupStop;
  Stop? dropOffStop;
  Trip? pickupTrip;
  Trip? dropOffTrip;
  String? absentOn;
  String? pickupPickTime, pickupDropTime, dropOffPickTime, dropOffDropTime;
  bool? nextStopIsYourPickupLocationNotificationOnOff, studentIsPickedUpNotificationOnOff,
      studentIsMissedPickupNotificationOnOff, busNearDropOffLocationNotificationOnOff,
      busArrivedAtPickupLocationNotificationOnOff, busArrivedAtDropOffLocationNotificationOnOff,
      busArrivedAtSchoolNotificationOnOff;
  int? busNearPickupLocationNotificationByDistance;
  double? pickupLat, pickupLng, dropOffLat, dropOffLng;
  String? pickupAddress, dropOffAddress, pickupPlaceId, dropOffPlaceId;
  int? morningBusId, afternoonBusId;

  StudentDetailsInfo({
    this.pickupRoute,
    this.dropOffRoute,
    this.pickupStop,
    this.dropOffStop,
    this.pickupTrip,
    this.dropOffTrip,
    this.pickupPickTime,
    this.pickupDropTime,
    this.dropOffPickTime,
    this.dropOffDropTime,
    this.absentOn,
    this.studentIsPickedUpNotificationOnOff,
    this.studentIsMissedPickupNotificationOnOff,
    this.nextStopIsYourPickupLocationNotificationOnOff,
    this.busNearDropOffLocationNotificationOnOff,
    this.busArrivedAtPickupLocationNotificationOnOff,
    this.busArrivedAtDropOffLocationNotificationOnOff,
    this.busArrivedAtSchoolNotificationOnOff,
    this.busNearPickupLocationNotificationByDistance,
    this.pickupLat,
    this.pickupLng,
    this.dropOffLat,
    this.dropOffLng,
    this.pickupAddress,
    this.dropOffAddress,
    this.pickupPlaceId,
    this.dropOffPlaceId,
    this.morningBusId,
    this.afternoonBusId
  });

  factory StudentDetailsInfo.fromJson(json) {
    return StudentDetailsInfo(
        pickupRoute: json['pickup_route'] != null
            ? RouteInfo.fromJson(json['pickup_route'])
            : null,
        dropOffRoute: json['drop_off_route'] != null
            ? RouteInfo.fromJson(json['drop_off_route'])
            : null,
        pickupStop: json['pickup_stop'] != null
            ? Stop.fromJson(json['pickup_stop'])
            : null,
        dropOffStop: json['drop_off_stop'] != null
            ? Stop.fromJson(json['drop_off_stop'])
            : null,
        pickupTrip: json['pickup_trip'] != null
            ? Trip.fromJson(json['pickup_trip'])
            : null,
        dropOffTrip: json['drop_off_trip'] != null
            ? Trip.fromJson(json['drop_off_trip'])
            : null,
        pickupPickTime: json['pickup_pick_time'],
        pickupDropTime: json['pickup_drop_time'],
        dropOffPickTime: json['drop_off_pick_time'],
        dropOffDropTime: json['drop_off_drop_time'],
        absentOn: json['absent_on'],

        studentIsPickedUpNotificationOnOff: json['student_is_picked_up_notification_on_off'] == 1 ? true : false,

        studentIsMissedPickupNotificationOnOff: json['student_is_missed_pickup_notification_on_off'] == 1 ? true : false,

        nextStopIsYourPickupLocationNotificationOnOff: json['next_stop_is_your_pickup_location_notification_on_off'] == 1 ? true : false,

        busNearDropOffLocationNotificationOnOff: json['bus_near_drop_off_location_notification_on_off'] == 1 ? true : false,

        busArrivedAtPickupLocationNotificationOnOff: json['bus_arrived_at_pickup_location_notification_on_off']  == 1 ? true : false,

        busArrivedAtDropOffLocationNotificationOnOff: json['bus_arrived_at_drop_off_location_notification_on_off'] == 1 ? true : false,

        busArrivedAtSchoolNotificationOnOff: json['bus_arrived_at_school_notification_on_off'] == 1 ? true : false,

        busNearPickupLocationNotificationByDistance: json['bus_near_pickup_location_notification_by_distance'] != null ? int.parse(json['bus_near_pickup_location_notification_by_distance'].toString()) : null,

        pickupLat: json['pickup_lat'] != null ? double.parse(json['pickup_lat'].toString()) : null,
        pickupLng: json['pickup_lng'] != null ? double.parse(json['pickup_lng'].toString()) : null,
        dropOffLat: json['drop_off_lat'] != null ? double.parse(json['drop_off_lat'].toString()) : null,
        dropOffLng: json['drop_off_lng'] != null ? double.parse(json['drop_off_lng'].toString()) : null,
        pickupAddress: json['pickup_address'],
        dropOffAddress: json['drop_off_address'],
        pickupPlaceId: json['pickup_place_id'],
        dropOffPlaceId: json['drop_off_place_id'],
        morningBusId: json['morning_bus_id'] != null ? int.parse(json['morning_bus_id'].toString()) : null,
        afternoonBusId: json['afternoon_bus_id'] != null ? int.parse(json['afternoon_bus_id'].toString()) : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickup_route': pickupRoute?.toJson(),
      'drop_off_route': dropOffRoute?.toJson(),
      'pickup_stop': pickupStop?.toJson(),
      'drop_off_stop': dropOffStop?.toJson(),
      'pickup_trip': pickupTrip?.toJson(),
      'drop_off_trip': dropOffTrip?.toJson(),
      'pickup_pick_time': pickupPickTime,
      'pickup_drop_time': pickupDropTime,
      'drop_off_pick_time': dropOffPickTime,
      'drop_off_drop_time': dropOffDropTime,
      'absent_on': absentOn,
      'student_is_picked_up_notification_on_off': studentIsPickedUpNotificationOnOff == true ? 1 : 0,
      'student_is_missed_pickup_notification_on_off': studentIsMissedPickupNotificationOnOff == true ? 1 : 0,
      'next_stop_is_your_pickup_location_notification_on_off': nextStopIsYourPickupLocationNotificationOnOff == true ? 1 : 0,
      'bus_near_drop_off_location_notification_on_off': busNearDropOffLocationNotificationOnOff == true ? 1 : 0,
      'bus_arrived_at_pickup_location_notification_on_off': busArrivedAtPickupLocationNotificationOnOff == true ? 1 : 0,
      'bus_arrived_at_drop_off_location_notification_on_off': busArrivedAtDropOffLocationNotificationOnOff == true ? 1 : 0,
      'bus_arrived_at_school_notification_on_off': busArrivedAtSchoolNotificationOnOff == true ? 1 : 0,
      'bus_near_pickup_location_notification_by_distance': busNearPickupLocationNotificationByDistance,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'drop_off_lat': dropOffLat,
      'drop_off_lng': dropOffLng,
      'pickup_address': pickupAddress,
      'drop_off_address': dropOffAddress,
      'pickup_place_id': pickupPlaceId,
      'drop_off_place_id': dropOffPlaceId,
      'morning_bus_id': morningBusId,
      'afternoon_bus_id': afternoonBusId
    };
  }
}