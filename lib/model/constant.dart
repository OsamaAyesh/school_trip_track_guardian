
enum PayMethod {
  WALLET,
  STRIPE,
  PAYPAL,
}

enum ScreenState {
  LOADING,
  FINISH,
}

enum FailState {
  INTERNET,
  GENERAL,
  UNAUTHENTICATED,
}


class Constant {

  /// -------------------- EDIT THIS WITH YOURS -------------------------------------------------
  static var failedText = "Data failure. Please try again later";

  static var noInternetText = "No internet connection";

  static var notAuthenticatedText = "Your account is either disabled or deleted. Please logout and log in again!";

  static var noItem = "No item found";

  static int timeOut = 15;
}
