
import 'package:school_trip_track_guardian/gui/screens/student_details_screen.dart';

import 'student_details_info.dart';

class DbUser{

    int? id, role, status;
    String? name, email, uid, fcmToken, avatar;
    int? wallet;
    String? address, telNumber, notes, studentIdentifier, registrationResponse;
    DbUser? school;

    StudentDetailsInfo? studentDetails;


    DbUser(
        {this.id,
            this.name,
            this.email,
            this.uid,
            this.fcmToken,
            this.role,
            this.status,
            this.avatar,
            this.wallet,
            this.address,
            this.telNumber,
            this.notes,
            this.studentIdentifier,
            this.school,
            this.registrationResponse,
            this.studentDetails}
        );

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'name': name,
            'email': email,
            'uid': uid,
            'fcm_token': fcmToken,
            'role_id':role,
            'status_id':status,
            'avatar':avatar,
            'balance':wallet,
            'address': address,
            'tel_number': telNumber,
            'notes': notes,
            'student_identification': studentIdentifier,
            'registration_response': registrationResponse,
            'school': school?.toJson(),
            'student_details': studentDetails,
        };
    }

    static DbUser fromJson(json) {
        return DbUser(
            id: json['id'],
            name: json['name'],
            email: json['email'],
            uid: json['uid'],
            role: json['role_id'],
            status: json['status_id'],
            avatar: json['avatar'],
            wallet: json['balance']!=null? int.parse(json['balance'].toString()):0,
            fcmToken: json['fcm_token'],
            address: json['address'],
            telNumber: json['tel_number'],
            notes: json['notes'],
            studentIdentifier: json['student_identification'],
            registrationResponse: json['registration_response'],
            school: json['school'] != null ? DbUser.fromJson(json['school']) : null,
            studentDetails: json['student_details'] != null ? StudentDetailsInfo.fromJson(json['student_details']) : null,
        );
    }

}
