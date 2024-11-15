
import 'package:flutter/material.dart';
import 'package:school_trip_track_guardian/gui/widgets/app_bar.dart';
import 'package:school_trip_track_guardian/gui/widgets/form_error.dart';
import 'package:school_trip_track_guardian/model/loading_state.dart';
import 'package:school_trip_track_guardian/services/service_locator.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:school_trip_track_guardian/utils/keyboard.dart';
import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';
import 'package:provider/provider.dart';

import '../languages/language_constants.dart';


class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  MyProfileScreenState createState() => MyProfileScreenState();
}

class MyProfileScreenState extends State<MyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool buttonPressed = true;

  String errorMessage = '';
  List<String> errors = [];

  ThisApplicationViewModel thisAppModel = serviceLocator<
      ThisApplicationViewModel>();


  String? phoneNumberStr, addressStr;

  @override
  void initState(){
    super.initState();

    errorMessage = '';
    if (thisAppModel.currentUser != null) {
      setState(() {
        phoneNumberStr = thisAppModel.currentUser!.telNumber ?? '';
        addressStr = thisAppModel.currentUser!.address ?? '';
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThisApplicationViewModel>(
        builder: (context, thisAppModel, child) {
          if(thisAppModel.updateProfileLoadingState.error != null) {
            errors.clear();
            errors.add(
                thisAppModel.updateProfileLoadingState.error!);
          }
          return Scaffold(
            appBar: buildAppBar(context, translation(context)?.basicInformation ?? 'Basic information'),
            body: _drawField(thisAppModel),
          );
        });

  }

  Widget _drawField(ThisApplicationViewModel thisAppModel) {
    //print(thisAppModel.currentUser.address?.isEmpty ?? true);
    return
      Form(
        key: _formKey,
        child:
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20,),
                Text(translation(context)?.accountInformation ?? 'Account information',
                    style: AppTheme.textDarkBlueLarge),
                const SizedBox(height: 30,),
                Row(
                  children: [
                    const SizedBox(width: 10,),
                    const Icon(Icons.person_outline, color: AppTheme.secondary,),
                    const SizedBox(width: 10,),
                    Text(thisAppModel.currentUser!.name!,
                        style: AppTheme.textPrimaryMedium),
                  ],
                ),
                const SizedBox(height: 30,),
                Row(
                  children: [
                    const SizedBox(width: 10,),
                    const Icon(Icons.email_outlined, color: AppTheme.secondary,),
                    const SizedBox(width: 10,),
                    Text(thisAppModel.currentUser!.email!,
                        style: AppTheme.textPrimaryMedium),
                  ],
                ),
                const SizedBox(height: 30,),
                //tel number text field with validation
                TextFormField(
                  initialValue: (thisAppModel.currentUser!.telNumber ?? ''),
                  keyboardType: TextInputType.phone,
                  maxLength: 20,
                  onChanged: (value) =>
                  phoneNumberStr = value,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    prefixIcon: const Icon(
                      Icons.phone,
                      color: AppTheme.secondary,
                    ),
                    hintText: translation(context)?.phoneNumber ?? 'Phone number',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return translation(context)?.pleaseEnterPhoneNumber ?? 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30,),
                //address text field with validation
                TextFormField(
                  initialValue: (thisAppModel.currentUser!.address ?? ''),
                  keyboardType: TextInputType.streetAddress,
                  maxLength: 100,
                  onChanged: (value) =>
                  addressStr = value,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      color: AppTheme.secondary,
                    ),
                    hintText: translation(context)?.address ?? 'Address',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return translation(context)?.pleaseEnterAddress ?? 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 50,),
                FormError(errors: errors),
                errorMessage != '' ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline, color: Colors.red,),
                      const SizedBox(width: 10,),
                      Flexible(child: Text(
                          errorMessage, style: AppTheme.subCaptionSecondary,
                          textAlign: TextAlign.center)),
                    ],
                  ),
                ) : Container(),
                Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          AppTheme.secondary),
                      shape: MaterialStateProperty.all<
                          RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      minimumSize: MaterialStateProperty.all<Size>(
                          const Size(200, 50)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        thisAppModel.updateProfileLoadingState
                            .inLoading() ?
                        const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ) : Text(translation(context)?.save ?? 'Save',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),),
                      ],
                    ),
                    onPressed: () {
                      //check form validation
                      if (_formKey.currentState!.validate() &&
                          !thisAppModel.updateProfileLoadingState
                              .inLoading()) {
                        _formKey.currentState!.save();
                        // if all are valid then go to success screen
                        KeyboardUtil.hideKeyboard(context);
                        thisAppModel.updateProfileEndpoint(
                            context, phoneNumberStr, addressStr);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  @override
  void dispose() {
    thisAppModel.updateProfileLoadingState = LoadingState();
    super.dispose();
  }
}