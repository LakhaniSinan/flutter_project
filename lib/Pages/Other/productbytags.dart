import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:grocery/Components/constantfile.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/appinfo.dart';
import 'package:grocery/beanmodel/cart/addtocartbean.dart';
import 'package:grocery/beanmodel/cart/cartitembean.dart';
import 'package:grocery/beanmodel/productbean/productwithvarient.dart';
import 'package:grocery/beanmodel/storefinder/storefinderbean.dart';
import 'package:grocery/beanmodel/wishlist/wishdata.dart';
import 'package:grocery/providergrocery/add2cartsnap.dart';
import 'package:grocery/providergrocery/cartcountprovider.dart';
import 'package:grocery/providergrocery/cartlistprovider.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';

class TagsProduct extends StatefulWidget {

  @override
  _TagsProductState createState() => _TagsProductState();
}

class _TagsProductState extends State<TagsProduct> {
  List<ProductDataModel> products = [];
  dynamic title;
  dynamic store_id;
  bool enterFirst = false;
  bool isLoading = false;
  StoreFinderData storedetail;
  List<WishListDataModel> wishModel = [];
  dynamic apCurrency;
  List<CartItemData> cartItemd = [];
  var _counter = 0;
  bool progressadd = false;
  CartCountProvider cartCounterProvider;
  CartListProvider cartListPro;
  ScrollController controllerFixed;

  bool isPageLoading = false;

  A2CartSnap a2cartSnap;

  @override
  void initState() {
    controllerFixed = ScrollController();
    controllerFixed.addListener(_scrollListener);
    super.initState();
    getSharedValue();
    // getCartList();
    // hitAppInfo();
  }

  // void getCartList() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   setState(() {
  //     apCurrency = preferences.getString('app_currency');
  //   });
  //   // var http = Client();
  //   // http.post(showCartUri,
  //   //     body: {'user_id': '${preferences.getInt('user_id')}'}).then((value) {
  //   //   print('cart - ${value.body}');
  //   //   if (value.statusCode == 200) {
  //   //     CartItemMainBean data1 =
  //   //     CartItemMainBean.fromJson(jsonDecode(value.body));
  //   //     if ('${data1.status}' == '1') {
  //   //       cartItemd.clear();
  //   //       cartItemd = List.from(data1.data);
  //   //       _counter = cartItemd.length;
  //   //     } else {
  //   //       setState(() {
  //   //         cartItemd.clear();
  //   //         _counter = 0;
  //   //       });
  //   //     }
  //   //   }
  //   // }).catchError((e) {
  //   //   print(e);
  //   // });
  // }

  void getSharedValue() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = pref.getString('app_currency');
    });
  }

  void getWislist(dynamic storeid) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    var url = showWishlistUri;
    var http = Client();
    http.post(url, body: {
      'user_id': '${userId}',
      'store_id':'${storeid}'
    }, headers: {
      'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
    }).then((value){
      print('resp - ${value.body}');
      if(value.statusCode == 200){
        WishListModel data1 = WishListModel.fromJson(jsonDecode(value.body));
        if(data1.status=="1" || data1.status==1){
          setState(() {
            wishModel.clear();
            wishModel = List.from(data1.data);
          });
        }
      }
    }).catchError((e){
    });
  }

  void getCategory(dynamic title, dynamic storeid) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var http = Client();
    http.post(tagProductUri,body: {
      'tag_name':'${title}',
      'store_id':'${storeid}'
    }, headers: {
      'Authorization': 'Bearer ${pref.getString('accesstoken')}'
    }).then((value){
      print('${value.body}');
      if(value.statusCode == 200){
        ProductModel data1 = ProductModel.fromJson(jsonDecode(value.body));
        if(data1.status=="1" || data1.status==1){
          setState(() {
            products.clear();
            products = List.from(data1.data);
          });
        }
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e){
      print(e);
      setState(() {
        isLoading = false;
      });
    });
  }

  void _scrollListener() {
    if (controllerFixed.offset >= controllerFixed.position.maxScrollExtent && !controllerFixed.position.outOfRange) {
      print(
          'reached bottom ${controllerFixed.offset} - ${controllerFixed.position}');
      setState(() {
        isPageLoading = true;
      });
      // getCategoryPage(catid, store_id);
    }
    if (controllerFixed.offset <= controllerFixed.position.minScrollExtent &&
        !controllerFixed.position.outOfRange) {
      print(
          'reached top ${controllerFixed.offset} - ${controllerFixed.position}');
    }
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String,dynamic> receivedData = ModalRoute.of(context).settings.arguments;
    if(!enterFirst){
      enterFirst = true;
      isLoading = true;
      cartCounterProvider = BlocProvider.of<CartCountProvider>(context);
      cartListPro = BlocProvider.of<CartListProvider>(context);
      a2cartSnap = BlocProvider.of<A2CartSnap>(context);
      storedetail = receivedData['storedetail'];
      store_id = storedetail.store_id;
      title = receivedData['tagname'];
      getWislist(store_id);
      getCategory(title, store_id);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: kMainTextColor),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<CartCountProvider, int>(
              builder: (context,cartCount){
                return Badge(
                  position: BadgePosition.topEnd(top: 5, end: 5),
                  padding: EdgeInsets.all(5),
                  animationDuration: Duration(milliseconds: 300),
                  animationType: BadgeAnimationType.slide,
                  badgeContent: Text(
                    cartCount.toString(),
                    style: TextStyle(color: Colors.white,fontSize: 10),
                  ),
                  child: IconButton(
                      onPressed: () async {
                        SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                        if (prefs.containsKey('islogin') &&
                            prefs.getBool('islogin')) {

                          Navigator.pushNamed(context, PageRoutes.cartPage).then((value) {
                            print('value d');
                            // getCartList();
                          }).catchError((e) {
                            print('dd');
                            // getCartList();
                          });
                          // Navigator.pushNamed(context, PageRoutes.cart)

                        } else {
                          Toast.show(locale.loginfirst, context,
                              gravity: Toast.CENTER,
                              duration: Toast.LENGTH_SHORT);
                        }
                      },
                      icon: ImageIcon(AssetImage('assets/ic_cart.png'))),
                );
              }),
        ],
      ),
      body:
      BlocBuilder<CartListProvider,List<CartItemData>>(
        builder: (context,cartList){
          cartItemd = List.from(cartList);
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(5.0),
            child: (isLoading)?buildGridShView():(products!=null && products.length>0)?buildGridView(products,wishModel,'$apCurrency',storedetail,locale):Align(
              alignment: Alignment.center,
              child: Text(locale.productnotfound),
            ),
          );
        },
      ),
    );
  }

  Widget buildGridView(List<ProductDataModel> listName, List<WishListDataModel> wishModel,String apCurrency,StoreFinderData storedetail, AppLocalizations locale,{bool favourites = false, Function callback}) {
    return BlocBuilder<A2CartSnap, AddtoCartB>(builder: (_, dVal) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: ListView.builder(
              controller: controllerFixed,
              itemCount: listName.length,
              shrinkWrap: true,
              primary: false,
              // physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                int qty = 0;
                int selectedIndexd = 0;
                if (cartItemd != null && cartItemd.length > 0) {
                  int indd = cartItemd.indexOf(
                      CartItemData(varient_id: '${listName[index].varientId}'));
                  if (indd >= 0) {
                    qty = cartItemd[indd].qty;
                  }
                }

                int iddV = listName[index]
                    .varients
                    .indexOf(ProductVarient(varientId: listName[index].varientId));
                if (iddV >= 0) {
                  selectedIndexd = iddV;
                }
                print('id = $selectedIndexd, ${listName[index].varientId}');

                return GestureDetector(
                  onTap: () {
                    int idd = wishModel.indexOf(WishListDataModel(
                        '',
                        '',
                        '${listName[index].varientId}',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        ''));
                    Navigator.pushNamed(context, PageRoutes.product, arguments: {
                      'pdetails': listName[index],
                      'storedetails': storedetail,
                      'isInWish': (idd >= 0),
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xffffffff),
                        borderRadius: BorderRadius.circular(5)),
                    margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
                                    child: Image.network(
                                      '${listName[index].productImage}',
                                      fit: BoxFit.cover,
                                    ),
                                    // Image.asset(
                                    //   'assets/ProductImages/Cauliflower.png',
                                    //   fit: BoxFit.cover,
                                    // ),
                                  )),
                              Visibility(
                                visible: (int.parse('${listName[index].stock}') > 0)
                                    ? false
                                    : true,
                                child: Positioned.fill(
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: kButtonBorderColor.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: kWhiteColor,
                                          borderRadius: BorderRadius.circular(5)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
                                  child: Row(
                                    children: [
                                      ((((double.parse('${listName[index].mrp}') -
                                          double.parse(
                                              '${listName[index].price}')) /
                                          double.parse(
                                              '${listName[index].mrp}')) *
                                          100) >
                                          0)
                                          ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 3, vertical: 1.5),
                                        child: Text(
                                          '${(((double.parse('${listName[index].mrp}') - double.parse('${listName[index].price}')) / double.parse('${listName[index].mrp}')) * 100).toStringAsFixed(2)} %',
                                          style: TextStyle(
                                            color: kWhiteColor,
                                            fontSize: 10,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            color: kMainColor,
                                            borderRadius:
                                            BorderRadius.circular(3)),
                                      )
                                          : SizedBox.shrink(),
                                      Visibility(
                                        visible: ('${listName[index].type}' !=
                                            'Regular'),
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3, vertical: 1.5),
                                          margin: const EdgeInsets.only(left: 5),
                                          child: Text(
                                            locale.inseason,
                                            style: TextStyle(
                                              color: kMainTextColor,
                                              fontSize: 10,
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                              color: kButtonBorderColor,
                                              borderRadius:
                                              BorderRadius.circular(3)),
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('${listName[index].productName}',
                                    maxLines: 2,
                                    style: TextStyle(
                                        color: kMainTextColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700)),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(locale.ptype,
                                                style: TextStyle(
                                                    color: kLightTextColor,
                                                    fontSize: 11)),
                                            Text('${listName[index].type}',
                                                style: TextStyle(
                                                    color: kMainTextColor,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w400)),
                                          ],
                                        )),
                                    Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(locale.pqty,
                                                style: TextStyle(
                                                    color: kLightTextColor,
                                                    fontSize: 11)),
                                            (listName[index].varients != null &&
                                                listName[index].varients.length > 1)
                                                ? Container(
                                              height: 20,
                                              child:
                                              DropdownButton<ProductVarient>(
                                                elevation: 0,
                                                dropdownColor: kWhiteColor,
                                                hint: Text(
                                                    '${listName[index].quantity} ${listName[index].unit}',
                                                    overflow: TextOverflow.clip,
                                                    maxLines: 1,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        color: kMainTextColor,
                                                        fontSize: 11)),
                                                isExpanded: false,
                                                icon: Icon(
                                                  Icons.keyboard_arrow_down,
                                                  size: 15,
                                                ),
                                                underline: Container(
                                                  height: 0.0,
                                                  color: kWhiteColor,
                                                ),
                                                items: listName[index]
                                                    .varients
                                                    .map((value) {
                                                  return DropdownMenuItem<
                                                      ProductVarient>(
                                                    value: value,
                                                    child: Text(
                                                        '${value.quantity} ${value.unit}',
                                                        textAlign:
                                                        TextAlign.start,
                                                        overflow:
                                                        TextOverflow.clip,
                                                        style: TextStyle(
                                                            color:
                                                            kLightTextColor,
                                                            fontSize: 11)),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  int iddV = listName[index]
                                                      .varients
                                                      .indexOf(ProductVarient(
                                                      varientId:
                                                      value.varientId));
                                                  if (iddV >= 0) {
                                                    setState(() {
                                                      selectedIndexd = iddV;
                                                      listName[index].varientId =
                                                          value.varientId;
                                                      listName[index].price =
                                                          value.price;
                                                      listName[index].mrp =
                                                          value.mrp;
                                                      listName[index].quantity =
                                                          value.quantity;
                                                      listName[index].unit =
                                                          value.unit;
                                                      listName[index].stock =
                                                          value.stock;
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
                                            )
                                                : Text(
                                                '${listName[index].quantity} ${listName[index].unit}',
                                                overflow: TextOverflow.clip,
                                                maxLines: 1,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: kMainTextColor,
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Visibility(
                                              visible: ('${listName[index].price}' ==
                                                  '${listName[index].mrp}')
                                                  ? false
                                                  : true,
                                              child: Text(
                                                  '$apCurrency ${listName[index].mrp}',
                                                  style: TextStyle(
                                                      color: kLightTextColor,
                                                      fontSize: 14,
                                                      decoration:
                                                      TextDecoration.lineThrough)),
                                            ),
                                            Text('$apCurrency ${listName[index].price}',
                                                style: TextStyle(
                                                    color: kMainColor,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400)),
                                          ],
                                        )),
                                    Expanded(
                                      child: Visibility(
                                        visible:
                                        (int.parse('${listName[index].stock}') >
                                            0)
                                            ? true
                                            : false,
                                        child: Stack(
                                          children: [
                                            Align(
                                              child: qty > 0
                                                  ? Container(
                                                height: 33,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: kMainColor
                                                        .withOpacity(0.4),
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        30)),
                                                padding: const EdgeInsets
                                                    .symmetric(horizontal: 5),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                                  children: [
                                                    buildIconButton(
                                                        Icons.remove, context,
                                                        onpressed: () {
                                                          if (qty > 0 &&
                                                              dVal.status ==
                                                                  false) {
                                                            a2cartSnap.hitSnap(
                                                                int.parse(
                                                                    '${listName[index].productId}'),
                                                                true);
                                                            addtocart2(
                                                                '${listName[index].storeId}',
                                                                '${listName[index].varientId}',
                                                                (qty - 1),
                                                                '0',
                                                                context,
                                                                0);
                                                          } else {
                                                            Toast.show(
                                                                locale.pcurprogress,
                                                                context,
                                                                duration: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                Toast.CENTER);
                                                          }
                                                        }),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    (dVal.status == true &&
                                                        '${dVal.prodId}' ==
                                                            '${listName[index].productId}')
                                                        ? SizedBox(
                                                      height: 10,
                                                      width: 10,
                                                      child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 1,
                                                      ),
                                                    )
                                                        : Text('x$qty',
                                                        style: Theme.of(
                                                            context)
                                                            .textTheme
                                                            .subtitle1),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    buildIconButton(
                                                        Icons.add, context,
                                                        type: 1,
                                                        onpressed: () {
                                                          if ((qty + 1) <=
                                                              int.parse(
                                                                  '${listName[index].stock}') &&
                                                              dVal.status ==
                                                                  false) {
                                                            a2cartSnap.hitSnap(
                                                                int.parse(
                                                                    '${listName[index].productId}'),
                                                                true);
                                                            addtocart2(
                                                                '${listName[index].storeId}',
                                                                '${listName[index].varientId}',
                                                                (qty + 1),
                                                                '0',
                                                                context,
                                                                0);
                                                          } else {
                                                            if (dVal.status ==
                                                                false) {
                                                              Toast.show(
                                                                  locale.outstock2,
                                                                  context,
                                                                  duration: Toast
                                                                      .LENGTH_SHORT,
                                                                  gravity: Toast
                                                                      .CENTER);
                                                            } else {
                                                              Toast.show(
                                                                  locale.pcurprogress,
                                                                  context,
                                                                  duration: Toast
                                                                      .LENGTH_SHORT,
                                                                  gravity: Toast
                                                                      .CENTER);
                                                            }
                                                          }
                                                        }),
                                                  ],
                                                ),
                                              )
                                                  : (dVal.status == true &&
                                                  '${dVal.prodId}' ==
                                                      '${listName[index].productId}')
                                                  ? SizedBox(
                                                height: 10,
                                                width: 10,
                                                child:
                                                CircularProgressIndicator(
                                                  strokeWidth: 1,
                                                ),
                                              )
                                                  : MaterialButton(
                                                onPressed: () {
                                                  if (int.parse(
                                                      '${listName[index].stock}') >
                                                      0 &&
                                                      dVal.status ==
                                                          false) {
                                                    a2cartSnap.hitSnap(
                                                        int.parse(
                                                            '${listName[index].productId}'),
                                                        true);
                                                    addtocart2(
                                                        '${listName[index].storeId}',
                                                        '${listName[index].varientId}',
                                                        (qty + 1),
                                                        '0',
                                                        context,
                                                        0);
                                                  } else {
                                                    if (dVal.status ==
                                                        false) {
                                                      Toast.show(
                                                          locale.outstock2,
                                                          context,
                                                          duration: Toast
                                                              .LENGTH_SHORT,
                                                          gravity: Toast
                                                              .CENTER);
                                                    } else {
                                                      Toast.show(
                                                          locale.pcurprogress,
                                                          context,
                                                          duration: Toast
                                                              .LENGTH_SHORT,
                                                          gravity: Toast
                                                              .CENTER);
                                                    }
                                                  }
                                                },
                                                splashColor: kMainColor,
                                                color: kMainColor
                                                    .withOpacity(0.4),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        child: Text(
                                                          'ADD',
                                                          textAlign: TextAlign
                                                              .center,
                                                          style: TextStyle(
                                                              color:
                                                              kMainColor,
                                                              fontSize: 15,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w600),
                                                        )),
                                                    Icon(Icons.add_sharp,
                                                        size: 15,
                                                        color: kMainColor)
                                                  ],
                                                ),
                                                elevation: 0,
                                                height: 33,
                                                shape:
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        30)),
                                              ),
                                              alignment: Alignment.bottomCenter,
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
              })),
          Visibility(
              visible: isPageLoading,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                child: Text('Loading'),
              ))
        ],
      );
    });
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
              cartListPro.emitCartList(data1.cart_items, data1.total_price);
              cartCounterProvider.hitCartCounter(data1.cart_items.length);
            } else {
              cartListPro.emitCartList([], 0.0);
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


