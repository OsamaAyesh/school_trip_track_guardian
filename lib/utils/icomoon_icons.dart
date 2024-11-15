// Place fonts/icomoon.ttf in your fonts/ directory and
// add the following to your pubspec.yaml
// flutter:
//   fonts:
//    - family: icomoon
//      fonts:
//       - asset: fonts/icomoon.ttf
import 'package:flutter/widgets.dart';

class Icomoon {
  Icomoon._();

  static const String _fontFamily = 'icomoon';

  static const IconData backArrow = IconData(0xe902, fontFamily: _fontFamily);
  static const IconData routeWidgetMarker = IconData(0xe900, fontFamily: _fontFamily);
  static const IconData roadSolid = IconData(0xe901, fontFamily: _fontFamily);
}