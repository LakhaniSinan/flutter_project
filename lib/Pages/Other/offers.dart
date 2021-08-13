import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/coupon/storecoupon.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class OffersPage extends StatefulWidget {
  @override
  _OffersPageState createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  var userName;
  List<StoreCouponData> offers = [];
  bool isCouponLoading = false;
  bool isEnteredFirst = false;

  @override
  void initState() {
    super.initState();
  }

  void getCouponList(String storeid, String cartid) async {
    print('$storeid $cartid');
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      isCouponLoading = true;
      userName = pref.getString('user_name');
    });
    var http = Client();
    http.post(storeCouponsUri, body: {'store_id': '$storeid','cart_id':'$cartid'}, headers: {
      'Authorization': 'Bearer ${pref.getString('accesstoken')}'
    }).then((value) {
      // print('vv - ${value.body}');
      if (value.statusCode == 200) {
        StoreCouponMain couponData =
            StoreCouponMain.fromJson(jsonDecode(value.body));
        if (couponData.status == '1' || couponData.status == 1) {
          setState(() {
            offers.clear();
            offers = List.from(couponData.data);
          });
        }
      }
      setState(() {
        isCouponLoading = false;
      });
    }).catchError((e) {
      print(e);
      setState(() {
        isCouponLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    if(!isEnteredFirst){
      Map<String,dynamic> mapData = ModalRoute.of(context).settings.arguments;
      isEnteredFirst = true;
      getCouponList(mapData['store_id'],mapData['cart_id']);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale.offers,
          style: TextStyle(
            color: kMainTextColor,
          ),
        ),
        centerTitle: true,
      ),
      body: (!isCouponLoading && offers!=null && offers.length>0)?ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            return buildOfferCard(
                context,
                offers[index].coupon_description,
                offers[index].coupon_code,
                offers[index].coupon_name,
                '${offers[index].cart_value}',locale);
          }):(isCouponLoading)?ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: 10,
          itemBuilder: (context, index) {
            return buildOfferSHCard();
          }):Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Text(locale.nooffernow,style: TextStyle(
          color: kMainColor,
          fontWeight: FontWeight.w600,
          fontSize: 16
        ),),
      ),
    );
  }

  Card buildOfferCard(BuildContext context, String offerContent,
      String offerCode, String couponName, String cartValue, AppLocalizations locale) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      color: Theme.of(context).cardColor,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(couponName,
                style: TextStyle(
                    color: kMainColor,
                    letterSpacing: 0.3,
                    fontSize: 16)),
            Text(offerContent,
                style: TextStyle(
                    color:kMainTextColor,
                    letterSpacing: 0.3,
                    fontSize: 16)),
            Text('${locale.mincartvalue} - $cartValue',
                style: TextStyle(
                    color: kMainTextColor,
                    letterSpacing: 0.3,
                    fontSize: 16))
          ],
        ),
        trailing: MaterialButton(
            minWidth: 90,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context).pop(offerCode);
            },
            child: Text(offerCode,
                style: TextStyle(
                    color: kMainTextColor,
                    fontSize: 15))),
      ),
    );
  }
  Widget buildOfferSHCard() {
    return Shimmer(
      duration: Duration(seconds: 3),
      color: Colors.white,
      enabled: true,
      direction: ShimmerDirection.fromLTRB(),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        color: kWhiteColor,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             Container(
               height: 10,
               width: 100,
               color: Colors.grey[300],
             ),
              SizedBox(
                height: 4,
              ),
              Container(
                height: 10,
                width: 100,
                color: Colors.grey[300],
              ),
              SizedBox(
                height: 4,
              ),
              Container(
                height: 10,
                width: 100,
                color: Colors.grey[300],
              ),
            ],
          ),
          trailing: MaterialButton(
              minWidth: 90,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            color: Colors.grey[300],
              onPressed: () {
                // Navigator.of(context).pop(offerCode);
              },),
        ),
      ),
    );
  }
}
