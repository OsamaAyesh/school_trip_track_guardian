import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:school_trip_track_guardian/gui/screens/schools_screen.dart';
import 'package:school_trip_track_guardian/gui/widgets/app_bar.dart';
import 'package:school_trip_track_guardian/model/user.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_trip_track_guardian/utils/util.dart';

import '../../services/service_locator.dart';
import '../../utils/config.dart';
import '../../utils/keyboard.dart';
import '../../view_models/this_application_view_model.dart';
import '../languages/language_constants.dart';
import '../widgets/form_error.dart';

class AddEditStudentScreen extends StatefulWidget {
  final DbUser? student;
  const AddEditStudentScreen({super.key, this.student});

  @override
  AddEditStudentScreenState createState() => AddEditStudentScreenState();
}

class AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  List<String> errors = [];
  String? studentNameStr, studentIdStr, studentNotesStr, studentPicFileName;
  DbUser? selectedSchool;
  final ImagePicker _picker = ImagePicker();

  TextEditingController? _schoolController, _nameController,
      _idController, _notesController, _schoolCodeController;

  ThisApplicationViewModel thisApplicationViewModel = serviceLocator<
      ThisApplicationViewModel>();

  @override
  void initState() {
    _schoolController = TextEditingController();
    _nameController = TextEditingController();
    _idController = TextEditingController();
    _notesController = TextEditingController();
    _schoolController = TextEditingController();
    _schoolCodeController = TextEditingController();

    if(widget.student != null) {
      loadStudentDataToGui();
    }

    thisApplicationViewModel.addNewStudentLoadingState.error = null;
    thisApplicationViewModel.deleteStudentLoadingState.error = null;
    super.initState();
  }

  void loadStudentDataToGui() {
    _nameController!.text = widget.student?.name ?? "";
    _idController!.text = widget.student?.studentIdentifier ?? "";
    _notesController!.text = widget.student?.notes ?? "";
    _schoolController!.text = widget.student?.school?.name ?? "";
    studentPicFileName = "";
    selectedSchool = widget.student?.school;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThisApplicationViewModel>(
        builder: (context, thisAppModel, child) {
          if(thisAppModel.addNewStudentLoadingState.error != null) {
            errors.clear();
            errors.add(
                thisAppModel.addNewStudentLoadingState.error!);
            //deleteStudentLoadingState
          }
          if(thisAppModel.deleteStudentLoadingState.error != null) {
            errors.clear();
            errors.add(
                thisAppModel.deleteStudentLoadingState.error!);
            //deleteStudentLoadingState
          }
          if(thisAppModel.settings?.hideSchools == true) {
            if (thisAppModel.getSchoolByCodeLoadingState.loadingFinished()) {
              if (thisAppModel.getSchoolByCodeLoadingState.error != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showErrorToast(
                      context, thisAppModel.getSchoolByCodeLoadingState.error!);
                  thisAppModel.getSchoolByCodeLoadingState.error = null;
                  _schoolController!.text = "";
                });
              }
              else {
                if (thisAppModel.selectedSchool != null) {
                  selectedSchool = thisAppModel.selectedSchool;
                  _schoolController!.text =
                      selectedSchool!.name ?? "";
                }
                else {
                  _schoolController!.text = "";
                }
              }
            }
          }
          return Scaffold(
            appBar: buildAppBar(
                context, widget.student != null ? translation(context)?.editStudent ?? 'Edit Student' : translation(context)?.addStudent ?? 'Add Student'),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: displayAddStudent(thisAppModel),
            ),
          );
        });
  }

  displayAddStudent(ThisApplicationViewModel thisAppModel) {
    // form that contains student name, id, notes, and picture
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          // student name
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              prefixIcon: const Icon(Icons.person, color: AppTheme.secondary),
              hintText: translation(context)?.studentName ?? 'Student Name',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return translation(context)?.studentNameRequired ??
                    'Student name is required';
              }
              return null;
            },
            //save to studentNameStr
            onSaved: (newValue) => studentNameStr = newValue,
          ),
          SizedBox(height: 10.h),
          // student id
          TextFormField(
            controller: _idController,
            decoration: InputDecoration(
              hintText: translation(context)?.studentId ?? 'Student ID',
              border: const UnderlineInputBorder(),
              prefixIcon: const Icon(Icons.perm_identity, color: AppTheme.secondary),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return translation(context)?.studentIdRequired ??
                    'Student ID is required';
              }
              return null;
            },
            //save to studentIdStr
            onSaved: (newValue) => studentIdStr = newValue,
          ),
          SizedBox(height: 10.h),
          thisAppModel.getSchoolByCodeLoadingState.inLoading() ?
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ) :
          TextFormField(
            controller: _schoolController,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              prefixIcon: const Icon(Icons.school, color: AppTheme.secondary),
              hintText: translation(context)?.school ?? 'School',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return translation(context)?.schoolIsRequired ??
                    'School is required';
              }
              return null;
            },
            readOnly: true,
            onTap: () async {
              if (thisAppModel.settings?.hideSchools == false) {
                // go to schools screen
                selectedSchool = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SchoolsScreen(schoolID: selectedSchool?.id),
                  ),
                );
                if (selectedSchool != null) {
                  //set school name
                  _schoolController!.text = selectedSchool!.name ?? "";
                }
                else {
                  _schoolController!.text = "";
                }
              }
              else {
                showSchoolCodeBottomSheet(thisAppModel);
              }
            },
          ),
          SizedBox(height: 10.h),
          // student notes
          TextFormField(
            controller: _notesController,
            //make multiline
            maxLines: 3,
            decoration: InputDecoration(
              hintText: translation(context)?.notesHint ?? 'Notes: e.g. class, year, etc.',
              border: UnderlineInputBorder(),
              prefixIcon: Icon(Icons.note, color: AppTheme.secondary),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return translation(context)?.studentNotesRequired ??
                    'Student notes are required';
              }
              return null;
            },
            //save to studentNotesStr
            onSaved: (newValue) => studentNotesStr = newValue,
          ),
          SizedBox(height: 10.h),
          // student picture
          InkWell(
            child: Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
              studentPicFileName != null && checkFileExist(studentPicFileName!)
                  ?
              Image.file(File(studentPicFileName!))
                  :
              Center(
                child: Icon(
                  Icons.image,
                  size: 50.w,
                  color: AppTheme.normalGrey,
                ),
              ),
            ),
            onTap: () async {
              changeStudentPicture(context, thisAppModel);
            },
          ),
          SizedBox(height: 10.h),
          FormError(errors: errors),
          SizedBox(height: 10.h),
          Center(
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    AppTheme.primary),
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
                  thisAppModel.addNewStudentLoadingState
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
                setState(() {
                  errors.clear();
                });
                //check form validation
                if (_formKey.currentState!.validate() &&
                    !thisAppModel.addNewStudentLoadingState
                        .inLoading()) {
                  if (studentPicFileName == null ||
                      studentPicFileName!.isEmpty) {
                    setState(() {
                      errors.add(translation(context)?.studentPicRequired ??
                          'Student picture is required');
                    });
                  }
                  else {
                    _formKey.currentState!.save();
                    // if all are valid then go to success screen
                    KeyboardUtil.hideKeyboard(context);
                    thisAppModel.addEditStudentEndpoint(
                        widget.student?.id, studentNameStr, studentIdStr,
                        studentNotesStr, studentPicFileName, selectedSchool?.id,
                        context);
                  }
                }
              },
            ),
          ),
          SizedBox(height: 10.h),
          widget.student != null ?
          Center(
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.red),
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
                  thisAppModel.deleteStudentLoadingState
                      .inLoading() ?
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white),
                  ) : Text(translation(context)?.delete ?? 'Delete',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),),
                ],
              ),
              onPressed: () {
                //show dialog to confirm delete
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: Text(translation(context)?.delete ?? 'Delete'),
                      content: const Text('Are you sure you want to delete this student?'),
                      actions: [
                        TextButton(
                          child: Text(translation(context)?.cancel ?? 'Cancel'),
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                        ),
                        TextButton(
                          child: Text(translation(context)?.delete ?? 'Delete'),
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            //delete student
                            thisAppModel.deleteStudentEndpoint(widget.student?.id, context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ) : Container(),
        ],
      ),
    );
  }
  void changeStudentPicture(BuildContext context, ThisApplicationViewModel thisAppModel) {
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
                  String? f = await pickAnImage(_picker, ImageSource.camera, "students");
                  setState(() {
                    if (f != null) {
                      studentPicFileName = f;
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(translation(context)?.gallery ?? 'Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  String? f = await pickAnImage(_picker, ImageSource.gallery, "students");
                  setState(() {
                    if (f != null) {
                      studentPicFileName = f;
                    }
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showSchoolCodeBottomSheet(ThisApplicationViewModel thisAppModel) {
    //show a bottom sheet to enter a school code
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom+20, left: 20, right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                autofocus: true,
                controller: _schoolCodeController,
                decoration: const InputDecoration(
                  labelText: 'School Code',
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  //apply promo code
                  //(String? promoCode, int? plannedTripID, double? price, BuildContext context)
                  if(_schoolCodeController!.text.isNotEmpty) {
                    thisAppModel.getSchoolByCodeEndpoint(
                        _schoolCodeController?.text);
                    //hide keyboard
                    KeyboardUtil.hideKeyboard(context);
                    //dismiss the bottom sheet
                    Navigator.of(context).pop();
                  }
                },
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: AppTheme.secondary,
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                // ),
                child: Text(
                  translation(context)?.add ?? 'Add',
                  style: AppTheme.textWhiteMedium,
                ),
              ),
            ],
          ),
        );
      },
      isScrollControlled: true,
      showDragHandle: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
      ),
    );
  }

  void showErrorToast(BuildContext context, String s) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(s),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  void dispose() {
    thisApplicationViewModel.selectedSchool = null;
    super.dispose();
  }

}