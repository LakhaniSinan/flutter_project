import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery/Components/custom_button.dart';
import 'package:grocery/Components/drawer.dart';
import 'package:grocery/Components/entry_field.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/storefinder/storefinderbean.dart';
import 'package:grocery/main.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  TextEditingController numberC = TextEditingController();
  TextEditingController nameC = TextEditingController();
  TextEditingController messageC = TextEditingController();
  var userName;
  bool islogin = false;
  var userNumber;
  int numberlimit = 1;
  List<StoreFinderData> storeDataList = [];
  StoreFinderData storeD;
  String selectCity = 'Select Store';
  bool isLoading = false;

  var http = Client();

  _ContactUsPageState() {
    storeD = StoreFinderData('', '', 'Select Store', '', '', '','', '','');
    storeDataList.add(storeD);
  }

  @override
  void initState() {
    super.initState();
    getProfileDetails();
  }

  void getProfileDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString('storelist', '');
    // prefs.setString('store_id_last', '');
    setState(() {
      islogin = prefs.getBool('islogin');
      userName = prefs.getString('user_name');
      userNumber = prefs.getString('user_phone');
      numberlimit = int.parse('${prefs.getString('numberlimit')}');
      nameC.text = '$userName';
      numberC.text = '$userNumber';
    });
    int st = -1;
    if (prefs.containsKey('store_id_last') && prefs.getString('store_id_last').length>0) {
      st = int.parse('${prefs.getString('store_id_last')}');
      print('$st');
      if (prefs.containsKey('storelist')) {
        print('dd - $st');
        print('${prefs.getString('storelist')}');
        var storeListpf = jsonDecode(prefs.getString('storelist')) as List;
        List<StoreFinderData> dataFinderL = [];
        dataFinderL = List.from(
            storeListpf.map((e) => StoreFinderData.fromJson(e)).toList());
        dataFinderL.add(StoreFinderData('', '', 'Not to store', '', '', '','', '',''));
        setState(() {
          print('${dataFinderL.toString()}');
          storeDataList.clear();
          storeDataList = dataFinderL;
        });
        int idd1 = dataFinderL.indexOf(StoreFinderData('', st, '', '', '', '','', '',''));
        if (idd1 >= 0) {
          setState(() {
            storeD = dataFinderL[idd1];
            selectCity = storeD.store_name;
            print('${storeD.toString()} - $selectCity');
          });
        }
      }
    } else {
      print('d3 - $st');
      setState(() {
        storeDataList.clear();
        storeD = null;
        selectCity = 'Select Store';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      // drawer: buildDrawer(context, '${userName}', islogin,onHit: () {
      //   SharedPreferences.getInstance().then((pref){
      //     pref.clear().then((value) {
      //       Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.signInRoot, (Route<dynamic> route) => false);
      //     });
      //   });
      // }),
      appBar: AppBar(
        title: Text(
          locale.contactUs,
          style: TextStyle(color: kMainTextColor),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery
            .of(context)
            .size
            .height,
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/icon.png',
                scale: 2.5,
                height: 280,
              ),
              Visibility(
                visible: (storeDataList != null && storeDataList.length > 0),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButton<StoreFinderData>(
                          hint: Text(
                            selectCity,
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                          ),
                          isExpanded: true,
                          iconEnabledColor: kMainTextColor,
                          iconDisabledColor: kMainTextColor,
                          iconSize: 30,
                          items: storeDataList.map((value) {
                            return DropdownMenuItem<StoreFinderData>(
                              value: value,
                              child: Text(value.store_name,
                                  overflow: TextOverflow.clip),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              storeD = value;
                              selectCity = value.store_name;
                            });
                            print(value.store_name);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(locale.callBackReq2, style:
                        Theme
                            .of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(fontSize: 16),),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: RaisedButton(
                          onPressed: () {
                            if (!isLoading) {
                              setState(() {
                                isLoading = true;
                              });
                              if (selectCity != 'Select Store' ||
                                  selectCity != 'Not to store') {
                                sendCallBackRequest(context, storeD.store_id);
                              } else {
                                sendCallBackRequest(context, '');
                              }
                            }
                          },
                          child: Text(locale.callBackReq1),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 20),
                child: Text(
                  locale.letUsKnowYourFeedbackQueriesIssueRegardingAppFeatures,
                  textAlign: TextAlign.center,
                  style:
                  Theme
                      .of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(fontSize: 19),
                ),
              ),
              Divider(
                thickness: 3.5,
                color: Colors.transparent,
              ),
              EntryField(
                  labelFontSize: 16,
                  controller: nameC,
                  labelFontWeight: FontWeight.w400,
                  label: locale.fullName),
              EntryField(
                  controller: numberC,
                  labelFontSize: 16,
                  maxLength: numberlimit,
                  readOnly: true,
                  labelFontWeight: FontWeight.w400,
                  label: locale.phoneNumber),
              EntryField(
                  hintStyle: Theme
                      .of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(
                      color: kHintColor,
                      fontSize: 18.3,
                      fontWeight: FontWeight.w400),
                  hint: locale.enterYourMessage,
                  controller: messageC,
                  labelFontSize: 16,
                  labelFontWeight: FontWeight.w400,
                  label: locale.yourFeedback),
              Divider(
                thickness: 3.5,
                color: Colors.transparent,
              ),
              isLoading ? Container(
                height: 60,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: Align(
                  widthFactor: 40,
                  heightFactor: 40,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
              ) : CustomButton(
                label: locale.submit,
                onTap: () {
                  if (!isLoading) {
                    setState(() {
                      isLoading = true;
                    });
                    if (messageC.text != null) {
                      sendFeedBack(messageC.text, context);
                    } else {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void sendFeedBack(dynamic message, BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    http.post(userFeedbackUri, body: {
      'user_id': '${preferences.getInt('user_id')}',
      'feedback': '$message'
    }, headers: {
      'Authorization': 'Bearer ${preferences.getString('accesstoken')}'
    }).then((value) {
      print(value.body);
      if (value.statusCode == 200) {
        var js = jsonDecode(value.body);
        if ('${js['status']}' == '1') {
          messageC.clear();
        }
        Toast.show(js['message'], context, gravity: Toast.CENTER,
            duration: Toast.LENGTH_SHORT);
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void sendCallBackRequest(BuildContext context, dynamic store_id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    http.post(callbackReqUri, body: {
      'user_id': '${preferences.getInt('user_id')}',
      'store_id': '$store_id',
    }, headers: {
      'Authorization': 'Bearer ${preferences.getString('accesstoken')}'
    }).then((value) {
      print(value.body);
      if (value.statusCode == 200) {
        var js = jsonDecode(value.body);
        // if('${js['status']}'=='1'){
        //   messageC.clear();
        // }
        Toast.show(js['message'], context, gravity: Toast.CENTER,
            duration: Toast.LENGTH_SHORT);
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
    });
  }

}
