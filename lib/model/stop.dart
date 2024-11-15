import 'package:school_trip_track_guardian/model/route_info.dart';

class Stop{
   int? id;
   String? name;
   String? placeId;
   String? address;
   String? lat;
   String? lng;
   double? distance;
   List<dynamic>? pickTimes;
   List<dynamic>? dropTimes;
   List<dynamic>? routesIds;
   List<dynamic>? tripsIds;
   List<dynamic>? availableSeats;

   //routes
   List<dynamic>? routes;

  Stop({
    this.id,
    this.name,
    this.placeId,
    this.address,
    this.lat,
    this.lng,
    this.distance,
    this.pickTimes,
    this.dropTimes,
    this.routesIds,
    this.tripsIds,
    this.routes,
    this.availableSeats,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'place_id': placeId,
      'address': address,
      'lat': lat,
      'lng': lng,
      'distance': distance,
      'pick_times': pickTimes,
      'drop_times': dropTimes,
      'routes_ids': routesIds,
      'trips_ids': tripsIds,
      'routes': routes,
      'available_seats': availableSeats,
    };
  }

  static Stop fromJson(json) {
    return Stop(
      id: json['id'],
      name: json['name'],
      placeId: json['place_id'],
      address: json['address'],
      lat: json['lat'],
      lng: json['lng'],
      distance: json['distance'] != null ? double.parse(json['distance'].toString()) : null,
      pickTimes: json['pick_times']?.map((p) => p.toString()).toList(),
      dropTimes: json['drop_times']?.map((p) => p.toString()).toList(),
      routesIds: json['routes_ids']?.map((p) => int.parse(p.toString())).toList(),
      tripsIds: json['trips_ids']?.map((p) => int.parse(p.toString())).toList(),
      routes: json['routes']?.map((p) => RouteInfo.fromJson(p)).toList(),
      availableSeats: json['available_seats']?.map((p) => int.parse(p.toString())).toList(),
    );
  }
}