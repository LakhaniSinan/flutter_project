import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery/Components/drawer.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/notificationbean/notificationlistdata.dart';
import 'package:grocery/main.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationShow extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NotificationShowState();
  }
}

class NotificationShowState extends State<NotificationShow> {
  var http = Client();
  List<NotificationListData> listdata = [];
  bool isLoading = false;
  String userName;
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
    getNotificaitonList(userId,preferences);
  }

  void getNotificaitonList(dynamic userid, SharedPreferences pref) async {
    setState(() {
      isLoading = true;
    });
    http.post(notificationListUri, body: {'user_id': '$userid'}, headers: {
      'Authorization': 'Bearer ${pref.getString('accesstoken')}'
    }).then((value) {
      if (value.statusCode == 200) {
        NotificationList data1 =
            NotificationList.fromJson(jsonDecode(value.body));
        if ('${data1.status}' == '1') {
          setState(() {
            listdata.clear();
            listdata = List.from(data1.data);
          });
        }
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

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Color(0xfff8f8f8),
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        title: Text(
          locale.notificaitonh,
          style: TextStyle(color: kMainTextColor),
        ),
        centerTitle: true,
      ),
      body: (!isLoading && listdata!=null && listdata.length>0)
          ?ListView.builder(
        itemCount: listdata.length,
          shrinkWrap: true,
          itemBuilder: (context,index){
        return Card(
          elevation: 1,
          margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
          clipBehavior: Clip.hardEdge,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${listdata[index].notiTitle}',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: kMainTextColor),),
                SizedBox(height: 5,),
                Visibility(
                  visible: ('${listdata[index].image}'!=null && '${listdata[index].image}'!='N/A' && '${listdata[index].image}'.toUpperCase()!='NULL'),
                  child: Container(
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 5),
                    width: MediaQuery.of(context).size.width,
                    child: Image.network('${listdata[index].image}'),
                  ),
                ),
                Text('${listdata[index].notiMessage}',style: TextStyle(fontSize: 13,color: kMainTextColor),),
              ],
            ),
          ),
        );
      }):Align(
        child: isLoading?SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(),
        ):Text(locale.nonotificaiton),
      ),
    );
  }
}
