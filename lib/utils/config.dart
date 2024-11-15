class Config {

  /// -------------------- EDIT THIS WITH YOURS -------------------------------------------------

  // Edit WEB_URL with your url. Make sure you do not add backslash('/') in the end url
  static String webUrl = "153.92.211.150/backend";
  static String serverUrl = "http://$webUrl";

  // static String webUrl = "10.0.2.2/backend";
  // static String serverUrl = "http://$webUrl";

  static String socketUrl = "http://153.92.211.150";
  static String socketPort = '6001';

  static String googleApikey = "AIzaSyBViS6aBy6Nx-C_wBx5ARgDnwoO_-Y9Tlg";
  static String systemName = "BTA";
  static String systemVersion = "1.0.0";
  static String systemCompany = "BTA Bus";
  static String developerInfo = "Developed by $systemCompany";

  static String shareText = "Check $systemName, the best app for school bus tracking! It's simple, easy and secure app.";

  static String credits = "Icons and several images are made by Genko Mono from www.vecteezy.com. See more at https://www.vecteezy.com/members/genkomono";


  static var braintreeTokenizationKey = "sandbox_8h4vrhnn_ybjk49xt4kwxmf5s";

  static var razorpayKey = "rzp_test_ijmPq7Vbya4sX1";
  //Public Key
  static var flutterwaveKey="FLWPUBK_TEST-5cb68e5b3515230a9aa660a724fd2985-X";

  //Stripe Key
  static var stripeKey="pk_test_nEOS0IR0TsaeU8YGHTe0rgN900UbSj7SgR";

  //PayStack Key
  static var paystackKey="pk_test_e8ccec1bfde7b90908a0fda5696c65f10ffd9797";



  static String androidInterstitialAdUnitId = "ca-app-pub-3940256099942544/1033173712";
  static String iosInterstitialAdUnitId = "ca-app-pub-3940256099942544/4411468910";

  // //PayTabs Keys
  // static var paytabsProfileId= "89661";
  // //Mobile SDK Keys
  // static var paytabsServerKey= "S6JN266GWN-JHG92J9TLH-W9TD9BZTZW";
  // static var paytabsClientKey= "CGKMQ7-92MD6H-TPM6P7-9BHNKB";/*Mobile SDK Keys*/
  // //2 chars iso country code
  // static var paytabsMerchantCountryCode= "EG";

}
