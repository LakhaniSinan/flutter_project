import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingPageState();
  }
}

class SettingPageState extends State<SettingPage> {
  var http = Client();
  bool valueSMS = false;
  bool valueINAPP = false;
  bool valueEmail = false;
  bool isRuning = false;

  @override
  void initState() {
    super.initState();
    getNotifyBy();
  }

  void getNotifyBy() async {
    setState(() {
      isRuning = true;
    });
    SharedPreferences.getInstance().then((pref) {
      http.post(notifyByUri, body: {
        'user_id': '${pref.getInt('user_id')}'
      }, headers: {
        'Authorization': 'Bearer ${pref.getString('accesstoken')}'
      }).then((value) {
        print('cart - ${value.body}');
        var uno = jsonDecode(value.body);
        if (value.statusCode == 200) {
          bool sms1 = '${uno['data']['sms']}' == '1' ? true : false;
          bool app1 = '${uno['data']['app']}' == '1' ? true : false;
          bool email1 = '${uno['data']['email']}' == '1' ? true : false;
          pref.setBool('sms', sms1);
          pref.setBool('inapp', app1);
          pref.setBool('email', email1);
          setState(() {
            valueSMS = sms1;
            valueINAPP = app1;
            valueEmail = email1;
          });
        }
        setState(() {
          isRuning = false;
        });
      }).catchError((e) {
        print(e);
        setState(() {
          isRuning = false;
        });
      });
    }).catchError((e) {
      setState(() {
        isRuning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff8f8f8),
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        title: Text('My Settings'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            margin: const EdgeInsets.only(top: 10, bottom: 1),
            color: kWhiteColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.sms, size: 20.0, color: kIconColor),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text("SMS",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: kMainTextColor,
                          fontSize: 18)),
                ),
                SizedBox(
                  width: 10,
                ),
                isRuning
                    ? SizedBox(
                  width: 30,
                  height: 30,
                  child: Align(
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                      color: kMainColor,
                    ),
                  ),
                )
                    : Switch(
                  onChanged: (value) {
                    setState(() {
                      valueSMS = value;
                    });
                    updateNotify();
                  },
                  value: valueSMS,
                  activeColor: kMainColor,
                  inactiveThumbColor: kButtonBorderColor,
                  inactiveTrackColor: kMainColor.withOpacity(0.5),
                )
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            margin: const EdgeInsets.only(top: 2, bottom: 1),
            color: kWhiteColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.app_blocking_sharp, size: 20.0, color: kIconColor),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text("IN APP",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: kMainTextColor,
                          fontSize: 18)),
                ),
                SizedBox(
                  width: 10,
                ),
                isRuning
                    ? SizedBox(
                  width: 30,
                  height: 30,
                  child: Align(
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                      color: kMainColor,
                    ),
                  ),
                )
                    : Switch(
                  onChanged: (value) {
                    setState(() {
                      valueINAPP = value;
                    });
                    updateNotify();
                  },
                  value: valueINAPP,
                  activeColor: kMainColor,
                  inactiveThumbColor: kButtonBorderColor,
                  inactiveTrackColor: kMainColor.withOpacity(0.5),
                )
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            margin: const EdgeInsets.only(top: 1, bottom: 1),
            color: kWhiteColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.email, size: 20.0, color: kIconColor),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text("E-MAIL",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: kMainTextColor,
                          fontSize: 18)),
                ),
                SizedBox(
                  width: 10,
                ),
                isRuning
                    ? SizedBox(
                        width: 30,
                        height: 30,
                        child: Align(
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            color: kMainColor,
                          ),
                        ),
                      )
                    : Switch(
                        onChanged: (value) {
                          setState(() {
                            valueEmail = value;
                          });
                          updateNotify();
                        },
                        value: valueEmail,
                        activeColor: kMainColor,
                        inactiveThumbColor: kButtonBorderColor,
                        inactiveTrackColor: kMainColor.withOpacity(0.5),
                      )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void updateNotify() async {
    setState(() {
      isRuning = true;
    });
    SharedPreferences.getInstance().then((pref) {
      http.post(updateNotifyByUri, body: {
        'user_id': '${pref.getInt('user_id')}',
        'sms': '${valueSMS?1:0}',
        'email': '${valueEmail?1:0}',
        'app': '${valueINAPP?1:0}',
      }, headers: {
        'Authorization': 'Bearer ${pref.getString('accesstoken')}'
      }).then((value) {
        print('cart - ${value.body}');
        var uno = jsonDecode(value.body);
        if (value.statusCode == 200 && '${uno['status']}'=='1') {
          pref.setBool('sms', valueSMS);
          pref.setBool('inapp', valueINAPP);
          pref.setBool('email', valueEmail);
          Toast.show(uno['message'], context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
        }
        setState(() {
          isRuning = false;
        });
      }).catchError((e) {
        print(e);
        setState(() {
          isRuning = false;
        });
      });
    }).catchError((e) {
      setState(() {
        isRuning = false;
      });
    });
  }
}
