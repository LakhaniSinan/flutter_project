import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:grocery/beanmodel/appinfo.dart';

class CartCountProvider extends Cubit<int> {
  dynamic currency_app = '';
  dynamic refferText = '';
  dynamic appLink = '';
  dynamic refferCode = '';
  dynamic appname = '';
  CartCountProvider() : super(0) {
    hitCounter();
  }

  void hitCounter() async {
    hitAppInfo();
  }

  String getCurrency(){
    return currency_app;
  }

  String appNameString(){
    return appname;
  }

  String refferCodeText(){
    return refferCode;
  }

  String refferTextS(){
    return refferText;
  }

  String appLinkP(){
    return appLink;
  }

  void hitCartCounter(int cartCount) {
    emit(cartCount);
  }

  void hitAppInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var http = Client();
    http.post(appInfoUri, body: {
      'user_id': '${(prefs.containsKey('user_id')) ? prefs.getInt('user_id') : ''}'
    }, headers: {
      'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
    }).then((value) {
      print(value.body);
      if (value.statusCode == 200) {
        AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
        print('data - ${data1.toString()}');
        if ('${data1.status}' == '1') {
          currency_app = '${data1.currencySign}';
          refferText = '${data1.refertext}';
          if(Platform.isAndroid){
            appLink = '${data1.androidAppLink}';
          }else if(Platform.isIOS){
            appLink = '${data1.iosAppLink}';
          }
          appname = '${data1.appName}';
          emit(int.parse('${data1.totalItems}'));
          prefs.setString('app_currency', '${data1.currencySign}');
          prefs.setString('app_referaltext', '${data1.refertext}');
          prefs.setString('app_name', '${data1.appName}');
          prefs.setString('country_code', '${data1.countryCode}');
          prefs.setString('numberlimit', '${data1.phoneNumberLength}');
          prefs.setInt('last_loc', int.parse('${data1.lastLoc}'));
          prefs.setString('wallet_credits', '${data1.userWallet}');
          prefs.setString('wishlistCount', '${data1.wishlistCount}');
          prefs.setString('imagebaseurl', '${data1.imageUrl}');
          getImageBaseUrl();
        }
      }
    }).catchError((e) {
      print(e);
    });
  }
}
