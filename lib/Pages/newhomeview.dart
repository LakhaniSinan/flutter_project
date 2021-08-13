import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:badges/badges.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:grocery/Components/constantfile.dart';
import 'package:grocery/Components/drawer.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Pages/locpage/locationpage.dart';
import 'package:grocery/Pages/newaccountscreen.dart';
import 'package:grocery/Pages/newcategoryscreen.dart';
import 'package:grocery/Pages/newhomep1.dart';
import 'package:grocery/Pages/newsearchscreen.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/banner/bannerdeatil.dart';
import 'package:grocery/beanmodel/cart/cartitembean.dart';
import 'package:grocery/beanmodel/category/topcategory.dart';
import 'package:grocery/beanmodel/storefinder/storefinderbean.dart';
import 'package:grocery/providergrocery/benprovider/toporbottombean.dart';
import 'package:grocery/providergrocery/bottomnavigationnavigator.dart';
import 'package:grocery/providergrocery/cartcountprovider.dart';
import 'package:grocery/providergrocery/cartlistprovider.dart';
import 'package:grocery/providergrocery/categoryprovider.dart';
import 'package:grocery/providergrocery/locationemiter.dart';
import 'package:grocery/providergrocery/locemittermodel.dart';
import 'package:grocery/providergrocery/searchprovide.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  '1234', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  _showNotification(flutterLocalNotificationsPlugin,
      '${message.notification.title}', '${message.notification.body}');
}

class NewHomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NewHomeViewState();
  }
}

class NewHomeViewState extends State<NewHomeView> {
  bool isEnteredFirst = false;
  bool islogin = true;
  var userName = '--';
  var http = Client();
  dynamic _scanBarcode;
  int selectedInd = 0;
  int _NotiCounter = 0;
  dynamic hintText = '--';
  String appbarTitle = '--';
  dynamic lat;
  dynamic lng;
  dynamic currentAddress = 'Tap/Set to change your location.';
  StoreFinderData storeFinderData;

  List<CartItemData> cartItemd = [];

  List<BannerDataModel> bannerList = [];
  Timer _timer;
  TextEditingController searchController = TextEditingController();

  bool isKeyboardOpen = false;

  CartCountProvider cartCountP;

  void scanProductCode(BuildContext context) async {
    await FlutterBarcodeScanner.scanBarcode(
            "#ff6666", "Cancel", true, ScanMode.DEFAULT)
        .then((value) {
      if (value != null && value.length > 0 && '$value' != '-1') {
        if (storeFinderData != null) {
          Navigator.pushNamed(context, PageRoutes.search, arguments: {
            'ean_code': value,
            'storedetails': storeFinderData,
          });
        }
        print('scancode - ${_scanBarcode}');
      }
    }).catchError((e) {});
  }

  List<TopCategoryDataModel> categoryList = [];
  LocationEmitter locEmitterP;
  CategoryProvider cateP;
  SearchProvider searchP;
  CartListProvider cartListPro;
  BottomNavigationEmitter navBottomProvider;

  @override
  void initState() {
    getImageBaseUrl();
    super.initState();
    setFirebase();
  }

  void setFirebase() async {
    try{
      await Firebase.initializeApp();
    }catch(e){

    }
    messaging = FirebaseMessaging.instance;
    iosPermission(messaging);
    var initializationSettingsAndroid =
    AndroidInitializationSettings('icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    messaging.getToken().then((value) {
      debugPrint('token: $value');
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        _showNotification(
            flutterLocalNotificationsPlugin,
            '${message.notification.title}',
            '${message.notification.body}');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        _showNotification(flutterLocalNotificationsPlugin, notification.title, notification.body);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      _showNotification(
          flutterLocalNotificationsPlugin,
          '${message.notification.title}',
          '${message.notification.body}');
    });
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  }


  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // var message = jsonDecode('${payload}');
    _showNotification(flutterLocalNotificationsPlugin, '${title}', '${body}');
  }

  Future selectNotification(String payload) async {}



  void iosPermission(FirebaseMessaging firebaseMessaging) {
    if(Platform.isIOS){
      firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    if (!isEnteredFirst) {
      isEnteredFirst = true;
      locEmitterP = BlocProvider.of<LocationEmitter>(context);
      cateP = BlocProvider.of<CategoryProvider>(context);
      searchP = BlocProvider.of<SearchProvider>(context);
      cartListPro = BlocProvider.of<CartListProvider>(context);
      cartCountP = BlocProvider.of<CartCountProvider>(context);
      navBottomProvider = BlocProvider.of<BottomNavigationEmitter>(context);
      searchController.addListener(() {
        if (isKeyboardOpen) {
          if (searchController.text.length > 0 && storeFinderData != null) {
            searchP.hitSearchData(searchController.text, storeFinderData);
          } else {
            searchP.hitSearchData('', storeFinderData);
          }
        }
      });
      if (locEmitterP.state != null &&
          locEmitterP.state.lat != null &&
          locEmitterP.state.lat > 0.0 &&
          locEmitterP.state.lng != null &&
          locEmitterP.state.lng > 0.0) {
        print('in this');
        locEmitterP.getStoreId(locEmitterP.state);
      } else {
        print('in that');
        locEmitterP.hitLocEmitterInitial();
      }
      navBottomProvider.hitBottomNavigation(
          0, appbarTitle, '${locale.searchOnGoGrocer}$appname');
      getUserPrefs();
    }
    // print(isEnteredFirst);
    // print(isKeyboardOpen);
    // print(MediaQuery.of(context).viewInsets.bottom);
    return WillPopScope(
      onWillPop: () async{
        if(navBottomProvider.state!=null && navBottomProvider.state.navigation == 0){
          return true;
        }else{
          navBottomProvider.hitBottomNavigation(0, appbarTitle,
              '${locale.searchOnGoGrocer}$appname');
          return false;
        }
      },
      child: SafeArea(
        top: true,
        bottom: true,
        left: false,
        right: false,
        child: BlocBuilder<BottomNavigationEmitter, TopAndBottomTitleCount>(
          builder: (context, bottonNavigator) {
            selectedInd = bottonNavigator.navigation;
            appbarTitle = bottonNavigator.apptitle;
            hintText = bottonNavigator.searchTitle;
            return Scaffold(
              backgroundColor: Color(0xfff8f8f8),
              drawerScrimColor: kTransparentColor,
              drawer: (selectedInd == 0)
                  ? buildDrawer(context, userName, islogin, onHit: () {
                      SharedPreferences.getInstance().then((pref) {
                        pref.clear().then((value) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              PageRoutes.signInRoot,
                              (Route<dynamic> route) => false);
                        });
                      });
                    })
                  : null,
              appBar: PreferredSize(
                preferredSize: Size(MediaQuery.of(context).size.width,
                    (selectedInd == 0 || selectedInd == 1) ? 120 : 60),
                child: Container(
                  color: kWhiteColor,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: (selectedInd == 0),
                        child: AppBar(
                          title: BlocBuilder<LocationEmitter, LocEmitterModel>(
                              builder: (context, locModel) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MaterialButton(
                                  onPressed: () {
                                    // locEmitterP.hitLocEmitter(LocEmitterModel(0.0,0.0,'Searching your location',true,null));
                                    var latdi = 0.0;
                                    var lngdi = 0.0;
                                    if (lat != null && lng != null) {
                                      latdi = lat;
                                      lngdi = lng;
                                    }
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return LocationPage(latdi, lngdi);
                                    }));
                                  },
                                  splashColor: kWhiteColor,
                                  color: kWhiteColor,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    // runSpacing: 0.0,
                                    // spacing: 0.0,
                                    // runAlignment: WrapAlignment.center,
                                    // alignment: WrapAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${locModel.address}',
                                          maxLines: 2,
                                          overflow: TextOverflow.clip,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: kMainTextColor,
                                              fontSize: 14),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: kMainTextColor,
                                        size: 20,
                                      )
                                    ],
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.all(0),
                                  minWidth: 0,
                                  height: 20,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  focusColor: kButtonBorderColor.withOpacity(0.8),
                                ),
                                Text(
                                  (locModel.storeFinderData != null &&
                                          locModel.storeFinderData
                                                  .store_opening_time !=
                                              null)
                                      ? '${locModel.storeFinderData.store_opening_time} AM - ${locModel.storeFinderData.store_closing_time} PM'
                                      : '00:00 AM - 00:00 PM',
                                  style: TextStyle(
                                      color: kMainTextColor, fontSize: 12),
                                )
                              ],
                            );
                          }),
                          actions: [
                            Visibility(
                              // visible: (storeFinderData != null &&
                              //     storeFinderData.store_id != null),
                              visible: true,
                              child: IconButton(
                                icon: ImageIcon(AssetImage(
                                  'assets/scanner_logo.png',
                                )),
                                onPressed: () async {
                                  scanProductCode(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: (selectedInd == 1 || selectedInd == 3),
                        child: AppBar(
                          backgroundColor: kWhiteColor,
                          title: Text(
                            appbarTitle,
                            style: TextStyle(
                                color: kMainTextColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          automaticallyImplyLeading: true,
                          centerTitle: true,
                          leading: GestureDetector(
                            onTap: (){
                              navBottomProvider.hitBottomNavigation(0, appbarTitle,
                                  '${locale.searchOnGoGrocer}$appname');
                            },
                            behavior: HitTestBehavior.opaque,
                           child: Icon(Icons.arrow_back_ios_sharp),
                          ),
                          actions: [
                            Visibility(
                              // visible: (storeFinderData != null &&
                              //     storeFinderData.store_id != null),
                              visible: true,
                              child: IconButton(
                                icon: ImageIcon(AssetImage(
                                  'assets/scanner_logo.png',
                                )),
                                onPressed: () async {
                                  scanProductCode(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: (selectedInd == 1),
                        child: Row(
                          children: [
                            Expanded(
                                child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                  color: kWhiteColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Color(0xfff8f8f8), width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color(0xfff8f8f8),
                                        offset: Offset(-1, -1),
                                        blurRadius: 5),
                                    BoxShadow(
                                        color: Color(0xfff8f8f8),
                                        offset: Offset(1, 1),
                                        blurRadius: 5)
                                  ]),
                              child: TextFormField(
                                readOnly: (selectedInd != 1),
                                onTap: () {
                                  categoryList = cateP.getCategoryList();
                                },
                                onChanged: (value) {
                                  List<TopCategoryDataModel> chList = categoryList
                                      .where((element) => element.title
                                          .toString()
                                          .toLowerCase()
                                          .contains(value.toLowerCase()))
                                      .toList();
                                  cateP.emitCategoryList(chList, storeFinderData);
                                },
                                autofocus: false,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(
                                        color: kMainTextColor, fontSize: 18),
                                decoration: InputDecoration(
                                    hintText: hintText,
                                    hintStyle:
                                        Theme.of(context).textTheme.subtitle2,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 10),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: kIconColor,
                                    ),
                                    focusColor: kMainTextColor,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none)),
                              ),
                            )),
                            Visibility(
                              visible: (selectedInd == 2),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Badge(
                                  padding: EdgeInsets.all(5),
                                  position: BadgePosition(end: -2.5, top: -5),
                                  animationDuration: Duration(milliseconds: 300),
                                  animationType: BadgeAnimationType.slide,
                                  badgeContent: Text(
                                    _NotiCounter.toString(),
                                    style: TextStyle(
                                        color: kWhiteColor, fontSize: 10),
                                  ),
                                  child: Icon(
                                    Icons.filter_list_sharp,
                                    color: kMainTextColor,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Visibility(
                        visible: (selectedInd == 0),
                        child: GestureDetector(
                          onTap: () {
                            print('dd');
                            // searchP.emitSearchNull();
                            navBottomProvider.hitBottomNavigation(
                                2, appbarTitle, hintText);
                            // setState(() {
                            //   selectedInd = 2;
                            // });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            height: 52,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                                color: kWhiteColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Color(0xfff8f8f8), width: 1),
                                boxShadow: [
                                  BoxShadow(
                                      color: Color(0xfff8f8f8),
                                      offset: Offset(-1, -1),
                                      blurRadius: 5),
                                  BoxShadow(
                                      color: Color(0xfff8f8f8),
                                      offset: Offset(1, 1),
                                      blurRadius: 5)
                                ]),
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Icon(
                                    Icons.search,
                                    color: kIconColor,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 2.0),
                                  child: Text('$hintText',
                                      style:
                                          Theme.of(context).textTheme.subtitle2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: (selectedInd == 2),
                        child: Row(
                          children: [
                            Expanded(
                                child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                  color: kWhiteColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Color(0xfff8f8f8), width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color(0xfff8f8f8),
                                        offset: Offset(-1, -1),
                                        blurRadius: 5),
                                    BoxShadow(
                                        color: Color(0xfff8f8f8),
                                        offset: Offset(1, 1),
                                        blurRadius: 5)
                                  ]),
                              child: TextFormField(
                                readOnly: false,
                                autofocus: false,
                                controller: searchController,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(
                                        color: kMainTextColor, fontSize: 18),
                                decoration: InputDecoration(
                                    hintText: hintText,
                                    hintStyle:
                                        Theme.of(context).textTheme.subtitle2,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 10),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: kIconColor,
                                    ),
                                    focusColor: kMainTextColor,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none)),
                              ),
                            )),
                            Visibility(
                              // visible: (selectedInd == 2),
                              visible: false,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Badge(
                                  padding: EdgeInsets.all(5),
                                  position: BadgePosition(end: -2.5, top: -5),
                                  animationDuration: Duration(milliseconds: 300),
                                  animationType: BadgeAnimationType.slide,
                                  badgeContent: Text(
                                    _NotiCounter.toString(),
                                    style: TextStyle(
                                        color: kWhiteColor, fontSize: 10),
                                  ),
                                  child: Icon(
                                    Icons.filter_list_sharp,
                                    color: kMainTextColor,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Visibility(
                        // visible: (selectedInd == 2),
                        visible: false,
                        child: Container(
                          height: 52,
                          alignment: Alignment.centerLeft,
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 7),
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                        color: kButtonBorderColor, width: 2)),
                                child: Row(
                                  children: [
                                    Text(
                                      "Category",
                                      style: TextStyle(
                                          color: kMainTextColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Icon(
                                      Icons.close,
                                      size: 20,
                                    )
                                  ],
                                ),
                              );
                            },
                            itemCount: 5,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              body: BlocBuilder<CartListProvider, List<CartItemData>>(
                  builder: (context, cartList) {
                cartItemd = List.from(cartList);
                 print('indi d - $selectedInd ${bottonNavigator.navigation}');
                return IndexedStack(
                  index: bottonNavigator.navigation,
                  children: [
                    BlocBuilder<LocationEmitter, LocEmitterModel>(
                        builder: (context, locModel) {
                      storeFinderData = locModel.storeFinderData;
                      if (locModel != null) {
                        if (locModel.isSearching) {
                          // return Container(
                          //   child: Align(
                          //     alignment: Alignment.center,
                          //     child: Padding(
                          //       padding: const EdgeInsets.all(8.0),
                          //       child: Wrap(
                          //         runAlignment: WrapAlignment.center,
                          //         alignment: WrapAlignment.center,
                          //         crossAxisAlignment: WrapCrossAlignment.center,
                          //         children: [
                          //           Padding(
                          //             padding: const EdgeInsets.all(8.0),
                          //             child: CircularProgressIndicator(strokeWidth: 2,color: kMainColor,),
                          //           ),
                          //           Text(
                          //             'searching your nearby store please wait..',
                          //             maxLines: 1,
                          //             overflow: TextOverflow.ellipsis,
                          //             textAlign: TextAlign.center,
                          //             style: TextStyle(
                          //                 letterSpacing: 1.5
                          //             ),),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // );
                          return buildSingleScreenView(context);
                        } else {
                          if (locModel.lat > 0.0 &&
                              locModel.lng > 0.0 &&
                              locModel.storeFinderData != null &&
                              locModel.storeFinderData.store_id != null) {
                            currentAddress = locModel.address;
                            return NewHomeView1(locModel, cartItemd);
                          } else {
                            return Container(
                              child: Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'No Product Found at your location or we are fetching your product by your nearest store.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(letterSpacing: 1.5),
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                      } else {
                        return Container(
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'null value',
                                textAlign: TextAlign.center,
                                style: TextStyle(letterSpacing: 1.5),
                              ),
                            ),
                          ),
                        );
                      }
                    }),
                    NewCategoryScreen(),
                    NewSearchScreen(),
                    AccountData(),
                  ],
                );
              }),
              bottomNavigationBar: Material(
                elevation: 1,
                child: Container(
                  color: kWhiteColor,
                  alignment: Alignment.center,
                  height: 52,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            navBottomProvider.hitBottomNavigation(0, appbarTitle,
                                '${locale.searchOnGoGrocer}$appname');
                            // hintText = ;
                            // setState(() {
                            //   selectedInd = 0;
                            //
                            // });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.home,
                                color: (selectedInd == 0)
                                    ? kMainColor
                                    : kMainTextColor,
                              ),
                              Text(
                                "Home",
                                style: TextStyle(
                                    color: (selectedInd == 0)
                                        ? kMainColor
                                        : kMainTextColor),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (selectedInd != 1) {
                              navBottomProvider.hitBottomNavigation(1, 'Category',
                                  'what are you looking for (e.g. mango, onion)');
                              if (storeFinderData != null) {
                                if (!cateP.state.isSearching) {
                                  cateP.hitBannerDetails(
                                      '${storeFinderData.store_id}',
                                      storeFinderData);
                                } else {
                                  Toast.show('currently in progress', context,
                                      duration: Toast.LENGTH_SHORT,
                                      gravity: Toast.CENTER);
                                }
                              }
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category,
                                color: (selectedInd == 1)
                                    ? kMainColor
                                    : kMainTextColor,
                              ),
                              Text(
                                "Categories",
                                style: TextStyle(
                                    color: (selectedInd == 1)
                                        ? kMainColor
                                        : kMainTextColor),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // searchP.emitSearchNull();
                            navBottomProvider.hitBottomNavigation(2, appbarTitle,
                                '${locale.searchOnGoGrocer}$appname');
                            // hintText = ;
                            // setState(() {
                            //   selectedInd = 2;
                            // });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search,
                                color: (selectedInd == 2)
                                    ? kMainColor
                                    : kMainTextColor,
                              ),
                              Text(
                                "Search",
                                style: TextStyle(
                                    color: (selectedInd == 2)
                                        ? kMainColor
                                        : kMainTextColor),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(PageRoutes.yourbasket)
                                .then((value) {
                              navBottomProvider.hitBottomNavigation(
                                  0,
                                  appbarTitle,
                                  '${locale.searchOnGoGrocer}$appname');
                              // hintText = ;
                            });
                            // setState(() {
                            //   // selectedInd = 0;
                            // });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BlocBuilder<CartCountProvider, int>(
                                  builder: (context, cartCount) {
                                return Badge(
                                  padding: EdgeInsets.all(5),
                                  animationDuration: Duration(milliseconds: 300),
                                  animationType: BadgeAnimationType.slide,
                                  badgeContent: Text(
                                    cartCount.toString(),
                                    style: TextStyle(
                                        color: kWhiteColor, fontSize: 10),
                                  ),
                                  child: Icon(
                                    Icons.shopping_basket,
                                    color: kMainTextColor,
                                  ),
                                );
                              }),
                              Text(
                                "Basket",
                                style: TextStyle(color: kMainTextColor),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (selectedInd != 3) {
                              navBottomProvider.hitBottomNavigation(
                                  3, 'Account', hintText);
                              cartCountP.hitCounter();
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_box_outlined,
                                color: (selectedInd == 3)
                                    ? kMainColor
                                    : kMainTextColor,
                              ),
                              Text(
                                "Account",
                                style: TextStyle(
                                    color: (selectedInd == 3)
                                        ? kMainColor
                                        : kMainTextColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void getUserPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getBool('islogin')) {
        userName = prefs.getString('user_name');
        islogin = true;
      } else {
        userName = 'Hey User';
        islogin = false;
      }
    });
  }
}

Future<void> _showNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    dynamic title,
    dynamic body) async {
  final Int64List vibrationPattern = Int64List(4);
  vibrationPattern[0] = 0;
  vibrationPattern[1] = 1000;
  vibrationPattern[2] = 5000;
  vibrationPattern[3] = 2000;
  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('1234', 'Notify', 'Notify On Shopping',
          vibrationPattern: vibrationPattern,
          importance: Importance.max,
          priority: Priority.high,
          enableLights: true,
          enableVibration: true,
          icon: 'icon',
          playSound: true,
          ticker: 'ticker');
  final IOSNotificationDetails iOSPlatformChannelSpecifics =
      IOSNotificationDetails(presentSound: true);
  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
      0, '${title}', '${body}', platformChannelSpecifics,
      payload: 'item x');
}
