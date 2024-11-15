
import 'package:intl/intl.dart';

class PaymentInfo{
    int? id, coinCount, planId;
    String? date;
    double? price;
    String? paymentMethod, planName;

    PaymentInfo(
        {this.id,
        this.date,
        this.price,
        this.paymentMethod,
        this.planId,
        this.planName,
        this.coinCount,
        });

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'payment_date': date,
            'price': price,
            'payment_method': paymentMethod,
            'plan_id': planId,
            'plan_name': planName,
            'coin_count': coinCount,
        };
    }

    static PaymentInfo fromJson(json) {
        return PaymentInfo(
            id: json['id'],
            //date: json['date'],
            price: json['price'] != null ? double.parse(json['price'].toString()) : 0,
            paymentMethod: json['payment_method'],
            date: json['payment_date']!=null? DateFormat('yyyy-MM-dd').format(DateTime.parse(json['payment_date']).toLocal()).toString():"",
            planId: json['plan_id'],
            planName: json['plan_name'],
            coinCount: json['coin_count'],
        );
    }

}
