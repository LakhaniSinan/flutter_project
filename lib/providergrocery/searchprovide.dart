import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/banner/bannerdeatil.dart';
import 'package:grocery/beanmodel/productbean/productwithvarient.dart';
import 'package:grocery/beanmodel/storefinder/storefinderbean.dart';
import 'package:grocery/providergrocery/searchproviderbean.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchProvider extends Cubit<SearchProviderBean>{
  Timer timer;
  var http;
  int dataLenght = 0;
  SearchProvider() : super(SearchProviderBean(false, [], null));

  void hitSearchData(String searchData, StoreFinderData storeFinderData) async{
    if(http==null){
      http = Client();
    }
    print(searchData.length);
    print(dataLenght);
    print(searchData);
    print(storeFinderData.store_id);
    if(searchData.length>0){
searchData = searchData.trim();
print(searchData.length);
      if(dataLenght==searchData.length){

      }else{
        if(dataLenght>0 && timer!=null){
          timer.cancel();
          http.close();
          if(state!=null){
           state.isSearching = false;
          }
        }
      }

      if(!state.isSearching){
        emit(SearchProviderBean(true, [],storeFinderData));
        dataLenght = searchData.length;
        timer = Timer(Duration(seconds: 3), (){
          SharedPreferences.getInstance().then((prefs){
            Client().post(searchByStoreUri, body: {
              'store_id': '${storeFinderData.store_id}',
              'keyword': '$searchData',
            }, headers: {
              'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
            }).then((value){
              print(value.body);
              if (value.statusCode == 200) {
                ProductModel pData = ProductModel.fromJson(jsonDecode(value.body));
                if ('${pData.status}' == '1') {
                  emit(SearchProviderBean(false, pData.data,storeFinderData));
                }else{
                  emit(SearchProviderBean(false, [],storeFinderData));
                }
              }else{
                emit(SearchProviderBean(false, [],storeFinderData));
              }
            }).catchError((e){
              print('ssd - $e');
              emit(SearchProviderBean(false, [],storeFinderData));
            });
          }).catchError((e){
            print('ssd1 - $e');
            emit(SearchProviderBean(false, [],storeFinderData));
          });
        });
      }else{
        print('in else part');
      }
    }else{
      print('in else part 2');
      if(timer!=null){
        timer.cancel();
      }
      http.close();
      emit(SearchProviderBean(false, [],storeFinderData));
    }

  }

  void emitSearchNull(){
    emit(SearchProviderBean(false, [],null));
  }

}