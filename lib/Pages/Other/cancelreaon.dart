import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/orderbean/cancelbean.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';

class CancelPage extends StatefulWidget {
  final dynamic cartid;

  CancelPage(this.cartid);

  @override
  CancelPageState createState() {
    return CancelPageState();
  }
}

class CancelPageState extends State<CancelPage> {
  bool isLoading = false;
  bool isDelete = false;
  String apCurrency = '';
  List<CancelData> rechargeHistory = [];
  var http = Client();

  @override
  void initState() {
    super.initState();
    getHistoryList();
  }

  @override
  void dispose() {
    http.close();
    super.dispose();
  }

  void getHistoryList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
      apCurrency = prefs.getString('app_currency');
    });

    http.get(cancellingReasonsUri, headers: {
      'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
    }).then((value) {
      print('ppy - ${value.body}');
      if (value.statusCode == 200) {
        CancelMain data1 = CancelMain.fromJson(jsonDecode(value.body));
        if ('${data1.status}' == '1') {
          setState(() {
            rechargeHistory.clear();
            rechargeHistory = List.from(data1.data);
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

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        children: [
          AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_sharp),
              onPressed: () {
                if(!isDelete){

                }
                Navigator.of(context).pop(false);
              },
            ),
            title: Text(
              locale.cancelreason,
              style: TextStyle(color: kMainTextColor),
            ),
            centerTitle: true,
          ),
          RowHistory(locale),
          Expanded(
            child: (!isDelete &&
                    !isLoading &&
                    rechargeHistory != null &&
                    rechargeHistory.length > 0)
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: rechargeHistory.length,
                    itemBuilder: (contexts, index) {
                      return GestureDetector(
                        onTap: () {
                          if (!isDelete) {
                            setState(() {
                              isDelete = true;
                            });
                            hitDelete(
                                '${rechargeHistory[index].reason}', context,locale);
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Card(
                          elevation: 3,
                          color: kWhiteColor,
                          clipBehavior: Clip.hardEdge,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Text(
                                  '${index + 1}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline1
                                      .copyWith(fontSize: 16),
                                ),
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${rechargeHistory[index].reason}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline1
                                        .copyWith(fontSize: 16),
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                      );
                    })
                : (isDelete || isLoading)
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 3,
                            clipBehavior: Clip.hardEdge,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Shimmer(
                                duration: Duration(seconds: 3),
                                color: Colors.white,
                                enabled: true,
                                direction: ShimmerDirection.fromLTRB(),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 10,
                                      width: 50,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      height: 10,
                                      width: 150,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        })
                    : Container(
                        alignment: Alignment.center,
                        child: isDelete
                            ? Align(
                                alignment: Alignment.center,
                                heightFactor: 40,
                                widthFactor: 40,
                                child: CircularProgressIndicator(),
                              )
                            : Text(''),
                      ),
          )
        ],
      ),
    );
  }

  Widget RowHistory(AppLocalizations locale) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Text(locale.sn,
              style: TextStyle(
                  color: Theme.of(context).backgroundColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Text(locale.reason,
                style: TextStyle(
                    color: Theme.of(context).backgroundColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ))
        ],
      ),
    );
  }

  void hitDelete(dynamic reason, BuildContext context, AppLocalizations locale) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    http.post(deleteOrderUri, body: {
      'cart_id': '${widget.cartid}',
      'reason': '$reason',
    }, headers: {
      'Authorization': 'Bearer ${pref.getString('accesstoken')}'
    }).then((value) {
      print('cc - ${value.body}');
      if (value.statusCode == 200) {
        var js = jsonDecode(value.body);
        if ('${js['status']}' == '1') {
          // Navigator.of(context).pop(true);
          showAlertDialog(context, locale);
        }else{
          Toast.show(locale.somethingwentwrong, context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
        }
      }else{
        Toast.show(locale.somethingwentwrong, context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
      }
      setState(() {
        isDelete = false;
      });
    }).catchError((e) {
      Toast.show(locale.somethingwentwrong, context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
      setState(() {
        isDelete = false;
      });
    });
  }

  showAlertDialog(BuildContext context, AppLocalizations locale) {
    // set up the buttons
    Widget remindButton = FlatButton(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Text(locale.ok),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(locale.notice1),
      content: Text(locale.notice2),
      actions: [
        remindButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    ).then((value){
      Navigator.of(context).pop(true);
    });
  }
}
