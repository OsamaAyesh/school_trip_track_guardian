

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:school_trip_track_guardian/connection/response/trip_search_response.dart';
import 'package:school_trip_track_guardian/model/route_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:school_trip_track_guardian/connection/all_apis.dart';
import 'package:school_trip_track_guardian/connection/response/auth_response.dart';
import 'package:school_trip_track_guardian/connection/utils.dart';
import 'package:school_trip_track_guardian/model/constant.dart';
import 'package:school_trip_track_guardian/model/device.dart';
import 'package:school_trip_track_guardian/model/loading_state.dart';
import 'package:school_trip_track_guardian/model/my_notification.dart';
import 'package:school_trip_track_guardian/model/push_notification.dart';
import 'package:school_trip_track_guardian/model/setting.dart';
import 'package:school_trip_track_guardian/model/trip.dart';
import 'package:school_trip_track_guardian/model/user.dart';
import 'package:school_trip_track_guardian/services/service_locator.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:school_trip_track_guardian/utils/auth.dart';
import 'package:school_trip_track_guardian/utils/twitter_auth.dart';
import 'package:laravel_echo/laravel_echo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../connection/response/payments_response.dart';
import '../model/plan.dart';
import '../model/student_details_info.dart';
import '../model/payment_info.dart';
import '../model/place.dart';
import '../model/reservation.dart';
import '../model/route_info.dart';
import '../model/stop.dart';
import '../utils/config.dart';

class MapData{
  LatLng? _latLng;
  String? _address;

  LatLng? get currentLatLng => _latLng;
  String? get currentAddress => _address;


  set currentLatLng(LatLng? latLng) {
    _latLng = latLng;
  }

  set currentAddress(String? address) {
    _address = address;
  }

  void clear() {
    _latLng = null;
    _address = null;
  }
}

class ThisApplicationViewModel extends ChangeNotifier {
  final AllApis _apiService = serviceLocator<AllApis>();

  late String firebaseToken;

  MapData? mapData;
  int nameTextFeildMaxLength = 30;
  GoogleMapController? mapController;
  void setCurrentMapAddress(String? address) { // this is the function that is called when the address is changed
    mapData?.currentAddress = address;
    notifyListeners();
  }

  void setCurrentMapLatLng(LatLng? latLng) { // When the latlng is changed this function is called
    mapData?.currentLatLng = latLng;
    notifyListeners();
  }

  /////////////////////////////////////////////Auth///////////////////////////

  Auth auth = serviceLocator<Auth>();
  bool? isLoggedIn;
  String? apiToken;
  DbUser? currentUser;



  IO.Socket? socket;
  Echo? echo;
  bool echoConnected = false;
  double? busLat, busLng, busSpeed;
  void initEcho() {
    socket = IO.io(
      '${Config.socketUrl}:${Config.socketPort}',
      IO.OptionBuilder()
          .disableAutoConnect()
          .setTransports(['websocket']).build(),
    );

    echo = Echo(
      broadcaster: EchoBroadcasterType.SocketIO,
      client: socket,
    );

    echo?.connect();

    echo?.connector.socket.on('connect', (_) {
      if (kDebugMode) {
        print('socket connected');
      }
      echoConnected = true;
      Future.delayed(Duration.zero,(){
        notifyListeners();
      });
    });

    echo?.connector.socket.on('disconnect', (_) {
      if (kDebugMode) {
        print('socket disconnected');
      }
      echoConnected = false;
      Future.delayed(Duration.zero,(){
        notifyListeners();
      });

    });
  }

  void connectEcho()
  {
    echo?.connect();
  }

  void disconnectEcho()
  {
    echo?.disconnect();
  }

  //leave channel
  void leaveChannel(String? channelId) {
    if(channelId == null) return;
    echo?.leave(channelId);
  }

  //listenToEcho
  void listenToEcho(String? channelId, String eventName) {
    if(channelId == null) return;
    echo?.channel(channelId)
        .listen(eventName, (e) {
      if (kDebugMode) {
        print('echo  $e');
      }
      Map<String, dynamic> data = jsonDecode(e['data']);
      busLat = double.parse(data['lat']);
      busLng = double.parse(data['lng']);
      busSpeed = double.parse(data['speed']);
      print('busLat: $busLat, busLng: $busLng, busSpeed: $busSpeed');
      notifyListeners();
    });
  }


  LoadingState? signInLoadingState = LoadingState();
  LoadingState? signOutLoadingState = LoadingState();
  LoadingState? signUpLoadingState = LoadingState();

  Future<void> initPlatformState() async { // Initialize the platform state
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) { // Gets the android device info and build data
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.id,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) { // Gets the ios device info and build data
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Future<void> isUserLoggedIn() async { // Checks if the user is logged in
    await getCurrentUser();
    String? t = await getApiToken();
    isLoggedIn = (t != null);
    if(isLoggedIn == true) {
      try {
        AuthResponse? resp = await _apiService.verifyUser(
            apiToken!, deviceData["model"]);
        if (resp == null) {
          signOut();
        }
        else {
          currentUser = resp.user;
          settings ??= Setting();
          settings = resp.settings;
          if (currentUser?.role != 4 && currentUser?.role != 5) {
            signOut();
          }
        }
      }
      catch (e) {
        if (kDebugMode) {
          print(e);
        }
        signOut();
      }
    }
    notifyListeners();
  }

  Future<String?> getApiToken() async { // Gets the api token from the shared preferences
    if (apiToken == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      apiToken = prefs.getString('apiToken');
    }
    if (kDebugMode) {
      print(apiToken);
    }
    return apiToken;
  }

  Future<DbUser?> getCurrentUser() async { // Gets the current user from the shared preferences
    if (currentUser == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? currentUserString = prefs.getString('currentUser');

      if (currentUserString == null) return null;

      dynamic currentUserDynamic = jsonDecode(currentUserString);
      currentUser = DbUser.fromJson(currentUserDynamic);
    }
    return currentUser;
  }

  Future<String?> signOut() async { // Signs out the user
    signOutLoadingState?.setLoadingStatus(ScreenState.LOADING, this);
    await auth.signOut().catchError((e) async {
      await onError(e, signOutLoadingState!);
    });
    clearAllUserData();

    apiToken = null;
    currentUser = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('apiToken');
    await prefs.remove('currentUser');
    await isUserLoggedIn();
    notifyListeners();
    return null;
  }

  Future<void> authWithOurServer(String? name, String token, bool signIn) async { // Authenticates with our server
    AuthResponse? authResponse;
    if (signIn) {
      signInLoadingState?.setError(null);
      authResponse = await _apiService
          .loginViaToken(token, deviceData["model"], firebaseToken)
          .catchError((e) async {
        await onError(e, signInLoadingState!);
        signInLoadingState?.setLoadingStatus(ScreenState.FINISH, this);
        return null;
      });
      if (authResponse != null) {
        currentUser = authResponse.user;
        //check if user is customer
        if (currentUser?.role != 4 && currentUser?.role != 5) {
          await signOut();
          signInLoadingState?.setError(1);
          signInLoadingState?.error = "You are not a guardian";
          signInLoadingState?.setLoadingStatus(ScreenState.FINISH, this);
          return;
        }
        apiToken = authResponse.token;
        // settings = authResponse.settings;

        // getPaymentsEndpoint();
        // getReservationsEndpoint();
        // getFavoritesEndpoint();
        // getNotificationsEndpoint();
      }
    } else {
      //sign up
      signUpLoadingState?.setError(null);
      authResponse = await _apiService
          .createUser(name!, token, deviceData["model"], firebaseToken)
          .catchError((e) async {
        await onError(e, signUpLoadingState!);
        return null;
      });
      if (authResponse != null) {
        currentUser = authResponse.user;
        apiToken = authResponse.token;
        getPaymentsEndpoint();
        getReservationsEndpoint();
        getFavoritesEndpoint();
        // settings = authResponse.settings;
      }
    }

    if (apiToken != null && currentUser != null) {
      //save to shared pref here
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('apiToken', apiToken!);
      String currentUserString = jsonEncode(currentUser?.toJson());
      await prefs.setString('currentUser', currentUserString);
      signInLoadingState?.setError(null);
    }

    if (authResponse != null &&
        authResponse.userNotifications != null &&
        authResponse.userNotifications!.isNotEmpty) {
      notificationsList.clear();
      notificationsList.addAll(authResponse.userNotifications as Iterable<MyNotification>);
      notifyListeners();
    }
  }

  void clearAllUserData() {
    notificationsList.clear();
    unseenNotificationsCount = 0;

    activeReservations.clear();
    pastReservations.clear();
  }
  LoadingState resetPasswordLoadingState = LoadingState();

  void resetPassword(String email, BuildContext context) { //Forgot password
    resetPasswordLoadingState.setError(null);
    resetPasswordLoadingState.setLoadingStatus(ScreenState.LOADING, this);
    auth.sendPasswordResetEmail(email).then((value) {
      resetPasswordLoadingState.setError(null);
      Fluttertoast.showToast(
          msg:
          'Password reset link sent to your email successfully.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.normalGrey,
          textColor: Colors.white);

      Future.delayed(const Duration(milliseconds: 50), () {
        Navigator.pop(context);
      });
    }).catchError((e) async {
      await onError(e, resetPasswordLoadingState);
    }).whenComplete(() {
      resetPasswordLoadingState.setLoadingStatus(ScreenState.FINISH, this);
      notifyListeners();
    });
  }

  Future<String?> signIn(String? email, String? password) async { // Signs in the user using email and password
    signInLoadingState?.setError(null);
    apiToken = null;
    signInLoadingState?.setLoadingStatus(ScreenState.LOADING, this);
    String? token = await auth.signIn(email!, password!).catchError((e) async {
      signInLoadingState?.setLoadingStatus(ScreenState.FINISH, this);
      await onError(e, signInLoadingState!);
      return null;
    });
    if (token != null) {
      await authWithOurServer(null, token, true);
    }
    await isUserLoggedIn();
    return apiToken;
  }

  Future<String?> signUp(String? name, String? email, String? password) async { // Signs up the user using email and password
    signUpLoadingState?.setError(null);
    apiToken = null;
    signUpLoadingState?.setLoadingStatus(ScreenState.LOADING, this);
    String? token = await auth.createUser(email, password).catchError((e) async {
      signUpLoadingState?.setLoadingStatus(ScreenState.FINISH, this);
      await onError(e, signUpLoadingState!);
      return null;
    });
    if (token != null) {
      await authWithOurServer(name, token, false);
    }
    await isUserLoggedIn();
    return apiToken;
  }

  Future<String?> authWithFacebook(bool signIn) async { // Authenticates with facebook
    signIn
        ? signInLoadingState?.setError(null)
        : signUpLoadingState?.setError(null);
    apiToken = null;
    signIn
        ? signInLoadingState?.setLoadingStatus(ScreenState.LOADING, this)
        : signUpLoadingState?.setLoadingStatus(ScreenState.LOADING, this);

    UserCredential? userCredential =
        await auth.signInWithFacebook().catchError((e) async {
      await onError(e, signIn ? signInLoadingState! : signUpLoadingState!);
      return null;
    });
    if (userCredential != null) {
      String? token = await userCredential.user?.getIdToken(true);
      await authWithOurServer(
          userCredential.additionalUserInfo!.profile!["name"], token!, signIn);
    }
    await isUserLoggedIn();
    if (apiToken != null) {
      if (kDebugMode) {
        print("apiToken: ${apiToken!}");
      }
    }
    return apiToken;
  }

  Future<String?> authWithTwitter(bool signIn) async { // Authenticates with twitter
    signIn
        ? signInLoadingState?.setError(null)
        : signUpLoadingState?.setError(null);
    apiToken = null;
    signIn
        ? signInLoadingState?.setLoadingStatus(ScreenState.LOADING, this)
        : signUpLoadingState?.setLoadingStatus(ScreenState.LOADING, this);
    UserCredential? userCredential =
        await signInWithTwitter().catchError((e) async {
      await onError(e, signIn ? signInLoadingState! : signUpLoadingState!);
      return null;
    });
    if (userCredential != null) {
      String? token = await userCredential.user?.getIdToken(true);
      await authWithOurServer(
          userCredential.additionalUserInfo?.profile!["name"], token!, signIn);
    }
    await isUserLoggedIn();
    if (apiToken != null)
      {if (kDebugMode) {
        print("apiToken: ${apiToken!}");
      }}
    return apiToken;
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential?> signInWithApple() async { // Authenticates with apple (firebase function)
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  Future<String?> authWithApple(bool signIn) async {
    // Authenticates with apple
    signIn
        ? signInLoadingState?.setError(null)
        : signUpLoadingState?.setError(null);
    apiToken = null;
    signIn
        ? signInLoadingState?.setLoadingStatus(ScreenState.LOADING, this)
        : signUpLoadingState?.setLoadingStatus(ScreenState.LOADING, this);
    UserCredential? userCredential =
    await signInWithApple().catchError((e) async {
      await onError(e, signIn ? signInLoadingState! : signUpLoadingState!);
      return null;
    });
    if (userCredential != null) {
      String? token = await userCredential.user?.getIdToken(true);
      String name = "";
      if (userCredential.additionalUserInfo?.profile!["name"] != null) {
        name = userCredential.additionalUserInfo?.profile!["name"];
      } else {
        String email = userCredential.additionalUserInfo?.profile!["email"];
        final startIndex = email.indexOf('@');
        name = email.substring(0, startIndex);
      }
      await authWithOurServer(name, token!, signIn);
      await isUserLoggedIn();
      if (apiToken != null) {
        if (kDebugMode) {
          print("apiToken: ${apiToken!}");
        }
      }
      return apiToken;
    }
    else {
      return null;
    }
  }

  Future<String?> authWithGoogle(bool signIn) async { // Authenticates with google
    signIn
        ? signInLoadingState?.setError(null)
        : signUpLoadingState?.setError(null);
    apiToken = null;
    signIn
        ? signInLoadingState?.setLoadingStatus(ScreenState.LOADING, this)
        : signUpLoadingState?.setLoadingStatus(ScreenState.LOADING, this);
    UserCredential? userCredential =
        await auth.signInWithGoogle().catchError((e) async {
      await onError(e, signIn ? signInLoadingState! : signUpLoadingState!);
      return null;
    });
    if (userCredential != null) {
      String? token = await userCredential.user?.getIdToken(true);
      await authWithOurServer(
          userCredential.additionalUserInfo?.profile!["name"], token!, signIn);
    }
    await isUserLoggedIn();
    if (apiToken != null) {if (kDebugMode) {
      print("apiToken: ${apiToken!}");
    }}
    return apiToken;
  }

  ////////////////////////////all guardians////////////////////////////////////
  LoadingState allGuardiansLoadingState = LoadingState();
  List<DbUser> allGuardians = [];
  void getAllGuardiansEndpoint() { // Gets all students from the server
    if (apiToken == null) return;
    callEndpoint(_apiService.getAllGuardians(apiToken!), allGuardiansLoadingState, this,
            (resp) {
              allGuardians = resp.items;
          allGuardiansLoadingState.setError(null);
        });
  }

  //////////////////////////////allStudents////////////////////////////////////
  LoadingState allStudentsLoadingState = LoadingState();
  List<DbUser> allStudents = [];
  void getAllStudentsEndpoint() { // Gets all students from the server
    if (apiToken == null) return;
    callEndpoint(_apiService.getAllStudents(apiToken!), allStudentsLoadingState, this,
        (resp) {
      allStudents = resp.items;
      allStudentsLoadingState.setError(null);
    });
  }

  /////////////////////////////////////schools/////////////////////////////////
  List<DbUser> schools = [];
  LoadingState schoolsLoadingState = LoadingState();

  void getSchoolsEndpoint() {
    if (apiToken == null) return;
    callEndpoint(_apiService.getAllSchools(apiToken!), schoolsLoadingState, this,
            (resp) {
          schools = resp.items;
          schoolsLoadingState.setError(null);
        });
  }

  DbUser? selectedSchool;
  LoadingState getSchoolByCodeLoadingState = LoadingState();
  void getSchoolByCodeEndpoint(String? code) { //Get school by code
    if (apiToken == null) return;
    callEndpoint(_apiService.getSchoolByCode(apiToken!, code), getSchoolByCodeLoadingState, this, (resp) {
      getSchoolByCodeLoadingState.setError(null);
      selectedSchool = resp;
      notifyListeners();
    });
  }
  ////////////////////////////// getClosestStops//////////////////////////////
  LoadingState closestStopsLoadingState = LoadingState();
  List<Stop> closestStops = [];
  void getClosestStopsEndpoint(int? studentId, double? lat, double? lang, bool? pickUp) { // Gets the closest stops from the server
    if (apiToken == null) return;
    callEndpoint(_apiService.getClosestStops(apiToken!, studentId, lat, lang, pickUp),
        closestStopsLoadingState, this, (resp) {
      closestStops = resp.items;
      closestStopsLoadingState.setError(null);
    });
  }

  /////////////////////////////// get Student Details /////////////////////////
  LoadingState studentDetailsLoadingState = LoadingState();
  DbUser? student;
  void getStudentDetailsEndpoint(int? id) { // Gets the details of a student from the server
    if (apiToken == null) return;
    callEndpoint(_apiService.getStudentDetails(apiToken!, id),
        studentDetailsLoadingState, this, (resp) {
      student = resp;
      studentDetailsLoadingState.setError(null);
    });
  }

  //////////////////////////// set-pickup-drop-off ///////////////////////////
  LoadingState setPickupDropOffLoadingState = LoadingState();
  void setPickupDropOffEndpoint(int? studentId, int? stopId,
      int? routeId, int? tripId, bool? pickUp, BuildContext context) { // Sets the pickup or drop off of a student
    if (apiToken == null) return;
    callEndpoint(_apiService.setPickupDropOff(apiToken!, studentId, stopId, routeId, tripId, pickUp),
        setPickupDropOffLoadingState, this, (resp) {
      setPickupDropOffLoadingState.setError(null);

      student = resp;
      //update student in all students list
      for (int i = 0; i < allStudents.length; i++) {
        if (allStudents[i].id == studentId) {
          allStudents[i].studentDetails = resp.studentDetails;
          break;
        }
      }

      Fluttertoast.showToast(
          msg: 'Pickup/Drop off set successfully.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.normalGrey,
          textColor: Colors.white);
    }, context: context, popCount: 2);
  }

  LoadingState setPickupDropOffLocationLoadingState = LoadingState();
  void setPickupDropOffLocationEndpoint(int? studentId, double? lat,
      double? lng, String? address, bool? pickUp, BuildContext context) {
    if (apiToken == null) return;
    callEndpoint(_apiService.setPickupDropOffLocation(apiToken!, studentId, lat, lng, address, pickUp),
        setPickupDropOffLocationLoadingState, this, (resp) {
          setPickupDropOffLocationLoadingState.setError(null);

          student = resp;
          //update student in all students list
          for (int i = 0; i < allStudents.length; i++) {
            if (allStudents[i].id == studentId) {
              allStudents[i].studentDetails = resp.studentDetails;
              break;
            }
          }

          Fluttertoast.showToast(
              msg: 'Pickup/Drop off set successfully. The change will take effect from tomorrow.',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: AppTheme.normalGrey,
              textColor: Colors.white);
        }, context: context, popCount: 1);
  }

  /////////////////////// delete guardian /////////////////////////////////
  LoadingState deleteGuardianLoadingState = LoadingState();
  int? deleteGuardianId;
  void deleteGuardianEndpoint(int? id) { // Deletes a guardian from the server
    if (apiToken == null) return;
    deleteGuardianLoadingState.error = null;
    deleteGuardianId = id;
    callEndpoint(_apiService.deleteGuardian(apiToken!, id),
        deleteGuardianLoadingState, this, (_) {
      deleteGuardianLoadingState.setError(null);

      for (int i = 0; i < allGuardians.length; i++) {
        if (allGuardians[i].id == id) {
          allGuardians.removeAt(i);
          break;
        }
      }
      Fluttertoast.showToast(
          msg: 'Guardian deleted successfully.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.normalGrey,
          textColor: Colors.white);

    });
  }

  ////////////////////////////////add new guardian/////////////////////////////
  LoadingState addNewGuardianLoadingState = LoadingState();
  void addGuardianEndpoint(String? email, String? name, BuildContext context) {
    // Adds a new guardian to the server
    if (apiToken == null) return;
    callEndpoint(_apiService.addGuardian(
        apiToken!,
        email, name),
        addNewGuardianLoadingState, this,
            (resp) {
          addNewGuardianLoadingState.setError(null);
          allGuardians.add(resp);
          Fluttertoast.showToast(
              msg: 'Guardian added successfully.',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: AppTheme.normalGrey,
              textColor: Colors.white);
        });
  }

  /////////////////////////////////add new student/////////////////////////////
  LoadingState addNewStudentLoadingState = LoadingState();
  void addEditStudentEndpoint(int? id, String? name, String? studentIdentifier,
      String? notes, String? picFile, int? schoolId, BuildContext context) {
    // Adds a new student to the server
    if (apiToken == null) return;
    callEndpoint(_apiService.addEditStudent(
        apiToken!,
        id,
        name,
        studentIdentifier,
        notes,
        picFile,
        schoolId),
        addNewStudentLoadingState, this,
            (resp) {
          addNewStudentLoadingState.setError(null);
          if (id == null) {
            allStudents.add(resp);
            Fluttertoast.showToast(
                msg: 'Student added successfully.',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: AppTheme.normalGrey,
                textColor: Colors.white);
          }
          else {
            for (int i = 0; i < allStudents.length; i++) {
              if (allStudents[i].id == id) {
                allStudents[i] = resp;
                break;
              }
            }
            Fluttertoast.showToast(
                msg: 'Student updated successfully.',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: AppTheme.normalGrey,
                textColor: Colors.white);
          }
        }, context: context);
  }

  ///////////////////////////set absent student///////////////////////////////////
  LoadingState setAbsentStudentLoadingState = LoadingState();
  void setAbsentStudentEndpoint(int? id) { // Sets a student as absent
    if (apiToken == null) return;
    setAbsentStudentLoadingState.error = null;
    callEndpoint(_apiService.setAbsentStudent(apiToken!, id),
        setAbsentStudentLoadingState, this, (resp) {
      setAbsentStudentLoadingState.setError(null);

      student?.studentDetails?.absentOn = resp;
      //update student in all students list
      for (int i = 0; i < allStudents.length; i++) {
        if (allStudents[i].id == student?.id) {
          allStudents[i].studentDetails?.absentOn =
              student?.studentDetails?.absentOn;
          break;
        }
      }

      Fluttertoast.showToast(
          msg: 'Student status updated successfully.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.normalGrey,
          textColor: Colors.white);
    });
  }

  /////////////////////////////////delete student/////////////////////////////
  LoadingState deleteStudentLoadingState = LoadingState();
  void deleteStudentEndpoint(int? id, BuildContext context) { // Deletes a student from the server
    if (apiToken == null) return;
    callEndpoint(_apiService.deleteStudent(apiToken!, id),
        deleteStudentLoadingState, this, (_) {
      deleteStudentLoadingState.setError(null);

      for (int i = 0; i < allStudents.length; i++) {
        if (allStudents[i].id == id) {
          allStudents.removeAt(i);
          break;
        }
      }
      Fluttertoast.showToast(
          msg: 'Student deleted successfully.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.normalGrey,
          textColor: Colors.white);

    }, context: context);
  }

  //requestDeleteAccount
  LoadingState requestDeleteAccountLoadingState = LoadingState();
  void requestDeleteAccountEndpoint() { // Requests to delete the account
    if (apiToken == null) return;
    callEndpoint(_apiService.requestDeleteAccount(apiToken!),
        requestDeleteAccountLoadingState, this, (_) {
      requestDeleteAccountLoadingState.setError(null);
      Fluttertoast.showToast(
          msg: 'Request sent successfully.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.normalGrey,
          textColor: Colors.white);
      signOut();
    });
  }

  /////////////////////////////////////////////Devices///////////////////////////

  Map<String, dynamic> deviceData = <String, dynamic>{};

  List<Device> devices = [];
  LoadingState devicesLoadingState = LoadingState();

  LoadingState deviceDeletingState = LoadingState();
  int? deviceDeletingIdx;

  void getDevicesEndpoint() { // Gets all devices from the server
    print("Api token in getDevices: $apiToken");
    if (apiToken == null) return;
    callEndpoint(_apiService.getAllDevices(apiToken!), devicesLoadingState, this,
        (resp) {
      devices = resp.items;
      for (int i = 0; i < devices.length; i++) {
        if (devices[i].name == deviceData["model"]) {
          Device tmp = devices[0];
          devices[0] = devices[i];
          devices[i] = tmp;
          break;
        }
      }
      devicesLoadingState.setError(null);
    });
  }

  void deleteDeviceEndpoint(int idx, int id) { //Deauthenticates a device
    if (apiToken == null) return;
    deviceDeletingIdx = idx;
    callEndpoint(_apiService.deleteDevices(apiToken!, id),
        deviceDeletingState, this, (_) {
      deviceDeletingState.setError(null);
      devices.removeAt(idx);
      notifyListeners();
    });
  }



  //////////////////////////// Complaints //////////////////////////////////////
  LoadingState createComplaintLoadingState = LoadingState();
  void createComplaintEndpoint(BuildContext context, String? complaint, int? reservationId) {
    // Gets all stops from the server
    if (apiToken == null) return;

    bool? locationServiceStatus;
    Position? currentGPSLocation;

    createComplaintLoadingState.loadError = null;
    createComplaintLoadingState.setLoadingStatus(ScreenState.LOADING, this);
    checkLocationService(context).then((LocationServicesStatus value) {
      locationServiceStatus = value == LocationServicesStatus.enabled;
      if (locationServiceStatus != null && locationServiceStatus!) {
        getLocation().then((value) {
          currentGPSLocation = value;
          callEndpoint(
              _apiService.createComplaint(apiToken!, complaint, reservationId,
                  currentGPSLocation?.latitude, currentGPSLocation?.longitude),
              createComplaintLoadingState, this,
                  (resp) {
                createComplaintLoadingState.setError(null);
                //show toast
                Fluttertoast.showToast(
                    msg: 'Complaint sent successfully.',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: AppTheme.normalGrey,
                    textColor: Colors.white);
              }, context: context);
        });
      }
      else {
        createComplaintLoadingState.error = "Please enable location access to send the complaint";
        createComplaintLoadingState.setError(1);
        createComplaintLoadingState.setLoadingStatus(ScreenState.FINISH, this);
      }
    });
  }

  ////////////////////////////Stops//////////////////////////////////////
  LoadingState stopsLoadingState = LoadingState();
  List<Stop> stops = [];
  void getStopsEndpoint() { // Gets all stops from the server
    if (apiToken == null) return;
    callEndpoint(_apiService.getStops(apiToken!), stopsLoadingState, this,
        (resp) {
      stops = resp.items;
      stopsLoadingState.setError(null);
    });
  }

  ////////////////////////Routes////////////////////////////////////////
  LoadingState routesLoadingState = LoadingState();
  List<RouteInfo> routes = [];
  void getRoutesEndpoint() { // Gets all routes from the server
    if (apiToken == null) return;
    callEndpoint(_apiService.getRoutes(apiToken!), routesLoadingState, this,
        (resp) {
      routes = resp.items;
      routesLoadingState.setError(null);
    });
  }

  ////////////////////////Route Details////////////////////////////////////////
  LoadingState routeDetailsLoadingState = LoadingState();
  RouteDetails? routeDetails;
  void getRouteDetailsEndpoint(int? routeId) { // Gets details of a route from the server
    if (apiToken == null) return;
    callEndpoint(_apiService.getRouteDetails(apiToken!, routeId), routeDetailsLoadingState, this,
        (resp) {
      routeDetails = resp;
      routeDetailsLoadingState.setError(null);
    });
  }

  //getTripDetailsEndpoint
  LoadingState plannedTripDetailsLoadingState = LoadingState();
  Trip? plannedTrip;
  void getPlannedTripDetailsEndpoint(int? tripId) { // Gets details of a planned trip from the server
    if (apiToken == null) return;
    callEndpoint(_apiService.getPlannedTripDetails(apiToken!, tripId),
        plannedTripDetailsLoadingState, this,
            (resp) {
          plannedTrip = resp;
          plannedTripDetailsLoadingState.setError(null);
        });
  }


  LoadingState tripDetailsLoadingState = LoadingState();
  Trip? trip;
  void getTripDetailsEndpoint(int? tripId) { // Gets details of a trip from the server
    if (apiToken == null) return;
    callEndpoint(_apiService.getTripDetails(apiToken!, tripId),
        tripDetailsLoadingState, this,
            (resp) {
          trip = resp;
          tripDetailsLoadingState.setError(null);
        });
  }

  ///////////////////////Notifications//////////////////////////////////
  MyNotification myNotifications = MyNotification();

  List<MyNotification> notificationsList = [];

  LoadingState notificationsLoadingState = LoadingState();
  int unseenNotificationsCount = 0;
  void getNotificationsEndpoint() { // Gets unread notifications
    if (apiToken == null) return;

    callEndpoint(_apiService.getNotifications(apiToken!),
        notificationsLoadingState, this, (resp) {
      notificationsList = resp.items;
      //update unseenNotificationsCount
      unseenNotificationsCount = 0;
      for (int i = 0; i < notificationsList.length; i++) {
        if (notificationsList[i].seen == 0) {
          unseenNotificationsCount++;
        }
      }
      notificationsLoadingState.setError(null);
      notifyListeners();
    });
  }

  void addNewUnseenNotification(PushNotification notification) { //Add unseen notifications
    MyNotification n = MyNotification(
        message: notification.body,
        createdAt: DateFormat("yyyy-MM-dd hh:mm aa").format(DateTime.now()),
        seen: 0,
        id: notification.id != null ? int.parse(notification.id!) : null);
    List<MyNotification> tmp = [];
    tmp.addAll(notificationsList);
    notificationsList.clear();
    unseenNotificationsCount++;
    notifyListeners();
    //wait for 1 second
    Future.delayed(const Duration(milliseconds: 100), () {
      //add new notification
      notificationsList.add(n);
      notificationsList.addAll(tmp);
      notifyListeners();
    });
  }

  LoadingState markAllAsSeenNotificationsLoadingState = LoadingState();

  void markAllNotificationsAsReadEndpoint() { //Mark all notifications as read
    if (apiToken == null) return;

    callEndpoint(_apiService.markAllNotificationAsSeen(apiToken!),
        markAllAsSeenNotificationsLoadingState, this, (_) {
      markAllAsSeenNotificationsLoadingState.setError(null);
      for (int i = 0; i < notificationsList.length; i++) {
        notificationsList[i].seen = 1;
      }
      unseenNotificationsCount = 0;
      notifyListeners();
    });
  }

  //deleteAllNotificationsEndpoint
  LoadingState deleteAllNotificationsLoadingState = LoadingState();
  void deleteAllNotificationsEndpoint() { // Deletes all notifications
    if (apiToken == null) return;

    callEndpoint(_apiService.deleteAllNotifications(apiToken!),
        deleteAllNotificationsLoadingState, this, (_) {
      deleteAllNotificationsLoadingState.setError(null);
      notificationsList.clear();
      unseenNotificationsCount = 0;
      notifyListeners();
    });
  }

  LoadingState markNotificationSeenLoadingState = LoadingState();
  void markNotificationEndpoint(int notificationIdx, int id) {
    // Mark notification as read
    if (apiToken == null) return;
    callEndpoint(_apiService.markNotificationAsSeen(apiToken!, id),
        markNotificationSeenLoadingState,
        this, (_) {
          markNotificationSeenLoadingState.setError(null);
          notificationsList[notificationIdx].seen = 1;
          unseenNotificationsCount--;
          notifyListeners();
        });
  }

  //updateStudentNotificationSettings
  LoadingState updateStudentNotificationSettingsLoadingState = LoadingState();
  void updateStudentNotificationSettingsEndpoint(int? studentId, List<Map<String, dynamic>> allNotificationsSettings, BuildContext context,

      ) { // Updates notification settings of a student
    if (apiToken == null) return;
    callEndpoint(_apiService.updateStudentNotificationSettings(apiToken!, studentId, allNotificationsSettings),
        updateStudentNotificationSettingsLoadingState, this, (_) {
      updateStudentNotificationSettingsLoadingState.setError(null);

      //update student in all students list
      for (int i = 0; i < allStudents.length; i++) {
        if (allStudents[i].id == studentId) {
          Map<String, dynamic>? studentSettings = allStudents[i].studentDetails?.toJson();
          for (int j = 0; j < allNotificationsSettings.length; j++)
          {
            studentSettings?[allNotificationsSettings[j]["key_name"]] = allNotificationsSettings[j]["type"] == "bool" ?
            (allNotificationsSettings[j]["value"] ? 1 : 0) : allNotificationsSettings[j]["value"];
          }
          allStudents[i].studentDetails = StudentDetailsInfo.fromJson(studentSettings!);
          student = allStudents[i];
          break;
        }
      }
      Fluttertoast.showToast(
          msg: 'Notification settings updated successfully.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.normalGrey,
          textColor: Colors.white);
    }, context: context);
  }


  //printStudentCardEndpoint
  LoadingState printStudentCardLoadingState = LoadingState();
  void printStudentCardEndpoint(int? studentId, BuildContext context) { // Prints the student card
    if (apiToken == null) return;
    callEndpoint(_apiService.printStudentCard(apiToken!, studentId),
        printStudentCardLoadingState, this, (_) {
      printStudentCardLoadingState.setError(null);
      Fluttertoast.showToast(
          msg: 'Student card sent to your email successfully.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.normalGrey,
          textColor: Colors.white);
    }, context: context);
  }

  /////////////////////Reservations////////////////////////////////
  List<Reservation> activeReservations = [];
  List<Reservation> pastReservations = [];
  LoadingState reservationsLoadingState = LoadingState();
  void getReservationsEndpoint() { //Get all reservations
    if (apiToken == null) return;

    callEndpoint(_apiService.getReservations(apiToken!), reservationsLoadingState,
        this, (resp) {
      //loop to resp.reservations and check if it is active or past
      activeReservations = [];
      pastReservations = [];
      for (int i = 0; i < resp.items.length; i++) {
        DateTime plannedDate = DateFormat("yyyy-MM-dd").parse(resp.items[i].trip.plannedDate);
        DateTime plannedDateWithoutTime = DateTime(plannedDate.year, plannedDate.month, plannedDate.day);
        DateTime nowWithoutTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        if (resp.items[i].rideStatus!=0 || plannedDateWithoutTime.isBefore(nowWithoutTime) || resp.items[i].trip.endedAt != null) {
          pastReservations.add(resp.items[i]);
        } else {
          activeReservations.add(resp.items[i]);
        }
      }
      reservationsLoadingState.setError(null);
    });
  }

  Reservation? reservationDetails;
  Position? reservationGPSLocation;
  LoadingState reservationDetailsLoadingState = LoadingState();
  void getReservationDetailsEndpoint(int? reservationId, bool? morning, BuildContext context) { // Gets details of a reservation from the server
    if (apiToken == null) return;

    bool? locationServiceStatus;
    reservationDetailsLoadingState.setLoadingStatus(ScreenState.LOADING, this);
    checkLocationService(context).then((LocationServicesStatus value) async {
      locationServiceStatus = value == LocationServicesStatus.enabled;
      if (locationServiceStatus != null && locationServiceStatus!) {
        reservationGPSLocation = await getLocation();
      }
    }).whenComplete(() {
      callEndpoint(_apiService.getReservationDetails(apiToken!, reservationId, morning),
          reservationDetailsLoadingState, this, (resp) {
            reservationDetails = resp;
            reservationDetailsLoadingState.setError(null);
            if(reservationDetails?.trip?.channel != null) {
              listenToEcho(
                  reservationDetails?.trip?.channel, 'TripPositionUpdated');
            }
          });
    });


  }

  /////////////////////Pay//////////////////////////////////////

  void setPaymentResponse(resp)
  {
    settings ??= Setting();
    settings?.currencyCode = resp.currencyCode;
    settings?.paymentMethod = resp.paymentMethod;

    var oldUser = currentUser;
    oldUser!.wallet = resp.walletBalance;
    currentUser = oldUser;

    payments = resp.items!;

    plans = resp.plans;
  }

  //sendRequestCoinsEndpoint
  LoadingState requestCoinsLoadingState = LoadingState();
  void requestCoinsEndpoint(int? planID) { // Requests coins from the server
    if (apiToken == null) return;
    callEndpoint(_apiService.requestCoins(apiToken!, planID),
        requestCoinsLoadingState, this, (resp) {
          requestCoinsLoadingState.setError(null);
          // var oldUser = currentUser;
          // oldUser!.wallet = resp.walletBalance;
          // currentUser = oldUser;
          Fluttertoast.showToast(
              msg: 'Coins request sent successfully.',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: AppTheme.normalGrey,
              textColor: Colors.white);
        });
  }

  //sendNonceForTrip
  LoadingState sendBrainTreeNonceForTripLoadingState = LoadingState();
  void sendBrainTreeNonceForTripEndpoint(String? nonce, int planId) { // Send invoice to server
    if (apiToken == null) return;

    callEndpoint(_apiService.sendNonceForTrip(apiToken!, nonce, planId),
        sendBrainTreeNonceForTripLoadingState, this,
            (resp) {
          if (resp.success) {
            setPaymentResponse(resp);
            sendBrainTreeNonceForTripLoadingState.setError(null);
          }
          else {
            sendBrainTreeNonceForTripLoadingState.setError(resp.message);
          }
        });
  }

  //sendPaymentID for RazorPay
  LoadingState captureRazorPayPaymentLoadingState = LoadingState();
  void captureRazorPayPaymentEndpoint(String? paymentID, int planId) { // Send payment id to server
    if (apiToken == null) return;

    callEndpoint(_apiService.captureRazorPayPayment(apiToken!, paymentID, planId),
        captureRazorPayPaymentLoadingState, this,
            (resp) {
          if (resp.success) {
            setPaymentResponse(resp);
            captureRazorPayPaymentLoadingState.setError(null);
          }
          else {
            captureRazorPayPaymentLoadingState.setError(resp.message);
          }
        });
  }

  //send transactionId for FlutterWave
  LoadingState captureFlutterWavePaymentLoadingState = LoadingState();
  void captureFlutterWavePaymentEndpoint(String? transactionID, int planId) { // Send transaction id to server
    if (apiToken == null) return;

    callEndpoint(_apiService.captureFlutterWavePayment(apiToken!, transactionID, planId),
        captureFlutterWavePaymentLoadingState, this,
            (resp) {
          if (resp.success) {
            setPaymentResponse(resp);
            captureFlutterWavePaymentLoadingState.setError(null);
          }
          else {
            captureFlutterWavePaymentLoadingState.setError(resp.message);
          }
        });
  }

  //initiate Stripe payment
  LoadingState initiateStripePaymentLoadingState = LoadingState();
  Future<Map<String, dynamic>?> initiateStripePaymentEndpoint(int planId) async {
    // Initiate stripe payment
    if (apiToken == null) return null;
    try {
      initiateStripePaymentLoadingState.setLoadingStatus(ScreenState.LOADING, this);
      Map<String, dynamic>? paymentIntent = await _apiService
          .initiateStripePayment(apiToken!, planId);
      String? paymentIntentClientSecret = paymentIntent["payment_intent_client_secret"];
      String? paymentIntentId = paymentIntent["payment_intent_id"];
      initiateStripePaymentLoadingState.setLoadingStatus(ScreenState.FINISH, this);
      if (paymentIntentClientSecret != null && paymentIntentId != null) {
        initiateStripePaymentLoadingState.setError(null);
        return paymentIntent;
      }
      else {
        initiateStripePaymentLoadingState.setError(1);
        return null;
      }
    }
    catch (e) {
      initiateStripePaymentLoadingState.setError(1);
      return null;
    }
  }

  //captureStripePaymentEndpoint
  LoadingState captureStripePaymentLoadingState = LoadingState();
  void captureStripePaymentEndpoint(String? paymentIntent, int planId) { // Capture stripe payment
    if (apiToken == null) return;

    callEndpoint(_apiService.captureStripePayment(apiToken!, paymentIntent, planId),
        captureStripePaymentLoadingState, this,
            (resp) {
          if (resp.success) {
            setPaymentResponse(resp);
            captureStripePaymentLoadingState.setError(null);
          }
          else {
            captureStripePaymentLoadingState.setError(resp.message);
          }
        });
  }

  //capturePayStackPaymentEndpoint
  LoadingState capturePayStackPaymentLoadingState = LoadingState();
  void capturePayStackPaymentEndpoint(String? reference, int planId) { // Capture paystack payment
    if (apiToken == null) return;

    callEndpoint(_apiService.capturePayStackPayment(apiToken!, reference, planId),
        capturePayStackPaymentLoadingState, this,
            (resp) {
          if (resp.success) {
            setPaymentResponse(resp);
            capturePayStackPaymentLoadingState.setError(null);
          }
          else {
            capturePayStackPaymentLoadingState.setError(resp.message);
          }
        });
  }

  //sendTranRef for Paytabs
  LoadingState sendPaytabsTransRefLoadingState = LoadingState();
  void sendPaytabsTransRefEndpoint(String? tranRef) { // Send TranRef to server
    if (apiToken == null) return;

    callEndpoint(_apiService.sendPaytabsTransRef(apiToken!, tranRef),
        sendPaytabsTransRefLoadingState, this,
            (resp) {
          if (resp.success) {
            setPaymentResponse(resp);
            sendPaytabsTransRefLoadingState.setError(null);
          }
          else {
            sendPaytabsTransRefLoadingState.setError(resp.message);
          }
        });
  }

  //fetch all previous payments
  List<PaymentInfo> payments = [];
  List<Plan> plans = [];
  LoadingState paymentsLoadingState = LoadingState();
  void getPaymentsEndpoint() {
    if (apiToken == null) return;

    callEndpoint(_apiService.getWalletCharges(apiToken!), paymentsLoadingState, this,
            (resp) {
              if (resp.success) {
                settings ??= Setting();
                settings?.currencyCode = resp.currencyCode;
                settings?.paymentMethod = resp.paymentMethod;

                payments = resp.items;
                plans = resp.plans;
                var oldUser = currentUser;
                oldUser!.wallet = resp.walletBalance;
                currentUser = oldUser;
                paymentsLoadingState.setError(null);
              }
              else {
                paymentsLoadingState.setError(resp.message);
              }
        });
  }


/////////////////////////////UserPublicProfile///////////////////////////////

  //uploadAvatar
  LoadingState uploadAvatarLoadingState = LoadingState();
  void uploadAvatarEndpoint(String? imagePath) { // Upload avatar
    if (apiToken == null) return;

    callEndpoint(_apiService.uploadAvatar(apiToken!, imagePath),
        uploadAvatarLoadingState, this, (resp) {
      currentUser!.avatar = resp;
      uploadAvatarLoadingState.setError(null);
    });
  }

  LoadingState updateProfileLoadingState = LoadingState();

  void updateProfileEndpoint(BuildContext context,
      String? telNumber, String? address,
      ) { //Update profile
    if (apiToken == null) return;

    callEndpoint(
        _apiService.updateProfile(
            apiToken!,
            address,
            telNumber),
        updateProfileLoadingState,
        this, (resp) {
      currentUser!.address = resp.address;
      currentUser!.telNumber = resp.telNumber;
      updateProfileLoadingState.setError(null);
    }, context: context);
  }
  
  /////////////////////////////FAQ, Terms and conditions///////////////////////////////
  String? terms;
  LoadingState termsLoadingState = LoadingState();

  void getTermsEndpoint() { // Terms URL

    callEndpoint(_apiService.getTerms(), termsLoadingState, this,
        (resp) {
      terms = resp;
      termsLoadingState.setError(null);
    });
  }

  /////////////////////// Settings //////////////////////////////////
  Setting? settings;
  ///////////////////////////////Favorite places //////////////////////////////
  List<Place>? favoritePlaces = [];
  List<LoadingState> deleteFavoritePlacesLoadingStates = [];
  List<LoadingState> deleteRecentPlacesLoadingStates = [];

  LoadingState favoritePlacesLoadingState = LoadingState();
  getFavoritesEndpoint() { //get favorite places
    if (apiToken == null) return;

    callEndpoint(_apiService.getFavoritesOrRecentPlaces(apiToken!, true),
        favoritePlacesLoadingState, this, (resp) {
      favoritePlaces = resp.items;
      deleteFavoritePlacesLoadingStates = List.generate(favoritePlaces!.length, (index) => LoadingState());
      favoritePlacesLoadingState.setError(null);
    });
  }

  List<Place>? recentPlaces = [];
  LoadingState recentPlacesLoadingState = LoadingState();
  
  getRecentPlacesEndpoint() {
    if (apiToken == null) return;

    callEndpoint(_apiService.getFavoritesOrRecentPlaces(apiToken!, false),
        recentPlacesLoadingState, this, (resp) {
          recentPlaces = resp.items;
          deleteRecentPlacesLoadingStates = List.generate(recentPlaces!.length, (index) => LoadingState());
          recentPlacesLoadingState.setError(null);
        });
  }

  LoadingState createPlaceLoadingState = LoadingState();
  void addPlaceEndpoint(Place place, BuildContext context) {
    if (apiToken == null) return;
    createPlaceLoadingState.setError(null);

    callEndpoint(
        _apiService.createEditPlace(apiToken!, place), createPlaceLoadingState,
        this,
            (resp) {
          if (place.favorite == 1) {
            if (place.id == null) {
              //insert at first
              favoritePlaces?.add(resp);
            }
            else {
              //update
              //find index of place
              int index = favoritePlaces!.indexWhere((element) => element.id == place.id);
              favoritePlaces?[index] = resp;
            }
          }
          else {
            // Todo: recent places
          }
          deleteFavoritePlacesLoadingStates.add(LoadingState());
          notifyListeners();
          createPlaceLoadingState.setError(null);
        }, context: context);
  }

  void deletePlaceEndpoint(int placeId, bool isFav, BuildContext? context) {
    if (apiToken == null) return;

    int index = isFav ? favoritePlaces!.indexWhere((element) =>
    element.id == placeId) :
    recentPlaces!.indexWhere((element) => element.id == placeId);

    if (isFav) {
      deleteFavoritePlacesLoadingStates[index] = LoadingState();
    } else {
      deleteRecentPlacesLoadingStates[index] = LoadingState();
    }

    callEndpoint(
        _apiService.deletePlace(apiToken!, placeId), isFav
        ? deleteFavoritePlacesLoadingStates[index]
        : deleteRecentPlacesLoadingStates[index],
        this,
            (resp) {
          (isFav ? favoritePlaces! : recentPlaces!).removeAt(index);
          (isFav
              ? deleteFavoritePlacesLoadingStates
              : deleteRecentPlacesLoadingStates).removeAt(index);
          notifyListeners();
        }, context: context);
  }
}
