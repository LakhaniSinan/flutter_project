import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/addressbean/showaddress.dart';
import 'package:grocery/beanmodel/cart/cartitembean.dart';
import 'package:grocery/beanmodel/cart/makeorderbean.dart';
import 'package:grocery/beanmodel/cart/timeslotbeannew.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';

class DeliveryOption extends StatefulWidget {
  @override
  DeliveryOptionState createState() => DeliveryOptionState();
}

class DeliveryOptionState extends State<DeliveryOption> {
  var http = Client();
  List<int> radioButtons = [0, -1, -1];
  bool isAddressLoading = false;
  bool isMakeingOrder = false;
  bool enterFirst = false;
  List<ShowAllAddressMain> allAddressData = [];
  List<CartItemData> cartItemd = [];
  dynamic cart_id;
  dynamic store_id;
  CartStoreDetails storeDetails;
  int seletedValue = -1;
  bool addressSelection = false;
  AddressData selectedAddrs;
  DateTime firstDate;

  // DateTime lastDate;
  List<DateTime> dateList = [];
  List<TimeSlotNewBeanData> radioList = [];
  String dateTimeSt = '';
  String apCurrency = '';
  int idd = 0;
  int idd1 = 0;
  bool isFetchingTime = false;
  String addressshow;
  bool isCouponApplied = false;
  bool isCouponAppliedProgress = false;
  String couponCodeTxt = '--';
  bool isChangeAddressTap = false;
  double totalPrice = 0.0;
  double totalMrp = 0.0;
  double deliveryFee = 0.0;
  double promocodeprice = 0.0;
  bool isOpenMenu = false;
  dynamic apcurrency;

  @override
  void initState() {
    super.initState();
  }

  void getAddressByUserId(dynamic storeid) async {
    setState(() {
      isAddressLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');

    var url = showAddressUri;
    await http.post(url, body: {
      'user_id': '${userId}',
      'store_id': '${storeid}'
    }, headers: {
      'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
    }).then((response) {
      print('Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        if (response.body != "[{\"data\":\"No Address Found\"}]") {
          var js = jsonDecode(response.body) as List;
          if (js != null && js.length > 0) {
            allAddressData =
                js.map((e) => ShowAllAddressMain.fromJson(e)).toList();
            int indexd = -1;
            for (int i = 0; i < allAddressData.length; i++) {
              indexd = allAddressData[i].data.indexOf(AddressData('', '', '',
                  '', '', '', '', '', '', '', '', '', '', 1, '', ''));
              if (indexd >= 0) {
                setState(() {
                  selectedAddrs = allAddressData[i].data[indexd];
                  seletedValue =
                      int.parse('${allAddressData[i].data[indexd].address_id}');
                  addressshow =
                      '${selectedAddrs.house_no}${selectedAddrs.landmark}${selectedAddrs.society}${selectedAddrs.city}(${selectedAddrs.pincode})${selectedAddrs.state}';
                });
              }
            }
          }
        } else {
          Toast.show('No address found', context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
        }
      }
      setState(() {
        isAddressLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isAddressLoading = false;
      });
      print(e);
    });
  }

  void prepareData(firstDate) {
    dateList.add(firstDate);
    for (int i = 0; i < 9; i++) {
      DateTime tt = DateFormat('dd/MM/yyyy').parse(DateFormat('dd/MM/yyyy')
          .format(firstDate.add(Duration(days: i + 1))));
      dateList.add(tt);
    }
  }

  void hitDateCounter(date) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      idd1 = 0;
      isFetchingTime = true;
    });
    http.post(timeSlotUri, body: {
      'selected_date': '${date}',
      'store_id': '${store_id}',
    }, headers: {
      'Authorization': 'Bearer ${preferences.getString('accesstoken')}'
    }).then((value) {
      print('time s - ${value.body}');
      if (value != null && value.statusCode == 200) {
        TimeSlotNewBean timebean =
            TimeSlotNewBean.fromJson(jsonDecode(value.body));
        if ('${timebean.status}' == '1') {
          setState(() {
            radioList.clear();
            radioList = timebean.data;
            isFetchingTime = false;
          });
        } else {
          setState(() {
            radioList = [];
            isFetchingTime = false;
          });
          Toast.show(timebean.message, context, duration: Toast.LENGTH_SHORT);
        }
      } else {
        setState(() {
          radioList = [];
          isFetchingTime = false;
        });
      }
    }).catchError((e) {
      setState(() {
        radioList = [];
        isFetchingTime = false;
      });
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String, dynamic> receivedData =
        ModalRoute.of(context).settings.arguments;
    if (!enterFirst) {
      enterFirst = true;
      apcurrency = receivedData['currency'];
      store_id = receivedData['store_id'];
      storeDetails = receivedData['store_d'];
      cartItemd = receivedData['cartdetails'];
      totalMrp = receivedData['totalmrp'];
      totalPrice = receivedData['totalprice'];
      deliveryFee = receivedData['deliveryfee'];
      firstDate = DateFormat('dd/MM/yyyy')
          .parse(DateFormat('dd/MM/yyyy').format(DateTime.now()));
      prepareData(firstDate);
      dateTimeSt =
          '${firstDate.year}-${(firstDate.month.toString().length == 1) ? '0' + firstDate.month.toString() : firstDate.month}-${firstDate.day}';
      dynamic date =
          '${firstDate.day}-${(firstDate.month.toString().length == 1) ? '0' + firstDate.month.toString() : firstDate.month}-${firstDate.year}';
      getAddressByUserId(store_id);
      hitDateCounter(date);
    }

    return WillPopScope(
      onWillPop: () async {
        if (isChangeAddressTap) {
          setState(() {
            isChangeAddressTap = false;
            isAddressLoading = false;
          });
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
          backgroundColor: Color(0xfff8f8f8),
          appBar: AppBar(
            backgroundColor: kWhiteColor,
            title: Text(
              isChangeAddressTap
                  ? locale.do1
                  : locale.do2,
              style: TextStyle(
                  color: kMainTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            automaticallyImplyLeading: true,
            centerTitle: true,
          ),
          body: isChangeAddressTap
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: (!isAddressLoading &&
                              allAddressData != null &&
                              allAddressData.length > 0)
                          ? ListView.builder(
                              itemCount: allAddressData.length,
                              shrinkWrap: true,
                              primary: false,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: buildRAddressTile(
                                      context,
                                      allAddressData[index].type,
                                      allAddressData[index].data),
                                );
                              })
                          : Container(
                              alignment: Alignment.center,
                              child: (isAddressLoading)
                                  ? Align(
                                      widthFactor: 50,
                                      heightFactor: 50,
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: kMainColor,
                                      ),
                                    )
                                  : Text(locale.nosaveaddress),
                            ),
                    ),
                    MaterialButton(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(locale.do3,
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: kWhiteColor,
                                    letterSpacing: 1.5,
                                    fontSize: 15)),
                            Icon(
                              Icons.add,
                              color: kWhiteColor,
                            )
                          ],
                        ),
                        height: 52,
                        color: kMainColor,
                        onPressed: () {
                          Navigator.pushNamed(context, PageRoutes.addaddressp)
                              .then((value) {
                            getAddressByUserId(store_id);
                          }).catchError((e) {
                            print(e);
                          });
                        }),
                  ],
                )
              : Column(children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: kWhiteColor,
                              ),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 15),
                                            child: Text(locale.do4,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    color: kMainTextColor,
                                                    letterSpacing: 1.5,
                                                    fontSize: 13)),
                                          ),
                                        ),
                                        MaterialButton(
                                          onPressed: () {
                                            setState(() {
                                              isChangeAddressTap = true;
                                            });
                                          },
                                          elevation: 0,
                                          color: kWhiteColor,
                                          splashColor: kMainColor,
                                          highlightColor: kMainColor,
                                          child: Text(locale.do5,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: kMainColor,
                                                  letterSpacing: 1.5,
                                                  fontSize: 16)),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          6, 5, 6, 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(right: 10),
                                            width: 20.0,
                                            height: 20.0,
                                            decoration: new BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xff75be75),
                                            ),
                                            child: Icon(Icons.done,
                                                size: 15.0, color: kWhiteColor),
                                          ),
                                          Expanded(
                                              child: Text(
                                                  (addressshow != null)
                                                      ? '$addressshow'
                                                      : locale.do6,
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: kMainTextColor,
                                                      fontSize: 14))),
                                        ],
                                      ),
                                    ),
                                  ])),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
                            decoration: BoxDecoration(
                              color: kWhiteColor,
                            ),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Text(
                                            locale.do7,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                color: kMainTextColor,
                                                letterSpacing: 1.5,
                                                fontSize: 13)),
                                      )),
                                  Divider(
                                    color: Color(0xfff8f8f8),
                                    height: 5,
                                    thickness: 2,
                                    indent: 2,
                                    endIndent: 2,
                                  ),
                                  Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      height: 80,
                                      color: kWhiteColor,
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: dateList.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            // access element from list using index
                                            // you can create and return a widget of your choice
                                            String dayName = DateFormat('EEE')
                                                .format(dateList[index]);
                                            return GestureDetector(
                                              onTap: () {
                                                if (!isFetchingTime) {
                                                  setState(() {
                                                    idd = index;
                                                    dateTimeSt =
                                                        '${dateList[index].year}-${(dateList[index].month.toString().length == 1) ? '0' + dateList[index].month.toString() : dateList[index].month}-${dateList[index].day}';
                                                    dynamic date =
                                                        '${dateList[index].day}-${(dateList[index].month.toString().length == 1) ? '0' + dateList[index].month.toString() : dateList[index].month}-${dateList[index].year}';

                                                    hitDateCounter(date);
                                                    print('${dateTimeSt}');
                                                  });
                                                } else {
                                                  Toast.show(
                                                      locale.pcurprogress,
                                                      context,
                                                      duration:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          Toast.LENGTH_LONG);
                                                }
                                              },
                                              behavior: HitTestBehavior.opaque,
                                              child: Container(
                                                width: 50.0,
                                                height: 80.0,
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 6),
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                decoration: new BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.elliptical(
                                                              35, 35)),
                                                  color: (idd == index)
                                                      ? kMainColor
                                                      : kWhiteColor,
                                                ),
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      SizedBox(
                                                        height: 4,
                                                      ),
                                                      Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                              (index ==
                                                                      0)
                                                                  ? 'Today'
                                                                  : '$dayName',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  color: (idd ==
                                                                          index)
                                                                      ? kWhiteColor
                                                                      : kMainTextColor,
                                                                  fontSize:
                                                                      14))),
                                                      Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                              '${dateList[index].day}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  color: (idd ==
                                                                          index)
                                                                      ? kWhiteColor
                                                                      : kMainTextColor,
                                                                  fontSize:
                                                                      14))),
                                                      Icon(Icons.circle,
                                                          size: 10.0,
                                                          color: (idd == index)
                                                              ? kWhiteColor
                                                              : kDateCircleColor)
                                                    ]),
                                              ),
                                            );
                                          })),
                                  Divider(
                                    color: Color(0xfff8f8f8),
                                    height: 2,
                                    thickness: 2,
                                    indent: 2,
                                    endIndent: 2,
                                  ),
                                ]),
                          ),
                          Container(
                              color: kWhiteColor,
                              child: isFetchingTime
                                  ? ListView.builder(
                                      primary: false,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: 5,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Shimmer(
                                                        duration: Duration(
                                                            seconds: 3),
                                                        color: kWhiteColor,
                                                        enabled: true,
                                                        direction:
                                                            ShimmerDirection
                                                                .fromLTRB(),
                                                        child: Container(
                                                          color:
                                                              kCardBackgroundColor,
                                                          width: 150,
                                                          height: 20,
                                                        )),
                                                    Shimmer(
                                                        duration: Duration(
                                                            seconds: 3),
                                                        color: kWhiteColor,
                                                        enabled: true,
                                                        direction:
                                                            ShimmerDirection
                                                                .fromLTRB(),
                                                        child: Container(
                                                          color:
                                                              kCardBackgroundColor,
                                                          width: 100,
                                                          height: 20,
                                                        )),
                                                  ],
                                                ),
                                                Divider(
                                                  color: Color(0xfff8f8f8),
                                                  height: 5,
                                                  thickness: 2,
                                                  indent: 2,
                                                  endIndent: 2,
                                                ),
                                              ],
                                            ));
                                      })
                                  : ListView.builder(
                                      primary: false,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: radioList.length,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        // access element from list using index
                                        // you can create and return a widget of your choice
                                        return Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        child: Text(
                                                            '${radioList[index].timeslot}',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                color:
                                                                    kMainTextColor,
                                                                fontSize: 15))),
                                                    '${radioList[index].availibility}' ==
                                                            'available'
                                                        ? Row(
                                                            children: [
                                                              Text(locale.do8,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300,
                                                                      color:
                                                                          kMainTextColor,
                                                                      fontSize:
                                                                          15)),
                                                              Radio(
                                                                value: index,
                                                                activeColor:
                                                                    kMainColor,
                                                                groupValue:
                                                                    idd1,
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    idd1 =
                                                                        value;
                                                                  });
                                                                },
                                                              ),
                                                            ],
                                                          )
                                                        : Text(locale.do9,
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                color:
                                                                    kLightTextColor,
                                                                fontSize: 15)),
                                                  ],
                                                ),
                                                Divider(
                                                  color: Color(0xfff8f8f8),
                                                  height: 5,
                                                  thickness: 2,
                                                  indent: 2,
                                                  endIndent: 2,
                                                ),
                                              ],
                                            ));
                                      })),
                          Visibility(
                            visible: isOpenMenu,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Divider(
                                  height: 10,
                                  thickness: 10,
                                  color: Color(0xfff8f8f8),
                                ),
                                Material(
                                  color: kWhiteColor,
                                  elevation: 1,
                                  child: Container(
                                    color: kWhiteColor,
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20, top: 10, bottom: 10),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding:
                                            const EdgeInsets.symmetric(vertical: 15),
                                            child: Text("${locale.do10} (${cartItemd.length} ${locale.od5})",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    color: kMainTextColor,
                                                    letterSpacing: 1.5,
                                                    fontSize: 13)),
                                          ),
                                          Divider(
                                            thickness: 1.5,
                                            height: 1.5,
                                            color: kButtonBorderColor.withOpacity(0.5),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15),
                                            child: Column(children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 8),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Expanded(
                                                      child: Text(locale.do11,
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.w400,
                                                              color: kMainTextColor,
                                                              fontSize: 15)),
                                                    ),
                                                    Text('$apcurrency $totalMrp',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.normal,
                                                            color: kMainTextColor,
                                                            fontSize: 15)),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 8),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Expanded(
                                                      child: Text(locale.do12,
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.w400,
                                                              color: kMainTextColor,
                                                              fontSize: 15)),
                                                    ),
                                                    Text('$apcurrency $totalPrice',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.normal,
                                                            color: kMainTextColor,
                                                            fontSize: 15)),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 8),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Expanded(
                                                      child: Text(locale.do13,
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.w400,
                                                              color: kMainTextColor,
                                                              letterSpacing: 1.5,
                                                              fontSize: 15)),
                                                    ),
                                                    Text('- $apcurrency ${(totalMrp-totalPrice)}',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.normal,
                                                            color: kMainTextColor,
                                                            letterSpacing: 1.5,
                                                            fontSize: 15)),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 8),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Expanded(
                                                      child: Text(locale.do14,
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.w400,
                                                              color: kMainTextColor,
                                                              letterSpacing: 1.5,
                                                              fontSize: 15)),
                                                    ),
                                                    Text('- $apcurrency $promocodeprice',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.normal,
                                                            color: kMainTextColor,
                                                            letterSpacing: 1.5,
                                                            fontSize: 15)),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 8),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Expanded(
                                                      child: Text(locale.do15,
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.w400,
                                                              color: kMainTextColor,
                                                              letterSpacing: 1.5,
                                                              fontSize: 15)),
                                                    ),
                                                    Text('$apcurrency $deliveryFee',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.normal,
                                                            color: kMainTextColor,
                                                            letterSpacing: 1.5,
                                                            fontSize: 15)),
                                                  ],
                                                ),
                                              ),
                                            ]),
                                          ),
                                          Divider(
                                            thickness: 1.5,
                                            height: 1.5,
                                            color: kButtonBorderColor.withOpacity(0.5),
                                          ),
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(bottom: 8, top: 8),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  child: Text(locale.do11,
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w400,
                                                          color: kMainTextColor,
                                                          fontSize: 15)),
                                                ),
                                                Text('$apcurrency ${totalPrice+deliveryFee}',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.normal,
                                                        color: kMainTextColor,
                                                        fontSize: 15)),
                                              ],
                                            ),
                                          ),
                                        ]),
                                  ),
                                ),
                                Divider(
                                  height: 10,
                                  thickness: 10,
                                  color: Color(0xfff8f8f8),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: kWhiteColor,
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 10, right: 15, left: 10),
                    child: Row(
                      children: [
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('$apcurrency ${totalPrice + deliveryFee}',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: kMainTextColor,
                                    letterSpacing: 1.7,
                                    fontSize: 18)),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isOpenMenu = !isOpenMenu;
                                  });
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Text(locale.do16,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: kMainColor,
                                        fontSize: 15)),
                              ),
                            ),
                          ],
                        )),
                        Expanded(
                            child: GestureDetector(
                          onTap: () {
                            if (!isMakeingOrder && !isFetchingTime && radioList!=null && radioList.length>0) {
                              setState(() {
                                isMakeingOrder = true;
                              });
                              makeOrderRequest(locale);
                            }else{
                              Toast.show(locale.do17, context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
                            }
                          },
                          child: (!isMakeingOrder)
                              ? Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: kMainColor,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: Text(
                                          locale.do18,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: kWhiteColor,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.6),
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward_ios,
                                          size: 17.0, color: kWhiteColor)
                                    ],
                                  ),
                                )
                              : Container(
                            height: 40,
                                child: Align(
                                    widthFactor: 40,
                                    heightFactor: 40,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: kMainColor,
                                    ),
                                  ),
                              ),
                        )),
                      ],
                    ),
                  ),
                ])),
    );
  }

  Widget buildRAddressTile(
      BuildContext context, String heading, List<AddressData> address) {
    var locale = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
      width: MediaQuery.of(context).size.width,
      color: kWhiteColor,
      child: ListView.separated(
        itemCount: address.length,
        shrinkWrap: true,
        primary: false,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          AddressData addData = address[index];
          String addressshow =
              '${addData.house_no}${addData.landmark}${addData.society}${addData.city}(${addData.pincode})${addData.state}';
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(heading,
                            textAlign: TextAlign.start,
                            softWrap: true,
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: kMainTextColor,
                                letterSpacing: 1.5,
                                fontSize: 18))),
                    Radio(
                        value: int.parse('${addData.address_id}'),
                        groupValue: seletedValue,
                        onChanged: (int value) {
                          if (seletedValue !=
                              int.parse('${addData.address_id}')) {
                            selectAddress(addData.address_id, addData);
                          }
                        }),
                  ],
                ),
              ),
              Row(
                children: [
                  Column(
                    children: [
                      Icon(
                        Icons.home,
                        color: kHomeIconColor,
                        size: 70,
                      ),
                      IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: kMainTextColor,
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(PageRoutes.editAddress, arguments: {
                              'address_d': addData,
                            }).then((value) {
                              getAddressByUserId(store_id);
                            }).catchError((e) {
                              getAddressByUserId(store_id);
                            });
                          }),
                    ],
                  ),
                  Expanded(
                      child: Column(
                    children: [
                      Text(
                        addressshow,
                        textAlign: TextAlign.start,
                        softWrap: true,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          // runAlignment: WrapAlignment.spaceBetween,
                          alignment: WrapAlignment.spaceBetween,
                          // crossAxisAlignment: WrapCrossAlignment.start,
                          children: [
                            Text(
                              '${locale.name} - ${addData.receiver_name}',
                              textAlign: TextAlign.start,
                              softWrap: true,
                            ),
                            Text(
                              '${locale.cnumber} - ${addData.receiver_phone}',
                              textAlign: TextAlign.start,
                              softWrap: true,
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
                ],
              )
            ],
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 10,
            thickness: 10,
          );
        },
      ),
    );
  }

  void selectAddress(dynamic address_id, AddressData addData) async {
    setState(() {
      addressSelection = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    http.post(selectAddressUri, body: {
      'address_id': '${address_id}'
    }, headers: {
      'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
    }).then((value) {
      print('address selection - ${value.body}');
      var jsd = jsonDecode(value.body);
      if (jsd['status'] == '1') {
        setState(() {
          seletedValue = int.parse('$address_id');
          selectedAddrs = addData;
          addressshow =
              '${selectedAddrs.house_no}${selectedAddrs.landmark}${selectedAddrs.society}${selectedAddrs.city}(${selectedAddrs.pincode})${selectedAddrs.state}';
          addressSelection = false;
          isChangeAddressTap = false;
        });
      } else {
        setState(() {
          addressSelection = false;
        });
      }
      Toast.show(jsd['message'], context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
    }).catchError((e) {
      setState(() {
        addressSelection = false;
      });
      print(e);
    });
  }


  void makeOrderRequest(AppLocalizations locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var http = Client();
    http.post(makeOrderUri, body: {
      'user_id': '${prefs.getInt('user_id')}',
      'delivery_date': '${dateTimeSt}',
      'time_slot': '${radioList[idd1]}',
    }, headers: {
      'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
    }).then((value) {
      print('making order value - ${value.body}');
      if (value.statusCode == 200) {
        MakeOrderBean orderBean =
            MakeOrderBean.fromJson(jsonDecode(value.body));
        if ('${orderBean.status}' == '1') {
          Navigator.pushNamed(context, PageRoutes.paymentOption, arguments: {
            'cart_id': '${cart_id}',
            'cartdetails': cartItemd,
            'storedetails': storeDetails,
            'orderdetails': orderBean.data,
            'address': selectedAddrs,
          });
          Toast.show(orderBean.message, context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
        } else {
          Toast.show(orderBean.message, context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
        }
      } else {
        Toast.show(locale.somethingwentwrong, context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      }
      setState(() {
        isMakeingOrder = false;
      });
    }).catchError((e) {
      setState(() {
        isMakeingOrder = false;
      });
      print(e);
    });
  }
}
