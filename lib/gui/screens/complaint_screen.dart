import 'package:school_trip_track_guardian/gui/widgets/form_error.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../view_models/this_application_view_model.dart';
import '../languages/language_constants.dart';

class ComplaintScreen extends StatefulWidget {
  final int reservationId;
  final ThisApplicationViewModel thisAppModel;
  const ComplaintScreen(this.thisAppModel, this.reservationId, {super.key});

  @override
  ComplaintScreenState createState() => ComplaintScreenState();
}
class ComplaintScreenState extends State<ComplaintScreen> {
  int maxCharacters = 2000;
  int textLength = 0;
  late TextEditingController _complaintController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _complaintController = TextEditingController();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<ThisApplicationViewModel>(
        builder: (context, thisAppModel, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: _formKey,
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        textLength = value.length;
                      });
                    },
                    controller: _complaintController,
                    decoration: InputDecoration(
                      hintText: translation(context)?.enterComplaint ?? 'Enter your complaint',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    minLines: 3,
                    maxLines: 6,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return translation(context)?.pleaseEnterComplaint ?? 'Please enter your complaint';
                      }
                      if (value.length < 10) {
                        return translation(context)?.pleaseEnterValidComplaint ?? 'Please enter a valid complaint (more than 10 characters)';
                      }
                      if (value.length > maxCharacters) {
                        return 'Your complaint is too long (more than $maxCharacters characters)';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    '$textLength/$maxCharacters',
                    style: AppTheme.textGreySmall,
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                TextButton(
                  onPressed: (){
                    if(_formKey.currentState!.validate()) {

                      //minimize the keyboard
                      FocusScope.of(context).unfocus();

                      String complaint = _complaintController.text;
                      thisAppModel.createComplaintEndpoint(context, complaint, widget.reservationId);
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: SizedBox(
                    height: 30.h,
                    width: 250.w,
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //spinner
                          thisAppModel.createComplaintLoadingState.inLoading() ?
                          SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ): Container(),
                          SizedBox(width: 10.w),
                          Text(
                            translation(context)?.sendComplaint ?? 'Send complaint',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                FormError(errors: thisAppModel.createComplaintLoadingState.loadError == 1 ?
                [thisAppModel.createComplaintLoadingState.error!] : [])
              ],
            ),
          );
        }
        );

  }
}
