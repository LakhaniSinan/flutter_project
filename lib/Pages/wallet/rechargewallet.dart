import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:grocery/Components/constantfile.dart';
import 'package:grocery/Components/entry_field.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/Theme/constantf.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/cart/makeorderbean.dart';
import 'package:grocery/beanmodel/creditcard.dart';
import 'package:grocery/beanmodel/paymentbean/paymentbean.dart';
import 'package:grocery/beanmodel/striperes/chargeresponse.dart';
import 'package:grocery/beanmodel/walletbean/walletmodel.dart';
import 'package:grocery/paypal/paypalpayment.dart';
import 'package:http/http.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:toast/toast.dart';

class RechargeWallet extends StatefulWidget{
  final String amt;
  RechargeWallet(this.amt);
  @override
  State<StatefulWidget> createState() {
    return RechargeWalletState();
  }

}

class RechargeWalletState extends State<RechargeWallet>{
  var http = Client();
TextEditingController rechargeController = TextEditingController();
  Razorpay _razorpay;
  var publicKey = '';
  var razorPayKey = 'rzp_live_PpuROp7TCnbmlk';
  bool razor = false;
  bool paystack = false;
  final _formKey = GlobalKey<FormState>();
  final _verticalSizeBox = const SizedBox(height: 20.0);
  final _horizontalSizeBox = const SizedBox(width: 10.0);
  String _cardNumber;
  String _cvv;
  int _expiryMonth = 0;
  int _expiryYear = 0;

  String _cardNumber1;
  String _cardName;
  String _cvv1;
  int _expiryMonth1 = 0;
  int _expiryYear1 = 0;
  CreditCard creditCardPay;

dynamic apCurrency;
  RazorPayBean rpayBean;
  PayPalBean payPalBean;
  PaystackBean paystackBean;
  StripeBean stripeBean;
  bool isLoading = true;
  bool enterFirst = true;
  bool showPaymentDialog = false;

@override
void initState() {
  super.initState();
  rechargeController.text = widget.amt;
  getPaymentList();
}

void getPaymentList() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  setState(() {
    apCurrency = pref.getString('app_currency');
  });
  http.post(paymentGatewaysUri, headers: {
    'Authorization': 'Bearer ${pref.getString('accesstoken')}'
  }).then((value) {
    print('ppy - ${value.body}');
    if (value.statusCode == 200) {
      PaymentMain data1 = PaymentMain.fromJson(jsonDecode(value.body));
      if ('${data1.status}' == '1') {
        setState(() {
          rpayBean = data1.razorpay;
          payPalBean = data1.paypal;
          paystackBean = data1.paystack;
          stripeBean = data1.stripe;
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }).catchError((e) {
    print(e);
    setState(() {
      isLoading = false;
    });
  });
}


  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String,dynamic> receivedData = ModalRoute.of(context).settings.arguments;
    setState(() {
      if (!enterFirst && receivedData.containsKey('amount')) {
        enterFirst = true;
        rechargeController.text = '${receivedData['amount']}';
      }
    });

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_sharp),
            onPressed: (){
              Navigator.of(context).pop(false);
            },
          ),
          title: Text(
            'Recharge Wallet',
            style: TextStyle(color: kMainTextColor),
          ),
          centerTitle: true,
        ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Container(
child: Column(
  children: [
    EntryField(
        hint: 'Enter your amount',
        controller: rechargeController,
        readOnly: false,
        // suffixIcon: (Icons.arrow_drop_down),
    ),
    Visibility(
        visible: isLoading,
          child:Container(
        width:MediaQuery.of(context).size.width,
        height: 60,
        alignment: Alignment.center,
        child: Align(
            widthFactor: 40,
            heightFactor: 40,
            alignment: Alignment.center,
            child: CircularProgressIndicator()
        ),
    ))
  ],
),
            ),
            Expanded(
                child: Stack(
                  children: [
                    (!isLoading)?
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            visible: (paystackBean!=null && '${paystackBean.paystack_status}'=='yes' || '${paystackBean.paystack_status}'=='Yes' || '${paystackBean.paystack_status}'=='YES')?true:false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildPaymentHead(context, locale.cards),
                                buildPaymentType(
                                    Icon(
                                      Icons.credit_card,
                                      size: 24,
                                      color: Colors.grey[700],
                                    ),
                                    locale.creditCard,callback:(){
                                  if(!isLoading){
                                    setState(() {
                                      isLoading = true;
                                    });
                                    payStatck("${paystackBean.paystack_public_key}",'$apCurrency',(double.parse('${rechargeController.text}')*100).toInt());
                                  }

                                }),
                                buildPaymentType(
                                    Icon(
                                      Icons.credit_card,
                                      size: 24,
                                      color: Colors.grey[700],
                                    ),
                                    locale.debitCard,callback: (){
                                  if(!isLoading){
                                    setState(() {
                                      isLoading = true;
                                    });
                                    payStatck("${paystackBean.paystack_public_key}",'$apCurrency',(double.parse('${rechargeController.text}')*100).toInt());
                                  }
                                }),
                                Divider(
                                  thickness: 0.2,
                                  height: 8,
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            thickness: 0.2,
                            height: 8,
                          ),
                          buildPaymentHead(context, locale.otherMethods),
                          Visibility(
                            visible: (payPalBean!=null && '${payPalBean.paypal_status}'=='yes' || '${payPalBean.paypal_status}'=='Yes' || '${payPalBean.paypal_status}'=='YES')?true:false,
                            child: buildPaymentType(
                                Image.asset('assets/PaymentIcons/payment_paypal.png'), 'PayPal',callback: (){
                              // PaypalPayment(clientId:'${payPalBean.paypal_client_id}',secret:'${payPalBean.paypal_secret}',amount: '${double.parse('${makeOrderData.rem_price}')}',onFinish:(id,status){
                              //   print('$id $status');
                              //   if(status=='success'){
                              //     checkOut('Card', 'success', 'no', '$id', 'paypal');
                              //   }
                              // });
                              print('done');
                              if(!isLoading){
                                setState(() {
                                  isLoading = true;
                                });
                                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                  return PaypalPayment(clientId:'${payPalBean.paypal_client_id}',secret:'${payPalBean.paypal_secret}',amount: '${double.parse('${rechargeController.text}')}',onFinish:(id,status){
                                    print('$id $status');
                                    if(status=='success'){
                                      checkOut('${rechargeController.text}', 'success', '$id', 'paypal');
                                    }else{
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  });
                                })).catchError((e){
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              }
                            }),
                          ),
                          Visibility(
                            visible: (paystackBean!=null && '${paystackBean.paystack_status}'=='yes' || '${paystackBean.paystack_status}'=='Yes' || '${paystackBean.paystack_status}'=='YES')?true:false,
                            child: buildPaymentType(
                                Image.asset('assets/PaymentIcons/payment_paypal.png'), 'PayStack',callback: (){
                              if(!isLoading){
                                setState(() {
                                  isLoading = true;
                                });
                                payStatck("${paystackBean.paystack_public_key}",'$apCurrency',(int.parse('${rechargeController.text}')*100).toInt());
                              }

                            }),
                          ),
                          Visibility(
                            visible: (rpayBean!=null && '${rpayBean.razorpay_status}'=='yes' || '${rpayBean.razorpay_status}'=='Yes' || '${rpayBean.razorpay_status}'=='YES')?true:false,
                            // visible:true,
                            child: buildPaymentType(
                                Image.asset('assets/PaymentIcons/payment_paypal.png'), 'Razor Pay',callback:(){
                              if(!isLoading){
                                setState(() {
                                  isLoading = true;
                                });
                                openCheckout(
                                    "${rpayBean.razorpay_key}", (double.parse('${rechargeController.text}')*100),'${rpayBean.razorpay_secret}');
                              }

                            }),
                          ),
                          Visibility(
                            visible: (stripeBean!=null && '${stripeBean.stripe_status}'.toUpperCase()=='YES')?true:false,
                            child: buildPaymentType(
                                Image.asset('assets/PaymentIcons/payment_stripe.png'), 'Stripe',callback: (){
                              if(!isLoading){
                                setState(() {
                                  isLoading = true;
                                });
                                Navigator.of(context).pushNamed(PageRoutes.stripecard).then((value){
                                  if(value!=null){
                                    CreditCard cardPay = value;
                                    setStripePayment(stripeBean.stripe_secret,double.parse('${rechargeController.text}'),cardPay,'INR',context);
                                  }else{
                                    Toast.show('Payment cancelled', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                }).catchError((e){
                                  Toast.show('Payment cancelled', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              }
                            }),
                          ),
                          Visibility(
                            visible: false,
                            child: buildPaymentType(Image.asset('assets/PaymentIcons/payment_payu.png'),
                                'PayU Money',callback: (){
                                  if(!isLoading){
                                    Toast.show('Comming Soon', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                                  }
                                }),
                          ),
                        ],
                      ),
                    )
                        :Container(),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }

  Padding buildPaymentHead(BuildContext context, String name) {
    return Padding(
      padding:
      const EdgeInsets.only(left: 28.0, right: 28.0, top: 14, bottom: 4),
      child: Text(
        name,
        style: Theme.of(context).textTheme.subtitle2.copyWith(
            fontSize: 16,
            color: Color(0xffa9a9a9),
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget buildPaymentType(var icon, String name, {Function callback}) {
    return InkWell(
      onTap: (){
        callback();
        // checkOut();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 28.0),
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor: Colors.grey[300], radius: 20, child: icon),
            SizedBox(
              width: 20,
            ),
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            )
          ],
        ),
      ),
    );
  }

  void checkOut(String amount, String paymentStatus, String paymentid, String paymentGateway) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var http = Client();
    http.post(rechargeWalletUri,body: {
      'user_id':'${prefs.getInt('user_id')}',
      'amount':'$amount',
      'recharge_status':'$paymentStatus',
      'payment_gateway':'$paymentGateway',
    }, headers: {
      'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
    }).then((value){
      // print('payment - ${value.body}');
      if(value.statusCode == 200){
        WalletModel orderBean = WalletModel.fromJson(jsonDecode(value.body));
        if('${orderBean.status}' == '1'){
          Navigator.of(context).pop(true);
          Toast.show(orderBean.message, context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
        }else{
          Toast.show(orderBean.message, context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
        }
      }else{
        Toast.show('Something went wrong!', context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e){
      setState(() {
        isLoading = false;
      });
      Toast.show('Something went wrong!', context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
      print(e);
    });
  }


  void razorPay(keyRazorPay, amount, String secretKey) async {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    createOrderId(keyRazorPay,secretKey,amount.toInt(),'INR','order_trn_${DateTime.now().millisecond}',_razorpay);
  }

  void openCheckout(keyRazorPay, amount, String secretKey) async {
    razorPay(keyRazorPay, amount,secretKey);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if(response.paymentId!=null){
      print('paymentid - ${response.paymentId}');
      checkOut('${rechargeController.text}', 'success', '${response.paymentId}', 'razorpay');
    }else{
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      isLoading = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      isLoading = false;
    });
  }

  void createOrderId(dynamic clientid, dynamic secretKey, dynamic amount, dynamic currency, dynamic receiptId, Razorpay razorpay) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var authn = 'Basic ' + base64Encode(utf8.encode('$clientid:$secretKey'));
    Map<String, String> headers = {
      'Authorization': authn,
      'Content-Type': 'application/json'
    };

    var body = {
      'amount':'$amount',
      'currency':'$currency',
      'receipt':'$receiptId',
      'payment_capture':true,
    };

    //
    http.post(orderApiRazorpay,body: jsonEncode(body),headers: headers).then((value){
      print('orderid data - ${value.body}');
      var jsData = jsonDecode(value.body);
      // setState(() {
      //   isLoading = false;
      // });
      Timer(Duration(seconds: 1), () async {
        var options = {
          'key': razorPayKey,
          'amount': amount,
          'name': '${prefs.getString('user_name')}',
          'description': 'Wallet Recharge',
          'order_id': '${jsData['id']}',
          'prefill': {
            'contact': '${prefs.getString('user_phone')}',
            'email': '${prefs.getString('user_email')}'
          },
          'external': {
            'wallets': ['paytm']
          }
        };

        try {
          _razorpay.open(options);
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          debugPrint(e);
        }
      });
    }).catchError((e){
      print(e);
      setState(() {
        isLoading = false;
      });
    });

  }
var payPlugin = PaystackPlugin();
  void payStatck(String key, String currencyd, int amount) async {
    if(key.startsWith("pk_")){
      payPlugin.initialize(publicKey: key).then((value){
        _startAfreshCharge(currencyd,amount);
      }).catchError((e){
        setState(() {
          isLoading = false;
        });
        print(e);
      });
    }else{
      setState(() {
        isLoading = false;
      });
      Toast.show('Server down please use another payment method.', context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
    }
  }

  _startAfreshCharge(String currencyd, int amount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // _formKey.currentState.save();

    Charge charge = Charge()
      ..amount = amount // In base currency
      ..email = '${prefs.getString('user_email')}'
      ..currency = '$currencyd'
      ..card = _getCardFromUI()
      ..reference = _getReference();
    _chargeCard(charge);
  }

  _chargeCard(Charge charge) async {
    payPlugin.chargeCard(context, charge: charge).then((value) {
      print('${value.status}');
      print('${value.message}');
      print('${value.toString()}');
      print('${value.card}');
      if (value.status && '${value.message}'.toUpperCase() == 'SUCCESS') {
        checkOut('${rechargeController.text}', 'success', '${value.reference}', 'paystack');
      }else{
        Toast.show('${value.message}', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
        setState(() {
          isLoading = false;
        });
      }
    }).catchError((e){
      print(e);
      setState(() {
        isLoading = false;
      });
    });
  }

  PaymentCard _getCardFromUI() {
    return PaymentCard(
      number: _cardNumber,
      cvc: _cvv,
      expiryMonth: _expiryMonth,
      expiryYear: _expiryYear,
    );
  }

  String _getReference() {
    final String uuid = GUIDGen.generate();
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS_';
    } else {
      platform = 'And_';
    }

    return '$platform$uuid';
  }

  void setStripePayment(dynamic clientScretKey, double amount,
      CreditCard creditCardPay, String paymentCurrency, BuildContext context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // print('${creditCardPay.toJson().toString()}');
    Map<String, String> headers = {
      'Authorization':
      'Bearer $clientScretKey',
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    // print('${creditCardPay.toJson().toString()}');

    var body1 = {
      'type': 'card',
      'card[number]': '${creditCardPay.number}',
      'card[exp_month]': '${creditCardPay.expMonth}',
      'card[exp_year]': '${creditCardPay.expYear}',
      'card[cvc]': '${creditCardPay.cvc}',
      'billing_details[email]': '${prefs.getString('user_email')}',
      'billing_details[name]': '${prefs.getString('user_name')}',
      'billing_details[phone]': '${prefs.getString('user_phone')}',
    };

    http
        .post(Uri.parse('https://api.stripe.com/v1/payment_methods'),
        body: body1, headers: headers)
        .then((value) {
      print(value.body);
      var jsP = jsonDecode(value.body);
      if(jsP['error']!=null){
        setState(() {
          isLoading = false;
        });
      }else{
        createPaymentIntent('${amount.toInt() * 100}', '$paymentCurrency',
            headers, jsP, clientScretKey, context);
      }
    }).catchError((e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    });

    // StripePayment.createPaymentMethod(PaymentMethodRequest(card: creditCardPay))
    //     .then((value) {
    //   print('pt - ${value.toJson().toString()}');
    //   createPaymentIntent('${amount.toInt() * 100}', '$paymentCurrency',
    //       headers, value, clientScretKey, context);
    // }).catchError((e) {
    //   Toast.show(e.message, context,
    //       gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
    //   setState(() {
    //     isLoading = false;
    //   });
    // });
  }

  void createPaymentIntent(
      String amount,
      String currency,
      Map<String, String> hearder,
      dynamic paymentMethod,
      clientScretKey,
      BuildContext context) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
        'description': 'Shopping Charges on $appname'
      };
      http.post(paymentApiUrl, body: body, headers: hearder).then((value) {
        var js = jsonDecode(value.body);
        if(js['error']!=null){
          setState(() {
            isLoading = false;
          });
        }else{
          confirmCreatePaymentIntent(amount, currency, hearder, paymentMethod, js, clientScretKey, context);
        }
      }).catchError((e) {
        print('dd ${e}');
        Toast.show(e.message, context,
            gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
        setState(() {
          isLoading = false;
        });
      });
    } catch (err) {
      Toast.show(
          'something went wrong with your payment if any amount deduct please wait for 10-15 working days.',
          context,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_SHORT);
      setState(() {
        isLoading = false;
      });
    }
  }

  void confirmCreatePaymentIntent(String amount,
      String currency,
      Map<String, String> hearder,
      dynamic paymentMethod,
      dynamic payintent,
      clientScretKey,
      BuildContext context) async{

    var body1 = {
      'payment_method': '${paymentMethod['id']}',
      'use_stripe_sdk': 'false',
      'return_url': '$paymentLoadURI',
    };

    http.post(Uri.parse('$paymentApiUrl/${payintent['id']}/confirm'),
        body: body1, headers: hearder)
        .then((value) {
      print(value.body);
      var js = jsonDecode(value.body);
      if(js['error']!=null){
        setState(() {
          isLoading = false;
        });
      }else{
        if('${js['status']}'=='succeeded'){
          checkOut('${rechargeController.text}', 'success', '${payintent['id']}', 'stripe');
        }else if('${js['status']}'=='requires_action'){
          if(js['next_action']!=null && js['next_action']['redirect_to_url']!=null){
            Navigator.of(context).pushNamed(PageRoutes.paymentdoned, arguments: {
              'url': js['next_action']['redirect_to_url']['url']
            }).then((value) {
              confirmPaymentStripe(payintent['id'], hearder,'${payintent['id']}');
            }).catchError((e) {
              print(e);
              setState(() {
                isLoading = false;
              });
            });
          }else{
            setState(() {
              isLoading = false;
            });
          }
        }
      }
    }).catchError((e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    });

  }

  void confirmPaymentStripe(dynamic jsValue, dynamic hearder, String payid) async{
    http.get(Uri.parse('$paymentApiUrl/$jsValue'),headers: hearder)
        .then((value) {
      print(value.body);
      var js = jsonDecode(value.body);
      if(js['error']!=null){
        setState(() {
          isLoading = false;
        });
      }else{
        print(js['status']);
        if('${js['status']}'=='succeeded'){
          checkOut('${rechargeController.text}', 'success', payid, 'stripe');
        }else{
          setState(() {
            isLoading = false;
          });
        }
      }
    }).catchError((e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    });
  }

//   void setStripePayment(dynamic clientScretKey, double amount, CreditCard creditCardPay, String apCurrency) {
//   double newAmount = amount*100;
//     Map<String, String> headers = {
//       'Authorization': 'Bearer ${clientScretKey}',
//       'Content-Type': 'application/x-www-form-urlencoded'
//     };
//     StripePayment.createPaymentMethod(PaymentMethodRequest(
//       card: creditCardPay
//     )).then((value){
//       createPaymentIntent('${newAmount.toInt()}','$apCurrency',headers,value,clientScretKey);
//     }).catchError((e){
//       Toast.show(e.message, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
//       setState(() {
//         isLoading = false;
//       });
//     });
//   }
//
// void createPaymentIntent(String amount, String currency,Map<String, String> hearder, PaymentMethod paymentMethod, clientScretKey) async {
//   try {
//     Map<String, dynamic> body = {
//       'amount': amount,
//       'currency': currency,
//       'payment_method_types[]': 'card',
//       'description': 'Wallet Recharge'
//     };
//    http.post(
//         paymentApiUrl,
//         body: body,
//         headers: hearder
//     ).then((value){
//       var js = jsonDecode(value.body);
//       // print('pIntent - ${value.body}');
//       // print('pIntent1 - ${paymentMethod.id}');
//       StripePayment.confirmPaymentIntent(
//         PaymentIntent(
//           clientSecret: '${js['client_secret']}',
//           paymentMethodId: '${paymentMethod.id}',
//         ),
//       ).then((paymentIntent) {
//         // print('cIntent - ${paymentIntent.toJson().toString()}');
//         if('${paymentIntent.status}'.toUpperCase()=='succeeded'.toUpperCase()){
//           checkOut('${rechargeController.text}', 'success', '${paymentIntent.paymentIntentId}', 'stripe');
//         }else{
//           setState(() {
//             isLoading = false;
//           });
//         }
//         setState(() {
//           isLoading = false;
//         });
//       }).catchError((e){
//         print(e);
//         Toast.show(e.message, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
//         setState(() {
//           isLoading = false;
//         });
//       });
//     }).catchError((e){
//      print('dd ${e}');
//      Toast.show(e.message, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
//      setState(() {
//        isLoading = false;
//      });
//    });
//   } catch (err) {
//   Toast.show('something went wrong with your payment if any amount deduct please wait for 10-15 working days.', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
//     setState(() {
//       isLoading = false;
//     });
//   }
// }

  void createCharge(String tokenId,dynamic secretKey,dynamic currency,dynamic amount, Map<String, String> headers) async {
    try {
      Map<String, dynamic> body = {
        'amount': '$amount',
        'currency': '$currency',
        'source': tokenId,
        'description': 'Wallet Recharge'
      };
      http.post(
          Uri.parse('https://api.stripe.com/v1/charges'),
          body: body,
          headers: headers
      ).then((value){
        print('ss - ${value.body}');
        if(value.body.toString().contains('error')){
          var jsd = jsonDecode(value.body);
          Error errorResp = Error.fromJson(jsd['error']);
          Toast.show('${errorResp.message}', context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
          setState(() {
            isLoading = false;
          });
        }else{
          StripeChargeResponse chargeResp = StripeChargeResponse.fromJson(jsonDecode(value.body));
          if('${chargeResp.status}'.toUpperCase()=='succeeded'.toUpperCase()){
            checkOut('${rechargeController.text}', 'success', '${chargeResp.paymentMethod}', 'stripe');
          }else{
            setState(() {
              isLoading = false;
            });
          }
        }
      });
    } catch (err) {
      print('err charging user: ${err.toString()}');
      setState(() {
        isLoading = false;
      });
    }
  }

}