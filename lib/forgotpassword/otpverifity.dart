import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:grocery/Components/custom_button.dart';
import 'package:grocery/Components/entry_field.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/appinfo.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ResetOtpVerify extends StatefulWidget {
  // final VoidCallback onVerificationDone;
  //
  // ResetOtpVerify(this.onVerificationDone);

  @override
  _ResetOtpVerifyState createState() => _ResetOtpVerifyState();
}

class _ResetOtpVerifyState extends State<ResetOtpVerify> {
  final TextEditingController _controller = TextEditingController();
  FirebaseMessaging messaging;
  bool isDialogShowing = false;
  dynamic token = '';
  var showDialogBox = false;
  var enteredFirst = false;
  var verificaitonPin = "";
  FirebaseAuth firebaseAuth;
  var actualCode;
  AuthCredential _authCredential;
  bool firebaseOtp = false;
  dynamic user_phone;
  dynamic referralcode;
  dynamic country_code;
  dynamic activity;
  AppInfoModel appInfo;

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
          hitFirebaseSuccessLoginStatus('success', context);
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

  // initilizedFirebaseAuth(userNumber) async {
  //   firecount = 1;
  //   Firebase.initializeApp();
  //   firebaseAuth = await FirebaseAuth.instance;
  //   PhoneCodeSent codeSent =
  //       (String verificationId, [int forceResendingToken]) async {
  //     setState(() {
  //       if (showDialogBox != null && showDialogBox) {
  //         showDialogBox = false;
  //       }
  //       actualCode = verificationId;
  //     });
  //     print(actualCode);
  //     print('Code sent');
  //   };
  //   final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
  //       (String verificationId) {
  //     // this.actualCode = verificationId;
  //     print(verificationId);
  //     print('Auto retrieval time out');
  //   };
  //   final PhoneVerificationFailed verificationFailed =
  //       (FirebaseAuthException authException) {
  //     print('${authException.message}');
  //     // setState(() {
  //     //
  //     // });
  //     if (authException.message.contains('not authorized')) {
  //     } else if (authException.message.contains('Network')) {
  //     } else {}
  //   };
  //   final PhoneVerificationCompleted verificationCompleted =
  //       (AuthCredential auth) {
  //     print('${auth.providerId}');
  //     // setState(() {});
  //   };
  //   firebaseAuth.verifyPhoneNumber(
  //       phoneNumber: userNumber,
  //       timeout: Duration(seconds: 60),
  //       verificationCompleted: verificationCompleted,
  //       verificationFailed: verificationFailed,
  //       codeSent: codeSent,
  //       codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  // }
  //
  // void _signInWithPhoneNumber(String smsCode, BuildContext context) async {
  //   print(actualCode);
  //   print(smsCode);
  //   _authCredential = await PhoneAuthProvider.credential(
  //       verificationId: actualCode, smsCode: smsCode);
  //   firebaseAuth.signInWithCredential(_authCredential).then((value) {
  //     User uss = value.user;
  //     if (uss != null) {
  //       print('${uss.phoneNumber}\n${uss.providerData.toList().toString()}');
  //       hitFirebaseSuccessLoginStatus('success', context);
  //     }
  //     setState(() {
  //       showDialogBox = false;
  //     });
  //   }).catchError((e) {
  //     print(e);
  //     setState(() {
  //       showDialogBox = false;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    if (!enteredFirst) {
      final Map<String, Object> dataRecevid =
          ModalRoute.of(context).settings.arguments;
      setState(() {
        enteredFirst = true;
        user_phone = dataRecevid['number'];
        appInfo = dataRecevid['appinfo'];
        firebaseOtp =
            '${appInfo.firebase}'.toUpperCase() == 'ON' ? true : false;
        country_code = '${appInfo.countryCode}';
      });
      hitAsynInit();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left_sharp,
            size: 30,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          locale.verification,
          style: TextStyle(color: kMainTextColor),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 48),
                  child: Text(
                    locale.pleaseEnterVerificationCodeSentGivenNumber,
                    style: Theme.of(context).textTheme.headline3,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 28.0, left: 18, right: 18, bottom: 4),
                  child: Text(
                    locale.enterVerificationCode,
                    style: Theme.of(context).textTheme.headline3.copyWith(
                        fontSize: 22,
                        color: Theme.of(context).backgroundColor,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                EntryField(
                  controller: _controller,
                  hint: locale.enterVerificationCode,
                  maxLines: 1,
                  maxLength: firebaseOtp ? 6 : 4,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10.0),
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      if (!showDialogBox) {
                        if (firebaseOtp) {
                          initialAuth('+$country_code$user_phone');
                        } else {
                          resendOtpM();
                        }
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      'RESEND OTP',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: kMainColor),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
            ],
          ),
              )),
          (showDialogBox)
              ? Container(
                height: 60,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: Align(
                  widthFactor: 40,
                  heightFactor: 40,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
              )
              : CustomButton(
                onTap: () {
                  // widget.onVerificationDone();
                  if (!showDialogBox) {
                    setState(() {
                      showDialogBox = true;
                    });
                    verificaitonPin = _controller.text;
                    if (firebaseOtp) {
                      hitSignIn(verificaitonPin, context);
                    } else {
                      hitService(verificaitonPin, context);
                    }
                  }
                },
              )
        ],
      ),
    );
  }

  void resendOtpM() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = resendOtpUri;
    await http.post(url, body: {
      'user_phone': '${user_phone}',
    }).then((response) {
      print('Response Body: - ${response.body}');
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
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = verifyOtpPPhoneUri;
    await http.post(url, body: {
      'user_phone': '${user_phone}',
      'otp': verificaitonPin,
    }).then((value) {
      print('Response Body: - ${value.body}');
      if (value.statusCode == 200) {
        var jv = jsonDecode(value.body);
        if ('${jv['status']}' == '1') {
          Navigator.popAndPushNamed(context, PageRoutes.restpassword3, arguments: {
            'appinfo': appInfo,
            'number': user_phone,
          });
        }
        Toast.show(jv['message'], context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      }
      setState(() {
        showDialogBox = false;
      });
    }).catchError((e) {
      print(e);
      setState(() {
        showDialogBox = false;
      });
    });
  }

  void hitFirebaseSuccessLoginStatus(
      String status, BuildContext context) async {
    var url = verifyOtpPFirebaseUri;
    await http.post(url, body: {
      'user_phone': '${user_phone}',
      'status': status,
    }).then((value) {
      print('Response Body: - ${value.body}');
      if (value.statusCode == 200) {
        var jv = jsonDecode(value.body);
        if ('${jv['status']}' == '1') {
          Navigator.popAndPushNamed(context, PageRoutes.restpassword3, arguments: {
            'appinfo': appInfo,
            'number': user_phone,
          });
        }
        Toast.show(jv['message'], context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      }
      setState(() {
        showDialogBox = false;
      });
    }).catchError((e) {
      print(e);
      setState(() {
        showDialogBox = false;
      });
    });
  }
}
