
class RouteInfo
{
  //id and name
  int? id;
  String? name;

  int? stopsCount;

  bool? isMorning;

  //constructor

  RouteInfo({
    this.id,
    this.name,
    this.stopsCount,
    this.isMorning,
  });

  //toJson

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stops_count': stopsCount,
      'is_morning': isMorning == true ? 1 : 0,
    };
  }

  //fromJson

  static RouteInfo fromJson(json) {
    return RouteInfo(
      id: json['id'],
      name: json['name'],
      stopsCount: json['stops_count'],
      isMorning: json['is_morning'] == 1 ? true : false,
    );
  }
}