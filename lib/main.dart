import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:school_trip_track_guardian/utils/config.dart';
import 'package:school_trip_track_guardian/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icon_badge/icon_badge.dart';
import 'package:ionicons/ionicons.dart';
import 'package:school_trip_track_guardian/gui/screens/wallet_screen.dart';
import 'package:unicons/unicons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'firebase_options.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:school_trip_track_guardian/services/service_locator.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:school_trip_track_guardian/utils/size_config.dart';
import 'package:school_trip_track_guardian/utils/tools.dart';
import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';
import 'package:school_trip_track_guardian/gui/screens/more_screen.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'gui/languages/language_constants.dart';
import 'gui/screens/guardians_screen.dart';
import 'gui/screens/home_screen.dart';
import 'gui/screens/notifications_screen.dart';
import 'gui/screens/sign_in_screen.dart';
import 'gui/widgets/animated_app_bar.dart';
import 'gui/widgets/custom_app_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'gui/widgets/my_interstitial_ad.dart';
import 'model/push_notification.dart';

void showNotification(PushNotification notification) {
  showSimpleNotification(
    Text(
      notification.title!,
      style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.secondary),
    ),
    subtitle: Text(
      notification.body!,
      style: const TextStyle(fontSize: 14, color: AppTheme.darkGrey),
    ),
    background: Colors.white,
    leading: const ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      child: CircleAvatar(
        backgroundImage: AssetImage("assets/images/notification.png"),
        backgroundColor: AppTheme.lightGrey,
      ),
    ),
    duration: const Duration(seconds: 4),
  );

  ThisApplicationViewModel thisAppModel =
  serviceLocator<ThisApplicationViewModel>();
  thisAppModel.addNewUnseenNotification(notification);
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

/////////////////////////////////////////////////////////////////
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("Handling a background message: ${message.data["body"]}");
  }

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'ezbus', 'ezbus',
    icon: '@drawable/ic_stat_ic_notification',
    importance: Importance.max,
    priority: Priority.high,
  );


  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    message.data["title"],
    message.data["body"],
    platformChannelSpecifics,
  );


  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    PushNotification notification = PushNotification(
        title: message.data["title"],
        body: message.data["body"],
        id: message.data["id"]);
    showNotification(notification);
  });
}

////////////////////////////////////////////////////////////////////
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  ///////////////////////////////////////////////////////////
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  ///////////////////////////////////////////////////////////
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);

  ThisApplicationViewModel thisAppModel =
  serviceLocator<ThisApplicationViewModel>();

  String? token = await FirebaseMessaging.instance.getToken();
  if (kDebugMode) {
    print("FirebaseMessaging token ${token!}");
  }
  thisAppModel.firebaseToken = token!;

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(ScreenUtilInit(
        designSize: const Size(1440/4, 3120/4),
        minTextAdapt: false,
        splitScreenMode: false,
        builder: (context, child) {
          return MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: thisAppModel),
              ],
              child: const MaterialApp(
                debugShowCheckedModeBanner: false,
                home: MyApp(),
              ));
        }
    ));
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThisApplicationViewModel thisAppModel =
  serviceLocator<ThisApplicationViewModel>();

  Future<Widget> loadFromFuture() async {
    // await Future.delayed(const Duration(milliseconds: 100), () {
    //   // Do something
    // });
    bool doNotShowLanding = true;
    // doNotShowLanding = await Tools.getDonotShow();
    await thisAppModel.initPlatformState();
    await thisAppModel.isUserLoggedIn();
    thisAppModel.initEcho();
    return MainApp(doNotShowLanding);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AnimatedSplashScreen.withScreenFunction(
      splash: getSplashScreen(),
      centered: true,
      splashIconSize: SizeConfig.screenHeight,
      screenFunction: () async{
        return loadFromFuture();
      },
    );
  }

  Widget getSplashScreen() {
    //screen with logo and spinner below it
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: SizeConfig.screenHeight! * 0.35,
                child: Image.asset(
                  'assets/images/splash.png',
                ),
              ),
              SizedBox(
                height: SizeConfig.screenHeight! * 0.05,
              ),
              Text(
                Config.systemName,
                textAlign: TextAlign.center,
                style: AppTheme.headlineBig,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 30.0.h),
            child: Container(
              alignment: Alignment.bottomCenter,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  final bool? doNotShowLanding;
  const MainApp(this.doNotShowLanding, {Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MainAppState? state = context.findAncestorStateOfType<_MainAppState>();
    state?.setLocale(newLocale);
  }
  static bool isRtl(BuildContext context){
    return Directionality.of(context)==TextDirection.rtl;
  }
}

class _MainAppState extends State<MainApp> {
  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    getLocale().then((locale) {
      setState(() {
        if (kDebugMode) {
          print("locale ${locale.languageCode}");
        }
        _locale = locale;
      });
    });
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: Config.systemName,
          theme: ThemeData(
              scaffoldBackgroundColor: AppTheme.backgroundColor
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: _locale,
          home: const MyHomePage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  FirebaseMessaging? _messaging;
  ThisApplicationViewModel thisAppModel =
  serviceLocator<ThisApplicationViewModel>();
  int notificationCounter = 1;

  String title = Config.systemName;
  final List<Widget> _children = [
    const HomeTab(),
    const WalletScreen(),
    const NotificationsScreen(),
    const GuardiansScreen(),
    const MoreScreen()
  ];
  final List<Widget> _tabIcons = [
    const Icon(UniconsLine.estate),
    const Icon(UniconsLine.wallet),
    const Icon(UniconsLine.bell),
    const Icon(Icons.people),
    const Icon(UniconsLine.ellipsis_h),
  ];
  final List<IconData> _tabIconData = [
    UniconsLine.estate,
    Ionicons.wallet_outline,
    UniconsLine.bell,
    Icons.people,
    UniconsLine.ellipsis_h,
  ];
  PageController? _pageController;

  int _currentIndex = 0;

  bool paymentScreenGuiUpdated = false;
  bool guardianScreenGuiUpdated = false;

  @override
  void dispose() {
    super.dispose();
    MyInterstitialAd.dispose();
  }

  @override
  void initState() {
    super.initState();
    MyInterstitialAd.createInterstitialAd();
    //////////////////////////////////////////////////
    initAndRegisterNotification();
    ////////////////////////////////////////////////////////////////
    _pageController = PageController();
    if (kDebugMode) {
      print("loading ...");
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        thisAppModel.getNotificationsEndpoint();
      });
    });
  }

  void initAndRegisterNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Parse the message received
      PushNotification notification = PushNotification(
          title: message.data["title"],
          body: message.data["body"],
          id: message.data["id"]);
      ThisApplicationViewModel thisAppModel =
      serviceLocator<ThisApplicationViewModel>();

      // For displaying the notification as an overlay
      showNotification(notification);
      // setState(() {
      //   thisAppModel.notificationInfo = notification;
      // });
      showNotificationDialog(context, notification);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
          title: message.data["title"],
          body: message.data["body"],
          id: message.data["id"]
      );

      thisAppModel.isUserLoggedIn().then((_) {
        if (thisAppModel.isLoggedIn!) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const NotificationsScreen()),
          );
        }
      });

      showNotification(notification);
    });
  }

  @override
  Widget build(context) {
    SizeConfig().init(context);

    return Consumer<ThisApplicationViewModel>(
      builder: (context, thisApplicationViewModel, child) {
        Widget firstScreen = _buildFirstScreen(context, thisApplicationViewModel);
        if (thisApplicationViewModel.isLoggedIn!) {
          return firstScreen;
        }
        else {
          return SignInScreen(firstScreen);
        }
      },
    );
  }

  Widget _buildFirstScreen(
      BuildContext context, ThisApplicationViewModel thisApplicationViewModel) {

    if(!paymentScreenGuiUpdated && thisApplicationViewModel.settings != null) {
      if (thisApplicationViewModel.settings?.hidePaymentParents == true) {
        //remove the payment tab
        _children.removeAt(1);
        _tabIcons.removeAt(1);
        _tabIconData.removeAt(1);
        paymentScreenGuiUpdated = true;
      }
      if (thisApplicationViewModel.currentUser?.role == 5 && !guardianScreenGuiUpdated) {
        int guardiansTabIndex = _children.indexWhere((
            element) => element is GuardiansScreen);
        if (guardiansTabIndex != -1) {
          //remove the guardians tab
          _children.removeAt(guardiansTabIndex);
          _tabIcons.removeAt(guardiansTabIndex);
          _tabIconData.removeAt(guardiansTabIndex);
          guardianScreenGuiUpdated = true;
        }
      }
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: getAppBar(thisApplicationViewModel),
        body: SizedBox.expand(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                MyInterstitialAd.showInterstitialAd();
              });
            },
            children: _children,
          ),
        ),
        bottomNavigationBar: Container(
          height: 80.h,
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, -2),
                spreadRadius: 0,
              )
            ],
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 24.h,
              width: 281.w,
              child: Row(
                children: List.generate(
                    _tabIcons.length,
                        (index) {
                      Widget icon = Icon(
                        _tabIconData[index],
                        color: _currentIndex == index ?
                        AppTheme.primaryDark :
                        AppTheme.normalGrey,
                      );
                      //check notification count and add badge
                      if (_children[index] is NotificationsScreen && thisApplicationViewModel.unseenNotificationsCount > 0) {
                        icon = IconBadge(
                          icon: Icon(
                            UniconsLine.bell,
                            color: _currentIndex == index ?
                            AppTheme.primaryDark :
                            AppTheme.normalGrey,
                          ),
                          itemCount: thisApplicationViewModel.unseenNotificationsCount,
                          badgeColor: Colors.red,
                          itemColor: Colors.white,
                          hideZero: true,
                          right: 20.w,
                        );
                      }
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentIndex = index;
                              MyInterstitialAd.showInterstitialAd();
                            });
                            _pageController?.jumpToPage(index);
                          },
                          child: icon,
                        ),
                      );
                    }
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget getAppBar(ThisApplicationViewModel thisApplicationViewModel) {
    if (_currentIndex == 0) {
      return const CustomAppBar();
    } else if (_currentIndex == 1 && thisApplicationViewModel.settings?.hidePaymentParents == false) {
      return AnimatedAppBar(translation(context)?.wallet ?? "Wallet", false);
    } else if (_currentIndex == 3) {
      return const CustomAppBar();
    } else {
      return const CustomAppBar();
    }
  }
}


