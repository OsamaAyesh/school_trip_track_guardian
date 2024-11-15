import 'package:school_trip_track_guardian/model/my_notification.dart';
import 'package:school_trip_track_guardian/model/setting.dart';
import 'package:school_trip_track_guardian/model/user.dart';

class AuthResponse {
  DbUser? user;
  String? token;
  List<MyNotification>? userNotifications = [];

  Setting? settings;

  AuthResponse({this.user, this.token, this.settings});

  factory AuthResponse.fromJson(json) {
    String? token = json["token"];
    return AuthResponse(
        user : json['user_data'] != null? DbUser.fromJson(json['user_data']) : null,
        token: token,
        settings: json['settings'] != null? Setting.fromJson(json['settings']) : null
    );
  }
}