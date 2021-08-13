import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grocery/Components/custom_button.dart';
import 'package:grocery/Components/drawer.dart';
import 'package:grocery/Components/entry_field.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Pages/Other/add_address.dart';
import 'package:grocery/Pages/User/profileedit.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/addressbean/showaddress.dart';
import 'package:grocery/beanmodel/signinmodel.dart';
import 'package:grocery/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyAccount extends StatefulWidget {
  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  var nameControler = TextEditingController();
  var emailControler = TextEditingController();
  var phoneControler = TextEditingController();
  String userName;
  bool islogin = false;
  String emailAddress;
  String mobileNumber;
  String _image;

  @override
  void initState() {
    super.initState();
    getProfileValue();
  }

  void getProfileValue() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    dynamic userId = preferences.getInt('user_id');
    setState(() {
      islogin = preferences.getBool('islogin');
      userName = preferences.getString('user_name');
      emailAddress = preferences.getString('user_email');
      mobileNumber = preferences.getString('user_phone');
      _image = '$imagebaseUrl${preferences.getString('user_image')}';
      nameControler.text = userName;
      emailControler.text = emailAddress;
      phoneControler.text = mobileNumber;
    });
    getProfileFromInternet(userId);
  }

  void getProfileFromInternet(dynamic userId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = myProfileUri;
    await http.post(url, body: {
      'user_id': '${userId}'
    },headers: {
      'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
    }).then((response) {
      print('Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        print('Response Body: - ${response.body}');
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
          // prefs.setString("accesstoken", '${signInData.token}');
          setState(() {
            userName = prefs.getString('user_name');
            emailAddress = prefs.getString('user_email');
            mobileNumber = prefs.getString('user_phone');
            _image = '$imagebaseUrl${prefs.getString('user_image')}';
            nameControler.text = userName;
            emailControler.text = emailAddress;
            phoneControler.text = mobileNumber;
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale.myProfile,
          style: TextStyle(color: kMainTextColor),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SizedBox(
                    //   height: 10,
                    // ),
                    // Text(
                    //   locale.myProfile,
                    //   style: Theme.of(context).textTheme.headline6.copyWith(
                    //       fontSize: 16, letterSpacing: 1, color: Color(0xffa9a9a9)),
                    // ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          border: Border.all(color: kMainColor),
                          borderRadius: BorderRadius.circular(5.0)),
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap:(){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEdit()));
                    },
                              behavior: HitTestBehavior.opaque,
                              child: Text(
                                locale.profileclickupdate,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(
                                    color: kMainColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          (_image!=null)?CachedNetworkImage(
                            imageUrl: '${_image}',
                            height: 100,
                            width: 120,
                            fit: BoxFit.fill,
                            placeholder: (context, url) => Align(
                              widthFactor: 50,
                              heightFactor: 50,
                              alignment: Alignment.center,
                              child: Container(
                                padding: const EdgeInsets.all(5.0),
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Image.asset('assets/icon.png'),
                          ):Image(
                            image: AssetImage('assets/icon.png'),
                            height: 100,
                            width: 120,
                            fit: BoxFit.fill,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0),
                    EntryField(
                      controller: nameControler,
                      labelFontWeight: FontWeight.w400,
                      horizontalPadding: 0,
                      label: locale.fullName,
                      labelFontSize: 16,
                      readOnly: true,
                    ),
                    EntryField(
                      controller: emailControler,
                      labelFontWeight: FontWeight.w400,
                      horizontalPadding: 0,
                      label: locale.emailAddress,
                      readOnly: true,
                      labelFontSize: 16,
                    ),
                    EntryField(
                      controller: phoneControler,
                      labelFontWeight: FontWeight.w400,
                      horizontalPadding: 0,
                      label: locale.phoneNumber,
                      readOnly: true,
                      labelFontSize: 16,
                    ),
                  ],
                ),
              ),
              // Spacer(),
              Divider(
                thickness: 3,
                color: Colors.transparent,
              ),
              // CustomButton(
              //   label: locale.addAddress.toUpperCase(),
              //   onPress: AddAddressPage(),
              //   action: () async{
              //     print('action success!');
              //     SharedPreferences pref = await SharedPreferences.getInstance();
              //     getAddressByUserId(pref.getInt('user_id'));
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

}
