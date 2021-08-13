import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/appinfo.dart';
import 'package:grocery/beanmodel/storefinder/storefinderbean.dart';
import 'package:grocery/providergrocery/locemittermodel.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class LocationEmitter extends Cubit<LocEmitterModel>{
  // LocationEmitter(LocEmitterModel initialState) : super(initialState);
  AppInfoModel infoM;
  LocationEmitter() : super(LocEmitterModel(0.0,0.0,'Tap/Set to change your location.',false,null)) {
    hitLocEmitterInitial();
  }

  void hitLocEmitterInitial() async{
    hitAppInfo();
  }

  void hitAppInfo() async {
    emit(LocEmitterModel(0.0,0.0,'Search your location please wait..',true,null));
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
        infoM = data1;
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
          if(state!=null && state.lat!=null && state.lat>0.0 && state.lng!=null && state.lng>0.0){
            print('in this');
            // getStoreId(state);
            Timer(Duration(seconds: 5), () async {
              double latw = state.lat;
              double lngw = state.lng;
              prefs.setString("lat", latw.toString());
              prefs.setString("lng", lngw.toString());
              Geocoder.local.
              findAddressesFromCoordinates(Coordinates(latw, lngw))
                  .then((value) {
                getStoreId(LocEmitterModel(latw, lngw,'${value[0].addressLine}',true,null));
              }).catchError((e){
                prefs.remove('lat');
                prefs.remove('lng');
                _getLocation();
              });
            });
          }else{
            print('in that');
            _getLocation();
          }
        }
      }else{
        emit(LocEmitterModel(0.0,0.0,'Tap/Set to change your location.',false,null));
      }
    }).catchError((e) {
      emit(LocEmitterModel(0.0,0.0,'Tap/Set to change your location.',false,null));
      print(e);
    });
  }

  void _getLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('last_loc') == 0 ||
        (!prefs.containsKey('lat') && !prefs.containsKey('lng'))) {
      Geolocator.checkPermission().then((permission){
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          Geolocator.isLocationServiceEnabled().then((isLocationServiceEnableds){
            if (isLocationServiceEnableds) {
              Geolocator
                  .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
                  .then((position){
                print(position.latitude);
                print(position.longitude);
                if (position != null && position.latitude!=null && position.latitude>0.0 && position.longitude!=null && position.longitude>0.0) {
                  Timer(Duration(seconds: 5), () async {
                    double latw = position.latitude;
                    double lngw = position.longitude;
                    prefs.setString("lat", latw.toString());
                    prefs.setString("lng", lngw.toString());
                    Geocoder.local.
                    findAddressesFromCoordinates(Coordinates(latw, lngw))
                        .then((value) {
                          // emit(LocEmitterModel(latw, lngw,'${value[0].addressLine}',false));
                          getStoreId(LocEmitterModel(latw, lngw,'${value[0].addressLine}',true,null));
                    }).catchError((e){
                      prefs.remove('lat');
                      prefs.remove('lng');
                      _getLocation();
                    });
                  });
                }
                else {
                  prefs.remove('lat');
                  prefs.remove('lng');
                  _getLocation();
                }
              }).catchError((e){
                prefs.remove('lat');
                prefs.remove('lng');
                _getLocation();
              });
            }
            else {
              Geolocator.openLocationSettings().then((value) {
                prefs.remove('lat');
                prefs.remove('lng');
                if (value) {
                  _getLocation();
                } else {
                  emit(LocEmitterModel(0.0,0.0,'Tap/Set to change your location.',false,null));
                }
              }).catchError((e) {
                prefs.remove('lat');
                prefs.remove('lng');
                emit(LocEmitterModel(0.0,0.0,'Tap/Set to change your location.',false,null));
              });
            }
          }).catchError((e){
            prefs.remove('lat');
            prefs.remove('lng');
            _getLocation();
          });
        }
        else if (permission == LocationPermission.denied) {
          Geolocator.requestPermission().then((pdPermission){
            prefs.remove('lat');
            prefs.remove('lng');
            if (pdPermission == LocationPermission.whileInUse ||
                pdPermission == LocationPermission.always) {
              _getLocation();
            } else {
              emit(LocEmitterModel(0.0,0.0,'Tap/Set to change your location.',false,null));
            }
          }).catchError((e){
            prefs.remove('lat');
            prefs.remove('lng');
            emit(LocEmitterModel(0.0,0.0,'Tap/Set to change your location.',false,null));
          });
        }
        else if (permission == LocationPermission.deniedForever) {
          Geolocator.openAppSettings().then((value) {
            prefs.remove('lat');
            prefs.remove('lng');
            if(value){
              _getLocation();
            }else{
              emit(LocEmitterModel(0.0,0.0,'Tap/Set to change your location.',false,null));
            }
          }).catchError((e) {
            prefs.remove('lat');
            prefs.remove('lng');
            emit(LocEmitterModel(0.0,0.0,'Tap/Set to change your location.',false,null));
          });
        }
      });

    } else {
      try{
        double lat = double.parse('${prefs.getString('lat')}');
        double lng = double.parse('${prefs.getString('lng')}');
        Geocoder.local.
        findAddressesFromCoordinates(Coordinates(lat, lng))
            .then((value) {
          // emit(LocEmitterModel(lat, lng,'${value[0].addressLine}',false));
          getStoreId(LocEmitterModel(lat, lng,'${value[0].addressLine}',true,null));
        }).catchError((e){
          prefs.remove('lat');
          prefs.remove('lng');
          _getLocation();
        });
      }catch(e){
        prefs.remove('lat');
        prefs.remove('lng');
        _getLocation();
        print(e);
      }
    }
  }

  void hitLocEmitter(LocEmitterModel latlngemitter){
    print(latlngemitter.toString());
    getStoreId(latlngemitter);
  }

  void getStoreId(LocEmitterModel latlngemitter) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    StoreFinderData storeFinderData;
    print('${prefs.getString('accesstoken')}');
var http = Client();
    http.post(getNearestStoreUri, body: {
      'lat': '${latlngemitter.lat}',
      'lng': '${latlngemitter.lng}',
    }, headers: {
      'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
    }).then((value) {
      print('loc - ${value.body}');
      if (value.statusCode == 200) {
        StoreFinderBean data1 =
        StoreFinderBean.fromJson(jsonDecode(value.body));
        if ('${data1.status}' == '1') {
          storeFinderData = data1.data;
          if (prefs.containsKey('storelist') &&
              prefs.getString('storelist').length > 0) {
            var storeListpf =
            jsonDecode(prefs.getString('storelist')) as List;
            List<StoreFinderData> dataFinderL = [];
            dataFinderL = List.from(
                storeListpf.map((e) => StoreFinderData.fromJson(e)).toList());
            print('storelist -> ${dataFinderL.toString()}');
            int idd1 = dataFinderL.indexOf(data1.data);
            if (idd1 < 0) {
              print(idd1);
              dataFinderL.add(data1.data);
            }

            prefs.setString('storelist', dataFinderL.toString());
          }
          else {
            List<StoreFinderData> dataFinderLd = [];
            dataFinderLd.add(data1.data);
            prefs.setString('storelist', dataFinderLd.toString());
          }
          prefs.setString('store_id_last', '${storeFinderData.store_id}');
          emit(LocEmitterModel(latlngemitter.lat,latlngemitter.lng,latlngemitter.address,false,storeFinderData));
        }else{
          emit(LocEmitterModel(latlngemitter.lat,latlngemitter.lng,latlngemitter.address,false,null));
        }
      }else{
        emit(LocEmitterModel(latlngemitter.lat,latlngemitter.lng,latlngemitter.address,false,null));
      }
    }).catchError((e) {
      print(e);
      emit(LocEmitterModel(latlngemitter.lat,latlngemitter.lng,latlngemitter.address,false,null));
    });
  }

}