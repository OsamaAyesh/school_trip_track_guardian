import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class SocialCard extends StatelessWidget {
  const SocialCard({
    Key? key,
    this.text,
    this.mini = false,
    this.press, this.type,
  }) : super(key: key);

  final String? text;
  final Buttons? type;
  final Function? press;
  final bool mini;

  @override
  Widget build(BuildContext context) {
    return SignInButton(
      type!,
      text: text,
      mini: mini,
      onPressed: press!,
    );
  }
}
