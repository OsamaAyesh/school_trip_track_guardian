
import 'package:school_trip_track_guardian/model/route_details.dart';
import 'package:school_trip_track_guardian/model/stop.dart';
import 'package:school_trip_track_guardian/model/trip.dart';

class Reservation{

    int id;
    String? ticketNumber;
    Trip? trip;
    String? reservationDate;
    Stop? firstStop;
    double? endPointLatitude, endPointLongitude, paidPrice;
    int? rideStatus; //0 not ride, 1-ride, 2-miss ride, 3-drop off
    String? startAddress, destinationAddress;
    String? plannedStartTime;
    int? endStopID;
    RouteDetails? routeDetails;
    Reservation(
        {
            required this.id,
            this.ticketNumber,
            this.trip,
            this.reservationDate,
            this.firstStop,
            this.endPointLatitude,
            this.endPointLongitude,
            this.paidPrice,
            this.rideStatus,
            this.startAddress,
            this.destinationAddress,
            this.plannedStartTime,
            this.endStopID,
            this.routeDetails,
        }
        );

    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'ticket_number': ticketNumber,
        'planned_trip': trip,
        'reservation_date': reservationDate,
        'first_stop': firstStop,
        'end_point_lat': endPointLatitude,
        'end_point_lng': endPointLongitude,
        'paid_price': paidPrice,
        'ride_status': rideStatus,
        'start_address': startAddress,
        'destination_address': destinationAddress,
        'planned_start_time': plannedStartTime,
        'end_stop_id': endStopID,
        'route_details': routeDetails,
      };
    }

    static Reservation fromJson(json) {
        return Reservation(
            id: json['id'],
            ticketNumber: json['ticket_number'],
            trip: json['planned_trip'] != null ? Trip.fromJson(json['planned_trip']) : null,
            reservationDate: json['reservation_date'],
            firstStop: json['first_stop'] != null ? Stop.fromJson(json['first_stop']) : null,
            endPointLatitude: json['end_point_lat'] != null ? double.parse(json['end_point_lat'].toString()) : null,
            endPointLongitude: json['end_point_lng'] != null ? double.parse(json['end_point_lng'].toString()) : null,
            paidPrice: json['paid_price'] != null ? double.parse(json['paid_price'].toString()) : null,
            rideStatus: json['ride_status'],
            startAddress: json['start_address'],
            destinationAddress: json['destination_address'],
            plannedStartTime: json['planned_start_time'].toString(),
            endStopID: json['end_stop_id'],
            routeDetails: json['route_details'] != null ? RouteDetails.fromJson(json['route_details']) : null,
        );
    }
}
