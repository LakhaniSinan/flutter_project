import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:grocery/Components/custom_button.dart';
import 'package:grocery/Components/entry_field.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/appinfo.dart';
import 'package:http/http.dart';
import 'package:toast/toast.dart';

class NumberScreenRestPassword extends StatefulWidget{
  // final VoidCallback onVerificationDone;
  //
  // NumberScreenRestPassword(this.onVerificationDone);

  @override
  NumberScreenRestPasswordState createState() {
    return NumberScreenRestPasswordState();
  }

}

class NumberScreenRestPasswordState extends State<NumberScreenRestPassword>{
  bool showDialogBox = false;
  bool enteredFirst = false;

  int checkValue = 0;

  TextEditingController emailAddressC = TextEditingController();
  TextEditingController phoneNumberC = TextEditingController();
  TextEditingController countryCodeController = TextEditingController();
  AppInfoModel appinfo;
  int numberLimit = 1;

  var http = Client();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    http.close();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    if(!enteredFirst){
      final Map<String, Object> rcvdData =
          ModalRoute.of(context).settings.arguments;
      setState(() {
        enteredFirst = true;
        appinfo = rcvdData['appinfo'];
        numberLimit = int.parse('${appinfo.phoneNumberLength}');
        countryCodeController.text = '${appinfo.countryCode}';
      });
    }
    return Scaffold(
      body: SafeArea(
      child: Column(
        children: [
          AppBar(
            leading: IconButton(
              icon: Icon(Icons.keyboard_arrow_left_sharp,size: 30,),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              locale.resetpassword,
              style: TextStyle(color: kMainTextColor),
            ),
            centerTitle: true,
          ),
          Expanded(
              child:SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20,top: 10,bottom: 10),
                      child: Text(
                        locale.selectrp,
                        style: TextStyle(
                          fontSize: 18,
                          color: kMainTextColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Radio(
                                  value: 0,
                                  groupValue: checkValue,
                                  toggleable: true,
                                  onChanged: (value) {
                                    // print(value);
                                    setState(() {
                                      checkValue = 0;
                                    });
                                    // print(checkValue);
                                  },
                                ),
                                Container(
                                  width: 5,
                                ),
                                Text(
                                  locale.mobilerp,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: kMainTextColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Radio(
                                  value: 1,
                                  groupValue: checkValue,
                                  toggleable: true,
                                  onChanged: (value) {
                                    // print(value);
                                    setState(() {
                                      checkValue = 1;
                                    });
                                    // print(checkValue);
                                  },
                                ),
                                Container(
                                  width: 5,
                                ),
                                Text(
                                  locale.emailrp,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: kMainTextColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
                    EntryField(
                      label: locale.selectCountry,
                      hint: locale.selectCountry,
                      controller: countryCodeController,
                      readOnly: true,
                      // suffixIcon: (Icons.arrow_drop_down),
                    ),
                    EntryField(
                      label: locale.phoneNumber,
                      hint: locale.enterPhoneNumber,
                      maxLines: 1,
                      maxLength: numberLimit,
                      keyboardType: TextInputType.number,
                      readOnly: showDialogBox,
                      controller: phoneNumberC,
                    ),
                    Visibility(
                      visible: (checkValue==1),
                      child: EntryField(
                        label: locale.emailAddress,
                        hint: locale.enterEmailAddress,
                        controller: emailAddressC,
                        readOnly: showDialogBox,
                      ),
                    ),
                  ],
                ),
              )
          ),
          showDialogBox?Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: Align(
              widthFactor: 40,
              heightFactor: 40,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
          ):CustomButton(
            onTap: () {
              // widget.onVerificationDone();
              if (!showDialogBox) {
                setState(() {
                  showDialogBox = true;
                });
if(checkValue==1){
  if(phoneNumberC.text!=null && phoneNumberC.text.length == numberLimit){
    if(emailAddressC.text!=null && emailValidator(emailAddressC.text)){
      hitForgetByNumber();
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
}else{
  if(phoneNumberC.text!=null && phoneNumberC.text.length == numberLimit){
    setState(() {
      showDialogBox = false;
    });
    if('${appinfo.firebase}'.toUpperCase() == 'ON'){
      Navigator.pushNamed(context, PageRoutes.restpassword2, arguments: {
        'appinfo': appinfo,
        'number': phoneNumberC.text,
      });
    }else{
      hitForgetByNumber();
    }
  }else{
    setState(() {
      showDialogBox = false;
    });
  }
}


              }
            },
          ),
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

  void hitForgetByNumber() async{
    http.post(forGetPasswordByPhoneUri,body: {
      'user_phone':'${phoneNumberC.text}',
    }).then((value){
      if(value.statusCode == 200){
        var jv = jsonDecode(value.body);
        if('${jv['status']}' == '1'){
          Navigator.pushNamed(context, PageRoutes.restpassword2, arguments: {
            'appinfo': appinfo,
            'number': phoneNumberC.text,
          });
        }
Toast.show(jv['message'], context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
      }
      setState(() {
        showDialogBox = false;
      });
    }).catchError((e){
      setState(() {
        showDialogBox = false;
      });
    });
  }

  void hitForgetByEmail() async{
    http.post(forGetPasswordByPhoneUri,body: {
      'user_phone':'${phoneNumberC.text}',
      'user_email':'${emailAddressC.text}',
    }).then((value){
      if(value.statusCode == 200){
        var jv = jsonDecode(value.body);
        if('${jv['status']}' == '1'){
          Navigator.pushNamed(context, PageRoutes.restpassword2, arguments: {
            'appinfo': appinfo,
            'number': phoneNumberC.text,
          });
        }
        Toast.show(jv['message'], context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
      }
      setState(() {
        showDialogBox = false;
      });
    }).catchError((e){
      setState(() {
        showDialogBox = false;
      });
    });
  }

}