import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/orderbean/orderbean_p.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';

class MyOrders extends StatefulWidget {
  // final VoidCallback onOrderCompleted;
  //
  // MyOrders(this.onOrderCompleted);

  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
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

  void getOrderList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      isloading = true;
      userName = preferences.getString('user_name');
      apcurrency = preferences.getString('app_currency');
    });
    int uId = preferences.getInt('user_id');
    print('ee  $uId');
    var http = Client();
    http.post(myOrdersUri, body: {'user_id': '${uId}'}, headers: {
      'Authorization': 'Bearer ${preferences.getString('accesstoken')}'
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
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);

    return WillPopScope(
      onWillPop: () async {
        // return Navigator.pushAndRemoveUntil(context,
        //     MaterialPageRoute(builder: (context) {
        //   return HomePage();
        // }), (Route<dynamic> route) => false);
        return Navigator.pushNamedAndRemoveUntil(
            context, PageRoutes.homePage, (route) => false);
        // return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left_sharp,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, PageRoutes.homePage, (route) => false);
              },
            ),
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
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                PageRoutes.orderdetails,
                                arguments: {'orderdetails': bean});
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Card(
                            elevation: 2,
                            shape: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none),
                            margin: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
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
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
