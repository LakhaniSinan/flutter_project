import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/appinfo.dart';
import 'package:grocery/beanmodel/signinmodel.dart';
import 'package:grocery/providergrocery/locationemiter.dart';
import 'package:grocery/providergrocery/profileprovider.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class AccountData extends StatefulWidget {
  @override
  AccountDataState createState() => AccountDataState();
}

class AccountDataState extends State<AccountData> {
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  GoogleSignIn _googleSignIn;
  bool showProgress = false;
  bool enteredFirst = false;
  int numberLimit = 10;
  TextEditingController countryCodeController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  AppInfoModel appInfoModeld;
  int checkValue = -1;
  List<String> languages = [];
  String selectLanguage = '';
  TextEditingController passwordController = TextEditingController();

  FirebaseMessaging messaging;
  dynamic token;

  int count = 0;

  String appNameA = '--';

  bool isNumberOk = false;

  bool valueNoti = true;
  bool isLogin = false;
  String userName = '--';
  String useremail = '--';
  String userMobileNumber = '--';
  String walletAmount = '--';
  String apCurrecny = '--';
  LocationEmitter locEmitterP;

  ProfileProvider pRovider;

  @override
  void initState() {
    super.initState();
    getSharedValue();
    hitAsyncInit();
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
      ],
    );
  }

  void hitAsyncInit() async {
    try {
      await Firebase.initializeApp();
      messaging = FirebaseMessaging.instance;
      messaging.getToken().then((value) {
        token = value;
      });
    } catch (e) {}
  }

  void getSharedValue() async {
    print('do');
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.getBool('islogin')) {
        setState(() {
          isLogin = true;
          userName = prefs.getString('user_name');
          useremail = prefs.getString('user_email');
          userMobileNumber = prefs.getString('user_phone');
          walletAmount = prefs.getString('wallet_credits');
          apCurrecny = prefs.getString('app_currency');
        });
      } else {
        setState(() {
          isLogin = false;
          apCurrecny = prefs.getString('app_currency');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    if (!enteredFirst) {
      locEmitterP = BlocProvider.of<LocationEmitter>(context);
      pRovider = BlocProvider.of<ProfileProvider>(context);
      enteredFirst = true;
      pRovider.hitCounter();
    }

    return BlocBuilder<ProfileProvider, AppInfoModel>(
        builder: (context, signModel) {
      appInfoModeld = signModel;
      if (signModel != null) {
        walletAmount = '${signModel.userWallet}';
        numberLimit = appInfoModeld.phoneNumberLength;
      } else {
        getSharedValue();
      }
      if(signModel!=null){
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          color: kWhiteColor,
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Divider(
                      thickness: 10,
                      height: 10,
                      color: Color(0xfff8f8f8),
                    ),
                    isLogin
                        ? Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('$userName',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: kMainColor,
                                                fontSize: 20)),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text('$useremail',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                color: kMainColor,
                                                fontSize: 18)),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text('$userMobileNumber',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black54,
                                                fontSize: 17)),
                                      ],
                                    )),
                                Image.asset(
                                  'assets/icon.png',
                                  height: 80,
                                  width: 80,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Divider(
                            thickness: 1.5,
                            height: 1.5,
                            color: kButtonBorderColor.withOpacity(0.5),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 20, top: 10, bottom: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(PageRoutes.myaccount);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Text(locale.ac1,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: kMainColor,
                                      fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                    )
                        : Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/icon.png',
                              height: 150,
                              width: 200,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(appname,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: kMainColor,
                                  fontSize: 25)),
                          SizedBox(
                            height: 5,
                          ),
                          Text(locale.ac2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kMainColor,
                                  fontSize: 18)),
                          SizedBox(
                            height: 10,
                          ),
                          Text(locale.ac3,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black54,
                                  fontSize: 17)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: MaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(30.0))),
                              onPressed: () {
                                showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                          height: 370.0,
                                          // padding: EdgeInsets.symmetric(horizontal: 20),
                                          decoration: BoxDecoration(
                                            color: kWhiteColor,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20.0),
                                                topRight:
                                                Radius.circular(20.0)),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                            children: <Widget>[
                                              Center(
                                                child: Container(
                                                  height: 3,
                                                  width: 120,
                                                  margin: const EdgeInsets.only(
                                                      bottom: 10, top: 5),
                                                  color: kButtonBorderColor,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10,
                                                    left: 20,
                                                    right: 20),
                                                child: Text(locale.ac4,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.w700,
                                                        color: kMainTextColor,
                                                        fontSize: 20)),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5,
                                                    left: 20,
                                                    right: 20),
                                                child: Text(locale.ac5,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        color: kMainTextColor,
                                                        fontSize: 15)),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15,
                                                    bottom: 5,
                                                    right: 20,
                                                    left: 20),
                                                child: Text(locale.mobilenuml,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        color: kMainTextColor,
                                                        fontSize: 15)),
                                              ),
                                              Container(
                                                height: 52,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        6),
                                                    border: Border.all(
                                                        color:
                                                        kButtonBorderColor,
                                                        width: 1)),
                                                margin:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 20),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 52,
                                                      color: kButtonBorderColor
                                                          .withOpacity(0.5),
                                                      alignment:
                                                      Alignment.center,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 15),
                                                      margin:
                                                      const EdgeInsets.only(
                                                          right: 5),
                                                      child: Text(
                                                          appInfoModeld != null
                                                              ? '+${appInfoModeld.countryCode}'
                                                              : '--',
                                                          textAlign:
                                                          TextAlign.center,
                                                          style: TextStyle(
                                                              color:
                                                              kMainTextColor,
                                                              fontSize: 15)),
                                                    ),
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller:
                                                        phoneNumberController,
                                                        readOnly: showProgress,
                                                        autofocus: false,
                                                        maxLength: numberLimit,
                                                        textAlign:
                                                        TextAlign.start,
                                                        keyboardType:
                                                        TextInputType
                                                            .number,
                                                        decoration:
                                                        InputDecoration(
                                                            border:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  0),
                                                              borderSide:
                                                              BorderSide(
                                                                  color:
                                                                  kTransparentColor),
                                                            ),
                                                            counterText: '',
                                                            enabledBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  0),
                                                              borderSide:
                                                              BorderSide(
                                                                  color:
                                                                  kTransparentColor),
                                                            ),
                                                            focusedBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  0),
                                                              borderSide:
                                                              BorderSide(
                                                                  color:
                                                                  kTransparentColor),
                                                            ),
                                                            errorBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  0),
                                                              borderSide:
                                                              BorderSide(
                                                                  color:
                                                                  kTransparentColor),
                                                            ),
                                                            disabledBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  0),
                                                              borderSide:
                                                              BorderSide(
                                                                  color:
                                                                  kTransparentColor),
                                                            ),
                                                            hintText:
                                                            "Enter your mobile number",
                                                            labelStyle:
                                                            TextStyle(
                                                                color:
                                                                kLightTextColor,
                                                                fontSize:
                                                                15),
                                                            suffixIcon: (isNumberOk)
                                                                ? Icon(
                                                                Icons
                                                                    .done,
                                                                size:
                                                                25.0,
                                                                color:
                                                                kMainColor)
                                                                : SizedBox
                                                                .shrink(),
                                                            // prefixText: '+91',
                                                            // prefixIcon: Text('+91',style: TextStyle(
                                                            // color: kMainColor,
                                                            // fontSize: 14
                                                            // )
                                                            // ),
                                                            contentPadding:
                                                            const EdgeInsets
                                                                .all(0)),
                                                        onChanged: (value) {
                                                          if (phoneNumberController
                                                              .text
                                                              .length ==
                                                              numberLimit) {
                                                            setState(() {
                                                              isNumberOk = true;
                                                            });
                                                          } else {
                                                            setState(() {
                                                              isNumberOk =
                                                              false;
                                                            });
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 15),
                                                child: (showProgress)
                                                    ? Container(
                                                  alignment:
                                                  Alignment.center,
                                                  height: 50,
                                                  width: 50,
                                                  child:
                                                  CircularProgressIndicator(
                                                    strokeWidth: 1,
                                                    color: kMainColor,
                                                  ),
                                                )
                                                    : MaterialButton(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              30.0))),
                                                  onPressed: () {
                                                    if (!showProgress) {
                                                      setState(() {
                                                        showProgress =
                                                        true;
                                                      });
                                                      if (phoneNumberController
                                                          .text !=
                                                          null &&
                                                          phoneNumberController
                                                              .text
                                                              .length ==
                                                              10) {
                                                        hitLoginUrl(
                                                            '${phoneNumberController.text}',
                                                            '',
                                                            'otp',
                                                            context);
                                                      } else {
                                                        Toast.show(
                                                            locale
                                                                .incorectMobileNumber,
                                                            context,
                                                            gravity: Toast
                                                                .CENTER,
                                                            duration: Toast
                                                                .LENGTH_SHORT);
                                                        setState(() {
                                                          showProgress =
                                                          false;
                                                        });
                                                      }
                                                    }
                                                    // else{
                                                    //   setState(() {
                                                    //     showProgress = false;
                                                    //   });
                                                    // }
                                                  },
                                                  color: kMainColor,
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10),
                                                    child: Text(
                                                      locale.Continuel1,
                                                      style: TextStyle(
                                                          color:
                                                          kWhiteColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .w600,
                                                          letterSpacing:
                                                          0.6),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: kButtonBorderColor
                                                        .withOpacity(0.5),
                                                    borderRadius: BorderRadius
                                                        .only(
                                                        topLeft:
                                                        Radius.circular(
                                                            30.0),
                                                        topRight:
                                                        Radius.circular(
                                                            30.0)),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .stretch,
                                                    children: [
                                                      Align(
                                                        alignment:
                                                        Alignment.center,
                                                        child: Text(
                                                            locale.Continuel2,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                FontWeight
                                                                    .w500,
                                                                color:
                                                                kLightTextColor,
                                                                fontSize: 15)),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                        children: [
                                                          MaterialButton(
                                                            onPressed: () {
                                                              if (!showProgress) {
                                                                setState(() {
                                                                  showProgress =
                                                                  true;
                                                                });
                                                                _handleSignIn(
                                                                    context);
                                                              }
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Image.asset(
                                                                  'assets/google_logo.png',
                                                                  height: 20,
                                                                  width: 20,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                    locale
                                                                        .googlel,
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color: Colors
                                                                            .black54,
                                                                        fontSize:
                                                                        15)),
                                                              ],
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    30)),
                                                            splashColor:
                                                            kWhiteColor,
                                                            color: kWhiteColor,
                                                            highlightColor:
                                                            kMainColor,
                                                            minWidth: 150,
                                                            height: 40,
                                                          ),
                                                          MaterialButton(
                                                            onPressed: () {
                                                              if (!showProgress) {
                                                                setState(() {
                                                                  showProgress =
                                                                  true;
                                                                });
                                                                _login(context);
                                                              }
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Image.asset(
                                                                  'assets/fb.png',
                                                                  height: 20,
                                                                  width: 20,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                    locale
                                                                        .facebookl,
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color: Colors
                                                                            .black54,
                                                                        fontSize:
                                                                        15)),
                                                              ],
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    30)),
                                                            splashColor:
                                                            kWhiteColor,
                                                            color: kWhiteColor,
                                                            highlightColor:
                                                            kMainColor,
                                                            minWidth: 150,
                                                            height: 40,
                                                          )
                                                        ],
                                                      ),
                                                      Align(
                                                        alignment:
                                                        Alignment.center,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            if (!showProgress) {
                                                              Navigator.pushNamed(
                                                                  context,
                                                                  PageRoutes
                                                                      .signUp,
                                                                  arguments: {
                                                                    'user_phone':
                                                                    '${phoneNumberController.text}',
                                                                    'numberlimit':
                                                                    numberLimit,
                                                                    'appinfo':
                                                                    appInfoModeld,
                                                                  });
                                                            }
                                                          },
                                                          behavior:
                                                          HitTestBehavior
                                                              .opaque,
                                                          child: RichText(
                                                            text: TextSpan(
                                                              text:
                                                              locale.login1,
                                                              children: [
                                                                TextSpan(
                                                                    text:
                                                                    ' ${locale.login2}',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color:
                                                                        kMainColor,
                                                                        fontSize:
                                                                        15))
                                                              ],
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  color:
                                                                  kMainTextColor,
                                                                  fontSize: 15),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ));
                                    });
                              },
                              color: kMainColor,
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  locale.signin,
                                  style: TextStyle(
                                      color: kWhiteColor,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 10,
                      height: 10,
                      color: Color(0xfff8f8f8),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(locale.ac6,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: kMainTextColor,
                              letterSpacing: 1.5,
                              fontSize: 13)),
                    ),
                    Divider(
                      thickness: 1.5,
                      height: 1.5,
                      color: kButtonBorderColor.withOpacity(0.5),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Column(children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 0, bottom: 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(PageRoutes.myaddress);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.account_balance_rounded,
                                    size: 17.0, color: kIconColor),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(locale.ac7,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: kMainTextColor,
                                          fontSize: 15)),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    size: 17.0, color: kIconColor)
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10, bottom: 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(PageRoutes.orderscreen);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.bookmark_border,
                                    size: 17.0, color: kIconColor),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(locale.ac8,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: kMainTextColor,
                                          fontSize: 15)),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    size: 17.0, color: kIconColor)
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10, bottom: 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(PageRoutes.favouriteitem);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.favorite, size: 17.0, color: kIconColor),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(locale.ac9,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: kMainTextColor,
                                          fontSize: 15)),
                                ),
                                // Text('',
                                //     style: TextStyle(
                                //         fontWeight: FontWeight.normal,
                                //         color: kMainTextColor,
                                //         fontSize: 15)),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    size: 17.0, color: kIconColor)
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10, bottom: 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(PageRoutes.walletscreen);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.account_balance_wallet_sharp,
                                    size: 17.0, color: kIconColor),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(locale.ac10,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: kMainTextColor,
                                          fontSize: 15)),
                                ),
                                Text("$apCurrecny $walletAmount",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: kMainTextColor,
                                        fontSize: 15)),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    size: 17.0, color: kIconColor)
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10, bottom: 0),
                          child: GestureDetector(
                            onTap: () {
                              if (locEmitterP != null &&
                                  locEmitterP.state != null &&
                                  locEmitterP.state.storeFinderData != null) {
                                Navigator.pushNamed(context, PageRoutes.offerpage,
                                    arguments: {
                                      'store_id':
                                      '${locEmitterP.state.storeFinderData.store_id}',
                                      'cart_id': '--'
                                    });
                              }
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.local_offer,
                                    size: 17.0, color: kIconColor),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(locale.ac11,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: kMainTextColor,
                                          fontSize: 15)),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    size: 17.0, color: kIconColor)
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10, bottom: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(Icons.text_fields, size: 17.0, color: kIconColor),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(locale.ac12,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: kMainTextColor,
                                        fontSize: 15)),
                              ),
                              // Text("English",
                              //     style: TextStyle(
                              //         fontWeight: FontWeight.normal,
                              //         color: kMainTextColor,
                              //         fontSize: 15)),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(Icons.arrow_forward_ios,
                                  size: 17.0, color: kIconColor)
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10, bottom: 10),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, PageRoutes.notification);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.notifications,
                                    size: 17.0, color: kIconColor),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(locale.ac13,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: kMainTextColor,
                                          fontSize: 15)),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    size: 17.0, color: kIconColor)
                                // Switch(
                                //   onChanged: (value) {
                                //     setState(() {
                                //       valueNoti = value;
                                //     });
                                //   },
                                //   value: valueNoti,
                                //   activeColor: kMainColor,
                                //   inactiveThumbColor: kButtonBorderColor,
                                //   inactiveTrackColor: kMainColor.withOpacity(0.5),
                                // )
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                    Divider(
                      thickness: 1.5,
                      height: 1.5,
                      color: kButtonBorderColor.withOpacity(0.5),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      thickness: 10,
                      height: 10,
                      color: Color(0xfff8f8f8),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(locale.ac14,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: kMainTextColor,
                              letterSpacing: 1.5,
                              fontSize: 13)),
                    ),
                    Divider(
                      thickness: 1.5,
                      height: 1.5,
                      color: kButtonBorderColor.withOpacity(0.5),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Column(children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 0, bottom: 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(PageRoutes.support);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.help_center_sharp,
                                    size: 17.0, color: kIconColor),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(locale.ac15,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: kMainTextColor,
                                          fontSize: 15)),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    size: 17.0, color: kIconColor)
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10, bottom: 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(PageRoutes.sharescreen);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.share, size: 17.0, color: kIconColor),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(locale.ac16,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: kMainTextColor,
                                          fontSize: 15)),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    size: 17.0, color: kIconColor)
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10, bottom: 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(PageRoutes.tncPage);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.code_outlined,
                                    size: 17.0, color: kIconColor),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(locale.ac17,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: kMainTextColor,
                                          fontSize: 15)),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    size: 17.0, color: kIconColor)
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10, bottom: 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(PageRoutes.aboutusscreen);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.account_box_outlined,
                                    size: 17.0, color: kIconColor),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(locale.ac18,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: kMainTextColor,
                                          fontSize: 15)),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    size: 17.0, color: kIconColor)
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10, bottom: 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(PageRoutes.settingsAccount);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.settings, size: 17.0, color: kIconColor),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(locale.ac19,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: kMainTextColor,
                                          fontSize: 15)),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    size: 17.0, color: kIconColor)
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                    Divider(
                      thickness: 1.5,
                      height: 1.5,
                      color: kButtonBorderColor.withOpacity(0.5),
                    ),
                    Divider(
                      thickness: 10,
                      height: 10,
                      color: Color(0xfff8f8f8),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          SharedPreferences.getInstance().then((pref) {
                            pref.clear().then((value) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  PageRoutes.signInRoot,
                                      (Route<dynamic> route) => false);
                            });
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.logout, size: 17.0, color: kIconColor),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(isLogin ? locale.logout : locale.login,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: kMainTextColor,
                                      fontSize: 15)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 10,
                      height: 10,
                      color: Color(0xfff8f8f8),
                    ),
                    Container(
                      height: 52,
                    )
                  ])),
        );
      }else{
        return Container();
      }

    });
  }

  void _handleSignIn(BuildContext contextd) async {
    _googleSignIn.isSignedIn().then((value) async {
      print('${value}');

      if (value) {
        if (_googleSignIn.currentUser != null) {
          socialLogin('google', '${_googleSignIn.currentUser.email}', '',
              contextd, _googleSignIn.currentUser.displayName, '');
        } else {
          _googleSignIn.signOut().then((value) async {
            await _googleSignIn.signIn().then((value) {
              var email = value.email;
              var nameg = value.displayName;
              socialLogin('google', '$email', '', contextd, nameg, '');
              // print('${email} - ${value.id}');
            }).catchError((e) {
              setState(() {
                showProgress = false;
              });
            });
          }).catchError((e) {
            setState(() {
              showProgress = false;
            });
          });
        }
      } else {
        try {
          await _googleSignIn.signIn().then((value) {
            var email = value.email;
            var nameg = value.displayName;
            socialLogin('google', '$email', '', contextd, nameg, '');
            // print('${email} - ${value.id}');
          });
        } catch (error) {
          setState(() {
            showProgress = false;
          });
          print(error);
        }
      }
    }).catchError((e) {
      setState(() {
        showProgress = false;
      });
    });
  }

  void socialLogin(dynamic loginType, dynamic email, dynamic fb_id,
      BuildContext contextd, dynamic userNameFb, dynamic fbmailid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (token != null) {
      var client = Client();
      client.post(socialLoginUri, body: {
        'type': '$loginType',
        'user_email': '$email',
        'email_id': '$fbmailid',
        'facebook_id': '$fb_id',
        'device_id': '$token',
      }).then((value) {
        print('${value.statusCode} - ${value.body}');
        var jsData = jsonDecode(value.body);
        SignInModel signInData = SignInModel.fromJson(jsData);
        if ('${signInData.status}' == '1') {
          var userId = int.parse('${signInData.data.id}');
          prefs.setInt("user_id", userId);
          prefs.setString("user_name", '${signInData.data.name}');
          prefs.setString("user_email", '${signInData.data.email}');
          prefs.setString("user_image", '${signInData.data.userImage}');
          prefs.setString("user_phone", '${signInData.data.userPhone}');
          prefs.setString("user_password", '${signInData.data.password}');
          prefs.setString("wallet_credits", '${signInData.data.wallet}');
          prefs.setString("user_city", '${signInData.data.userCity}');
          prefs.setString("user_area", '${signInData.data.userArea}');
          prefs.setString("block", '${signInData.data.block}');
          prefs.setString("app_update", '${signInData.data.appUpdate}');
          prefs.setString("reg_date", '${signInData.data.regDate}');
          prefs.setBool("phoneverifed", true);
          prefs.setBool("islogin", true);
          prefs.setString("refferal_code", '${signInData.data.referralCode}');
          prefs.setString("reward", '${signInData.data.rewards}');
          prefs.setString("accesstoken", '${signInData.token}');
          Navigator.pushNamedAndRemoveUntil(
              context, PageRoutes.homePage, (route) => false);
        } else {
          if (loginType == 'google') {
            Navigator.pushNamed(contextd, PageRoutes.signUp, arguments: {
              'user_email': '${email}',
              'u_name': '${userNameFb}',
              'numberlimit': numberLimit,
              'appinfo': appInfoModeld,
            });
          } else {
            Navigator.pushNamed(contextd, PageRoutes.signUp, arguments: {
              'fb_id': '${fb_id}',
              'user_email': '${fbmailid}',
              'u_name': '${userNameFb}',
              'numberlimit': numberLimit,
              'appinfo': appInfoModeld,
            });
          }
        }
        setState(() {
          showProgress = false;
        });
      }).catchError((e) {
        setState(() {
          showProgress = false;
        });
        print(e);
      });
    } else {
      if (count == 0) {
        setState(() {
          count = 1;
        });
        messaging.getToken().then((value) {
          setState(() {
            token = value;
            socialLogin(
                loginType, email, fb_id, contextd, userNameFb, fbmailid);
          });
        }).catchError((e) {
          setState(() {
            showProgress = false;
          });
        });
      } else {
        setState(() {
          showProgress = false;
        });
      }
    }
  }

  void _login(BuildContext contextt) async {
    await facebookSignIn.logIn(['email']).then((result) {
      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          final FacebookAccessToken accessToken = result.accessToken;
          hitgraphResponse(accessToken, contextt);
          break;
        case FacebookLoginStatus.cancelledByUser:
          setState(() {
            showProgress = false;
          });
          break;
        case FacebookLoginStatus.error:
          setState(() {
            showProgress = false;
          });
          break;
      }
    }).catchError((e) {
      setState(() {
        showProgress = false;
      });
      print(e);
    });
  }

  void hitgraphResponse(
      FacebookAccessToken accessToken, BuildContext contextt) async {
    var http = Client();
    http
        .get(Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${accessToken.token}'))
        .then((graphResponse) {
      final profile = jsonDecode(graphResponse.body);
      print(profile);
      print(profile['first_name']);
      print(profile['last_name']);
      print(profile['email']);
      print(profile['id']);
      socialLogin(
          'facebook',
          '',
          '${profile['id']}',
          contextt,
          profile['name'],
          (profile['email'] != null &&
                  profile['email'].toString().length > 0 &&
                  '${profile['email']}'.toUpperCase() != 'NULL')
              ? profile['email']
              : '');
    }).catchError((e) {
      print(e);
      setState(() {
        showProgress = false;
      });
    });
  }

  void hitLoginUrl(dynamic user_phone, dynamic user_password, dynamic logintype,
      BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (token != null) {
      var http = Client();
      http.post(loginUri, body: {
        'user_phone': '$user_phone',
        'user_password': '$user_password',
        'device_id': '$token',
        'logintype': '$logintype',
      }).then((value) {
        print('sign - ${value.body}');
        if (value.statusCode == 200) {
          var jsData = jsonDecode(value.body);
          SignInModel signInData = SignInModel.fromJson(jsData);
          print('${signInData.toString()}');
          if ('${signInData.status}' == '0') {
            Toast.show(signInData.message, context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
            Navigator.pushNamed(context, PageRoutes.signUp, arguments: {
              'user_phone': '${user_phone}',
              'numberlimit': numberLimit,
              'appinfo': appInfoModeld,
            });
          } else if ('${signInData.status}' == '1') {
            var userId = int.parse('${signInData.data.id}');
            prefs.setInt("user_id", userId);
            prefs.setString("user_name", '${signInData.data.name}');
            prefs.setString("user_email", '${signInData.data.email}');
            prefs.setString("user_image", '${signInData.data.userImage}');
            prefs.setString("user_phone", '${signInData.data.userPhone}');
            prefs.setString("user_password", '${signInData.data.password}');
            prefs.setString("wallet_credits", '${signInData.data.wallet}');
            prefs.setString("user_city", '${signInData.data.userCity}');
            prefs.setString("user_area", '${signInData.data.userArea}');
            prefs.setString("block", '${signInData.data.block}');
            prefs.setString("app_update", '${signInData.data.appUpdate}');
            prefs.setString("reg_date", '${signInData.data.regDate}');
            prefs.setBool("phoneverifed", true);
            prefs.setBool("islogin", true);
            prefs.setString("refferal_code", '${signInData.data.referralCode}');
            prefs.setString("reward", '${signInData.data.rewards}');
            prefs.setString("accesstoken", '${signInData.token}');
            Navigator.pushNamedAndRemoveUntil(
                context, PageRoutes.homePage, (route) => false);
            // Navigator.popAndPushNamed(context, PageRoutes.home);
          } else if ('${signInData.status}' == '2') {
            Navigator.pushNamed(context, PageRoutes.verification, arguments: {
              'token': '${token}',
              'user_phone': '${user_phone}',
              'firebase': '${appInfoModeld.firebase}',
              'country_code': '${appInfoModeld.countryCode}',
              'activity': 'login',
            });
          } else if ('${signInData.status}' == '3') {
            Navigator.pushNamed(context, PageRoutes.verification, arguments: {
              'token': '${token}',
              'user_phone': '${user_phone}',
              'firebase': '${appInfoModeld.firebase}',
              'country_code': '${appInfoModeld.countryCode}',
              'activity': 'login',
            });
          } else {
            Toast.show(signInData.message, context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
          }
        }
        setState(() {
          showProgress = false;
        });
      }).catchError((e) {
        setState(() {
          showProgress = false;
        });
        print(e);
      });
    } else {
      if (count == 0) {
        setState(() {
          count = 1;
        });
        messaging.getToken().then((value) {
          setState(() {
            token = value;
            hitLoginUrl(user_phone, user_password, logintype, context);
          });
        }).catchError((e) {
          setState(() {
            showProgress = false;
          });
        });
      } else {
        setState(() {
          showProgress = false;
        });
      }
    }
  }
}
