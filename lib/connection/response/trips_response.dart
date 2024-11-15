import 'package:school_trip_track_guardian/model/trip.dart';

class TripsResponse {
  List<Trip>? items = [];

  TripsResponse({this.items});

  factory TripsResponse.fromJson(List<dynamic> list) {
    return TripsResponse(
        items: list.map((p) => Trip.fromJson(p)).toList()
    );
  }
}