import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:grocery/Components/drawer.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Pages/Other/cancelreaon.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/orderbean/orderbean_p.dart';
import 'package:grocery/main.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';

class MyOrdersDrawer extends StatefulWidget {
  @override
  _MyOrdersDrawerState createState() => _MyOrdersDrawerState();
}

class _MyOrdersDrawerState extends State<MyOrdersDrawer> {
  var userName;
  List<MyOrderBeanMain> myOrders = [];
  bool isloading = false;
  bool islogin = false;
  dynamic apcurrency;
  MyOrderDataMain selectedDatabean = null;

  TextEditingController messageController = TextEditingController();

  double userR = 1.0;

  var isAlert = false;

  @override
  void initState() {
    super.initState();
    getOrderList();
  }

  void getAppCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  var http = Client();

  @override
  void dispose() {
    http.close();
    super.dispose();
  }

  void getOrderList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      isloading = true;
      islogin = preferences.getBool('islogin');
      userName = preferences.getString('user_name');
      apcurrency = preferences.getString('app_currency');
    });
    int uId = preferences.getInt('user_id');
    print('ee  $uId');
    http.post(myOrdersUri, body: {'user_id': '${uId}'}, headers: {
      'Authorization': 'Bearer ${preferences.getString('accesstoken')}'
    }).timeout(
        Duration(seconds: 90), onTimeout: () {
      return null;
    }).then((value) {
      print('ww ${value.body}');
      if (value.statusCode == 200) {
        var jd = jsonDecode(value.body) as List;
        // var jd = js['data'] as List;
        if (jd != null && jd.length > 0) {
          print('${jd.toString()}');
          myOrders.clear();
          myOrders = jd.map((e) => MyOrderBeanMain.fromJson(e)).toList();
          print('${myOrders.toString()}');
        }
      }
      setState(() {
        isloading = false;
      });
    }).catchError((e) {
      setState(() {
        isloading = false;
      });
      print(e);
    });
    // http.post(myOrdersUri, body: {'user_id': '${uId}'})
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Color(0xfff8f8f8),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: kWhiteColor,
          title: Text(
            locale.myOrders,
            style: TextStyle(color: kMainTextColor),
          ),
          centerTitle: true,
        ),
      ),
      body: (!isloading && myOrders != null && myOrders.length > 0)
          ? Stack(
              children: [
                Container(
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: myOrders.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      MyOrderBeanMain bean = myOrders[index];
                      return GestureDetector(
                        onTap: (){
                          Navigator.of(context).pushNamed(PageRoutes.orderdetails,arguments: {
                            'orderdetails':bean
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Card(
                          elevation: 2,
                          shape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none),
                          margin:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          color: Colors.white,
                          child: Column(
                            children: [
                              buildItem(
                                  context,
                                  '${bean.data[0].varientImage}',
                                  '${bean.storeName}',
                                  '${bean.data.length} items',
                                  '${bean.cartId}',
                                  '${bean.data[0].orderDate}'),
                              buildOrderInfoRow(
                                  context,
                                  '$apcurrency ${('${bean.paymentMethod}'.toUpperCase() == 'CARD') ? 0.0 : bean.remainingAmount}',
                                  '${bean.paymentMethod}',
                                  '${bean.orderStatus}',
                                  borderRadius: 0),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 12.0, vertical: 12),
                              //   child: Column(
                              //     children: [
                              //       builRow(bean.orderStatus),
                              //       SizedBox(
                              //         height: 10,
                              //       ),
                              //       Padding(
                              //         padding: const EdgeInsets.symmetric(
                              //             horizontal: 6.0),
                              //         child: Row(
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.spaceBetween,
                              //           children: [
                              //             Text(
                              //               locale.placed + '  ',
                              //               style: TextStyle(fontSize: 12),
                              //             ),
                              //             Text(
                              //               locale.packing,
                              //               style: TextStyle(fontSize: 12),
                              //             ),
                              //             Text(
                              //               locale.dispatched,
                              //               style: TextStyle(fontSize: 12),
                              //             ),
                              //             Text(
                              //               locale.track,
                              //               style: TextStyle(fontSize: 12),
                              //             ),
                              //             Text(
                              //               ' ' + locale.delivered,
                              //               style: TextStyle(fontSize: 12),
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // Visibility(
                              //   visible:
                              //       (bean.data != null && bean.data.length > 0),
                              //   child: Column(
                              //     children: [
                              //       Container(
                              //         color: Colors.grey[100],
                              //         width: MediaQuery.of(context).size.width,
                              //         padding: const EdgeInsets.symmetric(
                              //             vertical: 8.0, horizontal: 12),
                              //         child: Text(
                              //           locale.orderedItems,
                              //           style:
                              //               Theme.of(context).textTheme.subtitle2,
                              //         ),
                              //       ),
                              //       ListView.builder(
                              //           itemCount: bean.data.length,
                              //           shrinkWrap: true,
                              //           physics: NeverScrollableScrollPhysics(),
                              //           itemBuilder: (context, indi) {
                              //             double _userRating = 0.0;
                              //             return Container(
                              //               color: Colors.grey[100],
                              //               padding: const EdgeInsets.symmetric(
                              //                   vertical: 8.0, horizontal: 12),
                              //               child: Column(
                              //                 crossAxisAlignment:
                              //                     CrossAxisAlignment.start,
                              //                 children: [
                              //                   buildAmountRow(
                              //                       '${bean.data[indi].productName}',
                              //                       '$apcurrency ${bean.data[indi].price}'),
                              //                   SizedBox(
                              //                     height: 5,
                              //                   ),
                              //                   Row(
                              //                     mainAxisAlignment:
                              //                         MainAxisAlignment
                              //                             .spaceBetween,
                              //                     children: [
                              //                       Text(
                              //                           'Qnt. ${bean.data[indi].qty}',
                              //                           style: Theme.of(context)
                              //                               .textTheme
                              //                               .subtitle2),
                              //                       ('${bean.orderStatus}'
                              //                                   .toUpperCase() ==
                              //                               'COMPLETED')
                              //                           ? RatingBar.builder(
                              //                               initialRating:
                              //                                   _userRating,
                              //                               minRating: 1,
                              //                               direction:
                              //                                   Axis.horizontal,
                              //                               allowHalfRating: true,
                              //                               unratedColor: Colors
                              //                                   .amber
                              //                                   .withAlpha(50),
                              //                               itemCount: 5,
                              //                               itemSize: 20.0,
                              //                               itemPadding: EdgeInsets
                              //                                   .symmetric(
                              //                                       horizontal:
                              //                                           4.0),
                              //                               itemBuilder:
                              //                                   (context, _) =>
                              //                                       Icon(
                              //                                 Icons.star,
                              //                                 color: Colors.amber,
                              //                               ),
                              //                               onRatingUpdate:
                              //                                   (rating) {
                              //                                 setState(() {
                              //                                   _userRating =
                              //                                       rating;
                              //                                   isAlert = true;
                              //                                   selectedDatabean =
                              //                                       bean.data[
                              //                                           indi];
                              //                                   // showAlertDialog(context,locale,bean.data[indi]);
                              //                                 });
                              //                               },
                              //                               updateOnDrag: true,
                              //                             )
                              //                           : SizedBox.shrink(),
                              //                     ],
                              //                   ),
                              //                 ],
                              //               ),
                              //             );
                              //           }),
                              //     ],
                              //   ),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       left: 8.0, right: 8, bottom: 10, top: 5),
                              //   child: Column(
                              //     children: [
                              //       buildAmountRow(locale.subtotal,
                              //           '$apcurrency ${(double.parse('${bean.price}') - double.parse('${bean.delCharge}'))}'),
                              //       buildAmountRow(locale.deliveryFee,
                              //           '$apcurrency ${bean.delCharge}'),
                              //       buildAmountRow(locale.promoCode,
                              //           '-$apcurrency ${bean.couponDiscount}'),
                              //       buildAmountRow(locale.paidbywallet,
                              //           '-$apcurrency ${bean.paidByWallet}'),
                              //       buildAmountRow(locale.amountToPay,
                              //           '$apcurrency ${('${bean.paymentMethod}'.toUpperCase() == 'CARD') ? 0.0 : bean.remainingAmount}',
                              //           fontWeight: FontWeight.w700),
                              //       Row(
                              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //         children: [
                              //           Visibility(
                              //             visible: ('${bean.orderStatus}'
                              //                     .toUpperCase() ==
                              //                 'COMPLETED'),
                              //             child: Align(
                              //               alignment: Alignment.centerLeft,
                              //               child: Padding(
                              //                 padding:
                              //                     const EdgeInsets.only(top: 8.0),
                              //                 child: RaisedButton(
                              //                   child: Text(
                              //                     'Invoice',
                              //                     style: TextStyle(
                              //                         color: kWhiteColor,
                              //                         fontSize: 14,
                              //                         fontWeight:
                              //                             FontWeight.w400),
                              //                   ),
                              //                   color: kMainColor,
                              //                   highlightColor: kMainColor,
                              //                   focusColor: kMainColor,
                              //                   splashColor: kMainColor,
                              //                   padding: EdgeInsets.symmetric(
                              //                       vertical: 8, horizontal: 10),
                              //                   shape: RoundedRectangleBorder(
                              //                     borderRadius:
                              //                         BorderRadius.circular(30.0),
                              //                   ),
                              //                   onPressed: () {
                              //                     Navigator.of(context)
                              //                         .pushNamed(
                              //                             PageRoutes.invoice,
                              //                             arguments: {
                              //                               'inv_details': bean,
                              //                             })
                              //                         .then((value) {})
                              //                         .catchError((e) {});
                              //                   },
                              //                 ),
                              //               ),
                              //             ),
                              //           ),
                              //           Visibility(
                              //             visible: ('${bean.orderStatus}'
                              //                     .toUpperCase() ==
                              //                 'PENDING'),
                              //             child: Align(
                              //               alignment: Alignment.centerRight,
                              //               child: Padding(
                              //                 padding:
                              //                     const EdgeInsets.only(top: 8.0),
                              //                 child: RaisedButton(
                              //                   child: Text(
                              //                     locale.cancelorder,
                              //                     style: TextStyle(
                              //                         color: kWhiteColor,
                              //                         fontSize: 14,
                              //                         fontWeight:
                              //                             FontWeight.w400),
                              //                   ),
                              //                   color: kMainColor,
                              //                   highlightColor: kMainColor,
                              //                   focusColor: kMainColor,
                              //                   splashColor: kMainColor,
                              //                   padding: EdgeInsets.symmetric(
                              //                       vertical: 8, horizontal: 10),
                              //                   shape: RoundedRectangleBorder(
                              //                     borderRadius:
                              //                         BorderRadius.circular(30.0),
                              //                   ),
                              //                   onPressed: () {
                              //                     Navigator.of(context).push(
                              //                         MaterialPageRoute(
                              //                             builder: (context) {
                              //                       return CancelPage(
                              //                           '${bean.cartId}');
                              //                     })).then((value) {
                              //                       if (value) {
                              //                         getOrderList();
                              //                       }
                              //                     }).catchError((e) {
                              //                       print(e);
                              //                     });
                              //                   },
                              //                 ),
                              //               ),
                              //             ),
                              //           )
                              //         ],
                              //       )
                              //     ],
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Visibility(
                //     visible: isAlert,
                //     child: selectedDatabean != null
                //         ? GestureDetector(
                //             onTap: () {},
                //             child: Container(
                //               height: MediaQuery.of(context).size.height,
                //               width: MediaQuery.of(context).size.width,
                //               alignment: Alignment.center,
                //               color: Colors.black87,
                //               child: SingleChildScrollView(
                //                 child: Container(
                //                   width: MediaQuery.of(context).size.width,
                //                   margin: EdgeInsets.all(20.0),
                //                   padding: EdgeInsets.all(20.0),
                //                   decoration: BoxDecoration(
                //                       color: Colors.white,
                //                       borderRadius: BorderRadius.circular(20)),
                //                   child: isloading
                //                       ? Container(
                //                           height: 50,
                //                           width: 50,
                //                           alignment: Alignment.center,
                //                           child: Align(
                //                             heightFactor: 40,
                //                             widthFactor: 40,
                //                             alignment: Alignment.center,
                //                             child: CircularProgressIndicator(),
                //                           ),
                //                         )
                //                       : Column(
                //                           children: [
                //                             Padding(
                //                               padding:
                //                                   const EdgeInsets.all(10.0),
                //                               child: Text(
                //                                 '${selectedDatabean.productName}',
                //                                 style: TextStyle(
                //                                     fontWeight: FontWeight.w700,
                //                                     fontSize: 18),
                //                               ),
                //                             ),
                //                             Padding(
                //                               padding:
                //                                   const EdgeInsets.all(10.0),
                //                               child: RatingBar.builder(
                //                                 initialRating: userR,
                //                                 minRating: 1,
                //                                 direction: Axis.horizontal,
                //                                 allowHalfRating: true,
                //                                 unratedColor:
                //                                     Colors.amber.withAlpha(50),
                //                                 itemCount: 5,
                //                                 itemSize: 35.0,
                //                                 itemPadding:
                //                                     EdgeInsets.symmetric(
                //                                         horizontal: 4.0),
                //                                 itemBuilder: (context, _) =>
                //                                     Icon(
                //                                   Icons.star,
                //                                   color: Colors.amber,
                //                                 ),
                //                                 onRatingUpdate: (rating) {
                //                                   setState(() {
                //                                     userR = rating;
                //                                   });
                //                                 },
                //                                 updateOnDrag: true,
                //                               ),
                //                             ),
                //                             Padding(
                //                               padding:
                //                                   const EdgeInsets.all(10.0),
                //                               child: Text(
                //                                 'Message',
                //                                 style: TextStyle(
                //                                     fontWeight: FontWeight.w700,
                //                                     fontSize: 14),
                //                               ),
                //                             ),
                //                             Padding(
                //                               padding: EdgeInsets.symmetric(
                //                                   horizontal: 20, vertical: 20),
                //                               child: TextFormField(
                //                                 maxLines: 5,
                //                                 controller: messageController,
                //                                 decoration: InputDecoration(
                //                                     hintText:
                //                                         'Enter your message',
                //                                     border: OutlineInputBorder(
                //                                         borderRadius:
                //                                             BorderRadius
                //                                                 .circular(20))),
                //                               ),
                //                             ),
                //                             Row(
                //                               mainAxisAlignment:
                //                                   MainAxisAlignment.end,
                //                               children: [
                //                                 GestureDetector(
                //                                   onTap: () {
                //                                     if (!isloading) {
                //                                       setState(() {
                //                                         isloading = true;
                //                                       });
                //                                       hitRating(context);
                //                                     }
                //                                   },
                //                                   child: Material(
                //                                     elevation: 2,
                //                                     clipBehavior: Clip.hardEdge,
                //                                     borderRadius:
                //                                         BorderRadius.all(
                //                                             Radius.circular(
                //                                                 20)),
                //                                     child: Container(
                //                                       padding: EdgeInsets.only(
                //                                           left: 20,
                //                                           right: 20,
                //                                           top: 10,
                //                                           bottom: 10),
                //                                       decoration: BoxDecoration(
                //                                           color: Colors.green,
                //                                           borderRadius:
                //                                               BorderRadius.all(
                //                                                   Radius
                //                                                       .circular(
                //                                                           20))),
                //                                       child: Text(
                //                                         locale.submit,
                //                                         style: TextStyle(
                //                                             fontSize: 13,
                //                                             color: kWhiteColor),
                //                                       ),
                //                                     ),
                //                                   ),
                //                                 ),
                //                                 SizedBox(
                //                                   width: 20,
                //                                 ),
                //                                 GestureDetector(
                //                                   onTap: () {
                //                                     if (!isloading) {
                //                                       setState(() {
                //                                         isAlert = false;
                //                                         selectedDatabean = null;
                //                                       });
                //                                     }
                //                                   },
                //                                   child: Material(
                //                                     elevation: 2,
                //                                     borderRadius:
                //                                         BorderRadius.all(
                //                                             Radius.circular(
                //                                                 20)),
                //                                     clipBehavior: Clip.hardEdge,
                //                                     child: Container(
                //                                       padding: EdgeInsets.only(
                //                                           left: 20,
                //                                           right: 20,
                //                                           top: 10,
                //                                           bottom: 10),
                //                                       decoration: BoxDecoration(
                //                                           color: Colors.red,
                //                                           borderRadius:
                //                                               BorderRadius.all(
                //                                                   Radius
                //                                                       .circular(
                //                                                           20))),
                //                                       child: Text(
                //                                         locale.notext,
                //                                         style: TextStyle(
                //                                             fontSize: 13,
                //                                             color: kWhiteColor),
                //                                       ),
                //                                     ),
                //                                   ),
                //                                 )
                //                               ],
                //                             )
                //                           ],
                //                         ),
                //                 ),
                //               ),
                //             ),
                //           )
                //         : SizedBox.shrink()),
              ],
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Align(
                alignment: Alignment.center,
                child: (isloading)
                    ? ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: 10,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Shimmer(
                            duration: Duration(seconds: 3),
                            color: Colors.white,
                            enabled: true,
                            direction: ShimmerDirection.fromLeftToRight(),
                            child: Card(
                              elevation: 3,
                              shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Stack(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Container(
                                                  height: 70,
                                                  width: 70,
                                                  color: Colors.grey[300],
                                                )),
                                            SizedBox(width: 15),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 10,
                                                  width: 130,
                                                  color: Colors.grey[300],
                                                ),
                                                SizedBox(height: 6),
                                                Container(
                                                  height: 10,
                                                  width: 100,
                                                  color: Colors.grey[300],
                                                ),
                                                SizedBox(height: 16),
                                                Container(
                                                  height: 10,
                                                  width: 70,
                                                  color: Colors.grey[300],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Positioned.directional(
                                          textDirection:
                                              Directionality.of(context),
                                          end: 0,
                                          bottom: 0,
                                          child: Container(
                                            height: 10,
                                            width: 70,
                                            color: Colors.grey[300],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(8)),
                                      color: Colors.grey[100],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 11.0, vertical: 12),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 10,
                                              width: 100,
                                              color: Colors.grey[300],
                                            ),
                                            SizedBox(height: 8),
                                            LimitedBox(
                                              maxWidth: 100,
                                              child: Container(
                                                height: 10,
                                                width: 130,
                                                color: Colors.grey[300],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 10,
                                              width: 100,
                                              color: Colors.grey[300],
                                            ),
                                            SizedBox(height: 8),
                                            LimitedBox(
                                              maxWidth: 100,
                                              child: Container(
                                                height: 10,
                                                width: 130,
                                                color: Colors.grey[300],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 10,
                                              width: 100,
                                              color: Colors.grey[300],
                                            ),
                                            SizedBox(height: 8),
                                            LimitedBox(
                                              maxWidth: 100,
                                              child: Container(
                                                height: 10,
                                                width: 130,
                                                color: Colors.grey[300],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Text(
                        'No Order found till date.',
                        style: TextStyle(
                          color: kMainColor,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
    );
  }

  CircleAvatar buildStatusIcon(IconData icon, {bool disabled = false}) =>
      CircleAvatar(
          backgroundColor: !disabled ? Color(0xff222e3e) : Colors.grey[300],
          child: Icon(
            icon,
            size: 20,
            color: !disabled
                ? Theme.of(context).primaryColor
                : Theme.of(context).scaffoldBackgroundColor,
          ));

  Container buildOrderInfoRow(BuildContext context, String price,
      String paymentMode, String orderStatus,
      {double borderRadius = 8}) {
    var locale = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(borderRadius)),
        color: Colors.grey[100],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 12),
      child: Row(
        children: [
          buildGreyColumn(context, locale.payment, price),
          Spacer(),
          buildGreyColumn(context, locale.paymentMode, paymentMode),
          Spacer(),
          buildGreyColumn(
              context, locale.orderStatus, orderStatus.replaceAll('_', ' '),
              text2Color: Theme.of(context).primaryColor),
        ],
      ),
    );
  }

  Padding buildItem(BuildContext context, String img, String name,
      String category, String orderId, String order_date) {
    var locale = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    img,
                    height: 70,
                    width: 70,
                    fit: BoxFit.fill,
                  )),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 6),
                  Text(
                    category,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  SizedBox(height: 16),
                  Text(locale.orderedOn + ' $order_date',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2
                          .copyWith(fontSize: 10.5)),
                ],
              ),
            ],
          ),
          Positioned.directional(
            textDirection: Directionality.of(context),
            end: 0,
            bottom: 0,
            child: Text(
              locale.orderID + ' $orderId',
              textAlign: TextAlign.right,
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .copyWith(fontSize: 10.5),
            ),
          ),
        ],
      ),
    );
  }


  Column buildGreyColumn(BuildContext context, String text1, String text2,
      {Color text2Color = Colors.black}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text1,
            style:
                Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 11)),
        SizedBox(height: 8),
        LimitedBox(
          maxWidth: 100,
          child: Text(text2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: text2Color)),
        ),
      ],
    );
  }


}
