
class Setting{

    String? currencyCode;

    String?  paymentMethod;
    bool? showAds;
    bool? simpleMode;
    bool? hideSchools;
    bool? hidePaymentParents;
    Setting({
        this.currencyCode,
        this.paymentMethod,
        this.showAds,
        this.simpleMode,
        this.hideSchools,
        this.hidePaymentParents,
    });

    Map<String, dynamic> toJson() {
        return {
            'currency_code': currencyCode,
            'payment_method': paymentMethod,
            'allow_ads_in_parent_app': showAds,
            'simple_mode': simpleMode,
            'hide_schools': hideSchools,
            'hide_payment_parents': hidePaymentParents,
        };
    }

    static Setting fromJson(json) {
        return Setting(
            currencyCode: json['currency_code'],
            paymentMethod: json['payment_method'],
            showAds: json['allow_ads_in_parent_app']!=null? (json['allow_ads_in_parent_app'] == 1 ? true : false) : false,
            simpleMode: json['simple_mode']!=null? (json['simple_mode'] == 1 ? true : false) : false,
            hideSchools: json['hide_schools']!=null? (json['hide_schools'] == 1 ? true : false) : false,
            hidePaymentParents: json['hide_payment_parents']!=null? (json['hide_payment_parents'] == 1 ? true : false) : false,
        );
    }

}
