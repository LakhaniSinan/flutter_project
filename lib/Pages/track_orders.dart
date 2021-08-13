import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/beanmodel/orderbean/orderbean_p.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackOrders extends StatefulWidget {
  @override
  TrackOrderState createState() => TrackOrderState();
}

class TrackOrderState extends State<TrackOrders> {
  bool isEnteredFirst = false;
  MyOrderBeanMain orderData;
  dynamic apcurrency;
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition kGooglePlex;

  double lat = 0.0;
  double lng = 0.0;

  @override
  void initState() {
    super.initState();
    getAppCurrency();
    kGooglePlex = CameraPosition(
      target: LatLng(0.0, 0.0),
      zoom: 12.151926,
    );
  }

  void getAppCurrency() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      apcurrency = preferences.getString('app_currency');
    });
  }

  void _getLocation(BuildContext context, AppLocalizations locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if ((!prefs.containsKey('lat') && !prefs.containsKey('lng'))) {
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
      }
      else if (permission == LocationPermission.denied) {
        LocationPermission permissiond = await Geolocator.requestPermission();
        if (permissiond == LocationPermission.whileInUse ||
            permissiond == LocationPermission.always) {
          _getLocation(context, locale);
        } else {
          Toast.show(locale.locpermission, context, duration: Toast.LENGTH_SHORT);
        }
      }
      else if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings().then((value) {
          _getLocation(context, locale);
        }).catchError((e) {
          Toast.show(locale.locpermission, context, duration: Toast.LENGTH_SHORT);
        });
      }
    }else{
      try{
        double lat = double.parse('${prefs.getString('lat')}');
        double lng = double.parse('${prefs.getString('lng')}');
        _goToTheLake(lat,lng);
      }catch(e){
        _getLocation(context,locale);
        print(e);
      }
    }

  }

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
      // value.moveCamera(CameraUpdate.newCameraPosition(_kLake));
      value.animateCamera(CameraUpdate.newCameraPosition(_kLake));
    });
    // _controller.future.then((value){
    //   print('hello progress done');
    //   value.animateCamera(CameraUpdate.newCameraPosition(_kLake)).then((value){
    //     inLake = false;
    //   });
    //  });


  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    if (!isEnteredFirst) {
      isEnteredFirst = true;
      Map<String, dynamic> receivedData =
          ModalRoute.of(context).settings.arguments;
      orderData = receivedData['orderdetails'];
      _getLocation(context, locale);
    }
    return SafeArea(
      top: true,
      bottom: true,
      left: false,
      right: false,
      child: Scaffold(
          body: Stack(children: [
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
            ),
            Positioned(
              top: 10,
              left: 15,
              child: IconButton(onPressed: (){
                Navigator.of(context).pop();
              }, icon: Container(
                width: 30.0,
                height: 30.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xfff6f7f9),
                ),
                child: Icon(Icons.arrow_back_ios_sharp,
                    size: 20.0, color: kMainTextColor),
              ),),
            ),
        SlidingUpPanel(
            maxHeight: 410,
            minHeight: 130,
            color: kWhiteColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            collapsed: Container(
              decoration: BoxDecoration(
                color: kWhiteColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30), topRight: Radius.circular(30))
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Container(
                      height: 3,
                      width: 120,
                      margin: const EdgeInsets.only(bottom: 10, top: 5),
                      color: kButtonBorderColor,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                              text: 'ORDER ID\n',
                              style: TextStyle(
                                fontSize: 12,
                                color: kLightTextColor,
                                fontWeight: FontWeight.w200,
                                letterSpacing: 1.2,
                              ),
                              children: [
                                TextSpan(
                                  text: '#${orderData.cartId}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: kMainTextColor,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1.5),
                                )
                              ]),textAlign: TextAlign.start,),
                        RichText(
                          text: TextSpan(
                              text:
                              'Estimated arrival time\n'.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: kLightTextColor,
                                fontWeight: FontWeight.w200,
                                letterSpacing: 1.2,
                              ),
                              children: [
                                TextSpan(text: '30 Min',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: kMainTextColor,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1.5),)
                              ]),textAlign: TextAlign.end,),
                      ],
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              width: 50.0,
                              height: 50.0,
                              decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                      fit: BoxFit.fill,
                                      image: new AssetImage(
                                          'assets/icon.png')))),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      child: Text('${orderData.dboyName}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: kMainTextColor,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 1.5,
                                        ),),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('${orderData.dboyPhone}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: kLightTextColor,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1.5,
                                      ),),
                                  ),
                                ],
                              )),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                              onTap: () {
                                callNumberToDeliverBoy(orderData.dboyPhone);
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: kMainColor.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                margin: EdgeInsets.all(5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.phone,
                                        size: 15.0, color: kWhiteColor),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Text(
                                      'Call Driver',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: kWhiteColor,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.6),
                                    )
                                  ],
                                ),
                              )),
                        ],
                      )),
                ],
              ),
            ),
            panel: Container(
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Center(
                      child: Container(
                        height: 3,
                        width: 120,
                        margin: const EdgeInsets.only(bottom: 20, top: 5),
                        color: kButtonBorderColor,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                                text: 'ORDER ID\n',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: kLightTextColor,
                                  fontWeight: FontWeight.w200,
                                  letterSpacing: 1.2,
                                ),
                                children: [
                                  TextSpan(
                                    text: '#${orderData.cartId}',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: kMainTextColor,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1.5),
                                  )
                                ]),textAlign: TextAlign.start,),
                          RichText(
                            text: TextSpan(
                                text:
                                'Estimated arrival time\n'.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: kLightTextColor,
                                  fontWeight: FontWeight.w200,
                                  letterSpacing: 1.2,
                                ),
                                children: [
                                  TextSpan(text: '30 Min',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: kMainTextColor,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1.5),)
                                ]),textAlign: TextAlign.end,),
                        ],
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                        fit: BoxFit.fill,
                                        image: new AssetImage(
                                            'assets/icon.png')))),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        child: Text('${orderData.dboyName}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: kMainTextColor,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 1.5,
                                          ),),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('${orderData.dboyPhone}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: kLightTextColor,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 1.5,
                                        ),),
                                    ),
                                  ],
                                )),
                            SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                                onTap: () {
                                  callNumberToDeliverBoy(orderData.dboyPhone);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: kMainColor.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  margin: EdgeInsets.all(5),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.phone,
                                          size: 15.0, color: kWhiteColor),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Text(
                                        'Call Driver',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: kWhiteColor,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.6),
                                      )
                                    ],
                                  ),
                                )),
                          ],
                        )),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Divider(
                        color: Color(0xfff6f7f9),
                        height: 5,
                        thickness: 2,
                        indent: 5,
                        endIndent: 5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Text('${orderData.storeName}'.toUpperCase(),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: kMainTextColor,
                                        letterSpacing: 1.5,
                                        fontSize: 18)),
                              ),
                              Text('$apcurrency ${orderData.price}',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: kMainTextColor,
                                      letterSpacing: 1.5,
                                      fontSize: 18)),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text('${orderData.storeAddress}',
                                maxLines: 2,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontWeight: FontWeight.w200,
                                    color: kLightTextColor,
                                    fontSize: 14)),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("DELIVERING AT",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: kLightTextColor,
                                  letterSpacing: 1.6,
                                  fontSize: 14)),
                          SizedBox(height: 5,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text('${orderData.userAddress}',
                                maxLines: 2,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.w200,
                                    color: kMainTextColor,
                                    fontSize: 14)),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Divider(
                        color: Color(0xfff6f7f9),
                        height: 5,
                        thickness: 2,
                        indent: 5,
                        endIndent: 5,
                      ),
                    ),
                    // Container(
                    //   margin: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                    //   padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                    //   width: MediaQuery.of(context).size.width,
                    //   decoration: BoxDecoration(
                    //     color: kMainColor.withOpacity(0.5),
                    //     borderRadius: BorderRadius.circular(5)
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       Icon(Icons.chat_bubble_outline_sharp,
                    //           size: 20.0, color: kMainColor),
                    //       SizedBox(
                    //         width: 10,
                    //       ),
                    //       Expanded(
                    //           child: Column(
                    //         children: [
                    //           Align(
                    //             alignment: Alignment.centerLeft,
                    //             child: Container(
                    //               child: Text("Need Support?",
                    //                   style: TextStyle(
                    //                     fontSize: 15,
                    //                     color: kMainTextColor,
                    //                     fontWeight: FontWeight.w600,
                    //                     letterSpacing: 1.5,
                    //                   )),
                    //             ),
                    //           ),
                    //           SizedBox(
                    //             height: 5,
                    //           ),
                    //           Align(
                    //             alignment: Alignment.centerLeft,
                    //             child: Text("Chat with us if needed",
                    //                 style: TextStyle(
                    //                   fontSize: 14,
                    //                   color: kLightTextColor,
                    //                   fontWeight: FontWeight.w400,
                    //                   letterSpacing: 1.2,
                    //                 )),
                    //           ),
                    //         ],
                    //       )),
                    //       SizedBox(
                    //         width: 10,
                    //       ),
                    //       Container(
                    //         alignment: Alignment.centerLeft,
                    //         child: Text("Chat",
                    //             style: TextStyle(
                    //               fontSize: 13,
                    //               color: kMainColor,
                    //               fontWeight: FontWeight.w600,
                    //               letterSpacing: 1.5,
                    //             )),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0))),
                        onPressed: () {
Navigator.of(context).pop();
                        },
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        color: kMainColor,
                        child: Text(
                          "Order Details",
                          style: TextStyle(
                              color: kWhiteColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6),
                        ),
                      ),
                    ),
                  ]),
            ))
      ])),
    );
  }

  void callNumberToDeliverBoy(dboynumber) async {
    await launch('tel:$dboynumber');
  }
}
// Response Body11: -
// I/flutter (11555): <!doctype html>
// I/flutter (11555): <html class="theme-light">
// I/flutter (11555): <!--
// I/flutter (11555): Swift_TransportException: Connection could not be established with host mailhog :stream_socket_client(): php_network_getaddresses: getaddrinfo failed: Name or service not known in file /home/solicitous/public_html/grocery_app/source/vendor/swiftmailer/swiftmailer/lib/classes/Swift/Transport/StreamBuffer.php on line 261
// I/flutter (11555):
// I/flutter (11555): #0 [internal function]: Swift_Transport_StreamBuffer-&gt;{closure}(2, 'stream_socket_c...', '/home/solicitou...', 264, Array)
// I/flutter (11555): #1 /home/solicitous/public_html/grocery_app/source/vendor/swiftmailer/swiftmailer/lib/classes/Swift/Transport/StreamBuffer.php(264): stream_socket_client('mailhog:1025', 0, 'php_network_get...', 30, 4, Resource id #623)
// I/flutter (11555): #2 /home/solicitous/public_html/grocery_app/source/vendor/swiftmailer/swiftmailer/lib/classes/Swift/Transport/StreamBuffer.php(58): Swift_Transport_StreamBuffer-&gt;establishSocketConnection()
// I/flutter (11555): #3 /home/solicitous/public_html/grocery_app/source/vendor/swiftmailer/swiftmailer/lib/classes/
