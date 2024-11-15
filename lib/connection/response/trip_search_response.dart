
import 'package:school_trip_track_guardian/model/route_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../model/stop.dart';
import '../../model/trip.dart';

class TripSearchResult {
  //id
  int? id;
  double? distanceToStartStop;
  RouteInfo? route;
  Stop? startStop, endStop;
  List<dynamic>? path;
  double? distanceToEndPoint;
  LatLng? endPoint;
  //List<dynamic>? trips;
  Trip? trip;
  double? price;
  double? distance;
  String? plannedStartTime, plannedStartDate, plannedEndTime;
  int? availableSeats;

  TripSearchResult({
    this.id,
    this.distanceToStartStop,
    this.route,
    this.startStop,
    this.endStop,
    this.path,
    this.distanceToEndPoint,
    this.endPoint,
    this.trip,
    this.price,
    this.distance,
    this.plannedStartTime,
    this.plannedStartDate,
    this.plannedEndTime,
    this.availableSeats,
  });

  factory TripSearchResult.fromJson(Map<String, dynamic> json)
  {
    return TripSearchResult(
      id: json['id'],
      distanceToStartStop: json['distanceToStartStop'] != null ? double.parse(json['distanceToStartStop'].toString()) : null,
      route: json['route'] != null ? RouteInfo.fromJson(json['route']) : null,
      startStop: json['startStop'] != null ? Stop.fromJson(json['startStop']) : null,
      endStop: json['endStop'] != null ? Stop.fromJson(json['endStop']) : null,
      path: json['path']?.map((e) => LatLng(e['lat'], e['lng'])).toList(),
      distanceToEndPoint: json['distanceToEndPoint'] != null ? double.parse(json['distanceToEndPoint'].toString()) : null,
      endPoint: json['endPoint'] != null ? LatLng(json['endPoint']['lat'], json['endPoint']['lng']) : null,
      trip: json['trip'] != null ? Trip.fromJson(json['trip']) : null,
      price: json['price'] != null ? double.parse(json['price'].toString()) : null,
      distance: json['distance'] != null ? double.parse(json['distance'].toString()) : null,
      plannedStartTime: json['plannedStartTime'],
      plannedStartDate: json['plannedStartDate'],
      plannedEndTime: json['plannedEndTime'],
      availableSeats: json['availableSeats'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'distanceToStartStop': distanceToStartStop,
    'route': route,
    'startStop': startStop,
    'endStop': endStop,
    'path': path,
    'distanceToEndPoint': distanceToEndPoint,
    'endPoint': endPoint,
    'trip': trip?.toJson(),
    'price': price,
    'distance': distance,
    'plannedStartTime': plannedStartTime,
    'plannedStartDate': plannedStartDate,
    'plannedEndTime': plannedEndTime,
    'availableSeats': availableSeats,
  };

}

class TripSearchResponse {

  List<dynamic>? tripSearchList;
  String? currencyCode;
  String? paymentMethod;
  TripSearchResponse({this.tripSearchList, this.currencyCode, this.paymentMethod});

  factory TripSearchResponse.fromJson(json) {
    List<dynamic> list = json["trip_search_results"];
    return TripSearchResponse(
        tripSearchList: list.map((p) => TripSearchResult.fromJson(p)).toList(),
        currencyCode: json['currency_code'],
        paymentMethod: json['payment_method']
    );
  }

}