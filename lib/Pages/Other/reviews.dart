import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/ratting/rattingbean.dart';
import 'package:http/http.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Reviews extends StatefulWidget {
  @override
  _ReviewsState createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  var http = Client();
  bool enteredFirst = false;
  bool reviewLoading = false;
  List<ProductRatingData> ratingData = [];
  int fiveCout = 0;
  int fourCout = 0;
  int threeCout = 0;
  int twoCout = 0;
  int oneCout = 0;

  double avrageRating = 0.0;
  dynamic storeid;
  dynamic v_id;

  String title = '';



  void getRatingValue(dynamic store_id, dynamic varient_id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      reviewLoading = true;
    });
    http.post(getProductRatingUri,body: {
      'store_id':'$store_id',
      'varient_id':'$varient_id'
    }, headers: {
      'Authorization': 'Bearer ${pref.getString('accesstoken')}'
    }).then((value) {
      if (value.statusCode == 200) {
        ProductRating data1 = ProductRating.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            print(avrageRating);
            ratingData.clear();
            ratingData = List.from(data1.data);
            if(ratingData.length>0){
              double rateV = 0.0;
              for(int i=0;i<ratingData.length;i++){
                rateV = rateV+double.parse('${ratingData[i].rating}');
                if(ratingData.length == i+1){
                  avrageRating = rateV/ratingData.length;
                }
              }
            }else{
              avrageRating = 5.0;
            }
            fiveCout = ratingData.where((element) => (double.parse('${element.rating}') == 5.0)).toList().length;
            fourCout = ratingData.where((element) => (double.parse('${element.rating}') >= 3.1 && double.parse('${element.rating}') < 4.1)).toList().length;
            threeCout = ratingData.where((element) => (double.parse('${element.rating}') >= 2.1 && double.parse('${element.rating}') < 3.1)).toList().length;
            twoCout = ratingData.where((element) => (double.parse('${element.rating}') >= 1.1 && double.parse('${element.rating}') < 2.1)).toList().length;
            oneCout = ratingData.where((element) => (double.parse('${element.rating}') == 1.0)).toList().length;
          });
        }
      }
      setState(() {
        reviewLoading = false;
      });
    }).catchError((e) {
      setState(() {
        reviewLoading = false;
      });
      print(e);
    });
  }

  double getPercentage(int count) {
    print('ss - $count ${ratingData.length}');
    return ((ratingData.length - count)/ratingData.length)*100;
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String, dynamic> receivedData = ModalRoute.of(context).settings.arguments;
    if(!enteredFirst){
      enteredFirst = true;
      storeid = receivedData['store_id'];
      v_id = receivedData['v_id'];
      title = receivedData['title'];
      getRatingValue(storeid, v_id);
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: kMainTextColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        locale.avgRatings,
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline6
                            .copyWith(fontSize: 14),
                      ),
                      buildBigRatingCard(context,avrageRating),
                      Text(
                        '${ratingData.length} ' + locale.ratings,
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline6
                            .copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                  VerticalDivider(
                    width: 20,
                    thickness: 0.6,
                    indent: 0,
                    endIndent: 0,
                    color: Colors.grey[200],
                  ),
                  Column(
                    children: [
                      buildReviewIndicator(context, '5', getPercentage(fiveCout),'$fiveCout'),
                      buildReviewIndicator(context, '4', getPercentage(fourCout), '$fourCout'),
                      buildReviewIndicator(context, '3', getPercentage(threeCout), '$threeCout'),
                      buildReviewIndicator(context, '2', getPercentage(twoCout), '$twoCout'),
                      buildReviewIndicator(context, '1', getPercentage(oneCout), '$oneCout'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    locale.recentReviews,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: ratingData.length,
                  itemBuilder: (context, index) {
                    return buildReviewCard(ratingData[index]);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Card buildReviewCard(ProductRatingData ratingData) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      color: Colors.white,
      shadowColor: Colors.grey[200],
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.transparent)),
      elevation: 0,
      child: Column(
        children: [
          ListTile(
            title: Text(
              '${ratingData.userName}',
              style:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
            ),
            subtitle: Row(
              children: [
                Text(
                  '${ratingData.createdAt}',
                  style: TextStyle(fontSize: 12),
                ),
                Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: (double.parse('${ratingData.rating}').clamp(1.0, 5.0) == double.parse('${ratingData.rating}'))?Color(0xffffb910):Colors.grey[400],
                      size: 18,
                    ),
                    Icon(
                      Icons.star,
                      color: (double.parse('${ratingData.rating}').clamp(2.0, 5.0) == double.parse('${ratingData.rating}'))?Color(0xffffb910):Colors.grey[400],
                      size: 18,
                    ),
                    Icon(
                      Icons.star,
                      color: (double.parse('${ratingData.rating}').clamp(3.0, 5.0) == double.parse('${ratingData.rating}'))?Color(0xffffb910):Colors.grey[400],
                      size: 18,
                    ),
                    Icon(
                      Icons.star,
                      color: (double.parse('${ratingData.rating}').clamp(4.0, 5.0) == double.parse('${ratingData.rating}'))?Color(0xffffb910):Colors.grey[400],
                      size: 18,
                    ),
                    Icon(
                      Icons.star,
                      color: (double.parse('${ratingData.rating}').clamp(5.0, 5.0) == double.parse('${ratingData.rating}'))?Color(0xffffb910):Colors.grey[400],
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Text(
                '${ratingData.description}',
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.1,
                    fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row buildReviewIndicator(context, String number, double percent,
      String reviews) {
    print('we - ${percent}');
    return Row(
      children: [
        Text(
          number,
          style: TextStyle(color: Colors.grey[600]),
        ),
        SizedBox(
          width: 5,
        ),
        Icon(
          Icons.star,
          color: Color(0xffffb910),
          size: 20,
        ),
        SizedBox(
          width: 10,
        ),
        // LinearPercentIndicator(
        //   backgroundColor: Colors.grey[300],
        //   width: 105.0,
        //   lineHeight: 6.0,
        //   percent: double.parse('${percent.toStringAsFixed(1)}')??0.0,
        //   progressColor: Colors.green,
        // ),
        SizedBox(
          width: 8,
        ),
        Text(
          reviews,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Container buildBigRatingCard(BuildContext context, double avrageRating) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.only(top: 6, bottom: 6, left: 12, right: 10),
      //width: 30,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${avrageRating.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            style: Theme
                .of(context)
                .textTheme
                .button
                .copyWith(fontSize: 16),
          ),
          SizedBox(
            width: 4,
          ),
          Icon(
            Icons.star,
            size: 14,
            color: Theme
                .of(context)
                .scaffoldBackgroundColor,
          ),
        ],
      ),
    );
  }
}
