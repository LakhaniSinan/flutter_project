import 'package:flutter/material.dart';

import 'package:grocery/Components/custom_button.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/main.dart';

class ConfirmOrderPage extends StatefulWidget {

  @override
  _ConfirmOrderPageState createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends State<ConfirmOrderPage> {
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return SafeArea(
      top: true,
      left: false,
      right: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: kWhiteColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 52,),
            Text(locale.cnfo1,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: kMainTextColor,
                    letterSpacing: 1.5,
                    fontSize: 25)),
            SizedBox(height: 5,),
            Text(locale.cnfo2,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: kLightTextColor,
                    letterSpacing: 0.2,
                    fontSize: 22)),
            SizedBox(height: 10,),
            Expanded(child: Image.asset(
              'assets/scooter.png',
              fit: BoxFit.contain,
            )),
            SizedBox(height: 5,),
            Expanded(child: Center(
              child: Text(locale.youCanCheckYourOrderProcessInMyOrdersSection,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: kLightTextColor,
                      letterSpacing: 0.2,
                      fontSize: 16)),
            )),
            SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MaterialButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, PageRoutes.homePage, (route) => false);
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  color: kMainColor,
                  elevation: 0.5,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    locale.cnfo3,
                    style: TextStyle(
                        color: kWhiteColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  )),
            ),
            SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MaterialButton(
                  onPressed: () {
                    Navigator.pushNamed(context, PageRoutes.myorder);
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  color: kWhiteColor,
                  elevation: 0.5,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    locale.cnfo4,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  )),
            ),
            SizedBox(height: 5,),
          ],
        ),
      ),
    );
  }
}
