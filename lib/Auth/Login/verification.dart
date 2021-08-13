import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/signinmodel.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerificationPage extends StatefulWidget {

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final TextEditingController _controller = TextEditingController();
  FirebaseMessaging messaging;
  bool isDialogShowing = false;
  dynamic token = '';
  var showDialogBox = false;
  var verificaitonPin = "";
  String actualCode;
  bool firebaseOtp = false;
  dynamic user_phone;
  String referralcode = '';
  dynamic country_code;
  dynamic activity;

  int firecount = 0;

  int count = 0;

  @override
  void initState() {
    super.initState();
  }

  void hitAsynInit() async{
    await Firebase.initializeApp();
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      token = value;
      if (firebaseOtp) {
        initialAuth('+$country_code$user_phone');
      }else{
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e){
      setState(() {
        showDialogBox = false;
      });
      print(e);
    });
  }

  initialAuth(String phoneNumberd) async{
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      phoneNumber:phoneNumberd,
      verificationCompleted: (PhoneAuthCredential credential) {
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
        setState(() {
          showDialogBox = false;
        });
      },
      codeSent: (String verificationId, int resendToken) {
        setState(() {
          showDialogBox = false;
          actualCode = verificationId;
        });
        print('code sent');
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  hitSignIn(String smsCode, BuildContext context){
    FirebaseAuth auth = FirebaseAuth.instance;
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId:actualCode, smsCode:smsCode);
    auth.signInWithCredential(credential).then((value){
      if(value!=null){
        User userd = value.user;
        if(userd!=null){
          if (activity == 'login') {
            hitFirebaseSuccessLoginStatus('success',context);
          } else {
            hitFirebaseSuccessStatus('success',context);
          }
        }else{
          setState(() {
            showDialogBox = false;
          });
        }
      }else{
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e){
      print('user null + $e');
      setState(() {
        showDialogBox = false;
      });
    });
  }



  @override
  void dispose() {
    // firebaseAuth.signOut();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom!=0;
    var locale = AppLocalizations.of(context);
    if (firecount == 0) {
      final Map<String, Object> dataRecevid =
          ModalRoute.of(context).settings.arguments;
      setState(() {
        firecount = 1;
        showDialogBox = true;
        token = dataRecevid['token'];
        user_phone = dataRecevid['user_phone'];
        firebaseOtp = ('${dataRecevid['firebase']}' == 'on' ||
            '${dataRecevid['firebase']}' == 'ON' ||
            '${dataRecevid['firebase']}' == 'On')
            ? true
            : false;
        referralcode = dataRecevid['referralcode'];
        country_code = dataRecevid['country_code'];
        activity = dataRecevid['activity'];
      });
      hitAsynInit();
    }

    return SafeArea(
      top: true,
      bottom: true,
      left: false,
      right: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            locale.verification,
            style: TextStyle(color: kMainTextColor),
          ),
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 48),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: '${locale.veri2}\n',
                        style: TextStyle(fontSize: 18,fontWeight: FontWeight.w800,color: kMainTextColor,letterSpacing: 1.2),
                        children: [
                          TextSpan(
                              text: '${locale.veri3} +$country_code$user_phone',
                              style: TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: kLightTextColor,letterSpacing: 1.1),
                          )
                        ]
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //       top: 28.0, left: 18, right: 18, bottom: 4),
                  //   child: Text(
                  //     locale.enterVerificationCode,
                  //     style: Theme.of(context).textTheme.headline3.copyWith(
                  //         fontSize: 22,
                  //         color: Theme.of(context).backgroundColor,
                  //         fontWeight: FontWeight.w500),
                  //   ),
                  // ),
                  // EntryField(
                  //   controller: _controller,
                  //   hint: locale.enterVerificationCode,
                  //   maxLines: 1,
                  //   maxLength: firebaseOtp ? 6 : 4,
                  //   keyboardType: TextInputType.number,
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PinCodeTextField(
                      autofocus: true,
                      controller: _controller,
                      hideCharacter: false,
                      highlight: false,
                      highlightColor: kButtonBorderColor.withOpacity(0.5),
                      defaultBorderColor: kButtonBorderColor.withOpacity(0.5),
                      hasTextBorderColor: kButtonBorderColor.withOpacity(0.5),
                      // highlightPinBoxColor: Colors.orange,
                      maxLength: firebaseOtp?6:4,
                      onDone: (text) {
                        verificaitonPin = text;
                      },
                      pinBoxWidth: 45,
                      pinBoxHeight: 50,
                      hasUnderline: false,
                      wrapAlignment: WrapAlignment.spaceAround,
                      pinBoxDecoration: ProvidedPinBoxDecoration.defaultPinBoxDecoration,
                      pinTextStyle: TextStyle(fontSize: 22.0),
                      pinBoxRadius: 5,
                      pinTextAnimatedSwitcherTransition:
                      ProvidedPinBoxTextAnimation.scalingTransition,
                      maskCharacter: '',
//                    pinBoxColor: Colors.green[100],
                      pinTextAnimatedSwitcherDuration:
                      Duration(milliseconds: 300),
//                    highlightAnimation: true,
                      highlightAnimationBeginColor: kButtonBorderColor.withOpacity(0.5),
                      highlightAnimationEndColor: kButtonBorderColor.withOpacity(0.5),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Align(alignment: Alignment.center,child: GestureDetector(
                    onTap: (){
                      if(!showDialogBox){
                        setState(() {
                          showDialogBox = true;
                        });
                        if (firebaseOtp) {
                          initialAuth('+$country_code$user_phone');
                        } else {
                          resendOtpM();
                        }
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          text: '${locale.veri4} ',
                          style: TextStyle(fontSize: 13,fontWeight: FontWeight.w400,color: kLightTextColor),
                          children: [
                            TextSpan(
                              text: locale.resend+'!',
                              style: TextStyle(fontSize: 13,fontWeight: FontWeight.w600,color: kMainColor,letterSpacing: 1.1),
                            )
                          ]
                      ),
                    ),),
                  ),
                  // SizedBox(height: 10.0),
                  // Visibility(
                  //     visible: showDialogBox,
                  //     child: Align(
                  //       alignment: Alignment.center,
                  //       child: CircularProgressIndicator(),
                  //     )),
                ],
              ),
            )),
            Visibility(
              visible: !isKeyboardOpen,
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: showDialogBox?Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(strokeWidth: 2,color: kMainColor,),
                  ):MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30.0))),
                    onPressed: () {
                      if (!showDialogBox) {
                        setState(() {
                          showDialogBox = true;
                        });
                        verificaitonPin = _controller.text;
                        if (firebaseOtp) {
                          hitSignIn(verificaitonPin, context);
                        } else {
                          if (activity == 'login') {
                            hitLoginService(verificaitonPin, context);
                          } else {
                            hitService(verificaitonPin, context);
                          }
                        }
                      }
                    },
                    color: kMainColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        locale.veri1,
                        style: TextStyle(
                            color: kWhiteColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Align(alignment: Alignment.center,child: GestureDetector(
                  onTap: (){
                    Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.signInRoot, (Route<dynamic> route) => false);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: '${locale.veri5} ',
                        style: TextStyle(fontSize: 13,fontWeight: FontWeight.w400,color: kLightTextColor),
                        children: [
                          TextSpan(
                            text: locale.veri6,
                            style: TextStyle(fontSize: 13,fontWeight: FontWeight.w600,color: kMainColor,letterSpacing: 1.1),
                          )
                        ]
                    ),
                  ),),),
                SizedBox(height: 20.0),
              ],
            ))
          ],
        ),
      ),
    );
  }

  void resendOtpM() async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = resendOtpUri;
    await http.post(url, body: {
      'user_phone': '${user_phone}',
    }).then((response) {
      print('Response Body..: - ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          showDialogBox = false;
        });
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        showDialogBox = false;
      });
    });

  }

  void hitService(String verificaitonPin, BuildContext context) async {
    if (token != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var url = verifyPhoneRefferalUri;
      await http.post(url, body: {
        'user_phone': '${user_phone}',
        'otp': verificaitonPin,
        'device_id':'$token',
        //'referral_code': (referralcode!=null && referralcode.length>0)?'${referralcode}':''
      }).then((response) {
        print('Response Body1: - ${response.body}');
        if (response.statusCode == 200) {
          print('Response Body2: - ${response.body}');
          var jsonData = jsonDecode(response.body);
          SignInModel signInData = SignInModel.fromJson(jsonData);
          if(signInData.status == "1" || signInData.status==1){
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
            Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.homePage, (Route<dynamic> route) => false);
          }
          setState(() {
            showDialogBox = false;
          });
        } else {
          setState(() {
            showDialogBox = false;
          });
        }
      }).catchError((e) {
        print(e);
        setState(() {
          showDialogBox = false;
        });
      });
    }
    else {
      if (count == 0) {
        setState(() {
          count = 1;
        });
        messaging.getToken().then((value) {
          setState(() {
            token = value;
            hitService(verificaitonPin,context);
          });
        }).catchError((e){
          setState(() {
            showDialogBox = false;
          });
        });
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }
  }

  void hitLoginService(String verificaitonPin, BuildContext context) async {
    if (token != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var url = loginVerifyPhoneUri;
      await http.post(url, body: {
        'user_phone': '${user_phone}',
        'device_id':'$token',
        'otp': verificaitonPin,
      }).then((response) {
        print('Response BodyL1: - ${response.body}');
        if (response.statusCode == 200) {
          print('Response BodyL2: - ${response.body}');
          var jsonData = jsonDecode(response.body);
          SignInModel signInData = SignInModel.fromJson(jsonData);
          if(signInData.status == "1" || signInData.status==1){
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
            Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.homePage, (Route<dynamic> route) => false);
          }
          setState(() {
            showDialogBox = false;
          });
        } else {
          setState(() {
            showDialogBox = false;
          });
        }
      }).catchError((e) {
        print(e);
        setState(() {
          showDialogBox = false;
        });
      });
    }
    else {
      if (count == 0) {
        setState(() {
          count = 1;
        });
        messaging.getToken().then((value) {
          setState(() {
            token = value;
            hitLoginService(verificaitonPin,context);
          });
        }).catchError((e){
          setState(() {
            showDialogBox = false;
          });
        });
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }

  }

  void hitFirebaseSuccessStatus(String status, BuildContext context) async {
    if (token != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var url = verifyViaFirebaseUri;
      await http.post(url, body: {
        'user_phone': '${user_phone}',
        'status': status,
        'device_id':'$token',
        'referral_code': (referralcode!=null && referralcode.length>0)?'${referralcode}':''
      }).then((response) {
        print('Response Body11: - ${response.body}');
        if (response.statusCode == 200) {
          print('Response Body22: - ${response.body}');
          var jsonData = jsonDecode(response.body);
          SignInModel signInData = SignInModel.fromJson(jsonData);
          if(signInData.status == "1" || signInData.status==1){
            var userId = int.parse('${signInData.data.id}');
            prefs.setInt("id", userId);
            prefs.setString("name", '${signInData.data.name}');
            prefs.setString("email", '${signInData.data.email}');
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
            Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.homePage, (Route<dynamic> route) => false);
          }
          setState(() {
            showDialogBox = false;
          });
        } else {
          setState(() {
            showDialogBox = false;
          });
        }
      }).catchError((e) {
        print(e);
        setState(() {
          showDialogBox = false;
        });
      });
    }
    else {
      if (count == 0) {
        setState(() {
          count = 1;
        });
        messaging.getToken().then((value) {
          setState(() {
            token = value;
            hitFirebaseSuccessStatus(status,context);
          });
        }).catchError((e){
          setState(() {
            showDialogBox = false;
          });
        });
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }

  }

  void hitFirebaseSuccessLoginStatus(
      String status, BuildContext context) async {
    if (token != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var url = loginVerifyViaFirebaseUri;
      await http.post(url, body: {
        'user_phone': '${user_phone}',
        'device_id':'$token',
        'status': status,
      }).then((response) {
        print('Response Body12: - ${response.body}');
        if (response.statusCode == 200) {
          print('Response Body12: - ${response.body}');
          var jsonData = jsonDecode(response.body);
          SignInModel signInData = SignInModel.fromJson(jsonData);
          if('${signInData.status}' == '1'){
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
            Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.homePage, (Route<dynamic> route) => false);
          }
          setState(() {
            showDialogBox = false;
          });
        } else {
          setState(() {
            showDialogBox = false;
          });
        }
      }).catchError((e) {
        setState(() {
          showDialogBox = false;
        });
      });
    }
    else {
      if (count == 0) {
        setState(() {
          count = 1;
        });
        messaging.getToken().then((value) {
          setState(() {
            token = value;
            hitFirebaseSuccessLoginStatus(status,context);
          });
        }).catchError((e){
          setState(() {
            showDialogBox = false;
          });
        });
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }

  }
}
