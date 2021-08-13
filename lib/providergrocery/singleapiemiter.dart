import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/singleapibean.dart';
import 'package:grocery/providergrocery/benprovider/singleapiemittermodel.dart';
import 'package:http/http.dart';
import 'package:pull_to_refresh/src/smart_refresher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingleApiEmitter extends Cubit<SingleApiEmitterBeanModel>{
  SingleApiEmitter() : super(SingleApiEmitterBeanModel(isSearching: false,dataModel: SingleApiHomePage(status: '0')));

  void hitSingleApiEmitter(String storeId, RefreshController refreshController) async{
    getSingleAPi(storeId,refreshController);
  }

  void getSingleAPi(String storeId, RefreshController refreshController) async {
    emit(SingleApiEmitterBeanModel(isSearching: true,dataModel: SingleApiHomePage(status: '0')));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var http = Client();
    http.post(oneApiUri, body: {'store_id': '$storeId'}, headers: {
      'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
    })
        .then((value) {
      print(value.body);
      if (value.statusCode == 200) {
        SingleApiHomePage data1 =
        SingleApiHomePage.fromJson(jsonDecode(value.body));
        if ('${data1.status}' == '1') {
          emit(SingleApiEmitterBeanModel(isSearching: false,dataModel: data1));
        }else{
          emit(SingleApiEmitterBeanModel(isSearching: false,dataModel: SingleApiHomePage(status: '0',message: data1.message)));
        }
      }
      else{
        emit(SingleApiEmitterBeanModel(isSearching: false,dataModel: SingleApiHomePage(status: '0')));
      }
      refreshController.refreshCompleted(resetFooterState: false);
    }).catchError((e) {
      refreshController.refreshCompleted(resetFooterState: false);
      emit(SingleApiEmitterBeanModel(isSearching: false,dataModel: SingleApiHomePage(status: '0')));
      print(e);
    });
  }
}