import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery/Components/custom_button.dart';
import 'package:grocery/Components/entry_field.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/appinfo.dart';
import 'package:grocery/beanmodel/citybean.dart';
import 'package:grocery/beanmodel/statebean.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as Client;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ProfileEdit extends StatefulWidget {
  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  bool showDialogBox = false;
  int numberLimit = 10;
  dynamic mobileNumber;
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
  String _Uimage;
  final picker = ImagePicker();
  int count = 0;

  @override
  void initState() {
    super.initState();
    getProfileValue();
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      token = value;
    });
  }

  void getProfileValue() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    dynamic userId = preferences.getInt('user_id');
    setState(() {
      // islogin = preferences.getBool('islogin');
      dynamic userName = preferences.getString('user_name');
      dynamic emailAddress = preferences.getString('user_email');
      dynamic mobileNumber = preferences.getString('user_phone');
      dynamic user_city = preferences.getString('user_city');
      dynamic user_area = preferences.getString('user_area');
      dynamic  _image1 = '$imagebaseUrl${preferences.getString('user_image')}';
      _Uimage = _image1;
      userFullNameC.text = '$userName';
      emailAddressC.text = '$emailAddress';
      phoneNumberC.text = '$mobileNumber';
      cityData = CityDataBean('',user_city);
      cityList.add(cityData);
      socityData = StateDataBean('',user_area,'','');
      socityList.add(socityData);
      // selectCity = user_city;
      // selectSocity = user_area;
    });
    hitCityData();
  }

  void hitCityData() {
    setState(() {
      showDialogBox = true;
    });
    var http = Client.Client();
    http.get(cityUri).then((value) {
      if (value.statusCode == 200) {
        CityBeanModel data1 = CityBeanModel.fromJson(jsonDecode(value.body));
        print('${data1.data.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            cityList.clear();
            cityList = List.from(data1.data);
            int id1 = cityList.indexOf(cityData);
            selectCity = cityList[id1].city_name;
            cityData = cityList[id1];
            selectCity = '${cityData.city_name}';
            socityList.clear();
            selectSocity = 'Select your socity/area';
            // socityData = null;
          });
          if (cityList.length > 0) {
            hitSocityList(cityData.city_name, AppLocalizations.of(context));
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

  void hitSocityList(dynamic cityName, locale) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var http = Client.Client();
    http.post(societyUri, body: {'city_name': '$cityName'}, headers: {
      'Authorization': 'Bearer ${pref.getString('accesstoken')}'
    }).then((value) {
      if (value.statusCode == 200) {
        StateBeanModel data1 = StateBeanModel.fromJson(jsonDecode(value.body));
        print('ee - ${data1.data.toString()}');
        print('ee - ${socityData.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            socityList.clear();
            socityList = List.from(data1.data);
            int id1 = socityList.indexOf(socityData);
            socityData = socityList[id1];
            selectSocity = socityData.society_name;
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
            (locale != null) ? locale.selectsocity2 : 'Select your society/area';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale.profileedit,
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
                              Container(
                                height: 80,
                                width: 80,
                                child: (_Uimage!=null)
                                    ?CachedNetworkImage(
                                  imageUrl: '$_Uimage',
                                  placeholder: (context, url) =>
                                      Align(
                                        widthFactor: 50,
                                        heightFactor: 50,
                                        alignment: Alignment.center,
                                        child: Container(
                                          padding:
                                          const EdgeInsets.all(
                                              5.0),
                                          width: 40,
                                          height: 40,
                                          child:
                                          CircularProgressIndicator(strokeWidth: 2,color: kMainColor,),
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) =>
                                      Image.asset(
                                        'assets/icon.png',height: 80,
                                        width: 80,),
                                )
                                    :Image(
                                  image:  FileImage(_image),
                                  height: 80,
                                  width: 80,
                                ),
                              ),
                              SizedBox(
                                width: 20.0,
                              ),
                              Expanded(
                                child: Text(
                                  locale.uploadpictext,
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(
                                          color: kMainTextColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Visibility(
                        visible: showDialogBox,
                        child: Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(strokeWidth: 2,color: kMainColor,),
                        )),
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
                      readOnly: false,
                      keyboardType: TextInputType.number,
                      controller: phoneNumberC,
                    ),
                  ],
                ),
              ),
            ),
            CustomButton(onTap: () {
              if (!showDialogBox) {
                setState(() {
                  showDialogBox = true;
                });
                // int numLength = (mobileNumber!=null && mobileNumber.toString().length>0)?numberLimit:10;
                if (userFullNameC.text != null) {
                  if (emailAddressC.text != null &&
                      emailValidator(emailAddressC.text)) {
                    if (phoneNumberC.text != null && phoneNumberC.text.length == numberLimit) {

                      hitSignUpUrl(
                          userFullNameC.text,
                          emailAddressC.text,
                          '${phoneNumberC.text}',
                          cityData.city_id,
                          socityData.society_id,
                          context);
                    }
                    else {
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
            },
              label: locale.update,
            )
          ],
        ),
      ),
    );
  }

  bool emailValidator(email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  void hitSignUpUrl(
      dynamic user_name,
      dynamic user_email,
      dynamic user_phone,
      dynamic user_city,
      dynamic user_area,
      BuildContext context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (token != null) {
      String fid;
      if(_image!=null){
        fid = _image.path.split('/').last;
      }
      var requestMulti = http.MultipartRequest('POST', profileEditUri);
      requestMulti.fields["user_id"] = '${prefs.getInt('user_id')}';
      requestMulti.fields["user_name"] = '${user_name}';
      requestMulti.fields["user_email"] = '${user_email}';
      requestMulti.fields["user_phone"] = '${user_phone}';
      requestMulti.fields["user_city"] = '${user_city}';
      requestMulti.fields["user_area"] = '${user_area}';
      requestMulti.fields["device_id"] = '${token}';
      if(fid!=null && fid.length>0){
        http.MultipartFile.fromPath('user_image', _image.path, filename: fid)
            .then((pic) {
          requestMulti.files.add(pic);
          requestMulti.send().then((values) {
            values.stream.toBytes().then((value) {
              var responseString = String.fromCharCodes(value);
              var jsonData = jsonDecode(responseString);
              print('${jsonData.toString()}');
              Toast.show(jsonData['message'], context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
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
            Toast.show(jsonData['message'], context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
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
          hitSignUpUrl(user_name, user_email, user_phone,
              user_city, user_area, context);
        });
      }
    }
  }
}
