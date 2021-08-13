import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Pages/Other/cancelreaon.dart';
import 'package:grocery/Pages/track_orders.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/orderbean/orderbean_p.dart';
import 'package:grocery/providergrocery/cartcountprovider.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class OrderDetails extends StatefulWidget {
  @override
  OrderDetailsState createState() => OrderDetailsState();
}

class OrderDetailsState extends State<OrderDetails> {
var http = Client();
  bool isEnteredFirst = false;
  MyOrderBeanMain orderData;
  dynamic apcurrency;

  bool isAlert  = false;

  bool isKeyboardOpen;

  @override
  void initState() {
    super.initState();
    getAppCurrency();
  }

  void getAppCurrency() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      apcurrency = preferences.getString('app_currency');
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom!=0;
    if(!isEnteredFirst){
      isEnteredFirst = true;
      Map<String,dynamic> receivedData = ModalRoute.of(context).settings.arguments;
      orderData = receivedData['orderdetails'];
    }

    return Scaffold(
        backgroundColor: kWhiteColor,
        appBar: AppBar(
          backgroundColor: kWhiteColor,
          title: Text(
            'Order Details',
            style: TextStyle(color: kMainTextColor),
          ),
          centerTitle: true,
          actions: [
            BlocBuilder<CartCountProvider, int>(
                builder: (context,cartCount){
                  return Badge(
                    position: BadgePosition.topEnd(top: 5, end: 5),
                    padding: EdgeInsets.all(5),
                    animationDuration: Duration(milliseconds: 300),
                    animationType: BadgeAnimationType.slide,
                    badgeContent: Text(
                      cartCount.toString(),
                      style: TextStyle(color: kWhiteColor,fontSize: 10),
                    ),
                    child: IconButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                          if (prefs.containsKey('islogin') &&
                              prefs.getBool('islogin')) {

                            Navigator.pushNamed(context, PageRoutes.cartPage).then((value) {
                              print('value d');
                              // getCartList();
                            }).catchError((e) {
                              print('dd');
                              // getCartList();
                            });
                            // Navigator.pushNamed(context, PageRoutes.cart)

                          } else {
                            Toast.show(locale.loginfirst, context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_SHORT);
                          }
                        },
                        icon: ImageIcon(AssetImage('assets/ic_cart.png'))),
                  );
                }),
          ],
        ),
        body: SingleChildScrollView(
            child: Column(
                children:[
                  Divider(
                    thickness: 10,
                    height: 10,
                    color: Color(0xfff8f8f8),
                  ),
                  Container(
                    color: kWhiteColor,
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text("ORDER ID - #${orderData.cartId}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: kLightTextColor,
                                  letterSpacing: 1.0,
                                  fontSize: 14)),
                        ),
                        Text('${orderData.deliveryDate}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: kLightTextColor,
                                letterSpacing: 1.0,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      color: Color(0xfff6f7f9),
                      height: 5,
                      thickness: 2,
                      indent: 5,
                      endIndent: 5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Text('${orderData.storeName}'.toUpperCase(),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: kMainTextColor,
                                      letterSpacing: 1.5,
                                      fontSize: 18)),
                            ),
                            Text('$apcurrency ${orderData.price}',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: kMainTextColor,
                                    letterSpacing: 1.5,
                                    fontSize: 18)),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text('${orderData.storeAddress}',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontWeight: FontWeight.w200,
                                  color: kLightTextColor,
                                  fontSize: 14)),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(locale.od1,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: kLightTextColor,
                                letterSpacing: 1.6,
                                fontSize: 14)),
                        SizedBox(height: 5,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text('${orderData.userAddress}',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w200,
                                  color: kMainTextColor,
                                  fontSize: 14)),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(locale.od2,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: kLightTextColor,
                                letterSpacing: 1.6,
                                fontSize: 14)),
                        SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.payment,
                                size: 20.0, color: kMainColor),
                            SizedBox(
                              width: 5,
                            ),
                            Text('${orderData.paymentMethod}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: kMainTextColor,
                                    fontSize: 15)),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Divider(
                            color: Color(0xfff6f7f9),
                            height: 5,
                            thickness: 2,
                            indent: 5,
                            endIndent: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(locale.od3,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: kLightTextColor,
                                letterSpacing: 1.6,
                                fontSize: 14)),
                        SizedBox(height: 3,),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10.0,3,10,10),
                          child: Divider(
                            color: Color(0xfff6f7f9),
                            height: 5,
                            thickness: 2,
                            indent: 5,
                            endIndent: 5,
                          ),
                        ),
                        ('${orderData.orderStatus}'
                            .toUpperCase() ==
                            'CANCELLED')?Text(locale.od15):builRow(orderData.orderStatus,locale),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Divider(
                            color: Color(0xfff6f7f9),
                            height: 5,
                            thickness: 2,
                            indent: 5,
                            endIndent: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10,0,10,10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('${locale.od4}(${orderData.data.length} ${locale.od5})',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: kLightTextColor,
                                letterSpacing: 1.6,
                                fontSize: 14)),
                        SizedBox(height: 6,),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10.0,3,10,10),
                          child: Divider(
                            color: Color(0xfff6f7f9),
                            height: 5,
                            thickness: 2,
                            indent: 5,
                            endIndent: 5,
                          ),
                        ),
                        Visibility(
                          visible:
                          (orderData.data != null && orderData.data.length > 0),
                          child: ListView.builder(
                              itemCount: orderData.data.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, indi) {
                                double _userRating = 0.0;
                                return Container(
                                  color: kWhiteColor,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      buildAmountRow(
                                          '${orderData.data[indi].productName}',
                                          '$apcurrency ${orderData.data[indi].price}'),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Text(
                                              'Qnt. ${orderData.data[indi].qty}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2),
                                          ('${orderData.orderStatus}'
                                              .toUpperCase() ==
                                              'COMPLETED')
                                              ? RatingBar.builder(
                                            initialRating:
                                            _userRating,
                                            minRating: 1,
                                            direction:
                                            Axis.horizontal,
                                            allowHalfRating: true,
                                            unratedColor: Colors
                                                .amber
                                                .withAlpha(50),
                                            itemCount: 5,
                                            itemSize: 20.0,
                                            itemPadding: EdgeInsets
                                                .symmetric(
                                                horizontal:
                                                4.0),
                                            itemBuilder:
                                                (context, _) =>
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                            onRatingUpdate:
                                                (rating) {
                                              setState(() {
                                                _userRating =
                                                    rating;
                                                isAlert = true;
                                                showAlertDialog(context,locale,orderData.data[indi]);
                                              });
                                            },
                                            updateOnDrag: true,
                                          )
                                              : SizedBox.shrink(),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Divider(
                            color: Color(0xfff6f7f9),
                            height: 5,
                            thickness: 2,
                            indent: 5,
                            endIndent: 5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8, bottom: 10, top: 5),
                          child: Column(
                            children: [
                              buildAmountRow(locale.subtotal,
                                  '$apcurrency ${(double.parse('${orderData.price}') - double.parse('${orderData.delCharge}'))}'),
                              buildAmountRow(locale.deliveryFee,
                                  '$apcurrency ${orderData.delCharge}'),
                              buildAmountRow(locale.promoCode,
                                  '-$apcurrency ${orderData.couponDiscount}'),
                              buildAmountRow(locale.paidbywallet,
                                  '-$apcurrency ${orderData.paidByWallet}'),
                              buildAmountRow(locale.amountToPay,
                                  '$apcurrency ${('${orderData.paymentMethod}'.toUpperCase() == 'CARD') ? 0.0 : orderData.remainingAmount}',
                                  fontWeight: FontWeight.w700),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Visibility(
                                    visible: ('${orderData.orderStatus}'
                                        .toUpperCase() ==
                                        'COMPLETED'),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.only(top: 8.0),
                                        child: RaisedButton(
                                          child: Text(
                                            locale.od6,
                                            style: TextStyle(
                                                color: kWhiteColor,
                                                fontSize: 14,
                                                fontWeight:
                                                FontWeight.w400),
                                          ),
                                          color: kMainColor,
                                          highlightColor: kMainColor,
                                          focusColor: kMainColor,
                                          splashColor: kMainColor,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(30.0),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pushNamed(
                                                PageRoutes.invoice,
                                                arguments: {
                                                  'inv_details': orderData,
                                                })
                                                .then((value) {})
                                                .catchError((e) {});
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: ('${orderData.orderStatus}'
                                        .toUpperCase() ==
                                        'PENDING'),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.only(top: 8.0),
                                        child: RaisedButton(
                                          child: Text(
                                            locale.cancelorder,
                                            style: TextStyle(
                                                color: kWhiteColor,
                                                fontSize: 14,
                                                fontWeight:
                                                FontWeight.w400),
                                          ),
                                          color: kMainColor,
                                          highlightColor: kMainColor,
                                          focusColor: kMainColor,
                                          splashColor: kMainColor,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(30.0),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) {
                                                      return CancelPage(
                                                          '${orderData.cartId}');
                                                    })).then((value) {
                                              if (value!=null && value) {
                                                setState(() {
                                                  orderData.orderStatus = 'Cancelled';
                                                });
                                              }
                                            }).catchError((e) {
                                              print(e);
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
            ])));
  }

  Padding buildAmountRow(String name, String price,
      {FontWeight fontWeight = FontWeight.w500}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        children: [
          Text(
            name,
            style: TextStyle(fontWeight: fontWeight),
          ),
          Spacer(),
          Text(
            price,
            style: TextStyle(fontWeight: fontWeight),
          ),
        ],
      ),
    );
  }

  Widget builRow(order_status, AppLocalizations locale) {
    int count = 1;
    if ('$order_status'.replaceAll('_', ' ').toUpperCase() == 'PENDING') {
      count = 1;
    } else if ('$order_status'.replaceAll('_', ' ').toUpperCase() ==
        'OUT FOR DELIVERY') {
      count = 3;
    } else if ('$order_status'.replaceAll('_', ' ').toUpperCase() ==
        'CONFIRMED') {
      count = 2;
    } else if ('$order_status'.replaceAll('_', ' ').toUpperCase() ==
        'COMPLETED') {
      count = 5;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20.0,
                height: 20.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: (count.clamp(1, 5) == count)?kMainColor:Color(0xffedf7ee),
                ),
                child: Icon(Icons.done,
                    size: 14.0, color: (count.clamp(1, 5) == count)?kWhiteColor:kMainColor),
              ),
              SizedBox(width: 5,),
              Expanded(
                child: Text(locale.od7,
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: kMainTextColor,
                        fontSize: 15)),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20.0,
                height: 20.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: (count.clamp(2, 5) == count)?kMainColor:Color(0xffedf7ee),
                ),
                child: Icon(Icons.done,
                    size: 14.0, color: (count.clamp(2, 5) == count)?kWhiteColor:kMainColor),
              ),
              SizedBox(width: 5,),
              Expanded(
                child: Text(locale.od8,
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: kMainTextColor,
                        fontSize: 15)),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20.0,
                height: 20.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: (count.clamp(2, 5) == count)?kMainColor:Color(0xffedf7ee),
                ),
                child: Icon(Icons.done,
                    size: 14.0, color: (count.clamp(2, 5) == count)?kWhiteColor:kMainColor),
              ),
              SizedBox(width: 5,),
              Expanded(
                child: Text(locale.od9,
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: kMainTextColor,
                        fontSize: 15)),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20.0,
                height: 20.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: (count.clamp(3, 5) == count)?kMainColor:Color(0xffedf7ee),
                ),
                child: Icon(Icons.done,
                    size: 14.0, color: (count.clamp(3, 5) == count)?kWhiteColor:kMainColor),
              ),
              SizedBox(
                width: 5
              ),
              Expanded(
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(locale.od10,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff75be75),
                                  fontSize: 16))),
                      // Align(
                      //     alignment: Alignment.centerLeft,
                      //     child: Text("Estimated arrival time",
                      //         style: TextStyle(
                      //             fontWeight: FontWeight.normal,
                      //             color: kMainTextColor,
                      //             fontSize: 15))),
                      // Align(
                      //     alignment: Alignment.centerLeft,
                      //     child: Text("Tomorrow, 10:30AM",
                      //         style: TextStyle(
                      //             fontWeight: FontWeight.bold,
                      //             color: kMainTextColor,
                      //             fontSize: 16))),
                    ],
                  )),
              Visibility(
                visible: ('$order_status'.replaceAll('_', ' ').toUpperCase() ==
                    'OUT FOR DELIVERY'),
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(PageRoutes.trackorder,arguments: {
                        'orderdetails':orderData
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kDateCircleColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      margin: EdgeInsets.all(5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.delivery_dining,
                              size: 20.0, color: kWhiteColor),
                          SizedBox(
                            width: 3,
                          ),
                          Text(
                            locale.od11,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: kWhiteColor,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.6),
                          )
                        ],
                      ),
                    )),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20.0,
                height: 20.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: (count==5)?kMainColor:Color(0xffedf7ee),
                ),
                child: Icon(Icons.done,
                    size: 14.0, color: (count==5)?kWhiteColor:kMainColor),
              ),
              SizedBox(width: 5,),
              Expanded(
                child: Text(locale.od12,
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: kMainTextColor,
                        fontSize: 15)),
              )
            ],
          ),
        )
      ],
    );
  }

  showAlertDialog(
      BuildContext context, AppLocalizations locale, MyOrderDataMain databean) {
    double userR = 0.0;
    TextEditingController messageController = TextEditingController();
    bool isloading = false;

    void hitRating(BuildContext context) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      http.post(addProductRatingUri, body: {
        'user_id': '${prefs.getInt('user_id')}',
        'varient_id': '${databean.varientId}',
        'store_id': '${databean.storeId}',
        'rating': '$userR',
        'description': '${messageController.text}',
      }, headers: {
        'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
      }).then((value) {
        print(value.body);
        if (value.statusCode == 200) {
          var js = jsonDecode(value.body);
          if ('${js['status']}' == '1') {
            messageController.clear();
            isAlert = false;
            isloading = false;
          }
          setState(() {
            isloading = false;
          });
          Navigator.of(context, rootNavigator: true).pop('dialog');
          Toast.show(js['message'], context,
              gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
        }
      }).catchError((e) {
        setState(() {
          isloading = false;
        });
        Navigator.of(context, rootNavigator: true).pop('dialog');
      });
    }

    Widget clear = GestureDetector(
      onTap: () {
        if (!isloading) {
          setState(() {
            isloading = true;
          });
          hitRating(context);
        }
      },
      child: Material(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            locale.continueText,
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );

    Widget no = GestureDetector(
      onTap: () {
        if (!isloading) {
          Navigator.of(context, rootNavigator: true).pop('dialog');
        }
      },
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        clipBehavior: Clip.hardEdge,
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            locale.notext,
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            insetPadding:
            EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            contentPadding:
            EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            title: Text(locale.rateourproduct),
            content: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              child: isloading
                  ? Container(
                height: 50,
                width: 50,
                alignment: Alignment.center,
                child: Align(
                  heightFactor: 40,
                  widthFactor: 40,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Visibility(
                    visible: !isKeyboardOpen,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        '${databean.productName}',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !isKeyboardOpen,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: RatingBar.builder(
                        initialRating: userR,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        unratedColor: Colors.amber.withAlpha(50),
                        itemCount: 5,
                        itemSize: 35.0,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            userR = rating;
                          });
                        },
                        updateOnDrag: true,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !isKeyboardOpen,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        locale.od13,
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    child: TextFormField(
                      maxLines: 5,
                      controller: messageController,
                      decoration: InputDecoration(
                          hintText: locale.od14,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                    ),
                  )
                ],
              ),
            ),
            actions: [clear, no],
          );
        });
      },
    );
  }

}
