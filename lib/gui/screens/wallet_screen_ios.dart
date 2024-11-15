//
// import 'dart:ffi';
// import 'dart:io';
//
// import 'package:flutter/cupertino.dart';
// import 'package:school_trip_track_guardian/gui/widgets/tab_choice_widget.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/material/card.dart' as material_card;
// import 'package:school_trip_track_guardian/model/loading_state.dart';
// import 'package:school_trip_track_guardian/services/service_locator.dart';
// import 'package:school_trip_track_guardian/utils/app_theme.dart';
// import 'package:school_trip_track_guardian/view_models/this_application_view_model.dart';
// import 'package:flutter/services.dart';
// // import 'package:flutter_paytabs_bridge/PaymentSdkTransactionType.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:provider/provider.dart';
//
// import 'package:simple_gradient_text/simple_gradient_text.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
//
// import '../../model/constant.dart';
// import '../../model/plan.dart';
// import '../../utils/config.dart';
// import '../../widgets.dart';
// import '../languages/language_constants.dart';
// import '../widgets/form_error.dart';
//
// //comment out the below lines if you are building for iOS
// // import 'package:flutter_paystack/flutter_paystack.dart';
// // import 'package:flutter_stripe/flutter_stripe.dart';
// // import 'package:flutterwave_standard/core/flutterwave.dart';
// // import 'package:flutterwave_standard/models/requests/customer.dart';
// // import 'package:flutterwave_standard/models/requests/customizations.dart';
// // import 'package:flutterwave_standard/models/responses/charge_response.dart';
// // import 'package:flutter_braintree/flutter_braintree.dart';
// // import 'package:razorpay_flutter/razorpay_flutter.dart';
//
//
// class WalletScreen extends StatefulWidget {
//   const WalletScreen({super.key});
//
//   @override
//   WalletScreenState createState() => WalletScreenState();
// }
//
// class WalletScreenState extends State<WalletScreen> {
//
//   ThisApplicationViewModel thisAppModel = serviceLocator<
//       ThisApplicationViewModel>();
//
//   PageController? _pageController;
//   int? paymentTabIdx = 0;
//
//   TabController? _controller;
//
//   final List<String> errors = [];
//
//   int? selectedPlan;
//   Map<String, dynamic>? stripePaymentIntent;
//   void removeAllErrors() {
//     setState(() {
//       errors.clear();
//     });
//   }
//
//   @override
//   void initState() {
//     _pageController = PageController();
//     thisAppModel.paymentsLoadingState.loadState = ScreenState.LOADING;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       setState(() {
//         removeAllErrors();
//         thisAppModel.getPaymentsEndpoint();
//       });
//     });
//     super.initState();
//   }
//
//   Future<void> _refreshData() {
//     return Future(
//             () {
//           thisAppModel.getPaymentsEndpoint();
//         }
//     );
//   }
//
//   Widget displayAllPayments(ThisApplicationViewModel thisApplicationViewModel) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           SizedBox(height: 10.h),
//           TabChoiceWidget(
//             color: AppTheme.secondary,
//             choices: [
//               translation(context)?.deposit ?? "Deposit",
//               translation(context)?.history ?? "History"
//             ],
//             pageController: _pageController,
//           ),
//           SizedBox(
//             height: 600.h,
//             child: PageView(
//                 controller: _pageController,
//                 onPageChanged: (pageIndex) {
//                   if (kDebugMode) {
//                     print("pageIndex $pageIndex");
//                   }
//                   setState(() {
//                     paymentTabIdx = pageIndex;
//                   });
//                   _controller?.animateTo(pageIndex);
//                 },
//                 children: List.generate(2, (index) {
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: RefreshIndicator(
//                       onRefresh: _refreshData,
//                       child: Stack(
//                         children: [
//                           displayPayments(thisApplicationViewModel, index),
//                         ],
//                       ),
//                     ),
//                   );
//                 })
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget displayPayments(ThisApplicationViewModel thisApplicationViewModel,
//       int index) {
//     if (thisApplicationViewModel.isLoggedIn != true) {
//       return signInOut(context, widget);
//     }
//     if (thisApplicationViewModel.paymentsLoadingState.inLoading()) {
//       return loadingScreen();
//     }
//     else {
//       if (thisApplicationViewModel.paymentsLoadingState.loadError != null) {
//         if (kDebugMode) {
//           print("page loading error. Display the error");
//         }
//         // page loading error. Display the error
//         return failedScreen(context,
//             thisApplicationViewModel.paymentsLoadingState.failState);
//       }
//       List<Widget> a = [];
//
//       if (index == 0) {
//         a.add(Column(
//           children: [
//             const SizedBox(height: 30),
//             Image.asset(
//               "assets/images/walletImage.png",
//               height: 130.h,
//             ),
//             SizedBox(height: 50.h),
//             // Text(
//             //   translation(context)?.myWalletBalance ?? 'My wallet balance ',
//             //   style: AppTheme.textPrimaryMedium
//             // ),
//             // const SizedBox(height: 10),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 //show in two digits
//                 '${thisApplicationViewModel.currentUser?.wallet
//                     ?.toString() ?? ''} ${translation(context)?.coins ?? 'Coins'}',
//                 style: AppTheme.textPrimaryHuge,
//               ),
//             ),
//             //add payment amount
//
//             SizedBox(height: 10.h),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.info_outline,
//                     color: AppTheme.secondary,
//                     size: 20,
//                   ),
//                   SizedBox(width: 10.w),
//                   Text(
//                     translation(context)?.oneCoinInfo ?? 'One coin allows you to track one student\n for one day.',
//                     style: AppTheme.textSecondarySmall,
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 3,
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             )
//
//           ],
//         ));
//         displayErrors(a, thisApplicationViewModel);
//       }
//       else {
//         if (thisApplicationViewModel.payments.isNotEmpty) {
//           a.add(
//             Padding(
//                 padding: EdgeInsets.only(top: 10.h, bottom: 30.h),
//                 child: Column(
//                     children: paymentsListScreen(thisApplicationViewModel)
//                 )
//             ),
//           );
//         }
//         else {
//           a.add(Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(height: 30.h),
//               Image.asset("assets/images/no_transaction.png", height: MediaQuery
//                   .of(context)
//                   .orientation == Orientation.landscape ? 150 : 300,),
//               Padding(
//                 padding: EdgeInsets.only(top: 30.h),
//                 child: Column(
//                   children: [
//                     Text(translation(context)?.noTransactionsYet ??
//                         "Oops... No transactions.",
//                       style: AppTheme.textSecondaryMedium,
//                       textAlign: TextAlign.center,),
//                     const SizedBox(height: 30),
//                   ],
//                 ),
//               ),
//             ],
//           ));
//         }
//       }
//       return ListView(
//           children: a
//       );
//     }
//   }
//
//   List<Widget> paymentsListScreen(
//       ThisApplicationViewModel thisApplicationViewModel) {
//     return
//       List.generate(thisApplicationViewModel.payments.length, (i) {
//         IconData payementIcon = thisApplicationViewModel.payments[i]
//             .paymentMethod == "PayPal"
//             ? FontAwesomeIcons.paypal
//             : FontAwesomeIcons.creditCard;
//         return material_card.Card(
//           elevation: 8,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(13.0),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(18.0),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           thisApplicationViewModel.payments[i].coinCount
//                               .toString(),
//                           style: AppTheme.textPrimaryXL,
//                         ),
//                         SizedBox(width: 5.w),
//                         Icon(
//                             FontAwesomeIcons.coins,
//                             color: AppTheme.secondary
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20.h),
//                     Text(
//                       thisApplicationViewModel.payments[i].planName.toString(),
//                       style: AppTheme.textSecondarySmall,
//                     ),
//                   ],
//                 ),
//                 Column(
//                   children: [
//                     Text(
//                       thisApplicationViewModel.payments[i].price.toString(),
//                       style: AppTheme.textlightPrimaryMedium,
//                     ),
//                     SizedBox(height: 5.h),
//                     Icon(
//                       payementIcon,
//                       color: AppTheme.primary,
//                     ),
//                     SizedBox(height: 5.h),
//                     Text(
//                       thisApplicationViewModel.payments[i].date.toString(),
//                       style: AppTheme.textlightPrimaryMedium,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ThisApplicationViewModel>(
//       builder: (context, thisApplicationViewModel, child) {
//         return Scaffold(
//           body: displayAllPayments(thisApplicationViewModel),
//           floatingActionButton: paymentTabIdx == 1 ? null :
//           thisApplicationViewModel.currentUser?.role == 4 ?
//           (thisApplicationViewModel.paymentsLoadingState
//               .inLoading() ? null : getPaymentButton(thisApplicationViewModel)) : null,
//         );
//         //displayAllPayments(thisApplicationViewModel);
//       },
//     );
//   }
//
//   getPaymentButton(ThisApplicationViewModel thisApplicationViewModel) {
//     if (thisApplicationViewModel.settings == null) {
//       return Container();
//     }
//     else {
//       var coins = thisApplicationViewModel.plans;
//       return ElevatedButton(
//         style: floatButtonStyle(),
//         onPressed: () {
//           showModalBottomSheet(
//               context: context,
//               builder: (BuildContext bc) {
//                 return SingleChildScrollView(
//                   child: SizedBox(
//                     height: coins.length > 4 ? MediaQuery
//                         .of(context)
//                         .size
//                         .height * .60 : coins.length * 120.h,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         children: [
//                           Text(
//                             'Select Coins',
//                             style: AppTheme.textPrimaryLarge,
//                           ),
//                           SizedBox(height: 10.h),
//                           Expanded(
//                             child: ListView.builder(
//                                 itemCount: coins.length,
//                                 itemBuilder: (BuildContext context,
//                                     int index) {
//                                   return Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: material_card.Card(
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(
//                                               10.0),
//                                         ),
//                                         elevation: 3,
//                                         child: Column(
//                                           children: [
//                                             ListTile(
//                                                 title: Padding(
//                                                   padding: const EdgeInsets.all(8.0),
//                                                   child: Column(
//                                                     crossAxisAlignment: CrossAxisAlignment
//                                                         .start,
//                                                     children: [
//                                                       Text(
//                                                         coins[index].name!,
//                                                         style: AppTheme
//                                                             .textSecondaryMedium,
//                                                         overflow: TextOverflow
//                                                             .ellipsis,
//                                                       ),
//                                                       SizedBox(height: 5.h),
//                                                       Text(
//                                                         "${coins[index]
//                                                             .price} ${thisAppModel
//                                                             .settings
//                                                             ?.currencyCode}",
//                                                         style: AppTheme
//                                                             .textPrimaryMedium,
//                                                         overflow: TextOverflow
//                                                             .ellipsis,
//                                                       ),
//                                                       SizedBox(height: 5.h),
//                                                       Text(
//                                                         "${coins[index]
//                                                             .coinCount} Coins",
//                                                         style: AppTheme
//                                                             .textPrimaryMedium,
//                                                         overflow: TextOverflow
//                                                             .ellipsis,
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                                 leading: const Icon(
//                                                   FontAwesomeIcons.coins,
//                                                   size: 30,
//                                                   color: AppTheme.secondary,
//                                                 ),
//                                                 onTap: () {
//                                                   //open button sheet that displays the routes
//                                                   Navigator.pop(context);
//                                                   requestPayment(
//                                                       thisApplicationViewModel,
//                                                       coins[index].id!);
//                                                 }
//                                             ),
//                                           ],
//                                         )),
//                                   );
//                                 }),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               });
//         },
//         child: isPaymentInProgress(thisApplicationViewModel) ?
//         const CircularProgressIndicator(
//           color: AppTheme.backgroundColor,
//         )
//             :
//         floatRequestButtonAddIcon(),
//       );
//     }
//   }
//
//   floatRequestButtonAddIcon() {
//     //text to request coins
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Wrap(
//         children: [
//           Text(
//             translation(context)?.requestCoins ?? 'Request Coins',
//             style: AppTheme.textPrimaryMedium,
//           ),
//           SizedBox(width: 10.w),
//           const Icon(
//             FontAwesomeIcons.coins,
//             color: AppTheme.backgroundColor,
//           ),
//         ],
//       ),
//     );
//   }
//
//   void showAlertDialog(BuildContext context, String title, String message) {
//     // set up the buttons
//     Widget continueButton = ElevatedButton(
//       child: const Text("Continue"),
//       onPressed: () {
//         Navigator.of(context, rootNavigator: true)
//             .pop();
//       },
//     );
//     // set up the AlertDialog
//     AlertDialog alert = AlertDialog(
//       title: Text(title),
//       content: Text(message),
//       actions: [
//         continueButton,
//       ],
//     );
//     // show the dialog
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
//
//   void displayErrors(List<Widget> a,
//       ThisApplicationViewModel thisApplicationViewModel) {
//     if (thisApplicationViewModel.settings == null) {
//       return;
//     }
//     else if (thisApplicationViewModel.settings?.paymentMethod == "braintree") {
//       if (thisApplicationViewModel.sendBrainTreeNonceForTripLoadingState.loadError !=
//           null) {
//         errors.add(
//             thisApplicationViewModel.sendBrainTreeNonceForTripLoadingState.error!);
//         a.add(FormError(errors: errors));
//         thisApplicationViewModel.sendBrainTreeNonceForTripLoadingState.loadError =
//         null;
//       }
//     }
//     else if (thisApplicationViewModel.settings?.paymentMethod == "razorpay") {
//       if (thisApplicationViewModel.captureRazorPayPaymentLoadingState
//           .loadError !=
//           null) {
//         errors.add(
//             thisApplicationViewModel.captureRazorPayPaymentLoadingState.error!);
//         a.add(FormError(errors: errors));
//         thisApplicationViewModel.captureRazorPayPaymentLoadingState.loadError =
//         null;
//       }
//     }
//     else
//     if (thisApplicationViewModel.settings?.paymentMethod == "flutterwave") {
//       if (thisApplicationViewModel.captureFlutterWavePaymentLoadingState
//           .loadError !=
//           null) {
//         errors.add(
//             thisApplicationViewModel.captureFlutterWavePaymentLoadingState
//                 .error!);
//         a.add(FormError(errors: errors));
//         thisApplicationViewModel.captureFlutterWavePaymentLoadingState
//             .loadError =
//         null;
//       }
//     }
//     else if (thisApplicationViewModel.settings?.paymentMethod == "stripe") {
//       if (thisApplicationViewModel.captureStripePaymentLoadingState
//           .loadError !=
//           null) {
//         errors.add(
//             thisApplicationViewModel.captureStripePaymentLoadingState.error!);
//         a.add(FormError(errors: errors));
//         thisApplicationViewModel.captureStripePaymentLoadingState
//             .loadError =
//         null;
//       }
//     }
//     else if (thisApplicationViewModel.settings?.paymentMethod == "paystack") {
//       if (thisApplicationViewModel.capturePayStackPaymentLoadingState
//           .loadError !=
//           null) {
//         errors.add(
//             thisApplicationViewModel.capturePayStackPaymentLoadingState.error!);
//         a.add(FormError(errors: errors));
//         thisApplicationViewModel.capturePayStackPaymentLoadingState
//             .loadError =
//         null;
//       }
//     }
//     else if (thisApplicationViewModel.settings?.paymentMethod == "paytabs") {
//       if (thisApplicationViewModel.sendPaytabsTransRefLoadingState
//           .loadError !=
//           null) {
//         errors.add(
//             thisApplicationViewModel.sendPaytabsTransRefLoadingState
//                 .error!);
//         a.add(FormError(errors: errors));
//         thisApplicationViewModel.sendPaytabsTransRefLoadingState
//             .loadError =
//         null;
//       }
//     }
//   }
//
//   isPaymentInProgress(ThisApplicationViewModel thisApplicationViewModel) {
//
//     return thisApplicationViewModel.requestCoinsLoadingState.inLoading();
//   }
//
//   void requestPayment(ThisApplicationViewModel thisApplicationViewModel, int planID) {
//     removeAllErrors();
//     //sendRequestCoinsEndpoint
//     thisApplicationViewModel.requestCoinsEndpoint(planID);
//   }
// }