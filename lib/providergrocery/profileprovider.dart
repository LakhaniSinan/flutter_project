import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery/beanmodel/appinfo.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/signinmodel.dart';

class ProfileProvider extends Cubit<AppInfoModel> {

  ProfileProvider() : super(AppInfoModel()) {
    hitCounter();
  }

  void hitCounter() async {
    hitAppInfo();
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
          prefs.setString('app_currency', '${data1.currencySign}');
          prefs.setString('app_referaltext', '${data1.refertext}');
          prefs.setString('app_name', '${data1.appName}');
          prefs.setString('country_code', '${data1.countryCode}');
          prefs.setString('numberlimit', '${data1.phoneNumberLength}');
          prefs.setInt('last_loc', int.parse('${data1.lastLoc}'));
          prefs.setString('imagebaseurl', '${data1.imageUrl}');
          getImageBaseUrl();
          emit(data1);
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  void emitAppInfo(AppInfoModel model){
    emit(model);
  }
}
