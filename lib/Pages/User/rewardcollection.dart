import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery/Components/drawer.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/signinmodel.dart';
import 'package:grocery/main.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RewardShow extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RewardShowState();
  }
}

class RewardShowState extends State<RewardShow> {
  var http = Client();
  bool isLoading = false;
  bool isLoadingR = false;
  String userName;
  String rewardPoint = '0';
  bool islogin = false;

  @override
  void initState() {
    super.initState();
    getProfileValue();
  }

  void getProfileValue() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    dynamic userId = preferences.getInt('user_id');
    setState(() {
      islogin = preferences.getBool('islogin');
      userName = preferences.getString('user_name');
    });
    getProfileFromInternet(userId);
  }

  void getProfileFromInternet(dynamic userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = myProfileUri;
    await http.post(url, body: {'user_id': '${userId}'}, headers: {
      'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
    }).then((response) {
      print('Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        print('Response Body: - ${response.body}');
        var jsonData = jsonDecode(response.body);
        SignInModel signInData = SignInModel.fromJson(jsonData);
        if (signInData.status == "1" || signInData.status == 1) {
          var userId = int.parse('${signInData.data.id}');
          prefs.setInt("user_id", userId);
          prefs.setString("user_name", '${signInData.data.name}');
          prefs.setString("user_email", '${signInData.data.email}');
          prefs.setString("user_image", '${signInData.data.userImage}');
          prefs.setString("user_phone", '${signInData.data.userPhone}');
          prefs.setString("user_password", '${signInData.data.password}');
          prefs.setString("wallet_credits", '${signInData.data.wallet}');
          prefs.setString("user_city", '${signInData.data.userCity}');
          prefs.setString("user_area", '${signInData.data.userArea}');
          prefs.setString("block", '${signInData.data.block}');
          prefs.setString("app_update", '${signInData.data.appUpdate}');
          prefs.setString("reg_date", '${signInData.data.regDate}');
          prefs.setBool("phoneverifed", true);
          prefs.setBool("islogin", true);
          prefs.setString("refferal_code", '${signInData.data.referralCode}');
          prefs.setString("reward", '${signInData.data.rewards}');
          // prefs.setString("accesstoken", '${signInData.token}');
          setState(() {
            userName = prefs.getString('user_name');
            rewardPoint = '${signInData.data.rewards}';
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      // drawer: buildDrawer(context, userName, islogin, onHit: () {
      //   SharedPreferences.getInstance().then((pref) {
      //     pref.clear().then((value) {
      //       // Navigator.pushAndRemoveUntil(context,
      //       //     MaterialPageRoute(builder: (context) {
      //       //   return GroceryLogin();
      //       // }), (Route<dynamic> route) => false);
      //       Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.signInRoot, (Route<dynamic> route) => false);
      //     });
      //   });
      // }),
      appBar: AppBar(
        title: Text(
          locale.rewardtitle,
          style: TextStyle(color: kMainTextColor),
        ),
        centerTitle: true,
      ),
      body: (!isLoading && double.parse(rewardPoint) > 0.0)
          ? Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Expanded(
                      child: Container(
                    alignment: Alignment.topCenter,
                    child: Text(rewardPoint),
                  )),
                  Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(top: 20),
                    alignment: Alignment.topCenter,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: isLoadingR
                          ? Align(
                              widthFactor: 50,
                              heightFactor: 50,
                              child: CircularProgressIndicator(),
                            )
                          : RaisedButton(
                              color: kMainColor,
                              child: Text(
                                locale.collectReward,
                                style: TextStyle(color: kWhiteColor),
                              ),
                              onPressed: () {
                                if (!isLoadingR) {
                                  setState(() {
                                    isLoadingR = true;
                                  });
                                  collectRewardPoint();
                                }
                              },
                            ),
                    ),
                  )
                ],
              ),
            )
          : Align(
              child: isLoading
                  ? SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    )
                  : Text(locale.noReward),
            ),
    );
  }

  void collectRewardPoint() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    http.post(redeemRewardsUri,
        body: {'user_id': '${prefs.getInt('user_id')}'}, headers: {
          'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
        }).then((value) {
      if (value.statusCode == 200) {
        var jsData = jsonDecode(value.body);
        if ('${jsData['status']}' == '1') {
          setState(() {
            rewardPoint = '0';
          });
        }
      }
      setState(() {
        isLoadingR = false;
      });
    }).catchError((e) {
      setState(() {
        isLoadingR = false;
      });
    });
  }
}
