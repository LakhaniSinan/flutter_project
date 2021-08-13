import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:grocery/Components/custom_button.dart';
import 'package:grocery/Components/entry_field.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/appinfo.dart';
import 'package:grocery/beanmodel/citybean.dart';
import 'package:grocery/beanmodel/signinmodel.dart';
import 'package:grocery/beanmodel/statebean.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool showDialogBox = false;
  bool isEnteredFirst = false;
  int numberLimit = 10;
  dynamic mobileNumber;
  dynamic u_name;
  dynamic emailId;
  dynamic fb_id;
  var userFullNameC = TextEditingController();
  var emailAddressC = TextEditingController();
  var phoneNumberC = TextEditingController();
  var passwordC = TextEditingController();
  var referralC = TextEditingController();
  String selectCity = 'Select city';
  String selectSocity = 'Select socity/area';
  List<CityDataBean> cityList = [];
  List<StateDataBean> socityList = [];
  CityDataBean cityData;
  StateDataBean socityData;
  AppInfoModel appinfo;
  FirebaseMessaging messaging;
  dynamic token;
  File _image;
  final picker = ImagePicker();
  int count = 0;

  @override
  void initState() {
    super.initState();
    try{
      messaging = FirebaseMessaging.instance;
      messaging.getToken().then((value) {
        token = value;
      });
    }catch(e){

    }
    hitCityData();
  }

  void hitCityData() {
    setState(() {
      showDialogBox = true;
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
            hitSocityList(cityList[0].city_name, AppLocalizations.of(context));
          } else {
            selectCity = 'Select your city';
            cityData = null;
            setState(() {
              showDialogBox = false;
            });
          }
        } else {
          setState(() {
            selectCity = 'Select your city';
            cityData = null;
            showDialogBox = false;
          });
        }
      } else {
        setState(() {
          selectCity = 'Select your city';
          cityData = null;
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      setState(() {
        selectCity = 'Select your city';
        cityData = null;
        showDialogBox = false;
      });
      print(e);
    });
  }

  void hitSocityList(dynamic cityName, locale) {
    var http = Client();
    http.post(societyUri, body: {'city_name': '$cityName'}).then((value) {
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
                : 'Select your socity/area';
            socityData = null;
          });
        }
      }
      setState(() {
        showDialogBox = false;
      });
    }).catchError((e) {
      setState(() {
        selectSocity =
            (locale != null) ? locale.selectsocity2 : 'Select your socity/area';
        socityData = null;
        showDialogBox = false;
      });
      print(e);
    });
  }

  _imgFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  _imgFromGallery() async {
    picker.getImage(source: ImageSource.gallery).then((pickedFile) {
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    }).catchError((e) => print(e));
  }

  void _showPicker(context, AppLocalizations locale) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text(locale.photolibrary),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text(locale.camera),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    final Map<String, Object> rcvdData =
        ModalRoute.of(context).settings.arguments;
    if(!isEnteredFirst){
      isEnteredFirst = true;
      mobileNumber =
      rcvdData.containsKey('user_phone') ? rcvdData['user_phone'] : '';
      if (rcvdData.containsKey('user_phone')) {
        phoneNumberC.text = '${mobileNumber}';
      }
      u_name = rcvdData.containsKey('u_name') ? rcvdData['u_name'] : '';
      if (rcvdData.containsKey('u_name')) {
        userFullNameC.text = '${u_name}';
      }
      emailId =
      rcvdData.containsKey('user_email') ? rcvdData['user_email'] : '';
      fb_id = rcvdData.containsKey('fb_id') ? rcvdData['fb_id'] : '';
      if (rcvdData.containsKey('user_email')) {
        emailAddressC.text = '${emailId}';
      }
      appinfo = rcvdData['appinfo'];
      numberLimit = rcvdData.containsKey('user_phone')
          ? (mobileNumber.toString().length>0)?mobileNumber.toString().length:int.parse('${rcvdData['numberlimit']}')
          : numberLimit;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale.register,
          style: TextStyle(color: kMainTextColor),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Divider(
                      thickness: 2.5,
                      color: Colors.transparent,
                    ),
                    SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _showPicker(context,locale);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 90,
                          decoration: BoxDecoration(
                              border: Border.all(color: kMainColor),
                              borderRadius: BorderRadius.circular(5.0)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image(
                                image: (_image != null)
                                    ? FileImage(_image)
                                    : AssetImage('assets/icon.png'),
                                height: 80,
                                width: 80,
                              ),
                              SizedBox(
                                width: 20.0,
                              ),
                              Text(
                                locale.uploadpictext,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(
                                        color: kMainTextColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    EntryField(
                      label: locale.fullName,
                      hint: locale.enterFullName,
                      controller: userFullNameC,
                      readOnly: showDialogBox,
                    ),
                    EntryField(
                      label: locale.emailAddress,
                      hint: locale.enterEmailAddress,
                      controller: emailAddressC,
                      readOnly: showDialogBox,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 1),
                      child: Text(
                        locale.selectycity1,
                        style: Theme.of(context).textTheme.headline6.copyWith(
                            color: kMainTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 21.7),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: DropdownButton<CityDataBean>(
                        hint: Text(
                          selectCity,
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                        ),
                        isExpanded: true,
                        iconEnabledColor: kMainTextColor,
                        iconDisabledColor: kMainTextColor,
                        iconSize: 30,
                        items: cityList.map((value) {
                          return DropdownMenuItem<CityDataBean>(
                            value: value,
                            child: Text(value.city_name,
                                overflow: TextOverflow.clip),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectCity = value.city_name;
                            cityData = value;
                            socityList.clear();
                            selectSocity = locale.selectsocity2;
                            socityData = null;
                            showDialogBox = true;
                          });
                          hitSocityList(value.city_name, locale);
                          print(value);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 1),
                      child: Text(
                        locale.selectsocity1,
                        style: Theme.of(context).textTheme.headline6.copyWith(
                            color: kMainTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 21.7),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: DropdownButton<StateDataBean>(
                        hint: Text(
                          selectSocity,
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                        ),
                        iconEnabledColor: kMainTextColor,
                        iconDisabledColor: kMainTextColor,
                        iconSize: 30,
                        isExpanded: true,
                        items: socityList.map((value) {
                          return DropdownMenuItem<StateDataBean>(
                            value: value,
                            child: Text(value.society_name,
                                overflow: TextOverflow.clip),
                          );
                        }).toList(),
                        onChanged: (valued) {
                          setState(() {
                            selectSocity = valued.society_name;
                            socityData = valued;
                          });
                        },
                      ),
                    ),
                    // EntryField(
                    //   label: locale.selectycity1,
                    //   hint: locale.selectycity2,
                    //   suffixIcon: Icons.arrow_drop_down,
                    // ),
                    // EntryField(
                    //   label: locale.selectsocity1,
                    //   hint: locale.selectsocity2,
                    //   suffixIcon: Icons.arrow_drop_down,
                    // ),
                    EntryField(
                      label: locale.phoneNumber,
                      hint: locale.enterPhoneNumber,
                      maxLines: 1,
                      maxLength: numberLimit,
                      readOnly:
                          (mobileNumber.toString().length == (int.parse('${appinfo.countryCode}')+numberLimit)) ? true : false,
                      keyboardType: TextInputType.number,
                      controller: phoneNumberC,
                    ),
                    EntryField(
                      label: locale.password1,
                      hint: locale.password2,
                      maxLines: 1,
                      readOnly: showDialogBox,
                      keyboardType: TextInputType.visiblePassword,
                      controller: passwordC,
                    ),
                    EntryField(
                      label: locale.referalcode1,
                      hint: locale.referalcode2,
                      maxLines: 1,
                      readOnly: showDialogBox,
                      keyboardType: TextInputType.text,
                      controller: referralC,
                    ),
                  ],
                ),
              ),
            ),
            (showDialogBox)?Container(
              height: 52,
              child: Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            ):CustomButton(onTap: () {
              if (!showDialogBox) {
                setState(() {
                  showDialogBox = true;
                });
                // int numLength = (mobileNumber!=null && mobileNumber.toString().length>0)?numberLimit:10;
                if (userFullNameC.text != null) {
                  if (emailAddressC.text != null &&
                      emailValidator(emailAddressC.text)) {
                    if (passwordC.text != null && passwordC.text.length > 6) {
                      if (phoneNumberC.text != null &&
                          phoneNumberC.text.length == numberLimit) {
                        hitSignUpUrl(
                            userFullNameC.text,
                            emailAddressC.text,
                            '${phoneNumberC.text}',
                            passwordC.text,
                            cityData.city_id,
                            socityData.society_id,
                            fb_id,
                            referralC.text,
                            context);
                      } else {
                        setState(() {
                          showDialogBox = false;
                        });
                        Toast.show(
                            '${locale.incorectMobileNumber}${numberLimit}',
                            context,
                            gravity: Toast.CENTER,
                            duration: Toast.LENGTH_SHORT);
                      }
                    } else {
                      setState(() {
                        showDialogBox = false;
                      });
                      Toast.show(locale.incorectPassword, context,
                          gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                    }
                  } else {
                    setState(() {
                      showDialogBox = false;
                    });
                    Toast.show(locale.incorectEmail, context,
                        gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                  }
                } else {
                  setState(() {
                    showDialogBox = false;
                  });
                  Toast.show(locale.incorectUserName, context,
                      gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                }
              }
            })
          ],
        ),
      ),
    );
  }

  // SizedBox(height: 10.0),
  // Visibility(
  // visible: showDialogBox,
  // child: ),

  bool emailValidator(email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  void hitSignUpUrl(
      dynamic user_name,
      dynamic user_email,
      dynamic user_phone,
      dynamic user_password,
      dynamic user_city,
      dynamic user_area,
      dynamic fb_id,
      dynamic referral_code,
      BuildContext context) {
    var requestMulti = http.MultipartRequest('POST', signupUri);
    requestMulti.fields["name"] = '${user_name}';
    requestMulti.fields["email"] = '${user_email}';
    requestMulti.fields["user_phone"] = '${user_phone}';
    requestMulti.fields["user_password"] = '${user_password}';
    requestMulti.fields["user_city"] = '${user_city}';
    requestMulti.fields["user_area"] = '${user_area}';
    requestMulti.fields["device_id"] = '${token}';
    requestMulti.fields["fb_id"] = '${fb_id}';
    requestMulti.fields["referral_code"] = '${referral_code}';
  http.MultipartFile.fromPath("image", _image.path,).then((pic) =>
        requestMulti.files.add(pic),
    );
    if (token != null) {
      if (_image != null) {
        String fid = _image.path.split('/').last;
        if(fid!=null && fid.length>0){
          http.MultipartFile.fromPath('user_image', _image.path, filename: fid)
              .then((pic) {
            requestMulti.files.add(pic);
            requestMulti.send().then((values) {
              values.stream.toBytes().then((value) {
                var responseString = String.fromCharCodes(value);
                print("response : $responseString");
                var jsonData = jsonDecode(responseString);
               print('jsonData : ${jsonData.toString()}');
                SignInModel signInData = SignInModel.fromJson(jsonData);
                print('signin : $signInData');
                if (signInData.status == "0" || signInData.status == 0) {
                  Toast.show(signInData.message, context,
                      duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                } else if (signInData.status == "1" || signInData.status == 1) {
                  Navigator.pushNamed(context, PageRoutes.verification,
                      arguments: {
                        'token': '${token}',
                        'user_phone': '${user_phone}',
                        'firebase': '${appinfo.firebase}',
                        'country_code': '${appinfo.countryCode}',
                        'referralcode': '${referral_code}',
                        'activity': 'signup',
                      });
                } else if (signInData.status == "2" || signInData.status == 2) {
                  Navigator.pushNamed(context, PageRoutes.verification,
                      arguments: {
                        'token': '${token}',
                        'user_phone': '${user_phone}',
                        'firebase': '${appinfo.firebase}',
                        'country_code': '${appinfo.countryCode}',
                        'referralcode': '${referral_code}',
                        'activity': 'signup',
                      });
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
            }).catchError((e) {
              setState(() {
                showDialogBox = false;
              });
              print(e);
            });
          }).catchError((e) {
            setState(() {
              showDialogBox = false;
            });
            print(e);
          });
        }
        else{
          print('not null');
          requestMulti.fields["user_image"] = '';
          requestMulti.send().then((value1){
            value1.stream.toBytes().then((value) {
              var responseString = String.fromCharCodes(value);
              var jsonData = jsonDecode(responseString);
              print('${jsonData.toString()}');
              SignInModel signInData = SignInModel.fromJson(jsonData);
              if (signInData.status == "0" || signInData.status == 0) {
                Toast.show(signInData.message, context,
                    duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
              } else if (signInData.status == "1" || signInData.status == 1) {
                Navigator.pushNamed(context, PageRoutes.verification,
                    arguments: {
                      'token': '${token}',
                      'user_phone': '${user_phone}',
                      'firebase': '${appinfo.firebase}',
                      'country_code': '${appinfo.countryCode}',
                      'referralcode': '${referral_code}',
                      'activity': 'signup',
                    });
              } else if (signInData.status == "2" || signInData.status == 2) {
                Navigator.pushNamed(context, PageRoutes.verification,
                    arguments: {
                      'token': '${token}',
                      'user_phone': '${user_phone}',
                      'firebase': '${appinfo.firebase}',
                      'country_code': '${appinfo.countryCode}',
                      'referralcode': '${referral_code}',
                      'activity': 'signup',
                    });
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
          }).catchError((e){
            setState(() {
              showDialogBox = false;
            });
          });
        }
      }
      else{
        print('not null');
        requestMulti.fields["user_image"] = '';
        requestMulti.send().then((value1){
          value1.stream.toBytes().then((value) {
            var responseString = String.fromCharCodes(value);
            var jsonData = jsonDecode(responseString);
            print('${jsonData.toString()}');
            SignInModel signInData = SignInModel.fromJson(jsonData);
            if (signInData.status == "0" || signInData.status == 0) {
              Toast.show(signInData.message, context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
            } else if (signInData.status == "1" || signInData.status == 1) {
              Navigator.pushNamed(context, PageRoutes.verification,
                  arguments: {
                    'token': '${token}',
                    'user_phone': '${user_phone}',
                    'firebase': '${appinfo.firebase}',
                    'country_code': '${appinfo.countryCode}',
                    'referralcode': '${referral_code}',
                    'activity': 'signup',
                  });
            } else if (signInData.status == "2" || signInData.status == 2) {
              Navigator.pushNamed(context, PageRoutes.verification,
                  arguments: {
                    'token': '${token}',
                    'user_phone': '${user_phone}',
                    'firebase': '${appinfo.firebase}',
                    'country_code': '${appinfo.countryCode}',
                    'referralcode': '${referral_code}',
                    'activity': 'signup',
                  });
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
        }).catchError((e){
          setState(() {
            showDialogBox = false;
          });
        });
      }
    } else {
      if (count == 0) {
        messaging.getToken().then((value) {
          token = value;
          count = 1;
          hitSignUpUrl(user_name, user_email, user_phone, user_password,
              user_city, user_area, fb_id, referral_code, context);
        });
      }
    }
  }
}
