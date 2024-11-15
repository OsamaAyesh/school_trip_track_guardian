class PayResponse {
  double? newWalletBalance;
  bool? success;
  String? message;
  PayResponse({this.newWalletBalance, this.success, this.message});

  factory PayResponse.fromJson(Map<String, dynamic> json) {
    return PayResponse(
        newWalletBalance: json['new_wallet_balance'] != null ? double.parse(json['new_wallet_balance'].toString()) : null,
        success: json['success'],
        message: json['message']
    );
  }
}