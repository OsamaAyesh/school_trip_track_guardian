
import 'dart:convert';
import 'dart:io';

import 'package:school_trip_track_guardian/connection/response/auth_response.dart';
import 'package:school_trip_track_guardian/connection/response/devices_response.dart';
import 'package:school_trip_track_guardian/connection/response/notifications_response.dart';
import 'package:school_trip_track_guardian/connection/response/pay_response.dart';
import 'package:school_trip_track_guardian/connection/response/places_response.dart';
import 'package:school_trip_track_guardian/connection/response/reservations_response.dart';
import 'package:school_trip_track_guardian/connection/response/routes_response.dart';
import 'package:school_trip_track_guardian/connection/response/stops_response.dart';
import 'package:school_trip_track_guardian/model/student_details_info.dart';
import 'package:school_trip_track_guardian/connection/response/trip_search_response.dart';
import 'package:school_trip_track_guardian/connection/response/users_response.dart';
import 'package:school_trip_track_guardian/model/constant.dart';
import 'package:school_trip_track_guardian/model/reservation.dart';
import 'package:school_trip_track_guardian/model/route_details.dart';
import 'package:school_trip_track_guardian/model/trip.dart';
import 'package:school_trip_track_guardian/model/user.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import '../model/place.dart';
import '../utils/config.dart';
import 'response/payments_response.dart';


class AllApis {

    bool localTest = false;
    Future<AuthResponse?> loginViaToken(String token, String deviceName,
        String firebaseToken) async { // login via token
        final params = {
            'token': token,
            'device_name': deviceName,
            'fcm_token': firebaseToken
        };

        // check if http or https
        final uri = getFullUrl('api/auth/loginViaToken');

        Response resp = await http.post(
            uri, headers: {HttpHeaders.contentTypeHeader: 'application/json'},
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);
            if (resp.statusCode == 200) {
                return AuthResponse.fromJson(body);
            } else {
                var error = body["errors"]["authentication"][0];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error);
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }
    }


    Future<AuthResponse?> verifyUser(String token, String deviceName) async {

        final uri = getFullUrl('api/auth/verify-user');

        final params = {
            'device_name': deviceName,
        };

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);
            if (resp.statusCode == 200) {
                return AuthResponse.fromJson(body);
            } else {
                var error = body["errors"]["authentication"][0];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error);
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }
    }

    Future<AuthResponse?> createUser(String name, String token,
        String deviceName, String firebaseToken) async { // create user
        final params = {
            'name': name,
            'token': token,
            'device_name': deviceName,
            'fcm_token': firebaseToken
        };

        final uri = getFullUrl('api/auth/createParent');

        Response resp = await http.post(
            uri, headers: {HttpHeaders.contentTypeHeader: 'application/json'},
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try
        {
            var body = jsonDecode(resp.body);
            if (resp.statusCode == 200) {
                return AuthResponse.fromJson(body);
            } else {
                var error = body["errors"]["authentication"][0];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error);
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }
    }

    Future<UsersResponse> getAllGuardians(String token) async {
        final uri = getFullUrl('api/users/parent-guardians');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try {
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var guardians = body["guardians"];
                // then parse the JSON.
                return UsersResponse.fromJson(guardians);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                error ??= body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }

    }

    //printStudentCard
    Future<String?> printStudentCard(String token, int? id) async {
        final params = {
            'student_id': id,
        };

        final uri = getFullUrl('api/users/print-student-card');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);

        if (resp.statusCode == 200) {
            // If the server did return a 200 OK response,
            // then parse the JSON.
            return "";
        }
        else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    Future<UsersResponse> getAllStudents(String token) async {
        final uri = getFullUrl('api/users/guardian-students');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try {
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var students = body["students"];
                // then parse the JSON.
                return UsersResponse.fromJson(students);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                error ??= body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }

    }
    Future<DevicesResponse> getAllDevices(String token) async { // get all devices of user including current device
        final uri = getFullUrl('api/users/devices');

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try {
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var devices = body["devices"];
                // then parse the JSON.
                return DevicesResponse.fromJson(devices);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                error ??= body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }

    }

    Future<String> deleteDevices(String token, int id) async { // deauthorize device
        final params = {
            'token_id': id.toString(),
        };

        final uri = getFullUrl('api/users/revoke-token');

        if(localTest) {
          await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.delete(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params)).timeout(
            Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);

        if (resp.statusCode == 200) {
            // If the server did return a 200 OK response,
            // then parse the JSON.
            return "";
        }
        else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    //upload-avatar
    Future<String?> uploadAvatar(String? token, String? avatarLocalFilePath) async {
        final uri = getFullUrl('api/users/upload-avatar');

        File uploadImage = File(avatarLocalFilePath!);
        List<int> imageBytes = uploadImage.readAsBytesSync();
        String avatarBase64 = base64Encode(imageBytes);

        final params = {
            'avatar': avatarBase64
        };

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode == 200) {
            // then parse the JSON.
            //get avatar_url
            var body = jsonDecode(resp.body);
            var avatarUrl = body["avatar_url"];
            return avatarUrl;
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var body = jsonDecode(resp.body);
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    //getSchoolByCode
    Future<DbUser> getSchoolByCode(String token, String? schoolCode) async {
        final uri = getFullUrl('api/users/get-school-by-code/$schoolCode');
        if(localTest) {
            await Future.delayed(const Duration(seconds: 3));
        }
        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try {
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var school = body["school"];
                // then parse the JSON.
                return DbUser.fromJson(school);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }

    }

    Future<UsersResponse> getAllSchools(String token) async {
        final uri = getFullUrl('api/users/all-schools');

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try {
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var schools = body;
                // then parse the JSON.
                return UsersResponse.fromJson(schools);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                error ??= body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }

    }



    Future<DbUser> addGuardian(String? token, String? email, String? name) async {
        final uri = getFullUrl('api/users/add-guardian');

        final params = {
            'name': name,
            'email': email,
        };

        if (localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        if (resp.statusCode == 200) {
            // then parse the JSON.
            var body = jsonDecode(resp.body);
            var user = body["guardian"];
            return DbUser.fromJson(user);
        } else {
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var body = jsonDecode(resp.body);
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
    }
    //addNewStudent
    Future<DbUser> addEditStudent(String? token, int? id, String? name,
        String? studentIdentifier, String? notes, String? picFile, int? schoolId) async {
        final uri = getFullUrl('api/users/add-edit-student');

        File uploadImage = File(picFile!);
        List<int> imageBytes = uploadImage.readAsBytesSync();
        String imageBase64 = base64Encode(imageBytes);

        final params = {
            'id': id,
            'name': name.toString(),
            'student_identification': studentIdentifier.toString(),
            'notes': notes.toString(),
            'pic': imageBase64,
            'school_id': schoolId,
        };

        if (localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        if (resp.statusCode == 200) {
            // then parse the JSON.
            var body = jsonDecode(resp.body);
            var user = body["student"];
            return DbUser.fromJson(user);
        } else {
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var body = jsonDecode(resp.body);
                var error = body["errors"];
                error ??= body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
    }

    Future<void> updateStudentNotificationSettings(String? token,
        int? studentId, List<Map<String, dynamic>> allNotificationsSettings) async {

        final uri = getFullUrl('api/users/update-notification-settings');

        final params = {
            'student_id': studentId,
            'notification_settings': allNotificationsSettings,
        };

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode == 200) {
            // then parse the JSON.
            var body = jsonDecode(resp.body);
            var user = body["user"];
            return;
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var body = jsonDecode(resp.body);
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    Future<DbUser> updateProfile(String? token, String? address, String? telNumber) async {
        final uri = getFullUrl('api/users/update-profile');

        final params = {
            'address': address.toString(),
            'tel_number': telNumber.toString(),
        };

        if(localTest) {
          await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode == 200) {
            // then parse the JSON.
            var body = jsonDecode(resp.body);
            var user = body["user"];
            return DbUser.fromJson(user);
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var body = jsonDecode(resp.body);
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    //setPickupDropOff
    Future<DbUser> setPickupDropOff(String? token, int? studentId, int? stopId,
        int? routeId, int? tripId, bool? pickUp) async {

        final uri = getFullUrl('api/stops/set-pickup-drop-off');

        final params = {
            'student_id': studentId,
            'stop_id': stopId,
            'route_id': routeId,
            'trip_id': tripId,
            'pick_up': pickUp == true ? "1" : "0",
        };

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            }
        ).catchError((e) {
            throw Exception(e.toString());
        });

        if (resp.statusCode == 200) {
            // then parse the JSON.
            var body = jsonDecode(resp.body);
            // If the server did return a 200 OK response,
            var details = body["student"];
            // then parse the JSON.
            return DbUser.fromJson(details);
        }
        else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var body = jsonDecode(resp.body);
            var error = body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    Future<DbUser> setPickupDropOffLocation(String? token, int? studentId, double? lat,
        double? lng, String? address, bool? pickUp) async {

        final uri = getFullUrl('api/stops/set-pickup-drop-off-location');

        final params = {
            'student_id': studentId,
            'lat': lat,
            'lng': lng,
            'address': address,
            'pick_up': pickUp == true ? "1" : "0",
        };

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            }
        ).catchError((e) {
            throw Exception(e.toString());
        });

        if (resp.statusCode == 200) {
            // then parse the JSON.
            var body = jsonDecode(resp.body);
            // If the server did return a 200 OK response,
            var details = body["student"];
            // then parse the JSON.
            return DbUser.fromJson(details);
        }
        else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var body = jsonDecode(resp.body);
            var error = body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    //setAbsentStudent
    Future<String?> setAbsentStudent(String? token, int? id) async {
        final uri = getFullUrl('api/users/set-absent-student');

        final params = {
            'id': id,
        };

        if(localTest) {
          await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            }
        ).catchError((e) {
            throw Exception(e.toString());
        });

        if (resp.statusCode == 200) {
            // then parse the JSON.
            var body = jsonDecode(resp.body);
            var message = body["absent_on"];
            return message;
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var body = jsonDecode(resp.body);
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    Future<String> getTerms() async {
        final uri = getFullUrl('api/docs/terms');

        Response resp = await http.get(uri).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode == 200) {
            // If the server did return a 200 OK response,
            var body = jsonDecode(resp.body);
            var terms = body["terms"];
            // then parse the JSON.
            return terms;
        } else {
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception('Failed to load ResponseInfo ');
        }
    }

    Future<PlacesResponse> getFavoritesOrRecentPlaces(String token, bool fav) async {
        final uri = fav ? getFullUrl('api/places/favorite-places') : getFullUrl('api/places/recent-places');

        if(localTest) {
          await Future.delayed(const Duration(seconds: 3));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var places = fav? body["favorite_places"] : body["recent_places"];
                // then parse the JSON.
                return PlacesResponse.fromJson(places);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                error ??= body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    Future<StopsResponse> getStops(String token) async {
        final uri = getFullUrl('api/stops/all');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var stops = body;
                // then parse the JSON.
                return StopsResponse.fromJson(stops);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                error ??= body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    Future<RoutesResponse> getRoutes(String token) async {
        final uri = getFullUrl('api/routes/all');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var routes = body;
                // then parse the JSON.
                return RoutesResponse.fromJson(routes);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                error ??= body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    //getClosestStops(apiToken!, lat, lang, pickUp)
    Future<StopsResponse> getClosestStops(String token, int? studentId, double? lat, double? lang, bool? pickUp) async {
        final params = {
            'student_id': studentId.toString(),
            'lat': lat.toString(),
            'lang': lang.toString(),
            'pick_up': pickUp == true ? "1" : "0",
        };
        final uri = getFullUrl('api/stops/get-closest-stops/all', params);

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        );

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var stops = body["stops"];
                // then parse the JSON.
                return StopsResponse.fromJson(stops);
            }
            else {
                var error = body["errors"];
                error ??= body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                if(error.toString().contains("No stops found")) {
                    throw Exception("No stops found");
                }
                else {
                    throw Exception(error.toString());
                }
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }


    Future<DbUser> getStudentDetails(String token, int? id) async {
        final uri = getFullUrl('api/users/get-student-details/$id');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        );
        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body["student"];
                // then parse the JSON.
                return DbUser.fromJson(details);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                error ??= body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    //Get RouteDetails
    Future<RouteDetails> getRouteDetails(String token, int? id) async {
        final uri = getFullUrl('api/routes/$id');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        );
        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body;
                // then parse the JSON.
                return RouteDetails.fromJson(details);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                error ??= body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    // getTripDetails
    Future<Trip> getTripDetails(String token, int? id) async {

        final uri = getFullUrl('api/trips/$id');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        );
        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var trip = body["trip"];
                // then parse the JSON.
                return Trip.fromJson(trip);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                error ??= body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    Future<Trip> getPlannedTripDetails(String token, int? id) async {

        final uri = getFullUrl('api/planned-trips/$id');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        );
        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var trip = body["trip"];
                // then parse the JSON.
                return Trip.fromJson(trip);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                error ??= body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    //get trip search results
    Future<TripSearchResponse> getTripSearchResults(String? token,
        String? startAddress, String? destinationAddress,
        double? startLat,
        double? startLng, double? endLat, double? endLng, DateTime? date) async {
        final params = {
            'start_address': startAddress.toString(),
            'destination_address': destinationAddress.toString(),
            'start_lat': startLat.toString(),
            'start_lng': startLng.toString(),
            'end_lat': endLat.toString(),
            'end_lng': endLng.toString(),
            'date': date.toString(),
        };
        Uri uri;
        if(token == null) {
            uri = getFullUrl('api/trips/search-by-guest', params);
        }
        else {
            uri = getFullUrl('api/trips/search-by-customer', params);
        }

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                // var details = body;
                // then parse the JSON.
                return TripSearchResponse.fromJson(body);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                error ??= body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    //  requestCoins(String token, int? planID)
    Future<String> requestCoins(String token, int? planID) async {
        final params = {
            'plan_id': planID.toString(),
        };

        final uri = getFullUrl('api/users/request-coins');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var message = body["message"];
                // then parse the JSON.
                return message;
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    Future<PayResponse> payForTrip(String token, int tripSearchResultID,
        PayMethod paymentMethod) async {
        final params = {
            'trip_search_result_id': tripSearchResultID.toString(),
            'payment_method': paymentMethod.index.toString(),
        };

        final uri = getFullUrl('api/trips/pay');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body;
                // then parse the JSON.
                return PayResponse.fromJson(details);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    Future<PaymentsResponse> sendNonceForTrip(String token, String? nonce, int planId) async {
        final params = {
            'nonce': nonce,
            'plan_id': planId.toString(),
        };

        final uri = getFullUrl('api/users/capture-braintree');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body;
                // then parse the JSON.
                return PaymentsResponse.fromJson(details);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    Future<PaymentsResponse> captureRazorPayPayment(String token, String? paymentID, int planId) async {
        final params = {
            'razorpay_payment_id': paymentID,
            'plan_id': planId.toString(),
        };

        final uri = getFullUrl('api/users/capture-razorpay-payment');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body;
                // then parse the JSON.
                return PaymentsResponse.fromJson(details);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    Future<PaymentsResponse> sendPaytabsTransRef(String token, String? tranRef) async {
        final params = {
            'tran_ref': tranRef,
        };

        final uri = getFullUrl('api/users/capture-paytabs-payment');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body;
                // then parse the JSON.
                return PaymentsResponse.fromJson(details);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    //initiateStripePayment
    Future<Map<String, dynamic>> initiateStripePayment(String token, int planId) async {
        final params = {
            'plan_id': planId.toString(),
        };

        final uri = getFullUrl('api/users/initialize-stripe-payment');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body;
                String? paymentIntentClientSecret = details["payment_intent"];
                String? paymentIntentId = details["payment_intent_id"];
                // then parse the JSON.
                return {
                    "payment_intent_client_secret": paymentIntentClientSecret,
                    "payment_intent_id": paymentIntentId,
                };
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    //captureStripePayment
    Future<PaymentsResponse> captureStripePayment(String token, String? paymentIntent, int planId) async {
        final params = {
            'payment_intent': paymentIntent,
            'plan_id': planId.toString(),
        };

        final uri = getFullUrl('api/users/capture-stripe-payment');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body;
                // then parse the JSON.
                return PaymentsResponse.fromJson(details);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    //capturePayStackPayment
    Future<PaymentsResponse> capturePayStackPayment(String token, String? reference, int planId) async {
        final params = {
            'reference': reference,
            'plan_id': planId.toString(),
        };

        final uri = getFullUrl('api/users/capture-paystack-payment');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body;
                // then parse the JSON.
                return PaymentsResponse.fromJson(details);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    Future<PaymentsResponse> captureFlutterWavePayment(String token, String? transactionID, int planId) async {
        final params = {
            'transaction_id': transactionID,
            'plan_id': planId.toString(),
        };

        final uri = getFullUrl('api/users/capture-flutterwave-payment');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try{
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var details = body;
                // then parse the JSON.
                return PaymentsResponse.fromJson(details);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e){
            throw Exception(e.toString());
        }
    }

    //getPayments
    Future<PaymentsResponse> getWalletCharges(String token) async {
        final uri = getFullUrl('api/users/wallet-charges');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try {
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                // then parse the JSON.
                return PaymentsResponse.fromJson(body);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                error ??= body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }

    }

    //getReservationDetails
    Future<Reservation?> getReservationDetails(String token, int? studentId, bool? morning) async {

        final params = {
            'student_id': studentId.toString(),
            'morning': morning == true ? "1" : "0",
        };

        final uri = getFullUrl('api/reservations/get-reservation-details', params);

        if(localTest) {
            await Future.delayed(const Duration(seconds: 3));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token'
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                return http.Response('Error: time out',
                    500);
            },
        );
        try {
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var reservation = body["reservation"];
                if(reservation == null) {
                    return null;
                }
                // then parse the JSON.
                return Reservation.fromJson(reservation);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else
            if (resp.statusCode == 404 && resp.reasonPhrase == "Not Found") {
                throw Exception("not found");
            }
            else {
                var error = body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch (e) {
            throw Exception(e.toString());
        }
    }

    Future<ReservationsResponse> getReservations(String token) async {
        final uri = getFullUrl('api/users/reservations');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 2));
        }

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        try {
            var body = jsonDecode(resp.body);

            if (resp.statusCode == 200) {
                // If the server did return a 200 OK response,
                var reservations = body["reservations"];
                // then parse the JSON.
                return ReservationsResponse.fromJson(reservations);
            }
            else
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var error = body["errors"];
                error ??= body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
        catch(e)
        {
            throw Exception(e.toString());
        }

    }

    Future<Place> createEditPlace(String token, Place place) async {
        final params = {
            'place': place.toJson(),
        };
        if(localTest) {
          await Future.delayed(const Duration(seconds: 3));
        }
        //token = token+"11";
        final uri = getFullUrl('api/places/add-edit-place');

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode == 200) {
            // then parse the JSON.
            var body = jsonDecode(resp.body);
            var place = body["place"];
            return Place.fromJson(place);
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var body = jsonDecode(resp.body);
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }


    Future<String> deleteGuardian(String token, int? id) async { // deauthorize device
        final params = {
            'id': id,
        };

        final uri = getFullUrl('api/users/delete-guardian');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.delete(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params)).timeout(
            Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);

        if (resp.statusCode == 200) {
            // If the server did return a 200 OK response,
            // then parse the JSON.
            return "";
        }
        else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }


    Future<String> requestDeleteAccount(String token) async {
        final uri = getFullUrl('api/users/request-delete-parent');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(
            Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);

        if (resp.statusCode == 200) {
            // If the server did return a 200 OK response,
            // then parse the JSON.
            return "";
        }
        else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    //deleteStudent
    Future<String> deleteStudent(String token, int? id) async { // deauthorize device
        final params = {
            'id': id,
        };

        final uri = getFullUrl('api/users/delete-student');

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.delete(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params)).timeout(
            Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);

        if (resp.statusCode == 200) {
            // If the server did return a 200 OK response,
            // then parse the JSON.
            return "";
        }
        else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    Future<String> deletePlace(String token, int id) async {
        final params = {
            'id': id,
        };

        if(localTest) {
            await Future.delayed(const Duration(seconds: 3));
            return "";
        }

        final uri = getFullUrl('api/places/delete-place');

        Response resp = await http.delete(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params)).timeout(
            Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);

        if (resp.statusCode == 200) {
            // If the server did return a 200 OK response,
            // then parse the JSON.
            return "";
        }
        else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    getFullUrl(String s, [Map<String, String>? params]) {
        Uri uri;
        String webUrl = Config.webUrl;
        String? path;
        //get substring from first / if exists
        if (webUrl.contains("/")) {
            path = "${webUrl.substring(webUrl.indexOf("/"))}/";
            webUrl = webUrl.substring(0, webUrl.indexOf("/"));
        }
        if(path != null) {
            s = path + s;
        }

        if (Config.serverUrl.startsWith("https")) {
            uri = Uri.https(
                webUrl, s, params);
        } else {
            uri = Uri.http(
                webUrl, s, params);
        }
        return uri;
    }

    Future<void> createComplaint(String? token, String? complaint, int? reservationId,
        double? customerLat, double? customerLng) async {
        final uri = getFullUrl('api/complaints/create');

        final params = {
            'reservation_id': reservationId.toString(),
            'complaint': complaint,
            'customer_lat': customerLat.toString(),
            'customer_lng': customerLng.toString()
        };

        if(localTest) {
            await Future.delayed(const Duration(seconds: 1));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode != 200) {
            if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
                throw Exception("unauthenticated");
            }
            else {
                var body = jsonDecode(resp.body);
                var error = body["errors"];
                error ??= body["message"];
                // If the server did not return a 200 OK response,
                // then throw an exception.
                throw Exception(error.toString());
            }
        }
    }

    //To be included in the next release
    /// ********************************************************************
    Future<NotificationsResponse> getNotifications(String token) async
    {
        Uri uri = getFullUrl('api/notifications/list-all');

        Response resp = await http.get(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            }).timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });


        if (resp.statusCode == 200) {
            var body = jsonDecode(resp.body);
            // If the server did return a 200 OK response,
            var notifications = body["notifications"];
            // then parse the JSON.
            return NotificationsResponse.fromJson(notifications);
        }
        else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var body = jsonDecode(resp.body);
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    Future<String> markNotificationAsSeen(String token, int id) async {
        final params = {
            'id': id.toString(),
        };

        Uri uri = getFullUrl('api/notifications/mark-as-seen');

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(params))
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);
        if (resp.statusCode == 200) {
            // then parse the JSON.
            return "";
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    Future<String> markAllNotificationAsSeen(String token) async {
        //token = token+"11";
        Uri uri = getFullUrl('api/notifications/mark-all-as-seen');

        //local test
        if(localTest) {
            await Future.delayed(const Duration(seconds: 2));
        }

        Response resp = await http.post(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },)
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);
        if (resp.statusCode == 200) {
            // then parse the JSON.
            return "";
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }

    //deleteAllNotifications
    Future<String> deleteAllNotifications(String token) async {
        Uri uri = getFullUrl('api/notifications/delete-all-notifications');

        //local test
        if(localTest) {
            await Future.delayed(const Duration(seconds: 2));
        }

        Response resp = await http.delete(uri,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
            },)
            .timeout(Duration(seconds: Constant.timeOut),
            onTimeout: () {
                // time has run out, do what you wanted to do
                throw Exception('Time out. Please try again later');
            },
        ).catchError((e) {
            throw Exception(e.toString());
        });

        var body = jsonDecode(resp.body);
        if (resp.statusCode == 200) {
            // then parse the JSON.
            return "";
        } else
        if (resp.statusCode == 401 && resp.reasonPhrase == "Unauthorized") {
            throw Exception("unauthenticated");
        }
        else {
            var error = body["errors"];
            error ??= body["message"];
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception(error.toString());
        }
    }


/// ********************************************************************
}
