import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:grocery/Components/custom_button.dart';
import 'package:grocery/Components/entry_field.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/addressbean/showaddress.dart';
import 'package:grocery/beanmodel/citybean.dart';
import 'package:grocery/beanmodel/mapsection/googlemapkey.dart';
import 'package:grocery/beanmodel/mapsection/mapboxbean.dart';
import 'package:grocery/beanmodel/mapsection/mapbybean.dart';
import 'package:grocery/beanmodel/statebean.dart';
import 'package:http/http.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class EditAddressPage extends StatefulWidget {
  @override
  _EditAddressPageState createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  var http = Client();
  AddressData addressd;
  TextEditingController pincodeC = TextEditingController();
  TextEditingController stateC = TextEditingController();
  TextEditingController addressLine1C = TextEditingController();
  TextEditingController addressLine2C = TextEditingController();
  TextEditingController houseNumberC = TextEditingController();
  TextEditingController receiverNameC = TextEditingController();
  TextEditingController receiverPhoneC = TextEditingController();

  bool enteredFirst = false;
  bool isPinE = false;
  bool isStateE = false;
  bool addresslineE = false;
  bool isHouseE = false;
  bool isRNameE = false;
  bool isRContactE = false;
  bool isCityE = false;
  bool isSocietyE = false;

  String isPinT = '--';
  String isStateT = '--';
  String addresslineT = '--';
  String isHouseT = '--';
  String isRNameT = '--';
  String isRContactT = '--';
  String isCityT = '--';
  String isSocietyT = '--';

  bool isSavingAddress = false;
  bool isBack = false;
  bool isComposing = false;
  String addressType = 'Home';
  List<String> addressTypeList = ['Home','Office','Others'];

  bool isHideType = true;

  TextEditingController titleCon = TextEditingController();

  bool getErrorStatus(
      bool isPinE,
      bool isStateE,
      bool addresslineE,
      bool isHouseE,
      bool isRNameE,
      bool isRContactE,
      bool isCityE,
      bool isSocietyE) {
    print('${isPinE}');
    if (isPinE) {
      setState(() {
        this.isPinE = true;
        isPinT = 'Enter your pincode/zipcode please.';
      });
    } else {
      setState(() {
        if (this.isPinE) {
          this.isPinE = false;
          isPinT = '--';
        }
      });
    }
    if (isStateE) {
      setState(() {
        this.isStateE = true;
        isStateT = 'Enter your state please.';
      });
    } else {
      setState(() {
        if (this.isStateE) {
          this.isStateE = false;
          isStateT = '--';
        }
      });
    }
    if (addresslineE) {
      setState(() {
        this.addresslineE = true;
        addresslineT = 'Enter your address please.';
      });
    } else {
      setState(() {
        if (this.addresslineE) {
          this.addresslineE = false;
          addresslineT = '--';
        }
      });
    }
    if (isHouseE) {
      setState(() {
        this.isHouseE = true;
        isHouseT = 'Enter your house/flat number please.';
      });
    } else {
      setState(() {
        if (this.isHouseE) {
          this.isHouseE = false;
          isHouseT = '--';
        }
      });
    }
    if (isRNameE) {
      setState(() {
        this.isRNameE = true;
        isRNameT = 'Enter your receiver name please.';
      });
    } else {
      setState(() {
        if (this.isRNameE) {
          this.isRNameE = false;
          isRNameT = '--';
        }
      });
    }
    if (isRContactE) {
      setState(() {
        this.isRContactE = true;
        isRContactT = 'Enter your receiver contact number please.';
      });
    } else {
      setState(() {
        if (this.isRContactE) {
          this.isRContactE = false;
          isRContactT = '--';
        }
      });
    }
    if (isCityE) {
      setState(() {
        this.isCityE = true;
        isCityT = 'please select your city to save address.';
      });
    } else {
      setState(() {
        if (this.isCityE) {
          this.isCityE = false;
          isCityT = '--';
        }
      });
    }
    if (isSocietyE) {
      setState(() {
        this.isSocietyE = true;
        isSocietyT = 'please select your socity to save address.';
      });
    } else {
      setState(() {
        if (this.isSocietyE) {
          this.isSocietyE = false;
          isSocietyT = '--';
        }
      });
    }
    return (isPinE &&
        isStateE &&
        addresslineE &&
        isHouseE &&
        isRNameE &&
        isRContactE &&
        isCityE &&
        isSocietyE);
  }

  bool isLoading = true;
  bool isVisbile = false;
  dynamic lat;
  dynamic lng;
  CameraPosition kGooglePlex = CameraPosition(
    target: LatLng(40.866813, 34.566688),
    zoom: 5.151926,
  );
  String currentAddress = "";
  Address address;
  final scrollController = ScrollController();

  bool isCityLoading = false;
  bool isSocityLoading = false;

  String selectCity = 'Select city';
  String selectSocity = 'Select Society/Area';
  List<CityDataBean> cityList = [];
  List<StateDataBean> socityList = [];
  CityDataBean cityData;
  StateDataBean socityData;

  bool isCityHide = true;
  bool isSocityHide = true;

  GooglePlace places;
  PlacesSearch placesSearch;
  List<SearchResult> searchPredictions = [];
  List<MapBoxPlace> placePred = [];
  SearchResult pPredictions;
  MapBoxPlace mapboxPredictions;
  TextEditingController searchController = TextEditingController();
  Completer<GoogleMapController> _controller = Completer();

  Future<void> _goToTheLake(lat, lng) async {
    final CameraPosition _kLake = CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(lat, lng),
        tilt: 59.440717697143555,
        zoom: 19.151926040649414);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  @override
  void initState() {
    super.initState();
    titleCon.text = addressType;
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
      } else {
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

  void _getLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      bool isLocationServiceEnableds =
      await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnableds) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        Timer(Duration(seconds: 5), () async {
          double lat = position.latitude;
          double lng = position.longitude;
          prefs.setString("lat", lat.toStringAsFixed(8));
          prefs.setString("lng", lng.toStringAsFixed(8));
          final coordinates = new Coordinates(lat, lng);
          await Geocoder.local
              .findAddressesFromCoordinates(coordinates)
              .then((value) {
            for (int i = 0; i < value.length; i++) {
              if (value[i].locality != null && value[i].locality.length > 0) {
                setState(() {
                  // currentAddress = value[0].addressLine;
                  // address = value[0];
                  _goToTheLake(lat, lng);
                });
                break;
              }
            }
          });
        });
      } else {
        await Geolocator.openLocationSettings().then((value) {
          if (value) {
            _getLocation();
          } else {
            Toast.show('Location permission is required!', context,
                duration: Toast.LENGTH_SHORT);
          }
        }).catchError((e) {
          Toast.show('Location permission is required!', context,
              duration: Toast.LENGTH_SHORT);
        });
      }
    } else if (permission == LocationPermission.denied) {
      LocationPermission permissiond = await Geolocator.requestPermission();
      if (permissiond == LocationPermission.whileInUse ||
          permissiond == LocationPermission.always) {
        _getLocation();
      } else {
        Toast.show('Location permission is required!', context,
            duration: Toast.LENGTH_SHORT);
      }
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings().then((value) {
        _getLocation();
      }).catchError((e) {
        Toast.show('Location permission is required!', context,
            duration: Toast.LENGTH_SHORT);
      });
    }
  }

  void _getCameraMoveLocation(LatLng data) async {
    Timer(Duration(seconds: 1), () async {
      lat = data.latitude;
      lng = data.longitude;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("lat", data.latitude.toStringAsFixed(8));
      prefs.setString("lng", data.longitude.toStringAsFixed(8));
      final coordinates = new Coordinates(data.latitude, data.longitude);
      await Geocoder.local
          .findAddressesFromCoordinates(coordinates)
          .then((value) {
        for (int i = 0; i < value.length; i++) {
          if (value[i].locality != null && value[i].locality.length > 0) {
            if(!isBack){
              setState(() {
                currentAddress = value[0].addressLine;
                address = value[0];
                pincodeC.text = address.postalCode;
                stateC.text = address.adminArea;
                addressLine1C.text = address.addressLine;
                _goToTheLake(lat, lng);
              });
            }
            break;
          }
        }
      });
    });
  }

  void getMapLoc() async {
    _getCameraMoveLocation(LatLng(lat, lng));
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String,dynamic> addressData = ModalRoute.of(context).settings.arguments;
    if(!enteredFirst){
      setState(() {
        enteredFirst = true;
        addressd = addressData['address_d'];
        isVisbile = true;
        int typeIndex = addressTypeList.indexOf('${addressd.type}');
        addressType = addressTypeList[typeIndex];
        pincodeC.text = '${addressd.pincode}';
        stateC.text = '${addressd.state}';
        addressLine1C.text = '${addressd.landmark}';
        addressLine2C.text = '';
        houseNumberC.text = '${addressd.house_no}';
        receiverNameC.text = '${addressd.receiver_name}';
        receiverPhoneC.text = '${addressd.receiver_phone}';
        currentAddress = '${addressd.landmark}';
        lat = double.parse('${addressd.lat}');
        lng = double.parse('${addressd.lng}');
        _goToTheLake(lat, lng);
      });
      hitCityDataR(context);
    }

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppBar(
                  title: Text(
                    locale.addAddress,
                    style: TextStyle(fontSize: 18, color: kMainTextColor),
                  ),
                  leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        if (isVisbile) {
                          setState(() {
                            isVisbile = false;
                          });
                        } else {
                          setState(() {
                            isBack = true;
                          });
                          Navigator.of(context).pop();
                        }
                      }),
                  actions: [
IconButton(icon: Icon(Icons.my_location_sharp), onPressed: (){
  _getLocation();
})
                  ],
                ),
                Expanded(
                  child: Stack(
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
                        onCameraIdle: () async{
                          try{
                            if(lat!=null && lng!=null){
                              getMapLoc();
                            }
                          }catch(e){
                            print(e);
                          }
                        },
                        onCameraMove: (post) {
                          lat = post.target.latitude;
                          lng = post.target.longitude;
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
                      Positioned(
                        top: 10,
                        left: 30,
                        right: 30,
                        child: Column(
                          children: [
                            Container(
                              height: 52,
                              decoration: BoxDecoration(
                                  color: kWhiteColor,
                                  borderRadius: BorderRadius.circular(10)),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: locale.locpage3,
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide:
                                    BorderSide(color: kHintColor, width: 1),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide:
                                    BorderSide(color: kHintColor, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide:
                                    BorderSide(color: kHintColor, width: 1),
                                  ),
                                ),
                                controller: searchController,
                                onEditingComplete: (){
                                  print('editing complete!');
                                },
                                onChanged: (value){
                                  print('changing complete!');
                                },
                                onTap: (){
                                  setState(() {
                                    isComposing = true;
                                  });
                                },
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
                                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                                        setState(() {
                                          pPredictions = searchPredictions[index];
                                          lat = pPredictions.geometry.location.lat;
                                          lng = pPredictions.geometry.location.lng;
                                          currentAddress = pPredictions.formattedAddress;
                                          searchController.clear();
                                          searchPredictions.clear();
                                          isComposing = false;
                                        });
                                        getMapLoc();
                                        // _getCameraMoveLocation(LatLng(lat, lng));
                                        // _goToTheLake(lat, lng);
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
                                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                                        setState(() {
                                          mapboxPredictions = placePred[index];
                                          lng = mapboxPredictions.geometry.coordinates[0];
                                          lat = mapboxPredictions.geometry.coordinates[1];
                                          currentAddress = mapboxPredictions.addressNumber;
                                          searchController.clear();
                                          placePred.clear();
                                          isComposing = false;
                                        });
                                        getMapLoc();
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
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: !isComposing,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 18.0, left: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Icon(
                                  Icons.check_box,
                                  size: 20,
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Flexible(
                              child: EntryField(
                                horizontalPadding: 0,
                                labelFontSize: 15,
                                labelFontWeight: FontWeight.w400,
                                readOnly: true,
                                label: locale.addressTitle,
                                controller: titleCon,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.only(bottom: 20.0, left: 12, right: 12),
                        child: GestureDetector(
                          onTap: () {
                            if (address != null) {
                              setState(() {
                                isPinE = false;
                                isStateE = false;
                                addresslineE = false;
                                isRContactE = false;
                                isRNameE = false;
                                isCityE = false;
                                isSocietyE = false;
                                isPinT = '--';
                                isStateT = '--';
                                addresslineT = '--';
                                isRContactT = '--';
                                isRNameT = '--';
                                isCityT = '--';
                                isSocietyT = '--';
                                isVisbile = !isVisbile;
                              });
                              hitCityData(context);
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on, size: 20),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      '$currentAddress',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  locale.taptosave,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(fontSize: 15, color: kMainColor),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.7,
                bottom: 0.0,
                child: (!isSavingAddress)
                    ? Visibility(
                  visible: isVisbile,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0)),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.7,
                      margin:
                      EdgeInsets.only(left: 10, right: 10, top: 10),
                      decoration: BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 5.0,
                          ),
                        ],
                      ),
                      child: Scrollbar(
                        controller: scrollController,
                        isAlwaysShown: true,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          controller: scrollController,
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: kRedColor,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isVisbile = false;
                                    });
                                  },
                                ),
                              ),
                              DropdownAType(context,
                                  heading: 'Select Address Type',
                                  hint: addressType,
                                  typeList: addressTypeList,
                                  callBackDrop: () {
                                    setState(() {
                                      isHideType = !isHideType;
                                    });
                                  }, hideCallBack: (value) {
                                    setState(() {
                                      isHideType = !isHideType;
                                      addressType = value;
                                    });
                                  }, isHide: isHideType),
                              Divider(
                                thickness: 2.5,
                                color: Colors.transparent,
                              ),
                              AddressTitle(
                                  heading: 'Receiver Name',
                                  hint: 'Enter Receiver Name',
                                  controller: receiverNameC,
                                  inputType: TextInputType.text,
                                  isloading: isLoading,
                                  isError: isRNameE,
                                  error: isRNameT),
                              Divider(
                                thickness: 2.5,
                                color: Colors.transparent,
                              ),
                              AddressTitle(
                                  heading: 'Receiver Contact Number',
                                  hint: 'Enter Receiver Contact Number',
                                  controller: receiverPhoneC,
                                  inputType: TextInputType.number,
                                  isloading: isLoading,
                                  isError: isRContactE,
                                  error: isRContactT),
                              Divider(
                                thickness: 2.5,
                                color: Colors.transparent,
                              ),
                              DropDownCityAddress(context,
                                  heading: 'City',
                                  hint: selectCity,
                                  cityList: cityList,
                                  isloading: isCityLoading,
                                  isHide: isCityHide, callBackDrop: () {
                                    print('done');
                                    setState(() {
                                      isCityHide = !isCityHide;
                                    });
                                  }, hideCallBack: (value) {
                                    print('dv - ${value.toString()}');
                                    setState(() {
                                      cityData = value;
                                      selectCity = value.city_name;
                                      isCityHide = true;
                                      isSocityLoading = true;
                                      isSocityHide = true;
                                      socityData = null;
                                      selectSocity = (locale != null)
                                          ? locale.selectsocity2
                                          : 'Select Society/Area';
                                    });
                                    hitSocityList(
                                        cityData.city_name, locale, context);
                                  }, isError: isCityE, error: isCityT),
                              Divider(
                                thickness: 2.5,
                                color: Colors.transparent,
                              ),
                              DropDownSocietyAddress(context,
                                  socityList: socityList,
                                  heading: 'Society/Area',
                                  hint: selectSocity,
                                  isHide: isSocityHide,
                                  isloading: isSocityLoading,
                                  callBackDrop: () {
                                    setState(() {
                                      isSocityHide = !isSocityHide;
                                    });
                                  }, hideCallBack: (value) {
                                    setState(() {
                                      socityData = value;
                                      selectSocity = value.society_name;
                                      isSocityHide = true;
                                    });
                                  }, isError: isSocietyE, error: isSocietyT),
                              Divider(
                                thickness: 2.5,
                                color: Colors.transparent,
                              ),
                              AddressTitle(
                                  heading: 'Pincode',
                                  hint: 'Pincode',
                                  controller: pincodeC,
                                  inputType: TextInputType.number,
                                  isloading: isLoading,
                                  isError: isPinE,
                                  error: isPinT),
                              Divider(
                                thickness: 2.5,
                                color: Colors.transparent,
                              ),
                              AddressTitle(
                                  heading: 'House/Flat Number',
                                  hint: 'Enter your house/flat number.',
                                  controller: houseNumberC,
                                  inputType: TextInputType.text,
                                  isloading: isLoading,
                                  isError: isHouseE,
                                  error: isHouseT),
                              Divider(
                                thickness: 2.5,
                                color: Colors.transparent,
                              ),
                              AddressTitle(
                                  heading: 'State',
                                  hint: 'State',
                                  controller: stateC,
                                  inputType: TextInputType.text,
                                  isloading: isLoading,
                                  isError: isStateE,
                                  error: isStateT),
                              Divider(
                                thickness: 2.5,
                                color: Colors.transparent,
                              ),
                              AddressTitle(
                                  heading: 'Address Line 1',
                                  hint: 'Address Line No.1',
                                  controller: addressLine1C,
                                  inputType: TextInputType.text,
                                  isloading: isLoading,
                                  isError: addresslineE,
                                  error: addresslineT),
                              Divider(
                                thickness: 2.5,
                                color: Colors.transparent,
                              ),
                              AddressTitle(
                                  heading: 'Address Line 2',
                                  hint:
                                  'Address Line No. 2/LandMark (Optional)',
                                  controller: addressLine2C,
                                  inputType: TextInputType.text,
                                  isloading: isLoading),
                              Divider(
                                thickness: 2.5,
                                color: Colors.transparent,
                              ),
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  MaterialButton(
                                    onPressed: () {
                                      if (!isSavingAddress) {
                                        setState(() {
                                          isSavingAddress = true;
                                        });
                                        if (!getErrorStatus(
                                            (pincodeC.text.toString().length < 1),
                                            (stateC.text.toString().length < 1),
                                            (addressLine1C.text.toString().length < 1),
                                            (houseNumberC.text.toString().length < 1),
                                            (receiverNameC.text.toString().length < 1),
                                            (receiverPhoneC.text.toString().length < 1),
                                            (cityData == null),
                                            (socityData == null))) {
                                          addAddress(addressd.address_id,context);
                                        } else {
                                          setState(() {
                                            isSavingAddress = false;
                                          });
                                        }
                                      }
                                    },
                                    child: Text(
                                      locale.continueText,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    color: kMainColor,
                                  ),
                                ],
                              ),
                              Divider(
                                thickness: 2.5,
                                color: Colors.transparent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                    : Align(
                  widthFactor: 50,
                  heightFactor: 50,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                )),
          ],
        ),
      ),
    );
  }

  void addAddress(addressid, BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    print('${socityData.society_name}');
    var http = Client();
    http.post(editAddressUri, body: {
      'user_id': '${preferences.getInt('user_id')}',
      'address_id': '$addressid',
      'receiver_name': '${receiverNameC.text}',
      'receiver_phone': '${receiverPhoneC.text}',
      'city_name': '${cityData.city_id}',
      'society_name': '${socityData.society_id}',
      'house_no': '${houseNumberC.text}',
      'state': '${stateC.text}',
      'landmark': (addressLine2C.text != null &&
          addressLine2C.text.toString().length > 0)
          ? '${addressLine1C.text}${addressLine2C.text}'
          : '${addressLine1C.text}',
      'pin': '${pincodeC.text}',
      'lat': '${lat}',
      'lng': '${lng}',
      'type': '${addressType}',
    }, headers: {
      'Authorization': 'Bearer ${preferences.getString('accesstoken')}'
    }).then((value) {
      print('addres - ${value.body}');
      if (value.statusCode == 200) {
        var jsData = jsonDecode(value.body);
        if ('${jsData['status']}' == '1') {
          setState(() {
            currentAddress =
            '${houseNumberC.text}${addressLine1C.text}${socityData.society_name}${cityData.city_name}(${pincodeC.text})${stateC.text}';
            isVisbile = false;
            pincodeC.clear();
            stateC.clear();
            houseNumberC.clear();
            receiverNameC.clear();
            receiverPhoneC.clear();
            addressLine1C.clear();
            addressLine2C.clear();
            socityList.clear();
            socityData = null;
            selectSocity = 'Select your Society/Area';
          });
          Navigator.of(context).pop();
        }
        Toast.show(jsData['message'], context,
            gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
      }
      setState(() {
        isSavingAddress = false;
      });
    }).catchError((e) {
      setState(() {
        isSavingAddress = false;
      });
      print(e);
    });
  }

  void hitCityDataR(BuildContext context) {
    setState(() {
      isCityLoading = true;
    });
    var http = Client();
    http.get(cityUri).then((value) {
      if (value.statusCode == 200) {
        CityBeanModel data1 = CityBeanModel.fromJson(jsonDecode(value.body));
        print('${data1.data.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          int idd = -1;
          setState(() {
            cityList.clear();
            cityList = List.from(data1.data);
            idd = cityList.indexOf(CityDataBean('','${addressd.city}'));
            selectCity = cityList[idd].city_name;
            cityData = cityList[idd];
            socityList.clear();
            selectSocity = 'Select your socity/area';
            socityData = null;
          });
          if (cityList.length > 0) {
            setState(() {
              isSocityLoading = true;
            });
            hitSocityListR(cityList[idd].city_name, AppLocalizations.of(context), context);
          } else {
            selectCity = 'Select your city';
            cityData = null;
            setState(() {
              isCityLoading = false;
            });
          }
        } else {
          setState(() {
            selectCity = 'Select your city';
            cityData = null;
            isCityLoading = false;
          });
        }
      } else {
        setState(() {
          selectCity = 'Select your city';
          cityData = null;
          isCityLoading = false;
        });
      }
    }).catchError((e) {
      setState(() {
        selectCity = 'Select your city';
        cityData = null;
        isCityLoading = false;
      });
      print(e);
    });
  }

  void hitSocityListR(dynamic cityName, locale, BuildContext context) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var http = Client();
    http.post(societyUri, body: {'city_name': '$cityName'}, headers: {
      'Authorization': 'Bearer ${pref.getString('accesstoken')}'
    }).then((value) {
      if (value.statusCode == 200) {
        StateBeanModel data1 = StateBeanModel.fromJson(jsonDecode(value.body));
        print('${data1.data.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            socityList.clear();
            socityList = List.from(data1.data);
            selectSocity = socityList[0].society_name;
            socityData = socityList[0];
          });
        } else {
          setState(() {
            selectSocity = (locale != null)
                ? locale.selectsocity2
                : 'Select your society/area';
            socityData = null;
          });
        }
      }
      setState(() {
        if (isCityLoading) {
          isCityLoading = false;
        }
        isSocityLoading = false;
      });
    }).catchError((e) {
      setState(() {
        selectSocity = (locale != null)
            ? locale.selectsocity2
            : 'Select your society/area';
        socityData = null;
        if (isCityLoading) {
          isCityLoading = false;
        }
        isSocityLoading = false;
      });
      print(e);
    });
  }

  void hitCityData(BuildContext context) {
    setState(() {
      isCityLoading = true;
    });
    var http = Client();
    http.get(cityUri).then((value) {
      if (value.statusCode == 200) {
        CityBeanModel data1 = CityBeanModel.fromJson(jsonDecode(value.body));
        print('${data1.data.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            cityList.clear();
            cityList = List.from(data1.data);
            selectCity = cityList[0].city_name;
            cityData = cityList[0];
            socityList.clear();
            selectSocity = 'Select your socity/area';
            socityData = null;
          });
          if (cityList.length > 0) {
            setState(() {
              isSocityLoading = true;
            });
            hitSocityList(
                cityList[0].city_name, AppLocalizations.of(context), context);
          } else {
            selectCity = 'Select your city';
            cityData = null;
            setState(() {
              isCityLoading = false;
            });
          }
        } else {
          setState(() {
            selectCity = 'Select your city';
            cityData = null;
            isCityLoading = false;
          });
        }
      } else {
        setState(() {
          selectCity = 'Select your city';
          cityData = null;
          isCityLoading = false;
        });
      }
    }).catchError((e) {
      setState(() {
        selectCity = 'Select your city';
        cityData = null;
        isCityLoading = false;
      });
      print(e);
    });
  }

  void hitSocityList(dynamic cityName, locale, BuildContext context) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var http = Client();
    http.post(societyUri, body: {'city_name': '$cityName'}, headers: {
      'Authorization': 'Bearer ${pref.getString('accesstoken')}'
    }).then((value) {
      if (value.statusCode == 200) {
        StateBeanModel data1 = StateBeanModel.fromJson(jsonDecode(value.body));
        print('${data1.data.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            socityList.clear();
            socityList = List.from(data1.data);
            int id = socityList.indexOf(StateDataBean('','${addressd.society}','',''));
            selectSocity = socityList[id].society_name;
            socityData = socityList[id];
          });
        } else {
          setState(() {
            selectSocity = (locale != null)
                ? locale.selectsocity2
                : 'Select your society/area';
            socityData = null;
          });
        }
      }
      setState(() {
        if (isCityLoading) {
          isCityLoading = false;
        }
        isSocityLoading = false;
      });
    }).catchError((e) {
      setState(() {
        selectSocity = (locale != null)
            ? locale.selectsocity2
            : 'Select your society/area';
        socityData = null;
        if (isCityLoading) {
          isCityLoading = false;
        }
        isSocityLoading = false;
      });
      print(e);
    });
  }
}

Widget AddressTitle(
    {String heading,
      String hint,
      TextEditingController controller,
      bool isloading = false,
      TextInputType inputType = TextInputType.text,
      bool isError = false,
      String error = '--'}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          heading,
          style: TextStyle(
              fontSize: 18,
              color: kLightTextColor,
              fontWeight: FontWeight.w500),
        ),
        TextFormField(
          readOnly: false,
          keyboardType: inputType,
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
          ),
          // initialValue: '131001',
        ),
        SizedBox(
          height: 5,
        ),
        Visibility(
            visible: isError,
            child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: kRedColor,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(color: kWhiteColor, width: 1.5)),
                child: Row(
                  children: [
                    Icon(
                      Icons.label_important,
                      color: kWhiteColor,
                      size: 20,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        error,
                        style: TextStyle(color: kWhiteColor),
                      ),
                    ),
                  ],
                )))
      ],
    ),
  );
}

Widget DropDownCityAddress(BuildContext context,
    {String heading,
      String hint,
      bool isloading = false,
      bool isError = false,
      String error = '--',
      bool isOpen = false,
      Function callBackDrop,
      List<CityDataBean> cityList,
      void hideCallBack(CityDataBean cityList),
      bool isHide = true}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          heading,
          style: TextStyle(
              fontSize: 18,
              color: kLightTextColor,
              fontWeight: FontWeight.w500),
        ),
        Container(
            decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                border: Border.all(color: kLightTextColor)),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            margin: EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hint,
                  style: TextStyle(
                      fontSize: 16,
                      color: kMainTextColor,
                      fontWeight: FontWeight.w500),
                ),
                isloading
                    ? SizedBox(
                  width: 30,
                  height: 30,
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: CircularProgressIndicator(),
                  ),
                )
                    : IconButton(
                    icon: isHide
                        ? Icon(Icons.arrow_drop_down_sharp)
                        : Icon(Icons.arrow_drop_up_sharp),
                    onPressed: () {
                      callBackDrop();
                    })
              ],
            )),
        Visibility(
          visible: (!isHide &&
              !isError &&
              !isloading &&
              (cityList != null && cityList.length > 0)),
          child: ListView.separated(
              itemCount: cityList.length,
              shrinkWrap: true,
              primary: false,
              separatorBuilder: (context, index) {
                return Divider(
                  thickness: 1.5,
                  color: Colors.transparent,
                );
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    hideCallBack(cityList[index]);
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          border: Border.all(color: kLightTextColor)),
                      padding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      child: Text(
                        cityList[index].city_name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            color: kMainTextColor,
                            fontWeight: FontWeight.w500),
                      )),
                );
              }),
        ),
        SizedBox(
          height: 5,
        ),
        Visibility(
            visible: isError,
            child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: kRedColor,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(color: kWhiteColor, width: 1.5)),
                child: Row(
                  children: [
                    Icon(
                      Icons.label_important,
                      color: kWhiteColor,
                      size: 20,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        error,
                        style: TextStyle(color: kWhiteColor),
                      ),
                    ),
                  ],
                )))
      ],
    ),
  );
}

Widget DropDownSocietyAddress(BuildContext context,
    {String heading,
      String hint,
      bool isloading = false,
      bool isError = false,
      String error = '--',
      bool isOpen = false,
      Function callBackDrop,
      List<StateDataBean> socityList,
      void hideCallBack(StateDataBean socityList),
      bool isHide = true}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          heading,
          style: TextStyle(
              fontSize: 18,
              color: kLightTextColor,
              fontWeight: FontWeight.w500),
        ),
        Container(
            decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                border: Border.all(color: kLightTextColor)),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            margin: EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    hint,
                    style: TextStyle(
                        fontSize: 16,
                        color: kMainTextColor,
                        fontWeight: FontWeight.w500),
                    maxLines: 2,
                  ),
                ),
                isloading
                    ? SizedBox(
                  width: 30,
                  height: 30,
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: CircularProgressIndicator(),
                  ),
                )
                    : IconButton(
                    icon: isHide
                        ? Icon(Icons.arrow_drop_down_sharp)
                        : Icon(Icons.arrow_drop_up_sharp),
                    onPressed: () {
                      callBackDrop();
                    })
              ],
            )),
        Visibility(
          visible: (!isHide &&
              !isError &&
              !isloading &&
              (socityList != null && socityList.length > 0)),
          child: ListView.separated(
              itemCount: socityList.length,
              shrinkWrap: true,
              primary: false,
              separatorBuilder: (context, index) {
                return Divider(
                  thickness: 1.5,
                  color: Colors.transparent,
                );
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    hideCallBack(socityList[index]);
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          border: Border.all(color: kLightTextColor)),
                      padding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      child: Text(
                        socityList[index].society_name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            color: kMainTextColor,
                            fontWeight: FontWeight.w500),
                      )),
                );
              }),
        ),
        SizedBox(
          height: 5,
        ),
        Visibility(
            visible: isError,
            child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: kRedColor,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(color: kWhiteColor, width: 1.5)),
                child: Row(
                  children: [
                    Icon(
                      Icons.label_important,
                      color: kWhiteColor,
                      size: 20,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        error,
                        style: TextStyle(color: kWhiteColor),
                      ),
                    ),
                  ],
                )))
      ],
    ),
  );
}


Widget DropdownAType(BuildContext context,
    {String heading,
      String hint,
      Function callBackDrop,
      List<String> typeList,
      void hideCallBack(String type),
      bool isHide = true}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          heading,
          style: TextStyle(
              fontSize: 18,
              color: kLightTextColor,
              fontWeight: FontWeight.w500),
        ),
        Container(
            decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                border: Border.all(color: kLightTextColor)),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            margin: EdgeInsets.only(top: 5),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        hint,
                        style: TextStyle(
                            fontSize: 16,
                            color: kMainTextColor,
                            fontWeight: FontWeight.w500),
                        maxLines: 2,
                      ),
                    ),
                    IconButton(
                        icon: isHide
                            ? Icon(Icons.arrow_drop_down_sharp)
                            : Icon(Icons.arrow_drop_up_sharp),
                        onPressed: () {
                          callBackDrop();
                        })
                  ],
                ),
                Visibility(
                  visible: !isHide,
                  child: Column(
                    children: [
                      ListView.separated(
                          itemCount: typeList.length,
                          shrinkWrap: true,
                          primary: false,
                          separatorBuilder: (context, index) {
                            return Divider(
                              thickness: 1.5,
                              color: Colors.transparent,
                            );
                          },
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                hideCallBack(typeList[index]);
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: kWhiteColor,
                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      border: Border.all(color: kLightTextColor)),
                                  padding:
                                  EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  child: Text(
                                    typeList[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: kMainTextColor,
                                        fontWeight: FontWeight.w500),
                                  )),
                            );
                          }),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                )
              ],
            )
        ),
      ],
    ),
  );
}
