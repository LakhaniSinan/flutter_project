import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/addressbean/showaddress.dart';
import 'package:grocery/beanmodel/cart/cartitembean.dart';
import 'package:grocery/beanmodel/cart/makeorderbean.dart';
import 'package:grocery/beanmodel/creditcard.dart';
import 'package:grocery/beanmodel/paymentbean/paymentbean.dart';
import 'package:grocery/beanmodel/striperes/chargeresponse.dart';
import 'package:grocery/beanmodel/walletbean/walletget.dart';
import 'package:grocery/paypal/paypalpayment.dart';
import 'package:grocery/providergrocery/cartcountprovider.dart';
import 'package:http/http.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:toast/toast.dart';

class PaymentOption extends StatefulWidget {
  @override
  PaymentOptionState createState() => PaymentOptionState();
}

class PaymentOptionState extends State<PaymentOption> {
  TextEditingController promoC = TextEditingController();
  Razorpay _razorpay;
  double walletAmount = 0.0;
  double deWalletAmount = 0.0;
  double previousAmount = 0.0;
  double promocodeprice = 0.0;
  bool isWallet = false;
  var publicKey = '';
  var razorPayKey = 'rzp_live_PpuROp7TCnbmlk';
  bool razor = false;
  bool paystack = false;
  String _cardNumber;
  String _cvv;
  int _expiryMonth = 0;
  int _expiryYear = 0;
  var http = Client();
  RazorPayBean rpayBean;
  PayPalBean payPalBean;
  PaystackBean paystackBean;
  StripeBean stripeBean;
  bool isLoading = false;
  bool isCouponAppliedProgress = false;
  dynamic cart_id;
  dynamic apCurrency;
  dynamic store_id;
  bool enterFirst = false;
  AddressData addressData;
  List<CartItemData> cartItemd = [];
  CartStoreDetails storeDetails;
  MakeOrderData makeOrderData;
  bool showPaymentDialog = false;
  bool isCouponApplied = false;
  CartCountProvider cartCountProvider;
  String couponCodeTxt = '--';
  var payPlugin = PaystackPlugin();

  @override
  void initState() {
    super.initState();
  }

  void getPaymentList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = prefs.getString('app_currency');
    });
    http.post(paymentGatewaysUri, headers: {
      'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
    }).then((value) {
      print('ppy - ${value.body}');
      if (value.statusCode == 200) {
        PaymentMain data1 = PaymentMain.fromJson(jsonDecode(value.body));
        razorPayKey = data1.razorpay.razorpay_key;
        if ('${data1.status}' == '1') {
          setState(() {
            rpayBean = data1.razorpay;
            payPalBean = data1.paypal;
            paystackBean = data1.paystack;
            stripeBean = data1.stripe;
          });
        }
      }
      // setState(() {
      //   isLoading = false;
      // });
      getWalletAmount();
    }).catchError((e) {
      getWalletAmount();
    });
  }

  void getWalletAmount() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var url = walletAmountUri;
    var http = Client();
    http.post(url, body: {'user_id': '${pref.getInt('user_id')}'}, headers: {
      'Authorization': 'Bearer ${pref.getString('accesstoken')}'
    }).then((value) {
          print('resp - ${value.body}');
          if (value.statusCode == 200) {
            WalletGet data1 = WalletGet.fromJson(jsonDecode(value.body));
            print('${data1.toString()}');
            if ('${data1.status}' == '1') {
              setState(() {
                walletAmount = double.parse('${data1.data}');
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

  void applyCoupon(String couponCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isCouponAppliedProgress = true;
    });
    var http = Client();
    http.post(applyCouponUri, body: {
      'cart_id': '${makeOrderData.cart_id}',
      'coupon_code': '${couponCode}',
    }, headers: {
      'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
    }).then((value) {
      print('cc value ${value.body}');
      if (value.statusCode == 200) {
        MakeOrderBean orderBean =
        MakeOrderBean.fromJson(jsonDecode(value.body));
        if ('${orderBean.status}' == '1') {
          setState(() {
            isCouponApplied = true;
            promocodeprice = double.parse('${orderBean.data.coupon_discount}');
            couponCodeTxt = '$couponCode';
          });
        }
      }
      setState(() {
        isCouponAppliedProgress = false;
      });
    }).catchError((e) {
      setState(() {
        isCouponAppliedProgress = false;
      });
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String,dynamic> receivedData = ModalRoute.of(context).settings.arguments;
    if (!enterFirst) {
      enterFirst = true;
      isLoading = true;
      cart_id = receivedData['cart_id'];
      cartItemd = receivedData['cartdetails'];
      storeDetails = receivedData['storedetails'];
      makeOrderData = receivedData['orderdetails'];
      addressData = receivedData['address'];
      cartCountProvider = BlocProvider.of<CartCountProvider>(context);
      // getWalletAmount();
      getPaymentList();
    }
    return Scaffold(
      backgroundColor: Color(0xfff6f7f9),
        appBar: AppBar(
          backgroundColor: kWhiteColor,
          title: Text(
            'Payment Option',
            style: TextStyle(
                color: kMainTextColor, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          automaticallyImplyLeading: true,
          centerTitle: true,
        ),
        body: (isLoading||isCouponAppliedProgress)?Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(strokeWidth: 2,color: kMainColor,),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(isCouponAppliedProgress?'we are appling your offer please do not press back button or close the app':'We are processing your payment please do not press back button and close the app.',textAlign: TextAlign.center,style: TextStyle(
                  color: kMainTextColor,
                  fontWeight: FontWeight.w400,
                ),),
              )
            ],
          ),
        ):SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Visibility(
                    visible: isCouponApplied,
                    child: Container(
                      height: 40,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xfff4d9c8)),
                        borderRadius: BorderRadius.circular(5.0),
                        color: Color(0xfffefce5),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding:
                            const EdgeInsets.only(left: 10, right: 5),
                            child: Icon(Icons.qr_code,
                                size: 20.0, color: kMainColor),
                          ),
                          Expanded(
                            child: Text('Coupon Code',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: kMainTextColor,
                                    fontSize: 15)),
                          ),
                          Text('$couponCodeTxt',
                              maxLines: 1,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: kMainTextColor,
                                  fontSize: 15)),
                          IconButton(onPressed: (){
                            setState(() {
                              if(isCouponApplied){
                                isCouponApplied= false;
                              }
                            });
                          }, icon: Icon(Icons.highlight_remove,
                              size: 20.0, color: kLightTextColor),padding: const EdgeInsets.only(left: 2, right: 6),),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !isCouponApplied,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 10,),
                        Material(
                          color: kWhiteColor,
                          elevation: 0,
                          child: Container(
                            color: kWhiteColor,
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Coupon/OnGoing Offers Codes', style: TextStyle(
                                          color: kMainTextColor,
                                          fontSize: 13,
                                        ),),
                                        GestureDetector(
                                          onTap: () {
                                            print('${cartItemd[0].store_id} , ${makeOrderData.cart_id}');
                                            Navigator.pushNamed(context, PageRoutes.offerpage, arguments: {
                                              'store_id': '${storeDetails.store_id}',
                                              'cart_id':'${makeOrderData.cart_id}'
                                            }).then((value){
                                              if (value != null && '$value' != 'null') {
                                                applyCoupon(value);
                                              }
                                            });
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Row(
                                            children: [
                                              Text('View All', style: TextStyle(
                                                color: kMainTextColor,
                                                fontSize: 13,
                                              ),),
                                              SizedBox(width: 5,),
                                              Icon(Icons.arrow_right, size: 25,
                                                color: kMainColor,)
                                            ],
                                          ),
                                        )
                                      ],),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Divider(
                                      thickness: 1.5,
                                      height: 1.5,
                                      color: kButtonBorderColor.withOpacity(0.5),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        hintText: 'Enter promo code here.',
                                        fillColor: kWhiteColor,
                                        filled: true,
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: MaterialButton(
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            clipBehavior: Clip.antiAlias,
                                            onPressed: () {
                                              if(promoC.text!=null && promoC.text.length>0){
                                                applyCoupon(promoC.text);
                                              }
                                            },
                                            color: Color(0xfff8f8f8),
                                            child: Text(
                                              'Apply',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: kMainColor),
                                            ),
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: kMainColor
                                            ),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: kMainColor
                                            ),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: kMainColor
                                            ),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: kMainColor
                                            ),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: kMainColor
                                            ),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                      ),
                                      readOnly: false,
                                      controller:promoC,
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                        SizedBox(height: 10,),
                      ],
                    ),
                  ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child:
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      Text("WALLET",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: kMainTextColor,
                              letterSpacing: 1.5,
                              fontSize: 14)),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Color(0xfff6f7f9),
                    height: 5,
                    thickness: 2,
                    indent: 5,
                    endIndent: 5,
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                    Icon(
                    Icons.account_balance_wallet_sharp,
                    size: 30,
                    color: kMainColor,
                  ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Text('$appname',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: kMainTextColor,
                                          fontSize: 15))),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("$apCurrency $walletAmount",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: kMainTextColor,
                                          fontSize: 15)),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                      width: 20.0,
                                      height: 20.0,
                                      child: Icon(Icons.done,
                                          size: 15.0,
                                          color: kMainTextColor),
                                      decoration: new BoxDecoration(
                                        shape: BoxShape.circle,
                                      ))
                                ],
                              ),
                            ],
                          ),
                          Text(
                              "Low balance, you need $apCurrency ${getRestWalletAmount()} more in your account.",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.pink,
                                  fontSize: 15)),
                        ],
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Color(0xfff6f7f9),
                    height: 5,
                    thickness: 2,
                    indent: 5,
                    endIndent: 5,
                  ),
                  SizedBox(
                    height: 6,
                  ),
                ]),
              ),
              Visibility(
                visible: (paystackBean!=null && '${paystackBean.paystack_status}'.toUpperCase()=='YES')?true:false,
                // visible: true,
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child:
                      Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('CREDIT & DEBIT CARD',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: kMainTextColor,
                                    letterSpacing: 1.5,
                                    fontSize: 14)),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(
                      color: Color(0xfff6f7f9),
                      height: 5,
                      thickness: 2,
                      indent: 5,
                      endIndent: 5,
                    ),
                    SizedBox(
                      height: 6,
                    ),
                            GestureDetector(
                              onTap: (){
                                if(!isLoading){
                                  setState(() {
                                    isLoading = true;
                                  });
                                  payStatck("${paystackBean.paystack_public_key}",(double.parse('${makeOrderData.rem_price}')*100).toInt(),context);
                                }
                              },
                              behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.credit_card,
                            size: 30,
                            color: kMainColor,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                              child: Text(locale.creditCard,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: kMainTextColor,
                                      fontSize: 15)))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(
                      color: Color(0xfff6f7f9),
                      height: 5,
                      thickness: 2,
                      indent: 5,
                      endIndent: 5,
                    ),
                    SizedBox(
                      height: 6,
                    ),
                            GestureDetector(
                              onTap: (){
                                if(!isLoading){
                                  setState(() {
                                    isLoading = true;
                                  });
                                  payStatck("${paystackBean.paystack_public_key}",(double.parse('${makeOrderData.rem_price}')*100).toInt(),context);
                                }
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    size: 30,
                                    color: kMainColor,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                      child: Text(locale.debitCard,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: kMainTextColor,
                                              fontSize: 15)))
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Divider(
                              color: Color(0xfff6f7f9),
                              height: 5,
                              thickness: 2,
                              indent: 5,
                              endIndent: 5,
                            ),
                            SizedBox(
                              height: 6,
                            ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     Expanded(
                    //       child: Text("Add New Card",
                    //           style: TextStyle(
                    //               fontWeight: FontWeight.bold,
                    //               color: Color(0xfff27427),
                    //               fontSize: 16)),
                    //     ),
                    //   ],
                    // ),
                  ]),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: Text("PAY ON DELIVERY",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: kMainTextColor,
                                  letterSpacing: 1.5,
                                  fontSize: 14))),
                    ],
                  )),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Color(0xfff6f7f9),
                    height: 5,
                    thickness: 2,
                    indent: 5,
                    endIndent: 5,
                  ),
                  SizedBox(
                    height: 6,
                  ),
                      GestureDetector(
                        onTap: (){
                          if(!isLoading){
                            setState(() {
                              isLoading = true;
                            });
                            checkOut('COD', 'success', 'no', '', '');
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Image.asset(
                          'assets/PaymentIcons/payment_cod.png',
                          height: 30,
                          width: 30,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Text("Cash",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: kMainTextColor,
                                            fontSize: 15))),
                              ],
                            ),
                            Text(
                                "Pay through cash when we deliver your item at your doorstep.",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: kMainTextColor,
                                    fontSize: 15)),
                          ],
                        ))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Color(0xfff6f7f9),
                    height: 5,
                    thickness: 2,
                    indent: 5,
                    endIndent: 5,
                  ),
                  SizedBox(
                    height: 6,
                  ),
                ]),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: Text(locale.otherMethods,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: kMainTextColor,
                                  letterSpacing: 1.5,
                                  fontSize: 14))),
                    ],
                  )),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Color(0xfff6f7f9),
                    height: 5,
                    thickness: 2,
                    indent: 5,
                    endIndent: 5,
                  ),
                  SizedBox(
                    height: 6,
                  ),
                      Visibility(
                        visible: (payPalBean!=null && '${payPalBean.paypal_status}'.toUpperCase()=='YES')?true:false,
                        child: buildPaymentType(
                            Image.asset('assets/PaymentIcons/payment_paypal.png',height: 30,width: 30,), locale.paypal,callback: (){
                          print('done');
                          if(!isLoading){
                            setState(() {
                              isLoading = true;
                            });
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return PaypalPayment(apCurrency:apCurrency,clientId:'${payPalBean.paypal_client_id}',secret:'${payPalBean.paypal_secret}',amount: '${double.parse('${makeOrderData.rem_price}')}',onFinish:(id,status){
                                print('$id $status');
                                if(status=='success'){
                                  checkOut('Card', 'success', 'no', '$id', 'paypal');
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
                        visible: (paystackBean!=null && '${paystackBean.paystack_status}'.toUpperCase()=='YES')?true:false,
                        child: buildPaymentType(
                            Image.asset('assets/PaymentIcons/payment_paypal.png',height: 30,width: 30,), locale.paystack,callback: (){
                          if(!isLoading){
                            setState(() {
                              isLoading = true;
                            });
                            payStatck("${paystackBean.paystack_public_key}",(double.parse('${makeOrderData.rem_price}')*100).toInt(),context);
                          }

                        }),
                      ),
                      Visibility(
                        visible: (rpayBean!=null && '${rpayBean.razorpay_status}'.toUpperCase()=='YES')?true:false,
                        child: buildPaymentType(
                            Image.asset('assets/PaymentIcons/payment_paypal.png',height: 30,width: 30,), locale.razorpay,callback:(){
                          if(!isLoading){
                            setState(() {
                              isLoading = true;
                            });
                            openCheckout('${rpayBean.razorpay_key}', (double.parse('${makeOrderData.rem_price}')*100),'${rpayBean.razorpay_secret}');
                          }

                        }),
                      ),
                      Visibility(
                        visible: (stripeBean!=null && '${stripeBean.stripe_status}'.toUpperCase()=='YES')?true:false,
                        child: buildPaymentType(
                            Image.asset('assets/PaymentIcons/payment_stripe.png',height: 30,width: 30,), locale.stripe,callback: (){
                          if(!isLoading){
                            setState(() {
                              isLoading = true;
                              // showPaymentDialog = true;
                            });
                            // StripePayment.setOptions(
                            //     StripeOptions(
                            //       publishableKey:'${stripeBean.stripe_publishable}',
                            //       merchantId: '${stripeBean.stripe_merchant_id}',
                            //       androidPayMode: 'test',
                            //     ));
                            Navigator.of(context).pushNamed(PageRoutes.stripecard).then((value){
                              if(value!=null){
                                CreditCard cardPay = value;
                                setStripePayment(stripeBean.stripe_secret,double.parse('${makeOrderData.rem_price}'),cardPay,'INR',context);
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
                        child: buildPaymentType(Image.asset('assets/PaymentIcons/payment_payu.png',height: 30,width: 30,),
                            locale.payumoney,callback: (){
                              if(!isLoading){
                                Toast.show('Comming Soon', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                              }
                            }),
                      ),
                ]),
              ),
              // Container(
              //   margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
              //   padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //   ),
              //   child:
              //       Column(mainAxisSize: MainAxisSize.min, children: [
              //     Container(
              //         child: Row(
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       mainAxisSize: MainAxisSize.max,
              //       children: [
              //         Expanded(
              //             child: Text("UPI",
              //                 textAlign: TextAlign.left,
              //                 style: TextStyle(
              //                     fontWeight: FontWeight.normal,
              //                     color: kMainTextColor,
              //                     fontSize: 16))),
              //       ],
              //     )),
              //     SizedBox(
              //       height: 5,
              //     ),
              //     Divider(
              //       color: Color(0xfff6f7f9),
              //       height: 5,
              //       thickness: 2,
              //       indent: 5,
              //       endIndent: 5,
              //     ),
              //     SizedBox(
              //       height: 6,
              //     ),
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       mainAxisSize: MainAxisSize.max,
              //       children: [
              //         Image.asset(
              //           'assets/PaymentIcons/payment_stripe.png',
              //           height: 30,
              //           width: 30,
              //         ),
              //         SizedBox(
              //           width: 5,
              //         ),
              //         Expanded(
              //             child: Column(
              //           mainAxisAlignment: MainAxisAlignment.start,
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             Row(
              //               mainAxisAlignment: MainAxisAlignment.start,
              //               children: [
              //                 Expanded(
              //                     child: Text("Add New UPI ID",
              //                         style: TextStyle(
              //                             fontWeight: FontWeight.bold,
              //                             color: Color(0xfff27427),
              //                             fontSize: 15))),
              //               ],
              //             ),
              //             Text("You need to have registered UPI ID",
              //                 style: TextStyle(
              //                     fontWeight: FontWeight.normal,
              //                     color: kMainTextColor,
              //                     fontSize: 15)),
              //           ],
              //         ))
              //       ],
              //     ),
              //     SizedBox(
              //       height: 5,
              //     ),
              //     Divider(
              //       color: Color(0xfff6f7f9),
              //       height: 5,
              //       thickness: 2,
              //       indent: 5,
              //       endIndent: 5,
              //     ),
              //     SizedBox(
              //       height: 6,
              //     ),
              //   ]),
              // )
            ])));
  }

  String getRestWalletAmount() {
    double totalPrice = double.parse('${makeOrderData.total_price}');
    return '${totalPrice-walletAmount}';
  }

  void checkOut(String paymentMethod, String paymentStatus, String wallet, String paymentid, String paymentGateway) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    http.post(checkoutUri,body: {
      'cart_id':'${makeOrderData.cart_id}',
      'payment_method':'$paymentMethod',
      'payment_status':'$paymentStatus',
      'wallet':'$wallet',
      'payment_id':'$paymentid',
      'payment_gateway':'$paymentGateway',
    }, headers: {
      'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
    }).then((value){
      print('payment - ${value.body}');
      if(value.statusCode == 200){
        MakeOrderBean orderBean = MakeOrderBean.fromJson(jsonDecode(value.body));
        if('${orderBean.status}' == '1'){
          cartCountProvider.hitCartCounter(0);
          Navigator.pushNamed(context, PageRoutes.confirmOrder);
          Toast.show(orderBean.message, context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
        }else if('${orderBean.status}' == '2'){
          cartCountProvider.hitCartCounter(0);
          Navigator.pushNamed(context, PageRoutes.confirmOrder);
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

  void payStatck(String key, int price, BuildContext context) async {
    if(key.startsWith("pk_")){
      payPlugin.initialize(publicKey: key).then((value){
        // setState(() {
        //   showPaymentDialog = true;
        //   isLoading = false;
        // });
        _startAfreshCharge((int.parse('${makeOrderData.rem_price}')*100));
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
      checkOut('Card', 'success', 'no', '${response.paymentId}', 'razorpay');
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


  _startAfreshCharge(int price) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // _formKey.currentState.save();

    Charge charge = Charge()
      ..amount = price // In base currency
      ..email = '${prefs.getString('user_email')}'
      ..currency = '${prefs.getString('app_currency')}'
      ..card = _getCardFromUI()
      ..reference = _getReference();

    _chargeCard(charge);
  }

  _chargeCard(Charge charge) async {
    payPlugin.chargeCard(context, charge: charge).then((value) {
      print('${value.status}');
      print('${value.toString()}');
      print('${value.card}');

      if (value.status && value.message == "Success") {
        setState(() {
          // showPaymentDialog = false;
          // _inProgress = false;
          // isLoading = true;
        });
        checkOut('Card', 'success', 'no', '${value.reference}', 'paystack');
      }
    }).catchError((e){
      setState(() {
        isLoading = false;
      });
    });
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  PaymentCard _getCardFromUI() {
    return PaymentCard(
      number: _cardNumber,
      cvc: _cvv,
      expiryMonth: _expiryMonth,
      expiryYear: _expiryYear,
    );
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
      'billing_details[address][line1]': '${addressData.landmark}',
      'billing_details[address][postal_code]': '${addressData.pincode}',
      'billing_details[address][state]': '${addressData.state}',
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
          checkOut('Card', 'success', 'no', '${payintent['id']}', 'stripe');
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
          checkOut('Card', 'success', 'no', payid, 'stripe');
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

  // void setStripePayment(dynamic clientScretKey, double amount, CreditCard creditCardPay) {
  //   print('${creditCardPay.toJson().toString()}');
  //   Map<String, String> headers = {
  //     'Authorization': 'Bearer ${clientScretKey}',
  //     'Content-Type': 'application/x-www-form-urlencoded'
  //   };
  //   StripePayment.createPaymentMethod(PaymentMethodRequest(
  //       card: creditCardPay
  //   )).then((value){
  //     print('pt - ${value.toJson().toString()}');
  //     createPaymentIntent('${amount.toInt()*100}','INR',headers,value,clientScretKey);
  //   }).catchError((e){
  //     Toast.show(e.message, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
  //     setState(() {
  //       isLoading = false;
  //     });
  //   });
  // }
  //
  // void createPaymentIntent(String amount, String currency,Map<String, String> hearder, PaymentMethod paymentMethod, clientScretKey) async {
  //   try {
  //     Map<String, dynamic> body = {
  //       'amount': amount,
  //       'currency': currency,
  //       'payment_method_types[]': 'card',
  //       'description': 'Shopping'
  //     };
  //     http.post(
  //         paymentApiUrl,
  //         body: body,
  //         headers: hearder
  //     ).then((value){
  //       var js = jsonDecode(value.body);
  //       print('pIntent - ${value.body}');
  //       print('pIntent1 - ${paymentMethod.id}');
  //       StripePayment.confirmPaymentIntent(
  //         PaymentIntent(
  //           clientSecret: '${js['client_secret']}',
  //           paymentMethodId: '${paymentMethod.id}',
  //         ),
  //       ).then((paymentIntent) {
  //         print('cIntent - ${paymentIntent.toJson().toString()}');
  //         if('${paymentIntent.status}'.toUpperCase()=='succeeded'.toUpperCase()){
  //           checkOut('Card', 'success', 'no', '${paymentIntent.paymentIntentId}', 'stripe');
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
  //       print('dd ${e}');
  //       Toast.show(e.message, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
  //       setState(() {
  //         isLoading = false;
  //       });
  //     });
  //   } catch (err) {
  //     Toast.show('something went wrong with your payment if any amount deduct please wait for 10-15 working days.', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
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
            checkOut('Card', 'success', 'no', '${chargeResp.paymentMethod}', 'stripe');
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

  Widget buildPaymentType(var icon, String name, {Function callback}) {
    return InkWell(
      onTap: (){
        callback();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              icon,
              SizedBox(
                width: 5,
              ),
              Expanded(
                  child: Text(
                      name,
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: kMainTextColor,
                          fontSize: 15)))
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Divider(
            color: Color(0xfff6f7f9),
            height: 5,
            thickness: 2,
            indent: 5,
            endIndent: 5,
          ),
          SizedBox(
            height: 6,
          ),
        ],
      ),
    );
  }
}
