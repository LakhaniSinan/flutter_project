import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/cart/addtocartbean.dart';
import 'package:grocery/beanmodel/cart/cartitembean.dart';
import 'package:grocery/beanmodel/cart/makeorderbean.dart';
import 'package:grocery/beanmodel/storefinder/storefinderbean.dart';
import 'package:grocery/providergrocery/add2cartsnap.dart';
import 'package:grocery/providergrocery/cartcountprovider.dart';
import 'package:grocery/providergrocery/cartlistprovider.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class YourBasket extends StatefulWidget {
  @override
  BasketState createState() => BasketState();
}

class BasketState extends State<YourBasket> {
  List<CartItemData> cartItemd = [];
  var http = Client();
  A2CartSnap a2cartSnap;
  CartListProvider cartListPro;
  CartCountProvider cartCounterProvider;
  dynamic apcurrency;
  dynamic cart_id;
  CartStoreDetails storeDetails;
  double totalPrice = 0.0;
  double totalMrp = 0.0;
  double deliveryFee = 0.0;
  double promocodeprice = 0.0;
  bool isOpenMenu = false;
  bool isMakeingOrder = false;

  void scanProductCode(BuildContext context) async {
    await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", true, ScanMode.DEFAULT)
        .then((value) {
      if (value != null && value.length > 0 && '$value' != '-1') {
        if(storeDetails!=null){
          Navigator.pushNamed(context, PageRoutes.search, arguments: {
            'ean_code': value,
            'storedetails': storeDetails,
          }).then((value){
            getCartList();
          });
        }
      }
    }).catchError((e) {});
  }

  @override
  void initState() {
    a2cartSnap = BlocProvider.of<A2CartSnap>(context);
    cartListPro = BlocProvider.of<CartListProvider>(context);
    cartCounterProvider = BlocProvider.of<CartCountProvider>(context);
    super.initState();
    getCartList();
  }

  void getCartList() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    print(preferences.getString('accesstoken'));
    setState(() {
      apcurrency = preferences.getString('app_currency');
    });
    print('${preferences.getInt('user_id')}');
    http.post(showCartUri,body: {
      'user_id':'${preferences.getInt('user_id')}'
    }, headers: {
      'Authorization': 'Bearer ${preferences.getString('accesstoken')}'
    }).then((value){
      print('cart - ${value.body}');
      if(value.statusCode == 200){
        CartItemMainBean data1 = CartItemMainBean.fromJson(jsonDecode(value.body));
        if('${data1.status}'=='1'){
          // cartItemd.clear();
          // cartItemd = List.from(data1.data);
          cartListPro.emitCartList(data1.data,data1.total_price);
          cartCounterProvider.hitCartCounter(data1.data.length);
          cart_id = cartItemd[0].order_cart_id;
          setState(() {
            totalPrice = double.parse('${data1.total_price}');
            totalMrp = double.parse('${data1.total_mrp}');
            storeDetails = data1.store_details;
            deliveryFee = double.parse('${data1.delivery_charge}');
          });
        }else{
          cartListPro.emitCartList([],0.0);
          cartCounterProvider.hitCartCounter(0);
          setState(() {
            totalPrice = 0.0;
            totalMrp = 0.0;
            deliveryFee = 0.0;
          });
        }
      }
    }).catchError((e){
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return SafeArea(
      top: true,
        bottom: true,
        left: false,
        right: false,
        child: Scaffold(
          backgroundColor: Color(0xfff8f8f8),
          appBar: AppBar(
            backgroundColor: kWhiteColor,
            title: Text(
              'Your Basket',
              style: TextStyle(
                  color: kMainTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            automaticallyImplyLeading: true,
            centerTitle: true,
            actions: [
              Visibility(
                // visible: (storeFinderData != null &&
                //     storeFinderData.store_id != null),
                visible: true,
                child: IconButton(
                  icon: ImageIcon(AssetImage(
                    'assets/scanner_logo.png',
                  )),
                  onPressed: () async {
                    scanProductCode(context);
                  },
                ),
              ),
            ],
          ),
          body: BlocBuilder<CartListProvider, List<CartItemData>>(
              builder: (context, cartList) {
                if(cartList!=null && cartList.length>0){
                  cartItemd = List.from(cartList);
                  cart_id = cartItemd[0].order_cart_id;
                  return Column(
                    children: [
                      Expanded(
                          child: SingleChildScrollView(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      height: 45,
                                      margin:
                                      EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                          color: kWhiteColor,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: kMainColor, width: 1),
                                          boxShadow: [
                                            BoxShadow(
                                                color: kMainColor,
                                                offset: Offset(-1, 0),
                                                blurRadius: 1),
                                            BoxShadow(
                                                color: kMainColor,
                                                offset: Offset(1, 1),
                                                blurRadius: 1)
                                          ]),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(left: 10, right: 5),
                                            child: Icon(Icons.savings,
                                                size: 25.0, color: kMainColor),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.only(left: 5, right: 10),
                                              child: Text(
                                                  'You are saving $apcurrency ${(totalMrp-totalPrice)+promocodeprice} with this purchase.',
                                                  maxLines: 1,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.normal,
                                                      color: kMainTextColor,
                                                      fontSize: 13)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    (cartItemd != null && cartItemd.length >0)
                                        ?BlocBuilder<A2CartSnap, AddtoCartB>(
                                        builder: (_, dVal) {
                                          return ListView.builder(
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              primary: false,
                                              physics: NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                return Slidable(
                                                  key: Key('${cartItemd[index].product_name}'),
                                                  actionPane: SlidableDrawerActionPane(),
                                                  actionExtentRatio: 0.25,
                                                  child: Material(
                                                    elevation: 1,
                                                    child: Container(
                                                      width: MediaQuery.of(context).size.width,
                                                      color: kWhiteColor,
                                                      padding:
                                                      const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            // mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                            children: [
                                                              Expanded(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment.start,
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text('${cartItemd[index].product_name}',
                                                                          textAlign: TextAlign.start,
                                                                          maxLines: 2,
                                                                          style: TextStyle(
                                                                              fontWeight:
                                                                              FontWeight.w500,
                                                                              letterSpacing: 1.5,
                                                                              color: kMainTextColor,
                                                                              fontSize: 15)),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top: 8.0),
                                                                        child: Text('$apcurrency ${(double.parse('${cartItemd[index].price}')/int.parse('${cartItemd[index].qty}'))}',
                                                                            textAlign: TextAlign.start,
                                                                            maxLines: 1,
                                                                            style: TextStyle(
                                                                                fontWeight:
                                                                                FontWeight.bold,
                                                                                color: kMainTextColor,
                                                                                fontSize: 13)),
                                                                      ),
                                                                    ],
                                                                  )),
                                                              Column(
                                                                // mainAxisAlignment: MainAxisAlignment.end,
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment.end,
                                                                children: [
                                                                  Container(
                                                                    height: 33,
                                                                    alignment: Alignment.center,
                                                                    decoration: BoxDecoration(
                                                                        color:
                                                                        kMainColor.withOpacity(0.4),
                                                                        borderRadius: BorderRadius.circular(30)
                                                                    ),
                                                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        buildIconButton(Icons.remove, context,
                                                                            onpressed: () {
                                                                              if (int.parse('${cartItemd[index].qty}') > 0 &&
                                                                                  dVal.status == false) {
                                                                                a2cartSnap.hitSnap(int.parse('${cartItemd[index].productid}'), true);
                                                                                addtocart2(
                                                                                    '${cartItemd[index].store_id}',
                                                                                    '${cartItemd[index].varient_id}',
                                                                                    (int.parse('${cartItemd[index].qty}') - 1),
                                                                                    '0',
                                                                                    context,
                                                                                    0);
                                                                              }else{
                                                                                Toast.show(locale.pcurprogress,
                                                                                    context,
                                                                                    duration: Toast.LENGTH_SHORT,
                                                                                    gravity: Toast.CENTER);
                                                                              }
                                                                            }),
                                                                        SizedBox(
                                                                          width: 8,
                                                                        ),
                                                                        (dVal.status == true && '${dVal.prodId}' == '${cartItemd[index].productid}')
                                                                            ? SizedBox(
                                                                          height: 10,
                                                                          width: 10,
                                                                          child: CircularProgressIndicator(
                                                                            strokeWidth: 1,
                                                                          ),
                                                                        ):Text('x${cartItemd[index].qty}',
                                                                            style:
                                                                            Theme.of(context).textTheme.subtitle1),
                                                                        SizedBox(
                                                                          width: 8,
                                                                        ),
                                                                        buildIconButton(Icons.add, context, type: 1,
                                                                            onpressed: () {
                                                                              if ((int.parse('${cartItemd[index].qty}') + 1) <=
                                                                                  int.parse('${cartItemd[index].stock}') &&
                                                                                  dVal.status == false) {
                                                                                a2cartSnap.hitSnap(int.parse('${cartItemd[index].productid}'), true);
                                                                                addtocart2(
                                                                                    '${cartItemd[index].store_id}',
                                                                                    '${cartItemd[index].varient_id}',
                                                                                    (int.parse('${cartItemd[index].qty}') + 1),
                                                                                    '0',
                                                                                    context,
                                                                                    0);
                                                                              } else {
                                                                                if(dVal.status == false){
                                                                                  Toast.show(locale.outstock2,
                                                                                      context,
                                                                                      duration: Toast.LENGTH_SHORT,
                                                                                      gravity: Toast.CENTER);
                                                                                }else{
                                                                                  Toast.show(locale.pcurprogress,
                                                                                      context,
                                                                                      duration: Toast.LENGTH_SHORT,
                                                                                      gravity: Toast.CENTER);
                                                                                }
                                                                              }
                                                                            }),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 8,),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Text("$apcurrency ${double.parse('${cartItemd[index].price}')}",
                                                                        textAlign: TextAlign.left,
                                                                        style: TextStyle(
                                                                            color: kMainTextColor,
                                                                            fontSize: 13)),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                          SizedBox(height: 10,),
                                                          Text('${cartItemd[index].quantity} ${cartItemd[index].unit}',
                                                              textAlign: TextAlign.start,
                                                              style: TextStyle(
                                                                  color: kLightTextColor,
                                                                  fontSize: 13)),
                                                          Padding(
                                                            padding: const EdgeInsets.fromLTRB(
                                                                5, 5, 5, 0),
                                                            child: Divider(
                                                              thickness: 1.5,
                                                              height: 1.5,
                                                              color: Color(0xfff8f8f8),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  secondaryActions: <Widget>[
                                                    IconSlideAction(
                                                      color: kTransparentColor,
                                                      iconWidget: ClipRRect(
                                                        borderRadius: BorderRadius.circular(30),
                                                        child: Container(
                                                          color: kRedColor,
                                                          padding: const EdgeInsets.all(6),
                                                          child: Icon(
                                                            Icons.delete_outline,
                                                            color: kWhiteColor,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                      onTap: (){
                                                        if (dVal.status == false) {
                                                          a2cartSnap.hitSnap(int.parse('${cartItemd[index].productid}'), true);
                                                          addtocart2(
                                                              '${cartItemd[index].store_id}',
                                                              '${cartItemd[index].varient_id}',
                                                              0,
                                                              '0',
                                                              context,
                                                              0);
                                                        }else{
                                                          Toast.show(locale.pcurprogress,
                                                              context,
                                                              duration: Toast.LENGTH_SHORT,
                                                              gravity: Toast.CENTER);
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                              itemCount: cartItemd.length);
                                        })
                                        :SizedBox.shrink(),
                                    Divider(
                                      height: 10,
                                      thickness: 10,
                                      color: Color(0xfff8f8f8),
                                    ),
                                    Visibility(
                                      visible: isOpenMenu,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Divider(
                                            height: 10,
                                            thickness: 10,
                                            color: Color(0xfff8f8f8),
                                          ),
                                          Material(
                                            color: kWhiteColor,
                                            elevation: 1,
                                            child: Container(
                                              color: kWhiteColor,
                                              padding: const EdgeInsets.only(
                                                  left: 20, right: 20, top: 10, bottom: 10),
                                              child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.symmetric(vertical: 15),
                                                      child: Text("${locale.do10} (${cartItemd.length} ${locale.od5})",
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
                                                          padding: const EdgeInsets.only(bottom: 8),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              Expanded(
                                                                child: Text(locale.do11,
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.w400,
                                                                        color: kMainTextColor,
                                                                        fontSize: 15)),
                                                              ),
                                                              Text('$apcurrency $totalMrp',
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.normal,
                                                                      color: kMainTextColor,
                                                                      fontSize: 15)),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(bottom: 8),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              Expanded(
                                                                child: Text(locale.do12,
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.w400,
                                                                        color: kMainTextColor,
                                                                        fontSize: 15)),
                                                              ),
                                                              Text('$apcurrency $totalPrice',
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.normal,
                                                                      color: kMainTextColor,
                                                                      fontSize: 15)),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(bottom: 8),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              Expanded(
                                                                child: Text(locale.do13,
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.w400,
                                                                        color: kMainTextColor,
                                                                        letterSpacing: 1.5,
                                                                        fontSize: 15)),
                                                              ),
                                                              Text('- $apcurrency ${(totalMrp-totalPrice)}',
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.normal,
                                                                      color: kMainTextColor,
                                                                      letterSpacing: 1.5,
                                                                      fontSize: 15)),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(bottom: 8),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              Expanded(
                                                                child: Text(locale.do14,
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.w400,
                                                                        color: kMainTextColor,
                                                                        letterSpacing: 1.5,
                                                                        fontSize: 15)),
                                                              ),
                                                              Text('- $apcurrency $promocodeprice',
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.normal,
                                                                      color: kMainTextColor,
                                                                      letterSpacing: 1.5,
                                                                      fontSize: 15)),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(bottom: 8),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              Expanded(
                                                                child: Text(locale.do15,
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.w400,
                                                                        color: kMainTextColor,
                                                                        letterSpacing: 1.5,
                                                                        fontSize: 15)),
                                                              ),
                                                              Text('$apcurrency $deliveryFee',
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.normal,
                                                                      color: kMainTextColor,
                                                                      letterSpacing: 1.5,
                                                                      fontSize: 15)),
                                                            ],
                                                          ),
                                                        ),
                                                      ]),
                                                    ),
                                                    Divider(
                                                      thickness: 1.5,
                                                      height: 1.5,
                                                      color: kButtonBorderColor.withOpacity(0.5),
                                                    ),
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(bottom: 8, top: 8),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                          Expanded(
                                                            child: Text(locale.do11,
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.w400,
                                                                    color: kMainTextColor,
                                                                    fontSize: 15)),
                                                          ),
                                                          Text('$apcurrency ${totalPrice+deliveryFee}',
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.normal,
                                                                  color: kMainTextColor,
                                                                  fontSize: 15)),
                                                        ],
                                                      ),
                                                    ),
                                                  ]),
                                            ),
                                          ),
                                          Divider(
                                            height: 10,
                                            thickness: 10,
                                            color: Color(0xfff8f8f8),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      height: 10,
                                      thickness: 10,
                                      color: Color(0xfff8f8f8),
                                    ),
                                  ]))),
                      Container(
                        color: kWhiteColor,
                        padding: const EdgeInsets.only(top: 10,bottom: 10,right: 15,left: 10),
                        child: Row(
                          children: [
                            Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('$apcurrency ${totalPrice+deliveryFee}',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: kMainTextColor,
                                            letterSpacing: 1.7,
                                            fontSize: 18)),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: GestureDetector(
                                        onTap: (){
                                          setState(() {
                                            isOpenMenu = !isOpenMenu;
                                          });
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Text("View Details",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: kMainColor,
                                                fontSize: 15)),
                                      ),
                                    ),
                                  ],
                                )),
                            Expanded(
                                child: GestureDetector(
                                  onTap: (){
                                    Navigator.pushNamed(context, PageRoutes.deliveryoption, arguments: {
                                      'store_id':'${storeDetails.store_id}',
                                      'store_d':storeDetails,
                                      'cartdetails':cartItemd,
                                      'currency':apcurrency,
                                      'totalmrp':totalMrp,
                                      'totalprice':totalPrice,
                                      'deliveryfee':deliveryFee,
                                    });

                                  },
                                  child: (!isMakeingOrder)?Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: kMainColor,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 5),
                                          child: Text(
                                            'Continue',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: kWhiteColor,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.6),
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward_ios,
                                            size: 17.0, color: kWhiteColor)
                                      ],
                                    ),
                                  ):Align(
                                    widthFactor: 40,
                                    heightFactor: 40,
                                    child: CircularProgressIndicator(strokeWidth: 2,color: kMainColor,),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      Divider(
                        height: 5,
                        thickness: 5,
                        color: kWhiteColor,
                      ),
                    ],
                  );
                }else{
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('No item in your please proceed to shop something to continue.',textAlign: TextAlign.center,),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          MaterialButton(onPressed: (){
Navigator.of(context).pop();
                          },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)
                            ),
                            color: kMainColor,
                            child: Text('Shop Now',style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: kMainTextColor,
                                letterSpacing: 1.5,
                                fontSize: 16)),)
                        ],
                      )
                    ],
                  );
                }

          }),
        ));
  }

  void _showSnackBar(dynamic ddd) {
    print('done');
  }

  Widget buildIconButton(IconData icon, BuildContext context,
      {Function onpressed, int type}) {
    return GestureDetector(
      onTap: () {
        onpressed();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 25,
        height: 25,
        alignment: Alignment.center,
        // decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(20),
        //     border: Border.all(color: type==1?kMainColor:kRedColor, width: 0)),
        child: Icon(
          icon,
          color: type==1?kMainColor:kRedColor,
          size: 16,
        ),
      ),
    );
  }

  void addtocart2(String storeid, String varientid, dynamic qnty, String special,
      BuildContext context, int index) async {
    var locale = AppLocalizations.of(context);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey('islogin') && preferences.getBool('islogin')) {
      if(preferences.getString('block')=='1'){
        a2cartSnap.hitSnap(-1, false);
        Toast.show(locale.blockmsg, context,
            gravity: Toast.CENTER,
            duration: Toast.LENGTH_SHORT);
      }else{
        http.post(addToCartUri, body: {
          'user_id': '${preferences.getInt('user_id')}',
          'qty': '${int.parse('$qnty')}',
          'store_id': '${int.parse('$storeid')}',
          'varient_id': '${int.parse('$varientid')}',
          'special': '${special}',
        }, headers: {
          'Authorization': 'Bearer ${preferences.getString('accesstoken')}'
        }).then((value) {
          print('cart add${value.body}');
          a2cartSnap.hitSnap(-1, false);
          if (value.statusCode == 200) {
            AddToCartMainModel data1 =
            AddToCartMainModel.fromJson(jsonDecode(value.body));
            if ('${data1.status}' == '1') {
              if(data1.cart_items!=null && data1.cart_items.length>0){
                totalPrice = double.parse('${data1.total_price}');
                totalMrp = double.parse('${data1.total_mrp}');
                cartListPro.emitCartList(data1.cart_items,data1.total_price);
                cartCounterProvider.hitCartCounter(data1.cart_items.length);
              }else{
                totalPrice = 0.0;
                totalMrp = 0.0;
                cartListPro.emitCartList([],0.0);
                cartCounterProvider.hitCartCounter(0);
              }
            } else {
              totalPrice = 0.0;
              totalMrp = 0.0;
              cartListPro.emitCartList([],0.0);
              // _counter = 0;
              cartCounterProvider.hitCartCounter(0);
            }
            Toast.show(data1.message, context,
                gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
          }
        }).catchError((e) {
          a2cartSnap.hitSnap(-1, false);
          print(e);
        });
      }
    } else {
      a2cartSnap.hitSnap(-1, false);
      Toast.show(locale.loginfirst, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
    }

  }


}
