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

class MyAddress extends StatefulWidget {
  @override
  _MyAddressState createState() => _MyAddressState();
}

class _MyAddressState extends State<MyAddress> {
  var nameControler = TextEditingController();
  var emailControler = TextEditingController();
  var phoneControler = TextEditingController();
  String userName;
  bool islogin = false;
  String emailAddress;
  String mobileNumber;
  String _image;
  List<ShowAllAddressMain> allAddressData = [];
  bool isAddressLoading = false;

  @override
  void initState() {
    super.initState();
    getAddressByUserId();
  }

  void getAddressByUserId() async{
    setState(() {
      isAddressLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = showAllAddressUri;
    await http.post(url, body: {
      'user_id': '${prefs.getInt('user_id')}'
    },headers: {
      'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
    }).then((response) {
      print('Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        var js = jsonDecode(response.body) as List;
        if(js!=null && js.length>0){
          allAddressData = js.map((e) => ShowAllAddressMain.fromJson(e)).toList();
        }
      }
      setState(() {
        isAddressLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isAddressLoading = false;
      });
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Color(0xfff8f8f8),
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        title: Text(
          'My Address',
          style: TextStyle(color: kMainTextColor),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Expanded(child: (!isAddressLoading && allAddressData!=null && allAddressData.length>0)?
           ListView.builder(
               itemCount: allAddressData.length,
               shrinkWrap: true,
               primary: false,
               // physics: NeverScrollableScrollPhysics(),
               itemBuilder: (context,index){
                 return buildRAddressTile(context,allAddressData[index].type,allAddressData[index].data);
               }):Container(
             alignment: Alignment.center,
             child: (isAddressLoading)?Align(
               widthFactor: 50,
               heightFactor: 50,
               alignment: Alignment.center,
               child: CircularProgressIndicator(),
             ):Text(locale.noaddressfound),
           )),
            Divider(
              thickness: 3,
              color: Colors.transparent,
            ),
            // CustomButton(
            //   label: locale.addAddress.toUpperCase(),
            //   onPress: AddAddressPage(),
            //   action: () async{
            //     print('action success!');
            //     // SharedPreferences pref = await SharedPreferences.getInstance();
            //     getAddressByUserId();
            //   },
            // ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: MaterialButton(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Add New Address',
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: kWhiteColor,
                              letterSpacing: 1.5,
                              fontSize: 15)),
                      Icon(
                        Icons.add,
                        color: kWhiteColor,
                      )
                    ],
                  ),
                  height: 52,
                  color: kMainColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  onPressed: () {
                    Navigator.pushNamed(context, PageRoutes.addaddressp)
                        .then((value) {
                      getAddressByUserId();
                    }).catchError((e) {
                      print(e);
                    });
                  }),
            ),
          ],
        ),
      ),
    );
  }

  // Widget buildAddressTile(BuildContext context, String heading,List<AddressData> address) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 4),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           heading,
  //           style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,),
  //         ),
  //         SizedBox(height: 10,),
  //         ListView.builder(
  //           itemCount: address.length,
  //             shrinkWrap: true,
  //             primary: false,
  //             physics: NeverScrollableScrollPhysics(),
  //             itemBuilder: (context,index){
  //             AddressData addData = address[index];
  //             String addressshow = 'Name - ${addData.receiver_name}\nContact Number - ${addData.receiver_phone}\n${addData.house_no}${addData.landmark}${addData.society}${addData.city}(${addData.pincode})${addData.state}';
  //           return Row(
  //             children: [
  //               Expanded(
  //                   child: Text(
  //                       addressshow,
  //                     textAlign: TextAlign.start,
  //                     style: TextStyle(fontSize: 14),
  //                   )
  //               ),
  //               IconButton(icon: Icon(
  //                 Icons.edit,
  //                 color: Color(0xff686868),
  //                 size: 20,
  //               ), onPressed: () async{
  //                 // SharedPreferences preferences = await SharedPreferences.getInstance();
  //                 // dynamic userId = preferences.getInt('user_id');
  //                 Navigator.of(context).pushNamed(PageRoutes.editAddress,arguments: {
  //                   'address_d':addData,
  //                 }).then((value){
  //                   getAddressByUserId();
  //                 }).catchError((e){
  //                   getAddressByUserId();
  //                 });
  //               }),
  //             ],
  //           );
  //         })
  //       ],
  //     ),
  //   );
  // }

  Widget buildRAddressTile(
      BuildContext context, String heading, List<AddressData> address) {
    var locale = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
      width: MediaQuery.of(context).size.width,
      color: kWhiteColor,
      child: ListView.separated(
        itemCount: address.length,
        shrinkWrap: true,
        primary: false,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          AddressData addData = address[index];
          String addressshow =
              '${addData.house_no}${addData.landmark}${addData.society}${addData.city}(${addData.pincode})${addData.state}';
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(heading,
                            textAlign: TextAlign.start,
                            softWrap: true,
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: kMainTextColor,
                                letterSpacing: 1.5,
                                fontSize: 18))),
                    // Radio(
                    //     value: int.parse('${addData.address_id}'),
                    //     groupValue: seletedValue,
                    //     onChanged: (int value) {
                    //       if (seletedValue !=
                    //           int.parse('${addData.address_id}')) {
                    //         selectAddress(addData.address_id, addData);
                    //       }
                    //     }),
                  ],
                ),
              ),
              Row(
                children: [
                  Column(
                    children: [
                      Icon(
                        Icons.home,
                        color: kHomeIconColor,
                        size: 70,
                      ),
                      IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: kMainTextColor,
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(PageRoutes.editAddress, arguments: {
                              'address_d': addData,
                            }).then((value) {
                              getAddressByUserId();
                            }).catchError((e) {
                              getAddressByUserId();
                            });
                          }),
                    ],
                  ),
                  Expanded(
                      child: Column(
                        children: [
                          Text(
                            addressshow,
                            textAlign: TextAlign.start,
                            softWrap: true,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              // runAlignment: WrapAlignment.spaceBetween,
                              alignment: WrapAlignment.spaceBetween,
                              // crossAxisAlignment: WrapCrossAlignment.start,
                              children: [
                                Text(
                                  '${locale.name} - ${addData.receiver_name}',
                                  textAlign: TextAlign.start,
                                  softWrap: true,
                                ),
                                Text(
                                  '${locale.cnumber} - ${addData.receiver_phone}',
                                  textAlign: TextAlign.start,
                                  softWrap: true,
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                ],
              )
            ],
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 10,
            thickness: 10,
          );
        },
      ),
    );
  }
}
