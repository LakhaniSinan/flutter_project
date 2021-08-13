import 'dart:convert';

import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery/Components/constantfile.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/cart/addtocartbean.dart';
import 'package:grocery/beanmodel/cart/cartitembean.dart';
import 'package:grocery/beanmodel/category/topcategory.dart';
import 'package:grocery/beanmodel/productbean/productwithvarient.dart';
import 'package:grocery/beanmodel/wishlist/wishdata.dart';
import 'package:grocery/providergrocery/add2cartsnap.dart';
import 'package:grocery/providergrocery/cartcountprovider.dart';
import 'package:grocery/providergrocery/cartlistprovider.dart';
import 'package:grocery/providergrocery/pagesnap.dart';
import 'package:grocery/providergrocery/searchprovide.dart';
import 'package:grocery/providergrocery/searchproviderbean.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';

class NewSearchScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NewSearchScreenState();
  }
}

class NewSearchScreenState extends State<NewSearchScreen> {
  
  bool isEnteredFirst = false;
  CartCountProvider cartCounterProvider;
  CartListProvider cartListPro;
  A2CartSnap a2cartSnap;
  dynamic appcurrency;

  @override
  void initState() {
    super.initState();
    getSharedValue();
  }

  void getSharedValue() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    appcurrency = pref.getString('app_currency');
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    if(!isEnteredFirst){
      isEnteredFirst = true;
      cartCounterProvider = BlocProvider.of<CartCountProvider>(context);
      cartListPro = BlocProvider.of<CartListProvider>(context);
      a2cartSnap = BlocProvider.of<A2CartSnap>(context);
    }
    return Container(
        color: Color(0xfff8f8f8),
        child: BlocBuilder<SearchProvider, SearchProviderBean>(
            builder: (context,listModel){
              if(listModel.isSearching){
                return SingleChildScrollView(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    primary: false,
                    itemCount: 10,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                            color: Color(0xffffffff),
                            borderRadius: BorderRadius.circular(5)),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 100,
                              margin: const EdgeInsets.only(left: 10),
                              child: Shimmer(
                                duration: Duration(seconds: 3),
                                color: Colors.white,
                                enabled: true,
                                direction: ShimmerDirection.fromLTRB(),
                                child: Container(
                                  height: 15,
                                  width: 120,
                                  color: Colors.grey[300],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .stretch,
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: [
                                    Shimmer(
                                      duration: Duration(seconds: 3),
                                      color: Colors.white,
                                      enabled: true,
                                      direction: ShimmerDirection.fromLTRB(),
                                      child: Container(
                                        height: 15,
                                        width: 100,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Shimmer(
                                              duration: Duration(seconds: 3),
                                              color: Colors.white,
                                              enabled: true,
                                              direction: ShimmerDirection.fromLTRB(),
                                              child: Container(
                                                height: 15,
                                                color: Colors.grey[300],
                                              ),
                                            )),
                                        Expanded(
                                            child: Shimmer(
                                              duration: Duration(seconds: 3),
                                              color: Colors.white,
                                              enabled: true,
                                              direction: ShimmerDirection.fromLTRB(),
                                              child: Container(
                                                height: 15,
                                                color: Colors.grey[300],
                                              ),
                                            )),
                                        Expanded(
                                            child: Shimmer(
                                              duration: Duration(seconds: 3),
                                              color: Colors.white,
                                              enabled: true,
                                              direction: ShimmerDirection.fromLTRB(),
                                              child: Container(
                                                height: 15,
                                                color: Colors.grey[300],
                                              ),
                                            )),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              children: [
                                                Shimmer(
                                                  duration: Duration(seconds: 3),
                                                  color: Colors.white,
                                                  enabled: true,
                                                  direction: ShimmerDirection.fromLTRB(),
                                                  child: Container(
                                                    height: 15,
                                                    width: 70,
                                                    color: Colors.grey[300],
                                                  ),
                                                ),
                                                Shimmer(
                                                  duration: Duration(seconds: 3),
                                                  color: Colors.white,
                                                  enabled: true,
                                                  direction: ShimmerDirection.fromLTRB(),
                                                  child: Container(
                                                    height: 15,
                                                    width: 70,
                                                    color: Colors.grey[300],
                                                  ),
                                                ),
                                              ],
                                            )),
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              Align(
                                                child: MaterialButton(
                                                  onPressed: () {},
                                                  splashColor: kWhiteColor,
                                                  color: Colors.grey[300],
                                                  child: Shimmer(
                                                    duration: Duration(seconds: 3),
                                                    color: Colors.white,
                                                    enabled: true,
                                                    direction: ShimmerDirection.fromLTRB(),
                                                    child: Container(
                                                      height: 33,
                                                      color: Colors.grey[300],
                                                    ),
                                                  ),
                                                  elevation: 0,
                                                  height: 33,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          30)),
                                                ),
                                                alignment: Alignment
                                                    .bottomCenter,
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              }else{
                if(listModel.searchdata!=null && listModel.searchdata.length>0){
                  return BlocBuilder<CartListProvider,List<CartItemData>>(
                    builder: (context,cartItemd){
                      return BlocBuilder<A2CartSnap, AddtoCartB>(builder: (_, dVal) {
                        return ListView.builder(
                            itemCount: listModel.searchdata.length,
                            shrinkWrap: true,
                            primary: false,
                            // physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              int qty = 0;
                              int selectedIndexd = 0;
                              if (cartItemd != null &&
                                  cartItemd.length > 0) {
                                int indd = cartItemd.indexOf(CartItemData(
                                    varient_id:
                                    '${listModel.searchdata[index].varientId}'));
                                if (indd >= 0) {
                                  qty = cartItemd[indd].qty;
                                }
                              }

                              int iddV = listModel.searchdata[index]
                                  .varients
                                  .indexOf(ProductVarient(
                                  varientId: listModel.searchdata[index]
                                      .varientId));
                              if (iddV >= 0) {
                                selectedIndexd = iddV;
                              }
                              print('id = $selectedIndexd, ${listModel.searchdata[index].varientId}');

                              return GestureDetector(
                                onTap: () {
                                  // int idd = wishModel.indexOf(WishListDataModel('', '',
                                  //     '${listModel.searchdata[index].varientId}', '', '', '', '', '', '', '', '', '', '','',''));
                                  Navigator.pushNamed(context, PageRoutes.product,
                                      arguments: {
                                        'pdetails': listModel.searchdata[index],
                                        'storedetails': listModel.storeData,
                                        'isInWish': false,
                                      });
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xffffffff),
                                      borderRadius: BorderRadius.circular(5)),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 120,
                                        child: Stack(
                                          fit: StackFit.passthrough,
                                          children: [
                                            Align(
                                                alignment: Alignment.center,
                                                child: Container(
                                                  height: 100,
                                                  child:
                                                  Image.network(
                                                    '${listModel.searchdata[index].productImage}',
                                                    fit: BoxFit.cover,
                                                  ),
                                                  // Image.asset(
                                                  //   'assets/ProductImages/Cauliflower.png',
                                                  //   fit: BoxFit.cover,
                                                  // ),
                                                )),
                                            Visibility(
                                              visible: (int.parse(
                                                  '${listModel.searchdata[index].stock}') >
                                                  0)
                                                  ? false
                                                  : true,
                                              child: Positioned.fill(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      color: kButtonBorderColor
                                                          .withOpacity(0.5),
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          5)),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: kWhiteColor,
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                    child: Text(
                                                      locale.outstock,
                                                      style: TextStyle(
                                                        color: kMainTextColor,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 5),
                                                child: Row(
                                                  children: [
                                                    ((((double.parse('${listModel.searchdata[index].mrp}') -
                                                        double.parse(
                                                            '${listModel.searchdata[index].price}')) /
                                                        double.parse(
                                                            '${listModel.searchdata[index].mrp}')) *
                                                        100) >
                                                        0)
                                                        ? Container(
                                                      padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 3,
                                                          vertical:
                                                          1.5),
                                                      child: Text(
                                                        '${(((double.parse('${listModel.searchdata[index].mrp}') - double.parse('${listModel.searchdata[index].price}')) / double.parse('${listModel.searchdata[index].mrp}')) * 100).toStringAsFixed(2)} %',
                                                        style: TextStyle(
                                                          color:
                                                          kWhiteColor,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                      decoration: BoxDecoration(
                                                          color: kMainColor,
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              3)),
                                                    )
                                                        : SizedBox.shrink(),
                                                    Visibility(
                                                      visible: ('${listModel.searchdata[index].type}'!='Regular'),
                                                      child: Container(
                                                        alignment: Alignment.center,
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 3,
                                                            vertical: 1.5),
                                                        margin:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                        child: Text(
                                                          locale.inseason,
                                                          style: TextStyle(
                                                            color: kMainTextColor,
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                        decoration: BoxDecoration(
                                                            color:
                                                            kButtonBorderColor,
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(3)),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 5),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                  '${listModel.searchdata[index].productName}',
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      color: kMainTextColor,
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.w700)),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                        children: [
                                                          Text(locale.ptype,
                                                              style: TextStyle(
                                                                  color:
                                                                  kLightTextColor,
                                                                  fontSize: 11)),
                                                          Text('${listModel.searchdata[index].type}',
                                                              style: TextStyle(
                                                                  color:
                                                                  kMainTextColor,
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                        ],
                                                      )),
                                                  Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                        children: [
                                                          Text(locale.pqty,
                                                              style: TextStyle(
                                                                  color:
                                                                  kLightTextColor,
                                                                  fontSize: 11)),
                                                          (listModel.searchdata[index]
                                                              .varients!=null&&listModel.searchdata[index]
                                                              .varients.length>1)?Container(
                                                            height: 20,
                                                            child: DropdownButton<
                                                                ProductVarient>(
                                                              elevation: 0,
                                                              dropdownColor:
                                                              kWhiteColor,
                                                              hint: Text(
                                                                  '${listModel.searchdata[index].quantity} ${listModel.searchdata[index].unit}',
                                                                  overflow:
                                                                  TextOverflow
                                                                      .clip,
                                                                  maxLines: 1,
                                                                  textAlign:
                                                                  TextAlign.start,
                                                                  style: TextStyle(
                                                                      color:
                                                                      kMainTextColor,
                                                                      fontSize: 11)),
                                                              isExpanded: false,
                                                              icon: Icon(
                                                                Icons
                                                                    .keyboard_arrow_down,
                                                                size: 15,
                                                              ),
                                                              underline: Container(
                                                                height: 0.0,
                                                                color: kWhiteColor,
                                                              ),
                                                              items: listModel.searchdata[index]
                                                                  .varients
                                                                  .map((value) {
                                                                return DropdownMenuItem<ProductVarient>(
                                                                  value: value,
                                                                  child: Text(
                                                                      '${value.quantity} ${value.unit}',
                                                                      textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                      overflow:
                                                                      TextOverflow
                                                                          .clip,
                                                                      style: TextStyle(
                                                                          color:
                                                                          kLightTextColor,
                                                                          fontSize:
                                                                          11)),
                                                                );
                                                              }).toList(),
                                                              onChanged: (value) {
                                                                int iddV = listModel.searchdata[index]
                                                                    .varients
                                                                    .indexOf(ProductVarient(
                                                                    varientId: value
                                                                        .varientId));
                                                                if (iddV >= 0) {
                                                                  setState(() {
                                                                    selectedIndexd = iddV;
                                                                    listModel.searchdata[index].varientId = value.varientId;
                                                                    listModel.searchdata[index].price = value.price;
                                                                    listModel.searchdata[index].mrp = value.mrp;
                                                                    listModel.searchdata[index].quantity = value.quantity;
                                                                    listModel.searchdata[index].unit = value.unit;
                                                                    listModel.searchdata[index].stock = value.stock;
                                                                  });
                                                                }
                                                                // print(value);
                                                                // print(iddV);
                                                                // print(selectedIndexd);
                                                                // print(listModel.searchdata[index].varientId);
                                                                // print(listModel.searchdata[index].price);
                                                                // print(listModel.searchdata[index].mrp);
                                                                // print(listModel.searchdata[index].quantity);
                                                                // print(listModel.searchdata[index].unit);
                                                              },
                                                            ),
                                                          ):Text(
                                                              '${listModel.searchdata[index].quantity} ${listModel.searchdata[index].unit}',
                                                              overflow:
                                                              TextOverflow
                                                                  .clip,
                                                              maxLines: 1,
                                                              textAlign:
                                                              TextAlign.start,
                                                              style: TextStyle(
                                                                  color:
                                                                  kMainTextColor,
                                                                  fontSize: 11)),
                                                          // Row(
                                                          //   children: [
                                                          //     Text('${showindex.data[index].quantity} ${showindex.data[index].unit}',
                                                          //         overflow: TextOverflow.ellipsis,
                                                          //         style: TextStyle(
                                                          //             color: kMainTextColor,
                                                          //             fontSize: 13,
                                                          //             fontWeight:
                                                          //             FontWeight.w400)),
                                                          //     SizedBox(
                                                          //       width: 5,
                                                          //     ),
                                                          //     Icon(
                                                          //       Icons.keyboard_arrow_down,
                                                          //       size: 15,
                                                          //     )
                                                          //   ],
                                                          // )
                                                        ],
                                                      )),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                        children: [
                                                          Visibility(
                                                            visible:
                                                            ('${listModel.searchdata[index].price}' ==
                                                                '${listModel.searchdata[index].mrp}')
                                                                ? false
                                                                : true,
                                                            child: Text(
                                                                '$appcurrency ${listModel.searchdata[index].mrp}',
                                                                style: TextStyle(
                                                                    color:
                                                                    kLightTextColor,
                                                                    fontSize: 14,
                                                                    decoration:
                                                                    TextDecoration
                                                                        .lineThrough)),
                                                          ),
                                                          Text(
                                                              '$appcurrency ${listModel.searchdata[index].price}',
                                                              style: TextStyle(
                                                                  color: kMainColor,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                        ],
                                                      )),
                                                  Expanded(
                                                    child: Visibility(
                                                      visible: (int.parse(
                                                          '${listModel.searchdata[index].stock}') >
                                                          0)
                                                          ? true
                                                          : false,
                                                      child: Stack(
                                                        children: [
                                                          Align(
                                                            child: qty > 0
                                                                ? Container(
                                                              height: 33,
                                                              alignment:
                                                              Alignment
                                                                  .center,
                                                              decoration: BoxDecoration(
                                                                  color: kMainColor
                                                                      .withOpacity(
                                                                      0.4),
                                                                  borderRadius:
                                                                  BorderRadius.circular(
                                                                      30)),
                                                              padding: const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                  5),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                                children: [
                                                                  buildIconButton(
                                                                      Icons.remove,
                                                                      context,
                                                                      onpressed:
                                                                          () {
                                                                        if (qty >
                                                                            0 &&
                                                                            dVal.status ==
                                                                                false) {
                                                                          a2cartSnap.hitSnap(
                                                                              int.parse('${listModel.searchdata[index].productId}'),
                                                                              true);
                                                                          addtocart2(
                                                                              '${listModel.searchdata[index].storeId}',
                                                                              '${listModel.searchdata[index].varientId}',
                                                                              (qty - 1),
                                                                              '0',
                                                                              context,
                                                                              0);
                                                                        } else {
                                                                          Toast.show(
                                                                              locale.pcurprogress,
                                                                              context,
                                                                              duration: Toast.LENGTH_SHORT,
                                                                              gravity: Toast.CENTER);
                                                                        }
                                                                      }),
                                                                  SizedBox(
                                                                    width:
                                                                    8,
                                                                  ),
                                                                  (dVal.status == true &&
                                                                      '${dVal.prodId}' ==
                                                                          '${listModel.searchdata[index].productId}')
                                                                      ? SizedBox(
                                                                    height: 10,
                                                                    width: 10,
                                                                    child: CircularProgressIndicator(
                                                                      strokeWidth: 1,
                                                                    ),
                                                                  )
                                                                      : Text(
                                                                      'x$qty',
                                                                      style: Theme.of(context).textTheme.subtitle1),
                                                                  SizedBox(
                                                                    width:
                                                                    8,
                                                                  ),
                                                                  buildIconButton(
                                                                      Icons
                                                                          .add,
                                                                      context,
                                                                      type:
                                                                      1,
                                                                      onpressed:
                                                                          () {
                                                                        if ((qty + 1) <= int.parse('${listModel.searchdata[index].stock}') &&
                                                                            dVal.status ==
                                                                                false) {
                                                                          a2cartSnap.hitSnap(
                                                                              int.parse('${listModel.searchdata[index].productId}'),
                                                                              true);
                                                                          addtocart2(
                                                                              '${listModel.searchdata[index].storeId}',
                                                                              '${listModel.searchdata[index].varientId}',
                                                                              (qty + 1),
                                                                              '0',
                                                                              context,
                                                                              0);
                                                                        } else {
                                                                          if (dVal.status ==
                                                                              false) {
                                                                            Toast.show(locale.outstock2,
                                                                                context,
                                                                                duration: Toast.LENGTH_SHORT,
                                                                                gravity: Toast.CENTER);
                                                                          } else {
                                                                            Toast.show(locale.pcurprogress,
                                                                                context,
                                                                                duration: Toast.LENGTH_SHORT,
                                                                                gravity: Toast.CENTER);
                                                                          }
                                                                        }
                                                                      }),
                                                                ],
                                                              ),
                                                            )
                                                                : (dVal.status ==
                                                                true &&
                                                                '${dVal.prodId}' ==
                                                                    '${listModel.searchdata[index].productId}')
                                                                ? SizedBox(
                                                              height:
                                                              10,
                                                              width: 10,
                                                              child:
                                                              CircularProgressIndicator(
                                                                strokeWidth:
                                                                1,
                                                              ),
                                                            )
                                                                : MaterialButton(
                                                              onPressed:
                                                                  () {
                                                                if (int.parse('${listModel.searchdata[index].stock}') >
                                                                    0 &&
                                                                    dVal.status ==
                                                                        false) {
                                                                  a2cartSnap.hitSnap(
                                                                      int.parse('${listModel.searchdata[index].productId}'),
                                                                      true);
                                                                  addtocart2(
                                                                      '${listModel.searchdata[index].storeId}',
                                                                      '${listModel.searchdata[index].varientId}',
                                                                      (qty + 1),
                                                                      '0',
                                                                      context,
                                                                      0);
                                                                } else {
                                                                  if (dVal.status ==
                                                                      false) {
                                                                    Toast.show(locale.outstock2,
                                                                        context,
                                                                        duration: Toast.LENGTH_SHORT,
                                                                        gravity: Toast.CENTER);
                                                                  } else {
                                                                    Toast.show(locale.pcurprogress,
                                                                        context,
                                                                        duration: Toast.LENGTH_SHORT,
                                                                        gravity: Toast.CENTER);
                                                                  }
                                                                }
                                                              },
                                                              splashColor:
                                                              kMainColor,
                                                              color: kMainColor
                                                                  .withOpacity(
                                                                  0.4),
                                                              child:
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                      child: Text(
                                                                        'ADD',
                                                                        textAlign:
                                                                        TextAlign.center,
                                                                        style: TextStyle(
                                                                            color: kMainColor,
                                                                            fontSize: 15,
                                                                            fontWeight: FontWeight.w600),
                                                                      )),
                                                                  Icon(
                                                                      Icons.add_sharp,
                                                                      size: 15,
                                                                      color: kMainColor)
                                                                ],
                                                              ),
                                                              elevation:
                                                              0,
                                                              height:
                                                              33,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                  BorderRadius.circular(30)),
                                                            ),
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      });
                    },
                  );
                }else{
                  return Align(
                    child: Text('No product found related your search...'),
                  );
                }
              }
            }));
  }

  void addtocart2(String storeid, String varientid, dynamic qnty,
      String special, BuildContext context, int index) async {
    var locale = AppLocalizations.of(context);
    // setState(() {
    //   progressadd = true;
    // });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey('islogin') && preferences.getBool('islogin')) {
      if (preferences.getString('block') == '1') {
        a2cartSnap.hitSnap(-1, false);
        // setState(() {
        //   progressadd = false;
        // });
        Toast.show(
            locale.blockmsg,
            context,
            gravity: Toast.CENTER,
            duration: Toast.LENGTH_SHORT);
      } else {
        var http = Client();
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
              cartListPro.emitCartList(data1.cart_items,data1.total_price);
              cartCounterProvider.hitCartCounter(data1.cart_items.length);
            } else {
              cartListPro.emitCartList([],0.0);
              // _counter = 0;
              cartCounterProvider.hitCartCounter(0);
            }
            Toast.show(data1.message, context,
                gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
          }
          // setState(() {
          //   progressadd = false;
          // });
        }).catchError((e) {
          a2cartSnap.hitSnap(-1, false);
          // setState(() {
          //   progressadd = false;
          // });
          print(e);
        });
      }
    } else {
      a2cartSnap.hitSnap(-1, false);
      // setState(() {
      //   progressadd = false;
      // });
      Toast.show(locale.loginfirst, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
    }
  }
}
