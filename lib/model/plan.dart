
import 'package:intl/intl.dart';

class Plan{
    int? id, coinCount, planType, availability;
    double? price;
    String? name;
    Plan({
        this.id,
        this.coinCount,
        this.price,
        this.planType,
        this.name,
        this.availability,
    });

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'name': name,
            'coin_count': coinCount,
            'price': price,
            'plan_type': planType,
            'availability': availability,
        };
    }

    static Plan fromJson(json) {
        return Plan(
            id: json['id'],
            name: json['name'],
            coinCount: json['coin_count'],
            price: json['price'] != null ? double.parse(json['price'].toString()) : null,
            planType: json['plan_type'],
            availability: json['availability'],
        );
    }

}
