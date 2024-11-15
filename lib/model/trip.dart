
import 'package:school_trip_track_guardian/model/route_info.dart';
import 'package:school_trip_track_guardian/model/trip_details.dart';

class Trip{
  Trip({
    this.id,
    this.channel,
    this.routeId,
    this.effectiveDate,
    this.repetitionPeriod,
    this.stopToStopAvgTime,
    this.firstStopTime,
    this.lastStopTime,
    this.plannedDate,
    this.route,
    this.tripDetail,
    this.isMorning,
    this.plannedTripDetail,
    this.lastPositionLat,
    this.lastPositionLng,
    this.startedAt,
    this.endedAt,
  });
  int? id;
  String? channel;
  int? routeId;
  String? effectiveDate;
  int? repetitionPeriod;
  int? stopToStopAvgTime;
  String? firstStopTime;
  String? lastStopTime;
  String? plannedDate;
  RouteInfo? route;
  double? lastPositionLat, lastPositionLng;
  List<dynamic>? tripDetail, plannedTripDetail;
  String? startedAt, endedAt;
  bool? isMorning;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel': channel,
      'route_id': routeId,
      'effective_date': effectiveDate,
      'repetition_period': repetitionPeriod,
      'stop_to_stop_avg_time': stopToStopAvgTime,
      'first_stop_time': firstStopTime,
      'last_stop_time': lastStopTime,
      'planned_date': plannedDate,
      'route': route,
      'trip_detail': tripDetail,
      'planned_trip_detail': plannedTripDetail,
      'last_position_lat' : lastPositionLat,
      'last_position_lng' : lastPositionLng,
      'started_at' : startedAt,
      'ended_at' : endedAt,
      'is_morning': isMorning == true ? 1 : 0,
    };
  }

  static Trip fromJson(json) {
    return Trip(
      id: json['id'],
      channel: json['channel'],
      routeId: json['route_id'],
      effectiveDate: json['effective_date'],
      repetitionPeriod: json['repetition_period'],
      stopToStopAvgTime: json['stop_to_stop_avg_time'],
      firstStopTime: json['first_stop_time'],
      lastStopTime: json['last_stop_time'],
      plannedDate: json['planned_date'],
      lastPositionLat: json['last_position_lat'] != null ? double.parse(json['last_position_lat'].toString()) : null,
      lastPositionLng: json['last_position_lng'] != null ? double.parse(json['last_position_lng'].toString()) : null,
      route: json['route'] != null ? RouteInfo.fromJson(json['route']) : null,
      tripDetail: json['trip_detail'] != null ? json['trip_detail'].map((p) => TripDetails.fromJson(p)).toList() : null,
      plannedTripDetail: json['planned_trip_detail'] != null ? json['planned_trip_detail'].map((p) => TripDetails.fromJson(p)).toList() : null,
      startedAt: json['started_at'],
      endedAt: json['ended_at'],
      isMorning: json['is_morning'] == 1 ? true : false,
    );
  }
}