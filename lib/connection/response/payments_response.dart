
import 'package:school_trip_track_guardian/model/payment_info.dart';
import 'package:school_trip_track_guardian/model/plan.dart';

class PaymentsResponse {
  List<PaymentInfo>? items = [];
  int? walletBalance;
  bool? success;
  String? message;
  String? currencyCode;
  String? paymentMethod;
  //list of coins
  List<dynamic>? plans;
  PaymentsResponse({this.items, this.walletBalance, this.success, this.message,
    this.currencyCode, this.paymentMethod, this.plans});

  factory PaymentsResponse.fromJson(Map<String, dynamic> json) {
    var list = json['payments'] as List;
    var walletBalance = json['wallet_balance'];
    var plans = json['plans'] as List;
    return PaymentsResponse(
        items: list.map((p) => PaymentInfo.fromJson(p)).toList(),
        walletBalance: walletBalance != null ? int.parse(walletBalance.toString()) : 0,
        success: json['success'],
        message: json['message'],
        currencyCode: json['currency'],
        paymentMethod: json['payment_method'],
        plans: plans.map((p) => Plan.fromJson(p)).toList(),
    );
  }
}