import 'dart:io';

import 'package:school_trip_track_guardian/utils/util.dart';
import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:school_trip_track_guardian/gui/widgets/direction_positioned.dart';
import '../../utils/app_theme.dart';
import '../../utils/config.dart';
import '../languages/language_constants.dart';
class ProfilePic extends StatelessWidget {
  final ThisApplicationViewModel thisApplicationViewModel;
  ProfilePic({
    Key? key, required this.thisApplicationViewModel,
  }) : super(key: key);

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20.h,),
        Stack(
          children: [
            SizedBox(
              height: 115.h,
              width: 115.h,
              child: thisApplicationViewModel.isLoggedIn == true ?
              CircleAvatar(
                backgroundImage: NetworkImage("${Config.serverUrl}${thisApplicationViewModel.currentUser?.avatar}"),
                backgroundColor: AppTheme.veryLightGrey,
              ) :
              const CircleAvatar(
                backgroundImage: AssetImage("assets/images/avatar.png"),
                backgroundColor: AppTheme.veryLightGrey,
              ),
            ),
            thisApplicationViewModel.isLoggedIn == true ?
            DirectionPositioned(
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: 46,
                width: 46,
                child: thisApplicationViewModel.uploadAvatarLoadingState.inLoading() == true ?
                const CircularProgressIndicator(
                  color: AppTheme.primary,
                ) :
                ElevatedButton(
                  // style: ElevatedButton.styleFrom(
                  //     backgroundColor: AppTheme.lightGrey,
                  //     padding: const EdgeInsets.all(0),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(50),
                  //       side: const BorderSide(color: AppTheme.lightGrey),
                  //     ),
                  //     elevation: 5),
                  onPressed: () {
                    changeProfilePicture(context);
                  },
                  child: const Icon(
                    Icons.camera_alt_outlined,
                  ),
                ),
              ),
            ) : Container(),
          ],
        ),
        SizedBox(height: 20.h,),
        //user name
        Text(thisApplicationViewModel.isLoggedIn == true
            ? thisApplicationViewModel.currentUser?.name ?? "Guest"
            : "Guest",
          textAlign: TextAlign.center,
          style: AppTheme.bold20DarkBlue,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,),
        SizedBox(height: 5.h,),
        //email
        Text(
          thisApplicationViewModel.isLoggedIn == true
              ? thisApplicationViewModel.currentUser?.email ?? ""
              : "",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  void changeProfilePicture(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 150.h,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(translation(context)?.camera ?? 'Camera'),
                onTap: () async {
                  Navigator.pop(context);
                   String? fileName = await pickAnImage(_picker, ImageSource.camera, "driver_documents");
                    if(fileName != null){
                      thisApplicationViewModel.uploadAvatarEndpoint(fileName);
                    }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(translation(context)?.gallery ?? 'Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  String? fileName = await pickAnImage(_picker, ImageSource.gallery, "driver_documents");
                  if(fileName != null){
                    thisApplicationViewModel.uploadAvatarEndpoint(fileName);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
