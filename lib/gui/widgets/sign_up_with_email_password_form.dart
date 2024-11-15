import 'package:flutter/material.dart';
import 'package:school_trip_track_guardian/gui/widgets/sign_up_widget.dart';
import 'package:school_trip_track_guardian/services/service_locator.dart';
import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';

import '../../utils/app_theme.dart';

class SignUpWithEmailPasswordForm extends StatefulWidget {
  final Widget? nextScreen;

  const SignUpWithEmailPasswordForm(this.nextScreen, {super.key});

  @override
  SignUpWithEmailPasswordFormState createState() => SignUpWithEmailPasswordFormState();
}

class SignUpWithEmailPasswordFormState extends State<SignUpWithEmailPasswordForm> {
  String? email;
  String? password;
  bool remember = false;
  bool isLoading = false;
  final List<String> errors = [];

  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error!);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(child: SignUpForm(widget.nextScreen)),
      )
    );
  }
}
