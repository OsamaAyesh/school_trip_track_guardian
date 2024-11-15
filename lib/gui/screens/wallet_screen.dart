
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:school_trip_track_guardian/gui/widgets/tab_choice_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/card.dart' as material_card;
import 'package:school_trip_track_guardian/model/loading_state.dart';
import 'package:school_trip_track_guardian/services/service_locator.dart';
import 'package:school_trip_track_guardian/utils/app_theme.dart';
import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_paytabs_bridge/PaymentSdkTransactionType.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../../model/constant.dart';
import '../../model/plan.dart';
import '../../utils/config.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';
import '../widgets/form_error.dart';

// import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:flutterwave_standard/core/flutterwave.dart';
// import 'package:flutterwave_standard/models/requests/customer.dart';
// import 'package:flutterwave_standard/models/requests/customizations.dart';
// import 'package:flutterwave_standard/models/responses/charge_response.dart';
// import 'package:flutter_braintree/flutter_braintree.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';


class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> {

  ThisApplicationViewModel thisAppModel = serviceLocator<
      ThisApplicationViewModel>();

  PageController? _pageController;
  int? paymentTabIdx = 0;

  TabController? _controller;

  final List<String> errors = [];

  int? selectedPlan;
  Map<String, dynamic>? stripePaymentIntent;
  // PaystackPlugin payStackPlugin = PaystackPlugin();
  void removeAllErrors() {
    setState(() {
      errors.clear();
    });
  }

  @override
  void initState() {
    _pageController = PageController();
    thisAppModel.paymentsLoadingState.loadState = ScreenState.LOADING;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        removeAllErrors();
        thisAppModel.getPaymentsEndpoint();
        // payStackPlugin.initialize(publicKey: Config.paystackKey);
      });
    });
    super.initState();
  }

  Future<void> _refreshData() {
    return Future(
            () {
          thisAppModel.getPaymentsEndpoint();
        }
    );
  }

  Widget displayAllPayments(ThisApplicationViewModel thisApplicationViewModel) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10.h),
          TabChoiceWidget(
            color: AppTheme.secondary,
            choices: [
              translation(context)?.deposit ?? "Deposit",
              translation(context)?.history ?? "History"
            ],
            pageController: _pageController,
          ),
          SizedBox(
            height: 600.h,
            child: PageView(
                controller: _pageController,
                onPageChanged: (pageIndex) {
                  if (kDebugMode) {
                    print("pageIndex $pageIndex");
                  }
                  setState(() {
                    paymentTabIdx = pageIndex;
                  });
                  _controller?.animateTo(pageIndex);
                },
                children: List.generate(2, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RefreshIndicator(
                      onRefresh: _refreshData,
                      child: Stack(
                        children: [
                          displayPayments(thisApplicationViewModel, index),
                        ],
                      ),
                    ),
                  );
                })
            ),
          ),
        ],
      ),
    );
  }

  Widget displayPayments(ThisApplicationViewModel thisApplicationViewModel,
      int index) {
    if (thisApplicationViewModel.isLoggedIn != true) {
      return signInOut(context, widget);
    }
    if (thisApplicationViewModel.paymentsLoadingState.inLoading()) {
      return loadingScreen();
    }
    else {
      if (thisApplicationViewModel.paymentsLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(context,
            thisApplicationViewModel.paymentsLoadingState.failState);
      }
      List<Widget> a = [];

      if (index == 0) {
        a.add(Column(
          children: [
            const SizedBox(height: 30),
            Image.asset(
              "assets/images/walletImage.png",
              height: 130.h,
            ),
            SizedBox(height: 50.h),
            // Text(
            //   translation(context)?.myWalletBalance ?? 'My wallet balance ',
            //   style: AppTheme.textPrimaryMedium
            // ),
            // const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                //show in two digits
                '${thisApplicationViewModel.currentUser?.wallet
                    ?.toString() ?? ''} ${translation(context)?.coins ?? 'Coins'}',
                style: AppTheme.textPrimaryHuge,
              ),
            ),
            //add payment amount

            SizedBox(height: 10.h),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppTheme.secondary,
                    size: 20,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    translation(context)?.oneCoinInfo ?? 'One coin allows you to track one student\n for one day.',
                    style: AppTheme.textSecondarySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )

          ],
        ));
        displayErrors(a, thisApplicationViewModel);
      }
      else {
        if (thisApplicationViewModel.payments.isNotEmpty) {
          a.add(
            Padding(
                padding: EdgeInsets.only(top: 10.h, bottom: 30.h),
                child: Column(
                  children: paymentsListScreen(thisApplicationViewModel)
                )
            ),
          );
        }
        else {
          a.add(Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30.h),
              Image.asset("assets/images/no_transaction.png", height: MediaQuery
                  .of(context)
                  .orientation == Orientation.landscape ? 150 : 300,),
              Padding(
                padding: EdgeInsets.only(top: 30.h),
                child: Column(
                  children: [
                    Text(translation(context)?.noTransactionsYet ??
                        "Oops... No transactions.",
                      style: AppTheme.textSecondaryMedium,
                      textAlign: TextAlign.center,),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ));
        }
      }
      return ListView(
          children: a
      );
    }
  }

  List<Widget> paymentsListScreen(
      ThisApplicationViewModel thisApplicationViewModel) {
    return
      List.generate(thisApplicationViewModel.payments.length, (i) {
        IconData payementIcon = thisApplicationViewModel.payments[i]
            .paymentMethod == "PayPal"
            ? FontAwesomeIcons.paypal
            : FontAwesomeIcons.creditCard;
        return material_card.Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          thisApplicationViewModel.payments[i].coinCount
                              .toString(),
                          style: AppTheme.textPrimaryXL,
                        ),
                        SizedBox(width: 5.w),
                        Icon(
                            FontAwesomeIcons.coins,
                            color: AppTheme.secondary
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      thisApplicationViewModel.payments[i].planName.toString(),
                      style: AppTheme.textSecondarySmall,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      thisApplicationViewModel.payments[i].price.toString(),
                      style: AppTheme.textlightPrimaryMedium,
                    ),
                    SizedBox(height: 5.h),
                    Icon(
                      payementIcon,
                      color: AppTheme.primary,
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      thisApplicationViewModel.payments[i].date.toString(),
                      style: AppTheme.textlightPrimaryMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThisApplicationViewModel>(
      builder: (context, thisApplicationViewModel, child) {
        return Scaffold(
          body: displayAllPayments(thisApplicationViewModel),
          floatingActionButton: paymentTabIdx == 1 ? null :
          thisApplicationViewModel.currentUser?.role == 4 ?
          (thisApplicationViewModel.paymentsLoadingState
              .inLoading() ? null : getPaymentButton(thisApplicationViewModel)) : null,
        );
        //displayAllPayments(thisApplicationViewModel);
      },
    );
  }

  getPaymentButton(ThisApplicationViewModel thisApplicationViewModel) {
    if (thisApplicationViewModel.settings == null) {
      return Container();
    }
    else {
      var coins = thisApplicationViewModel.plans;
      return ElevatedButton(
          style: floatButtonStyle(),
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext bc) {
                  return SingleChildScrollView(
                    child: SizedBox(
                      height: coins.length > 4 ? MediaQuery
                          .of(context)
                          .size
                          .height * .60 : coins.length * 120.h,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              'Select Coins',
                              style: AppTheme.textPrimaryLarge,
                            ),
                            SizedBox(height: 10.h),
                            Expanded(
                              child: ListView.builder(
                                  itemCount: coins.length,
                                  itemBuilder: (BuildContext context,
                                      int index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: material_card.Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10.0),
                                          ),
                                          elevation: 3,
                                          child: Column(
                                            children: [
                                              ListTile(
                                                  title: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Text(
                                                          coins[index].name!,
                                                          style: AppTheme
                                                              .textSecondaryMedium,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        SizedBox(height: 5.h),
                                                        Text(
                                                          "${coins[index]
                                                              .price} ${thisAppModel
                                                              .settings
                                                              ?.currencyCode}",
                                                          style: AppTheme
                                                              .textPrimaryMedium,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        SizedBox(height: 5.h),
                                                        Text(
                                                          "${coins[index]
                                                              .coinCount} Coins",
                                                          style: AppTheme
                                                              .textPrimaryMedium,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  leading: const Icon(
                                                    FontAwesomeIcons.coins,
                                                    size: 30,
                                                    color: AppTheme.secondary,
                                                  ),
                                                  onTap: () {
                                                    //open button sheet that displays the routes
                                                    Navigator.pop(context);
                                                    if (thisApplicationViewModel
                                                        .settings
                                                        ?.paymentMethod ==
                                                        "braintree") {
                                                      payBrainTree(
                                                          thisApplicationViewModel,
                                                          coins[index].id!,
                                                          coins[index].price!);
                                                    }
                                                    else
                                                    if (thisApplicationViewModel
                                                        .settings
                                                        ?.paymentMethod ==
                                                        "razorpay") {
                                                      payRazorPay(
                                                          thisApplicationViewModel,
                                                          coins[index].id!,
                                                          coins[index].price!);
                                                    }
                                                    else
                                                    if (thisApplicationViewModel
                                                        .settings
                                                        ?.paymentMethod ==
                                                        "flutterwave") {
                                                      payFlutterWave(
                                                          thisApplicationViewModel,
                                                          coins[index].id!,
                                                          coins[index].price!);
                                                    }
                                                    else
                                                    if (thisApplicationViewModel
                                                        .settings
                                                        ?.paymentMethod ==
                                                        "stripe") {
                                                      payStripe(
                                                          thisApplicationViewModel,
                                                          coins[index].id!,
                                                          coins[index].price!);
                                                    }
                                                    if (thisApplicationViewModel
                                                        .settings
                                                        ?.paymentMethod ==
                                                        "paystack") {
                                                      payPaystack(
                                                          thisApplicationViewModel,
                                                          coins[index].id!,
                                                          coins[index].price!);
                                                    }
                                                    else
                                                    if (thisApplicationViewModel
                                                        .settings
                                                        ?.paymentMethod ==
                                                        "paytabs") {
                                                      payPayTabs(
                                                          thisApplicationViewModel,
                                                          coins[index].id!,
                                                          coins[index].price!);
                                                    }
                                                  }
                                              ),
                                            ],
                                          )),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          },
          child: isPaymentInProgress(thisApplicationViewModel) ?
          const CircularProgressIndicator(
            color: AppTheme.backgroundColor,
          )
              :
          floatButtonAddIcon(),
      );
    }
  }

  handlePaymentErrorResponse(PaymentFailureResponse response) {
    thisAppModel.captureRazorPayPaymentLoadingState.error = response.message;
    thisAppModel.captureRazorPayPaymentLoadingState.setError(1);
    _showMessage('Payment Failed!!!');
    //display error
    // showAlertDialog(context, "Payment Failed", "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}");
  }

  handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    //display paymentId, orderId, signature;
    // showAlertDialog(context, "Payment Successful", "Payment ID: ${response.paymentId}");
    //captureRazorPayPaymentEndpoint
    if(selectedPlan != null) {
      thisAppModel.captureRazorPayPaymentEndpoint(response.paymentId, selectedPlan!);
    }
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    // set up the buttons
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void displayErrors(List<Widget> a,
      ThisApplicationViewModel thisApplicationViewModel) {
    if (thisApplicationViewModel.settings == null) {
      return;
    }
    else if (thisApplicationViewModel.settings?.paymentMethod == "braintree") {
      if (thisApplicationViewModel.sendBrainTreeNonceForTripLoadingState.loadError !=
          null) {
        errors.add(
            thisApplicationViewModel.sendBrainTreeNonceForTripLoadingState.error!);
        a.add(FormError(errors: errors));
        thisApplicationViewModel.sendBrainTreeNonceForTripLoadingState.loadError =
        null;
      }
    }
    else if (thisApplicationViewModel.settings?.paymentMethod == "razorpay") {
      if (thisApplicationViewModel.captureRazorPayPaymentLoadingState
          .loadError !=
          null) {
        errors.add(
            thisApplicationViewModel.captureRazorPayPaymentLoadingState.error!);
        a.add(FormError(errors: errors));
        thisApplicationViewModel.captureRazorPayPaymentLoadingState.loadError =
        null;
      }
    }
    else
    if (thisApplicationViewModel.settings?.paymentMethod == "flutterwave") {
      if (thisApplicationViewModel.captureFlutterWavePaymentLoadingState
          .loadError !=
          null) {
        errors.add(
            thisApplicationViewModel.captureFlutterWavePaymentLoadingState
                .error!);
        a.add(FormError(errors: errors));
        thisApplicationViewModel.captureFlutterWavePaymentLoadingState
            .loadError =
        null;
      }
    }
    else if (thisApplicationViewModel.settings?.paymentMethod == "stripe") {
      if (thisApplicationViewModel.captureStripePaymentLoadingState
          .loadError !=
          null) {
        errors.add(
            thisApplicationViewModel.captureStripePaymentLoadingState.error!);
        a.add(FormError(errors: errors));
        thisApplicationViewModel.captureStripePaymentLoadingState
            .loadError =
        null;
      }
    }
    else if (thisApplicationViewModel.settings?.paymentMethod == "paystack") {
      if (thisApplicationViewModel.capturePayStackPaymentLoadingState
          .loadError !=
          null) {
        errors.add(
            thisApplicationViewModel.capturePayStackPaymentLoadingState.error!);
        a.add(FormError(errors: errors));
        thisApplicationViewModel.capturePayStackPaymentLoadingState
            .loadError =
        null;
      }
    }
    else if (thisApplicationViewModel.settings?.paymentMethod == "paytabs") {
      if (thisApplicationViewModel.sendPaytabsTransRefLoadingState
          .loadError !=
          null) {
        errors.add(
            thisApplicationViewModel.sendPaytabsTransRefLoadingState
                .error!);
        a.add(FormError(errors: errors));
        thisApplicationViewModel.sendPaytabsTransRefLoadingState
            .loadError =
        null;
      }
    }
  }
  void _showMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  payPaystack(ThisApplicationViewModel thisApplicationViewModel, int planID, double price) async {
    removeAllErrors();
    double payAmount = price ?? 0;
    payAmount = payAmount * 100;
    if (payAmount == 0) {
      return;
    }
    //convert to int
    // int payAmountInt = payAmount.toInt();
    // var platform = (Platform.isIOS) ? 'iOS' : 'Android';
    // final thisDate = DateTime.now().millisecondsSinceEpoch;
    // String reference ='ChargedFrom${platform}_$thisDate';
    // selectedPlan = planID;
    // var charge = Charge()
    //   ..amount = payAmountInt //the money should be in kobo hence the need to multiply the value by 100
    //   ..reference = reference
    //   ..putMetaData('plan_id', planID.toString())
    //   ..email = thisApplicationViewModel.currentUser?.email ?? '';
    // CheckoutResponse response = await payStackPlugin.checkout(
    //   context,
    //   method: CheckoutMethod.card,
    //   charge: charge,
    // );if (response.status == true) {
    //   //sendPayStackPaymentIDEndpoint
    //   thisApplicationViewModel.capturePayStackPaymentEndpoint(
    //       response.reference, planID);
    // } else {
    //   _showMessage('Payment Failed!!!');
    // }
  }
  payStripe(ThisApplicationViewModel thisApplicationViewModel, int planID, double price)
  async {
    removeAllErrors();
    Stripe.publishableKey = Config.stripeKey;
    try {
      //STEP 1: Create Payment Intent
      stripePaymentIntent = await thisApplicationViewModel
          .initiateStripePaymentEndpoint(planID);
      print("stripePaymentIntent: $stripePaymentIntent");
      if (stripePaymentIntent == null) {
        _showMessage('Payment Failed!!!');
        return;
      }
      //STEP 2: Initialize Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: stripePaymentIntent!['payment_intent_client_secret'],
              style: ThemeMode.light,
              merchantDisplayName: 'School Trip Track'))
          .then((value) {
        print('Payment Sheet Initialized');
      })
          .onError((error, stackTrace) {
        _showMessage('Payment Failed!!!');
        print('Error is:---> $error');
      });

      //STEP 3: Display Payment sheet
      displayStripePaymentSheet();
    } catch (err) {
      throw Exception(err);
    }
    selectedPlan = planID;
  }

  displayStripePaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        print('Payment Sheet Completed');
        //send stripePaymentIntent
        thisAppModel.captureStripePaymentEndpoint(stripePaymentIntent!['payment_intent_id']
            , selectedPlan!);
      })
          .onError((error, stackTrace) {
        throw Exception(error);
      });
    }
    on StripeException catch (e) {
      _showMessage('Payment Failed!!!');
      print('Error is:---> $e');
    }
    catch (e) {
      _showMessage('Payment Failed!!!');
      print('$e');
    }
  }

  payFlutterWave(ThisApplicationViewModel thisApplicationViewModel, int planID, double price)
  {
    removeAllErrors();
    selectedPlan = planID;
    // final Customer customer = Customer(
    //     phoneNumber: thisAppModel.currentUser?.telNumber ?? '',
    //     email: thisAppModel.currentUser?.email ?? '',
    //     name: thisAppModel.currentUser?.name ?? ''
    // );
    // final Flutterwave flutterWave = Flutterwave(
    //     context: context,
    //     publicKey: Config.flutterwaveKey,
    //     currency: thisApplicationViewModel.settings!.currencyCode!,
    //     redirectUrl: "https://www.google.com/",
    //     //generate unique references per transaction
    //     txRef: DateTime.now().toIso8601String(),
    //     amount: price.toString(),
    //     customer: customer,
    //     paymentOptions: "card",
    //     customization: Customization(
    //         title: translation(context)?.addMoneyToWallet ??
    //             'Add money to wallet'),
    //     isTestMode: false);
    // flutterWave.charge().then((ChargeResponse response) =>
    // {
    //   if(response.status!.toLowerCase() == "successful" && selectedPlan != null) {
    //     //sendFlutterWavePaymentIDEndpoint
    //     thisApplicationViewModel.captureFlutterWavePaymentEndpoint(
    //         response.transactionId, selectedPlan!)
    //   }
    //   else {
    //     _showMessage('Payment Failed!!!')
    //   }
    // });
  }

  payRazorPay(ThisApplicationViewModel thisApplicationViewModel, int planID, double price) {
    removeAllErrors();
    Razorpay razorpay = Razorpay();
    double payAmount = price ?? 0;
    payAmount = payAmount * 100;
    if (payAmount == 0) {
      return;
    }
    selectedPlan = planID;
    var options = {
      'key': Config.razorpayKey,
      'amount': payAmount,
      'name': Config.systemCompany,
      'description': translation(context)?.addMoneyToWallet ??
          'Add money to wallet',
      'retry': {'enabled': true, 'max_count': 1},
      'prefill': {
        'contact': thisAppModel.currentUser?.telNumber ?? '',
        'email': thisAppModel.currentUser?.email ?? ''
      },
    };
    razorpay.on(
        Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(
        Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.open(options);
  }

  payBrainTree(ThisApplicationViewModel thisApplicationViewModel, int planID, double price) async {
    removeAllErrors();
    if (price == 0) {
      //sendNonceForTripEndpoint
      thisApplicationViewModel.sendBrainTreeNonceForTripEndpoint(
          "123",
          planID);
    }
    else {
      // final request = BraintreeDropInRequest(
      //   clientToken: Config.braintreeTokenizationKey,
      //   collectDeviceData: true,
      //   vaultManagerEnabled: true,
      //   googlePaymentRequest: BraintreeGooglePaymentRequest(
      //     totalPrice: price.toString(),
      //     currencyCode: thisApplicationViewModel.settings!.currencyCode!,
      //     billingAddressRequired: false,
      //   ),
      //   paypalRequest: BraintreePayPalRequest(
      //     amount: price.toString(),
      //     displayName: Config.systemCompany,
      //     currencyCode: thisApplicationViewModel.settings!.currencyCode!,
      //   ),
      // );
      // BraintreeDropInResult? result = await BraintreeDropIn
      //     .start(request);
      // if (result != null) {
      //   if (kDebugMode) {
      //     print('Nonce: ${result.paymentMethodNonce
      //         .nonce}');
      //   }
      //   //sendNonceForTripEndpoint
      //   thisApplicationViewModel.sendBrainTreeNonceForTripEndpoint(
      //       result.paymentMethodNonce.nonce,
      //       planID);
      // } else {
      //   if (kDebugMode) {
      //     print('Selection was canceled.');
      //   }
      // }
    }
  }

  isPaymentInProgress(ThisApplicationViewModel thisApplicationViewModel) {

    return thisApplicationViewModel.sendBrainTreeNonceForTripLoadingState.inLoading() ||
    thisApplicationViewModel.captureRazorPayPaymentLoadingState.inLoading() ||
    thisApplicationViewModel.captureFlutterWavePaymentLoadingState.inLoading() ||
    thisApplicationViewModel.initiateStripePaymentLoadingState.inLoading() ||
    thisApplicationViewModel.captureStripePaymentLoadingState.inLoading() ||
    thisApplicationViewModel.capturePayStackPaymentLoadingState.inLoading();
  }

  void payPayTabs(ThisApplicationViewModel thisApplicationViewModel, int planID, double price)
  {
      removeAllErrors();
      // double payAmount = price;
      // if (payAmount == 0) {
      //   return;
      // }
      // var billingDetails = BillingDetails(
      //     thisApplicationViewModel.currentUser?.name ?? '',
      //     thisApplicationViewModel.currentUser?.email ?? '',
      //     thisApplicationViewModel.currentUser?.telNumber ?? '',
      //     thisApplicationViewModel.currentUser?.address ?? '',
      //     Config.paytabsMerchantCountryCode,
      //     "",
      //     "",
      //     "");
      // var configuration = PaymentSdkConfigurationDetails(
      //     profileId: Config.paytabsProfileId,
      //     serverKey: Config.paytabsServerKey,
      //     clientKey: Config.paytabsClientKey,
      //     merchantCountryCode: Config.paytabsMerchantCountryCode,
      //     billingDetails: billingDetails,
      //     showBillingInfo: true,
      //     cartId: 'Add money to wallet',
      //     cartDescription: translation(context)?.addMoneyToWallet ??
      //         'Add money to wallet',
      //     merchantName: Config.systemCompany,
      //     screentTitle: "Pay with Card",
      //     locale: PaymentSdkLocale.EN,
      //     amount: payAmount,
      //     currencyCode: thisApplicationViewModel.settings!.currencyCode!);
      //
      // FlutterPaytabsBridge.startCardPayment(configuration, (event) {
      //   setState(() {
      //     if (event["status"] == "success") {
      //       // Handle transaction details here.
      //       var transactionDetails = event["data"];
      //       print(transactionDetails);
      //
      //       if (transactionDetails["isSuccess"]) {
      //         print("successful transaction");
      //         //sendPayTabsPaymentIDEndpoint
      //         //get transactionReference inside paymentResult
      //         String transactionReference = transactionDetails["transactionReference"];
      //         thisApplicationViewModel.sendPaytabsTransRefEndpoint(transactionReference);
      //       } else {
      //         print("failed transaction");
      //       }
      //     } else if (event["status"] == "error") {
      //       showAlertDialog(context, "Payment Failed", event["message"]);
      //       // Handle error here.
      //     } else if (event["status"] == "event") {
      //       // Handle cancel events here.
      //     }
      //   });
      // });
  }
}