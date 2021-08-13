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

class ChangePassword extends StatefulWidget {

  // final VoidCallback onVerificationDone;
  //
  // ChangePassword(this.onVerificationDone);


  @override
  ChangePasswordState createState() {
    return ChangePasswordState();
  }

}

class ChangePasswordState extends State<ChangePassword> {
  bool showDialogBox = false;
  TextEditingController password1 = TextEditingController();
  TextEditingController password2 = TextEditingController();
  AppInfoModel appinfo;
  String userNumber;

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
    final Map<String, Object> dataRecevid =
        ModalRoute
            .of(context)
            .settings
            .arguments;
    setState(() {
      userNumber = dataRecevid['number'];
      appinfo = dataRecevid['appinfo'];
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              title: Text(
                locale.changepassword,
                style: TextStyle(color: kMainTextColor),
              ),
              centerTitle: true,
            ),
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 20, top: 10, bottom: 10),
                      child: Text(
                        locale.passwordheading,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: kMainTextColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    EntryField(
                      label: locale.newpassword1,
                      hint: locale.newpassword2,
                      controller: password1,
                    ),
                    EntryField(
                      label: locale.confirmpassword1,
                      hint: locale.confirmpassword2,
                      controller: password2,
                    ),
                  ],
                )
            ),
            showDialogBox ? Container(
              height: 60,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              alignment: Alignment.center,
              child: Align(
                widthFactor: 40,
                heightFactor: 40,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            ) : CustomButton(
              onTap: () {
                // widget.onVerificationDone();
                if (!showDialogBox) {
                  setState(() {
                    showDialogBox = true;
                  });
                  if (password2.text != null && password2.text.length >= 5) {
                    if ((password1.text != null &&
                        password1.text.length >= 5) &&
                        (password1.text == password2.text)) {
                      changePassword(context);
                    } else {
                      setState(() {
                        showDialogBox = false;
                      });
                    }
                  } else {
                    setState(() {
                      showDialogBox = false;
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void changePassword(BuildContext context) async {
    http.post(changePasswordUri, body: {
      'user_phone': '$userNumber',
      'user_password': '${password1.text}',
    }).then((value) {
      if (value.statusCode == 200) {
        var jv = jsonDecode(value.body);
        if ('${jv['status']}' == '1') {
          Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.signInRoot, (Route<dynamic> route) => false);
        }
        Toast.show(jv['message'], context, duration: Toast.LENGTH_SHORT,
            gravity: Toast.CENTER);
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