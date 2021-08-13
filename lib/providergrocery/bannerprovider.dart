import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/banner/bannerdeatil.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BanerProvider extends Cubit<List<BannerDataModel>>{
  // BanerProvider(List<BannerDataModel> initialState) : super(initialState);

  BanerProvider() : super([]) {
    hitBannerDetails();
  }

  void hitBannerDetails() async{
    SharedPreferences.getInstance().then((prefs){
      Client().post(storeBannerUri, body: {'store_id': '${prefs.getString('store_id_last')}'})
          .then((value){
        BannerModel cateData =
        BannerModel.fromJson(jsonDecode(value.body));
        emit(cateData.data);
      }).catchError((e){

      });
    }).catchError((e){

    });
  }

  void emitBannerList(List<BannerDataModel> bannerL){
    emit(bannerL);
  }

}