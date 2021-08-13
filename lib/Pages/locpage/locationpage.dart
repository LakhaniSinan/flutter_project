import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';

// import 'package:google_place/google_place.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/mapsection/googlemapkey.dart';
import 'package:grocery/beanmodel/mapsection/mapboxbean.dart';
import 'package:grocery/beanmodel/mapsection/mapbybean.dart';
import 'package:grocery/providergrocery/locationemiter.dart';
import 'package:grocery/providergrocery/locemittermodel.dart';
import 'package:http/http.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:toast/toast.dart';

class LocationPage extends StatelessWidget {
  final dynamic lat;
  final dynamic lng;

  LocationPage(this.lat, this.lng);

  @override
  Widget build(BuildContext context) {
    return SetLocation(lat, lng);
  }
}

class SetLocation extends StatefulWidget {
  final dynamic lat;
  final dynamic lng;

  SetLocation(this.lat, this.lng);

  @override
  SetLocationState createState() => SetLocationState(lat, lng);
}

// GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: apiKey);

class SetLocationState extends State<SetLocation> {
  var http = Client();
  bool isLoading = false;
  GooglePlace places;
  PlacesSearch placesSearch;
  List<SearchResult> searchPredictions = [];
  List<MapBoxPlace> placePred = [];
  SearchResult pPredictions;
  MapBoxPlace mapboxPredictions;
  dynamic lat;
  dynamic lng;
  CameraPosition kGooglePlex;
  TextEditingController searchController = TextEditingController();

  bool enteredFirst = false;

  bool pageDistroy = false;
  bool enteredSearch = false;

  SetLocationState(this.lat, this.lng) {
    if(this.lat!=null && this.lat>0.0 && this.lng!=null && this.lng>0.0){
      kGooglePlex = CameraPosition(
        target: LatLng(lat, lng),
        zoom: 12.151926,
      );
    }else{
      kGooglePlex = CameraPosition(
        target: LatLng(0.0, 0.0),
        zoom: 12.151926,
      );
    }

  }

  bool isCard = false;
  Completer<GoogleMapController> _controller = Completer();
  var isVisible = false;
  var currentAddress = '';
  Future<void> _goToTheLake(double latf, double lngf) async {
    setState(() {
      this.lat = latf;
      this.lng = lngf;
    });
    final CameraPosition _kLake = CameraPosition(
      // bearing: 192.8334901395799,
        target: LatLng(latf, lngf),
        // tilt: 59.440717697143555,
        zoom: 19.15);
    _controller.future.then((value){
      value.moveCamera(CameraUpdate.newCameraPosition(_kLake)).then((value){
        print('done motion.');
        Geocoder.local
            .findAddressesFromCoordinates(Coordinates(lat, lng))
            .then((value) {
          for (int i = 0; i < value.length; i++) {
            if (value[i].locality != null && value[i].locality.length > 1) {
              if(!pageDistroy){
                setState(() {
                  currentAddress = value[i].addressLine;
                });
              }
              break;
            }
          }
        });
      });
    });
    // _controller.future.then((value){
    //   print('hello progress done');
    //   value.animateCamera(CameraUpdate.newCameraPosition(_kLake)).then((value){
    //     inLake = false;
    //   });
    //  });


  }

  void getMapbyApi() async {
    setState(() {
      isLoading = true;
    });
    http.get(mapbyUri).then((value) {
      if (value.statusCode == 200) {
        MapByKey googleMapD = MapByKey.fromJson(jsonDecode(value.body));
        if ('${googleMapD.status}' == '1') {
          if ('${googleMapD.data.mapbox}' == '1') {
            getMapBoxKey();
          } else if ('${googleMapD.data.googleMap}' == '1') {
            getGoogleMapKey();
          } else {
            setState(() {
              isLoading = false;
            });
          }
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void getGoogleMapKey() async {
    http.get(googleMapUri).then((value) {
      if (value.statusCode == 200) {
        GoogleMapKey googleMapD = GoogleMapKey.fromJson(jsonDecode(value.body));
        if ('${googleMapD.status}' == '1') {
          setState(() {
            places = new GooglePlace('${googleMapD.data.mapApiKey}');
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

  void getMapBoxKey() async {
    http.get(mapboxUri).then((value) {
      if (value.statusCode == 200) {
        MapBoxApiKey googleMapD = MapBoxApiKey.fromJson(jsonDecode(value.body));
        if ('${googleMapD.status}' == '1') {
          setState(() {
            placesSearch = PlacesSearch(
              apiKey: '${googleMapD.data.mapboxApi}',
              limit: 5,
            );
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
  LocationEmitter locEmitterP;
  // locEmitterP.hitLocEmitterInitial();

  @override
  void initState() {
    locEmitterP = BlocProvider.of<LocationEmitter>(context);
    super.initState();
    getMapbyApi();
    searchController.addListener(() async {
      if (searchController.text != null && searchController.text.length > 0) {
        if (places != null) {
          await places.search
              .getTextSearch(searchController.text)
              .then((value) {
            if (searchController.text != null &&
                searchController.text.length > 0) {
              setState(() {
                searchPredictions.clear();
                searchPredictions = List.from(value.results);
                // print(value.results[0].formattedAddress);
                // print('${value.candidates[0].geometry.location.lat} ${value.candidates[0].geometry.location.lng}');
              });
            } else {
              setState(() {
                searchPredictions.clear();
              });
            }
          }).catchError((e) {
            setState(() {
              searchPredictions.clear();
            });
          });
        } else if (placesSearch != null) {
          placesSearch.getPlaces(searchController.text).then((value) {
            if (searchController.text != null &&
                searchController.text.length > 0) {
              setState(() {
                placePred.clear();
                placePred = List.from(value);
                print(value[0].placeName);
                print(
                    '${value[0].geometry.coordinates[0]} ${value[0].geometry.coordinates[1]}');
              });
            } else {
              setState(() {
                placePred.clear();
              });
            }
          }).catchError((e) {
            setState(() {
              placePred.clear();
            });
          });
        }
      }
      else {
        if (places != null) {
          setState(() {
            searchPredictions.clear();
          });
        } else if (placesSearch != null) {
          setState(() {
            placePred.clear();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    pageDistroy = true;
    super.dispose();
  }

  void _getLocation(BuildContext context, AppLocalizations locale) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      bool isLocationServiceEnableds =
          await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnableds) {
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((position){
          if(position!=null){
            double lat = position.latitude;
            double lng = position.longitude;
            _goToTheLake(lat,lng);
          }
        });
      } else {
        await Geolocator.openLocationSettings().then((value) {
          if (value) {
            _getLocation(context, locale);
          } else {
            Toast.show(locale.locpermission, context,
                duration: Toast.LENGTH_SHORT);
          }
        }).catchError((e) {
          Toast.show(locale.locpermission, context,
              duration: Toast.LENGTH_SHORT);
        });
      }
    } else if (permission == LocationPermission.denied) {
      LocationPermission permissiond = await Geolocator.requestPermission();
      if (permissiond == LocationPermission.whileInUse ||
          permissiond == LocationPermission.always) {
        _getLocation(context, locale);
      } else {
        Toast.show(locale.locpermission, context, duration: Toast.LENGTH_SHORT);
      }
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings().then((value) {
        _getLocation(context, locale);
      }).catchError((e) {
        Toast.show(locale.locpermission, context, duration: Toast.LENGTH_SHORT);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    if (!enteredFirst) {
      setState(() {
        enteredFirst = true;
      });
      _getLocation(context, locale);
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: kGooglePlex,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            buildingsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onCameraIdle: () {
              // getMapLoc();
            },
            onCameraMove: (post) {
              lat = post.target.latitude;
              lng = post.target.longitude;
              _goToTheLake(lat,lng);
            },
          ),
          Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(bottom: 36.0),
                child: Image.asset(
                  'assets/map_pin.png',
                  height: 36,
                ),
              )),
          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 36.0),
                child: RaisedButton(
                  onPressed: () {
                    locEmitterP.hitLocEmitter(LocEmitterModel(lat,lng,currentAddress,true,null));
                    Navigator.of(context).pop();
                  },
                  child: Text(locale.locpage1),
                ),
              )),
          Positioned(
              top: 10,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    title: Text(
                      locale.locpage2,
                      style: TextStyle(fontSize: 16.7, color: kMainTextColor),
                    ),
                    actions: [
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: IconButton(
                            icon: Icon(
                              Icons.my_location,
                              color: kMainColor,
                            ),
                            iconSize: 30,
                            onPressed: () {
                              _getLocation(context, locale);
                            },
                          ))
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: 52,
                    // margin: EdgeInsets.only(left: 20,right: 20),
                    decoration: BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: locale.locpage3,
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: kHintColor, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: kHintColor, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: kHintColor, width: 1),
                        ),
                      ),
                      controller: searchController,
                      // onEditingComplete: (){
                      //   if(searchController.text!=null && searchController.text.length<=0){
                      //     print('leg');
                      //   }
                      // },
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    color: kWhiteColor,
                    margin: EdgeInsets.only(top: 5),
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          'assets/map_pin.png',
                          scale: 3,
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Expanded(
                          child: Text(
                            '${currentAddress}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.caption,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: (searchPredictions != null &&
                        searchPredictions.length > 0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      color: kWhiteColor,
                      height: 300,
                      margin: EdgeInsets.only(top: 5),
                      padding:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                      child: ListView.separated(
                        itemCount: searchPredictions.length,
                        shrinkWrap: true,
                        primary: true,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                pPredictions = searchPredictions[index];
                                lat = pPredictions.geometry.location.lat;
                                lng = pPredictions.geometry.location.lng;
                                searchController.clear();
                                searchPredictions.clear();
                              });
                              // _getCameraMoveLocation(LatLng(lat, lng));
                              _goToTheLake(lat, lng);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              children: <Widget>[
                                Image.asset(
                                  'assets/map_pin.png',
                                  scale: 3,
                                ),
                                SizedBox(
                                  width: 16.0,
                                ),
                                Expanded(
                                  child: Text(
                                    '${searchPredictions[index].formattedAddress}',
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.caption,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            thickness: 1,
                            color: kLightTextColor,
                          );
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible: (placePred != null && placePred.length > 0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      color: kWhiteColor,
                      height: 300,
                      margin: EdgeInsets.only(top: 5),
                      padding:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                      child: ListView.separated(
                        itemCount: placePred.length,
                        shrinkWrap: true,
                        primary: true,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                mapboxPredictions = placePred[index];
                                lng = mapboxPredictions.geometry.coordinates[0];
                                lat = mapboxPredictions.geometry.coordinates[1];
                                searchController.clear();
                                placePred.clear();
                              });
                              _goToTheLake(lat, lng);
                              // _getCameraMoveLocation(LatLng(lat, lng));
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              children: <Widget>[
                                Image.asset(
                                  'assets/map_pin.png',
                                  scale: 3,
                                ),
                                SizedBox(
                                  width: 16.0,
                                ),
                                Expanded(
                                  child: Text(
                                    '${placePred[index].placeName}',
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.caption,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            thickness: 1,
                            color: kLightTextColor,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  // void getMapLoc() async {
  //   _getCameraMoveLocation(LatLng(lat, lng));
  // }
}

class Uuid {
  final Random _random = Random();

  String generateV4() {
    final int special = 8 + _random.nextInt(4);
    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}
