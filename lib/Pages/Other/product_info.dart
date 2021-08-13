import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery/Components/constantfile.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/cart/addtocartbean.dart';
import 'package:grocery/beanmodel/cart/cartitembean.dart';
import 'package:grocery/beanmodel/productbean/productwithvarient.dart';
import 'package:grocery/beanmodel/ratting/rattingbean.dart';
import 'package:grocery/beanmodel/storefinder/storefinderbean.dart';
import 'package:grocery/beanmodel/whatsnew/whatsnew.dart';
import 'package:grocery/beanmodel/wishlist/addorremovewish.dart';
import 'package:grocery/beanmodel/wishlist/wishdata.dart';
import 'package:grocery/providergrocery/add2cartsnap.dart';
import 'package:grocery/providergrocery/cartcountprovider.dart';
import 'package:grocery/providergrocery/cartlistprovider.dart';
import 'package:grocery/providergrocery/pagesnap.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ProductInfo extends StatefulWidget {
  @override
  _ProductInfoState createState() => _ProductInfoState();
}

class _ProductInfoState extends State<ProductInfo> {
  ProductDataModel productDetails;
  var http = Client();
  List<ProductVarient> varaintList = [];
  List<Tags> tagsList = [];
  List<ProductDataModel> sellerProducts = [];
  List<WishListDataModel> wishModel = [];
  List<CartItemData> cartItemd = [];
  StoreFinderData storedetails;
  bool progressadd = false;
  bool isWishList = false;
  String image;
  String name;
  String productid;
  String price;
  String mrp;
  String varientid;
  String storeid;
  String desp;
  bool enterFirst = false;
  bool inCart = false;
  dynamic apCurrency;

  int ratingvalue = 0;
  double avrageRating = 0.0;
  int selectedIndex = 0;
  int _counter = 0;
  CartCountProvider cartCounterProvider;
  CartListProvider cartListPro;
  A2CartSnap a2cartSnap;

  ImageSnapReview pageSnap;

  @override
  void initState() {
    super.initState();
    getCartList();
  }

  void scanProductCode(BuildContext context) async {
    await FlutterBarcodeScanner.scanBarcode(
            "#ff6666", "Cancel", true, ScanMode.DEFAULT)
        .then((value) {
      if (value != null && value.length > 0 && '$value' != '-1') {
        if (storedetails != null) {
          Navigator.pushNamed(context, PageRoutes.search, arguments: {
            'ean_code': value,
            'storedetails': storedetails,
          });
        }
        // setState(() {
        //   _scanBarcode = value;
        // });
        // print('scancode - ${_scanBarcode}');
      }
    }).catchError((e) {});
  }

  @override
  void dispose() {
    http.close();
    super.dispose();
  }

  void getRatingValue(dynamic store_id, dynamic varient_id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    http.post(getProductRatingUri, body: {
      'store_id': '$store_id',
      'varient_id': '$varient_id'
    }, headers: {
      'Authorization': 'Bearer ${pref.getString('accesstoken')}'
    }).then((value) {
      if (value.statusCode == 200) {
        ProductRating data1 = ProductRating.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            List<ProductRatingData> dataL = List.from(data1.data);
            ratingvalue = dataL.length;
            if (ratingvalue > 0) {
              double rateV = 0.0;
              for (int i = 0; i < dataL.length; i++) {
                rateV = rateV + double.parse('${dataL[i].rating}');
                if (dataL.length == i + 1) {
                  avrageRating = rateV / dataL.length;
                }
              }
            } else {
              avrageRating = 5.0;
            }
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  void getWislist(dynamic storeid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    var url = showWishlistUri;
    var http = Client();
    http.post(url, body: {
      'user_id': '${userId}',
      'store_id': '${storeid}'
    }, headers: {
      'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
    }).then((value) {
      print('resp - ${value.body}');
      if (value.statusCode == 200) {
        WishListModel data1 = WishListModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            wishModel.clear();
            wishModel = List.from(data1.data);
          });
        }
      }
    }).catchError((e) {});
  }

  void getCartList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = preferences.getString('app_currency');
    });
  }

  void getTopSellingList(dynamic storeid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    http.post(topSellingUri, body: {
      'store_id': '${storeid}'
    }, headers: {
      'Authorization': 'Bearer ${prefs.getString('accesstoken')}'
    }).then((value) {
      if (value.statusCode == 200) {
        WhatsNewModel data1 = WhatsNewModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            sellerProducts.clear();
            sellerProducts = List.from(data1.data);
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  void addOrRemove(
      dynamic storeid, dynamic varientId, BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    dynamic userid = preferences.getInt('user_id');
    print('${storeid} ${userid} ${varientId}');
    var http = Client();
    http.post(addRemWishlistUri, body: {
      'store_id': '${storeid}',
      'user_id': '${userid}',
      'varient_id': '${varientId}',
    }, headers: {
      'Authorization': 'Bearer ${preferences.getString('accesstoken')}'
    }).then((value) {
      print('resd ${value.body}');
      if (value.statusCode == 200) {
        AddRemoveWishList data1 =
            AddRemoveWishList.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            isWishList = true;
          });
        } else if (data1.status == "2" || data1.status == 2) {
          setState(() {
            isWishList = false;
          });
        }
        Toast.show(data1.message, context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      }
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    if (!enterFirst) {
      Map<String, dynamic> receivedData =
          ModalRoute.of(context).settings.arguments;
      cartCounterProvider = BlocProvider.of<CartCountProvider>(context);
      cartListPro = BlocProvider.of<CartListProvider>(context);
      a2cartSnap = BlocProvider.of<A2CartSnap>(context);
      pageSnap = BlocProvider.of<ImageSnapReview>(context);
      enterFirst = true;
      productDetails = receivedData['pdetails'];
      storedetails = receivedData['storedetails'];
      image = productDetails.productImage;
      name = productDetails.productName;
      productid = '${productDetails.productId}';
      if (productDetails.varients != null &&
          productDetails.varients.length > 0) {
        varaintList.clear();
        varaintList = List.from(productDetails.varients);
        selectedIndex = varaintList
            .indexOf(ProductVarient(varientId: productDetails.varientId));
        price = '${productDetails.varients[selectedIndex].price}';
        mrp = '${productDetails.varients[selectedIndex].mrp}';
        varientid = '${productDetails.varients[selectedIndex].varientId}';
        desp = productDetails.varients[selectedIndex].description;
        print(desp);
        print(productDetails.description);
      } else {
        varaintList.clear();
        selectedIndex = 0;
        price = '${productDetails.price}';
        mrp = '${productDetails.mrp}';
        varientid = '${productDetails.varientId}';
        desp = productDetails.description;
      }

      storeid = '${storedetails.store_id}';
      if (cartItemd != null && cartItemd.length > 0) {
        int ind1 = cartItemd.indexOf(CartItemData(varient_id: '${varientid}'));
        if (ind1 >= 0) {
          setState(() {
            inCart = true;
          });
        }
      }
      isWishList = receivedData['isInWish'];
      if (productDetails.tags != null && productDetails.tags.length > 0) {
        tagsList.clear();
        tagsList = List.from(productDetails.tags);
      } else {
        tagsList.clear();
      }

      print('${receivedData['isInWish']}');
      print('${isWishList}');
      getRatingValue(storeid, varientid);
      getTopSellingList(storeid);
      getWislist(storeid);
      // getCartList();;
    }

    return SafeArea(
      top: true,
      bottom: true,
      left: false,
      right: false,
      child: Scaffold(
        backgroundColor: kWhiteColor,
        appBar: AppBar(
          backgroundColor: kWhiteColor,
          automaticallyImplyLeading: true,
          title: Text('${productDetails.productName}'),
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
            cartItemd = List.from(cartList);
            int qty = 0;
            if (cartItemd != null && cartItemd.length > 0) {
              int ind1 =
                  cartItemd.indexOf(CartItemData(varient_id: '$varientid'));
              if (ind1 >= 0) {
                qty = cartItemd[ind1].qty;
              }
            }
            if (qty > 0) {
              inCart = true;
            } else {
              inCart = false;
            }
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        (productDetails.images!=null && productDetails.images.length>1)
                            ?Container(
                          color: kWhiteColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CarouselSlider(
                                options: CarouselOptions(
                                    height: 200.0,
                                    viewportFraction: 1,
                                    onPageChanged: (index, reason) {
                                      pageSnap.pageSnapReview(index);
                                    },
                                    autoPlay: false),
                                items: productDetails.images.map((i) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                        width: MediaQuery.of(context)
                                            .size
                                            .width,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        // padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(5),
                                            color: kMainColor,
                                            image: DecorationImage(
                                                image: AssetImage('assets/offerback.png'),
                                                fit: BoxFit.fill
                                            )
                                        ),
                                        child: Container(
                                          height: 200,
                                          color: kWhiteColor,
                                          child: Image.network(
                                            '$imagebaseUrl${i.image}',
                                            fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0),
                                child: BlocBuilder<ImageSnapReview, int>(
                                    builder: (context, pageI) {
                                      return Container(
                                        height: 20,
                                        alignment: Alignment.center,
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: productDetails.images.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding:
                                              const EdgeInsets.all(2.0),
                                              child: Card(
                                                // type: MaterialType.circle,
                                                color: (pageI == index)
                                                    ? kMainColor
                                                    : kCardBackgroundColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10)),
                                                child: Container(
                                                  height: (pageI == index)
                                                      ? 15
                                                      : 10,
                                                  width: (pageI == index)
                                                      ? 15
                                                      : 10,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: (pageI == index)
                                                        ? kMainColor
                                                        : kCardBackgroundColor,
                                                    // borderRadius: BorderRadius.circular(10)
                                                    // shape: BoxShape.circle,
                                                    // border: Border.all(color: (index==pageIndex)?kMainColor:kLightTextColor)
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          separatorBuilder: (context, index) {
                                            return SizedBox(
                                              width: 5,
                                            );
                                          },
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        )
                            : Container(
                          height: 200,
                          color: kWhiteColor,
                          child: Image.network(
                            '${productDetails.productImage}',
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        Divider(
                          color: Color(0xfff6f7f9),
                          height: 10,
                          thickness: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    child: Row(
                                      children: [
                                        ((((double.parse('${productDetails.varients[selectedIndex].mrp}') -
                                                            double.parse(
                                                                '${productDetails.varients[selectedIndex].price}')) /
                                                        double.parse(
                                                            '${productDetails.varients[selectedIndex].mrp}')) *
                                                    100) >
                                                0)
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 3,
                                                        vertical: 1.5),
                                                child: Text(
                                                  '${(((double.parse('${productDetails.varients[selectedIndex].mrp}') - double.parse('${productDetails.varients[selectedIndex].price}')) / double.parse('${productDetails.varients[selectedIndex].mrp}')) * 100).toStringAsFixed(2)} %',
                                                  style: TextStyle(
                                                    color: kWhiteColor,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                    color: kMainColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3)),
                                              )
                                            : SizedBox.shrink(),
                                        Visibility(
                                          visible: ('${productDetails.type}'!='Regular'),
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 3, vertical: 1.5),
                                            margin:
                                                const EdgeInsets.only(left: 5),
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
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Text(
                                      '${productDetails.productName}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline3
                                          .copyWith(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                    ),
                                  ),
                                ],
                              )),
                              IconButton(
                                onPressed: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  if (prefs.containsKey('islogin') &&
                                      prefs.getBool('islogin')) {
                                    if (prefs.getString('block') == '1') {
                                      Toast.show(
                                          locale.blockmsg,
                                          context,
                                          gravity: Toast.CENTER,
                                          duration: Toast.LENGTH_SHORT);
                                    } else {
                                      addOrRemove(storeid, varientid, context);
                                    }
                                  } else {
                                    Toast.show(locale.loginfirst, context,
                                        gravity: Toast.CENTER,
                                        duration: Toast.LENGTH_SHORT);
                                  }
                                },
                                icon: Icon(isWishList
                                    ? Icons.favorite
                                    : Icons.favorite_border),
                                color: kMainColor,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(locale.ptype,
                                      style: TextStyle(
                                          color: kLightTextColor,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 15)),
                                  Text('${productDetails.type}',
                                      style: TextStyle(
                                          color: kMainTextColor,
                                          fontSize: 13,
                                          letterSpacing: 1.4,
                                          fontWeight: FontWeight.w300)),
                                ],
                              )),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Text('Storage Life',
                                  //     style: TextStyle(
                                  //         color: kLightTextColor,
                                  //         fontSize: 11)),
                                  // Text('5 Days',
                                  //     style: TextStyle(
                                  //         color: kMainTextColor,
                                  //         fontSize: 13,
                                  //         fontWeight: FontWeight
                                  //             .w400)),
                                ],
                              )),
                              Expanded(
                                  child: (productDetails.varients!=null && productDetails.varients.length>1)
                                      ?Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(locale.pqty,
                                      style: TextStyle(
                                          color: kLightTextColor,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 15)),
                                  Container(
                                    height: 20,
                                    child: DropdownButton<ProductVarient>(
                                      elevation: 0,
                                      dropdownColor: kWhiteColor,
                                      hint: Text(
                                          '${productDetails.varients[selectedIndex].quantity} ${productDetails.varients[selectedIndex].unit}',
                                          overflow: TextOverflow.clip,
                                          maxLines: 1,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: kMainTextColor,
                                              fontSize: 13,
                                              letterSpacing: 1.4,
                                              fontWeight: FontWeight.w300)),
                                      isExpanded: false,
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 15,
                                      ),
                                      underline: Container(
                                        height: 0.0,
                                        color: kWhiteColor,
                                      ),
                                      items:
                                          productDetails.varients.map((value) {
                                        return DropdownMenuItem<ProductVarient>(
                                          value: value,
                                          child: Text(
                                              '${value.quantity} ${value.unit}',
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.clip,
                                              style: TextStyle(
                                                  color: kLightTextColor,
                                                  fontSize: 11)),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        int iddV = productDetails.varients
                                            .indexOf(ProductVarient(
                                                varientId: value.varientId));
                                        if (iddV >= 0) {
                                          setState(() {
                                            selectedIndex = iddV;
                                          });
                                          // showindex
                                          //     .data[index]
                                          //     .varientId =
                                          //     value.varientId;
                                        }
                                      },
                                    ),
                                  ),
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
                              )
                                      : Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(locale.pqty,
                                          style: TextStyle(
                                              color: kLightTextColor,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15)),
                                      Text(
                                          '${productDetails.quantity} ${productDetails.unit}',
                                          overflow:
                                          TextOverflow
                                              .clip,
                                          maxLines: 1,
                                          textAlign:
                                          TextAlign.start,
                                          style: TextStyle(
                                              color:
                                              kMainTextColor,
                                              fontSize: 11))
                                    ],
                                  )
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: Color(0xfff6f7f9),
                          height: 10,
                          thickness: 10,
                        ),
                        // Container(
                        //     color: Colors.white,
                        //     child: Padding(
                        //         padding: EdgeInsets.all(3.0),
                        //         child: Column(children: [
                        //           Row(
                        //             children: [
                        //               Container(
                        //                 height: 30,
                        //                 padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                        //                 decoration: BoxDecoration(
                        //                   color: Colors.redAccent,
                        //                   border: Border.all(color: Colors.redAccent,),
                        //                   borderRadius: BorderRadius.circular(5),
                        //                 ),
                        //                 margin: EdgeInsets.all(5),
                        //                 child: Row(
                        //                   mainAxisAlignment:
                        //                   MainAxisAlignment.start,
                        //                   children: [
                        //
                        //                     Text("-25%",
                        //                         style: TextStyle(
                        //                             fontWeight: FontWeight.bold,
                        //                             color: Colors.white,
                        //                             fontSize: 13)),
                        //
                        //
                        //                   ],
                        //                 ),
                        //               ),
                        //               Text("In Season",
                        //                   style: TextStyle(
                        //                       fontWeight: FontWeight.bold,
                        //                       color: Colors.black54,
                        //                       fontSize: 15)),
                        //             ],
                        //           ),
                        //           Container(
                        //             width: MediaQuery
                        //                 .of(context)
                        //                 .size
                        //                 .width,
                        //             color: Colors.white,
                        //             child: Row(
                        //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //               children: [
                        //                 Expanded(child:
                        //                 Align(
                        //                   alignment: Alignment.centerLeft,
                        //                   child: Container(
                        //                     child: Text("Washington Apples",
                        //                         style: TextStyle(
                        //                             fontWeight: FontWeight.bold,
                        //                             color: Colors.black,
                        //                             fontSize: 17)),
                        //                   ),
                        //                 )),
                        //
                        //
                        //                 Icon(Icons.favorite,
                        //                     size: 20.0, color: Colors.pink),
                        //               ],
                        //             ),
                        //           ),
                        //           Container(
                        //               margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        //               child: Padding(
                        //                   padding: EdgeInsets.all(3.0),
                        //                   child: Container(
                        //                     width: MediaQuery
                        //                         .of(context)
                        //                         .size
                        //                         .width,
                        //                     color: Colors.white,
                        //                     child: Row(
                        //                       mainAxisAlignment: MainAxisAlignment
                        //                           .spaceEvenly,
                        //                       children: [
                        //                         Expanded(
                        //                             child: Column(
                        //                               children: [
                        //                                 Align(
                        //                                   alignment: Alignment
                        //                                       .centerLeft,
                        //                                   child: Container(
                        //                                     child: Text("Type",
                        //                                         style: TextStyle(
                        //                                             fontWeight: FontWeight
                        //                                                 .normal,
                        //                                             color: Colors
                        //                                                 .black54,
                        //                                             fontSize: 15)),
                        //                                   ),
                        //                                 ),
                        //                                 Align(
                        //                                     alignment: Alignment
                        //                                         .centerLeft,
                        //                                     child: Row(
                        //                                       children: [
                        //                                         Image.asset(
                        //                                           'assets/premium_icon.png',
                        //                                           fit: BoxFit.fill,
                        //                                           height: 20,
                        //                                           width: 20,
                        //                                         ),
                        //                                         Text("  Premium",
                        //                                             style: TextStyle(
                        //                                                 fontWeight: FontWeight
                        //                                                     .normal,
                        //                                                 color: Colors
                        //                                                     .black,
                        //                                                 fontSize: 15)),
                        //                                       ],
                        //                                     )),
                        //                               ],
                        //                             )),
                        //                         SizedBox(width: 4,),
                        //
                        //                         Expanded(
                        //                             child: Column(
                        //                               children: [
                        //                                 Align(
                        //                                   alignment: Alignment
                        //                                       .centerLeft,
                        //                                   child: Container(
                        //                                     child: Text("Storage Life",
                        //                                         style: TextStyle(
                        //                                             fontWeight: FontWeight
                        //                                                 .normal,
                        //                                             color: Colors
                        //                                                 .black54,
                        //                                             fontSize: 15)),
                        //                                   ),
                        //                                 ),
                        //                                 Align(
                        //                                     alignment: Alignment
                        //                                         .centerLeft,
                        //                                     child: Text("3 Days",
                        //                                         style: TextStyle(
                        //                                             fontWeight: FontWeight
                        //                                                 .normal,
                        //                                             color: Colors.black,
                        //                                             fontSize: 15))),
                        //                               ],
                        //                             )),
                        //                         SizedBox(
                        //                           width: 25,
                        //                         ),
                        //                         Expanded(
                        //                             child: Column(
                        //                               children: [
                        //                                 Align(
                        //                                   alignment: Alignment
                        //                                       .centerLeft,
                        //                                   child: Container(
                        //                                     child: Text("QTY",
                        //                                         style: TextStyle(
                        //                                             fontWeight: FontWeight
                        //                                                 .normal,
                        //                                             color: Colors
                        //                                                 .black54,
                        //                                             fontSize: 15)),
                        //                                   ),
                        //                                 ),
                        //                                 Align(
                        //                                     alignment: Alignment
                        //                                         .centerRight,
                        //                                     child: Row(
                        //                                       children: [
                        //                                         Text("3 Units",
                        //                                             style: TextStyle(
                        //                                                 fontWeight: FontWeight
                        //                                                     .normal,
                        //                                                 color: Colors
                        //                                                     .black,
                        //                                                 fontSize: 15)),
                        //                                         Icon(Icons
                        //                                             .arrow_circle_down_sharp,
                        //                                             size: 20.0,
                        //                                             color: Colors
                        //                                                 .black54),
                        //                                       ],
                        //                                     )),
                        //                               ],
                        //                             )),
                        //                       ],
                        //                     ),
                        //                   )))
                        //         ],)
                        //     )),
                        //
                        (tagsList!=null && tagsList.length>0)
                            ?Container(
                          color: kWhiteColor,
                              child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 10,),
                              Container(
                                height: 40,
                                child: ListView.builder(
                                    itemCount: 10,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          Navigator.pushNamed(context, PageRoutes.tagproduct,
                                              arguments: {
                                                'storedetail': storedetails,
                                                'tagname': tagsList[index].tag
                                              }).then((value) {
                                            print('value d');
                                            getCartList();
                                          }).catchError((e) {
                                            print('dd');
                                            getCartList();
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(horizontal: 10),
                                          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(color: kMainColor, width: 1),
                                            color: kWhiteColor,
                                          ),
                                          child: Row(
                                            children: [
                                              Text('${productDetails.tags[index].tag}'),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            SizedBox(height: 10,),
                              Divider(
                                color: Color(0xfff6f7f9),
                                height: 10,
                                thickness: 10,
                              ),
                          ],
                        ),
                            )
                            :SizedBox.shrink(),
                        Container(
                            color: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(locale.prddetails,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                color: kMainTextColor,
                                                letterSpacing: 1.5,
                                                fontSize: 17)),
                                        GestureDetector(
                                          onTap: (){
                                            Navigator.pushNamed(
                                                context, PageRoutes.reviewsall,arguments: {
                                              'store_id':'$storeid',
                                              'v_id':'$varientid',
                                              'title':'$name'
                                            }).then((value){
                                              getRatingValue(storeid, varientid);
                                            });
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              buildRating(context,avrageRating: avrageRating),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                child: Text(
                                                  '${locale.readAllReviews1} $ratingvalue ${locale.readAllReviews2}',
                                                  style: TextStyle(
                                                      color: Color(
                                                        0xffa9a9a9,
                                                      ),
                                                      fontSize: 13),
                                                ),
                                              ),
                                              Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xffa9a9a9)),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  // Align(
                                  //   alignment: Alignment.centerLeft,
                                  //   child: Container(
                                  //     margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                                  //     child: Text('Product Details',
                                  //         style: TextStyle(
                                  //             fontWeight: FontWeight.w300,
                                  //             color: kMainTextColor,
                                  //             letterSpacing: 1.5,
                                  //             fontSize: 17)),
                                  //   ),
                                  // ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Divider(
                                    color: Color(0xfff6f7f9),
                                    height: 5,
                                    thickness: 2,
                                    indent: 5,
                                    endIndent: 5,
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Text('${productDetails.description}',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w200,
                                          color: kMainTextColor,
                                          fontSize: 14)),
                                  // Align(
                                  //   alignment: Alignment.centerLeft,
                                  //   child: Container(
                                  //     margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  //     child: Text(
                                  //       "An apple is an edible fruit produced by an apple tree. Apple trees are cultivated worldwide and are the most widely grown species in the genus Malus. The tree originated in Central Asia, where its wild ancestor, Malus sieversii, is still found today.",
                                  //       style: TextStyle(
                                  //           fontWeight: FontWeight.normal,
                                  //           color: Colors.black54,
                                  //           fontSize: 17),
                                  //       // linkColor: Colors.blue,
                                  //     ),
                                  //   ),
                                  // ),
                                  // Align(
                                  //   alignment: Alignment.centerLeft,
                                  //   child: Container(
                                  //     margin: EdgeInsets.fromLTRB(0, 12, 0, 5),
                                  //     child: Text("Shelf Life",
                                  //         style: TextStyle(
                                  //             fontWeight: FontWeight.bold,
                                  //             color: Colors.black54,
                                  //             fontSize: 17)),
                                  //   ),
                                  // ),
                                  // Align(
                                  //   alignment: Alignment.centerLeft,
                                  //   child: Container(
                                  //     margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  //     child: Text(
                                  //       "An apple is an edible fruit produced by an apple tree. Apple trees are cultivated worldwide and are the most widely grown species in the genus Malus. The tree originated in Central Asia, where its wild ancestor, Malus sieversii, is still found today.",
                                  //       maxLines: 2,
                                  //       style: TextStyle(
                                  //           fontWeight: FontWeight.normal,
                                  //           color: Colors.black54,
                                  //           fontSize: 17),
                                  //     ),
                                  //   ),
                                  // ),
                                ])),
                      ],
                    ),
                  )),
                  Container(
                    color: kWhiteColor,
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Column(
                      children: [
                        BlocBuilder<A2CartSnap, AddtoCartB>(builder: (_, dVal) {
                          return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            width: MediaQuery.of(context).size.width,
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '$apCurrency ${productDetails.varients[selectedIndex].price}',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                              fontSize: 15)),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                          '${productDetails.varients[selectedIndex].quantity} ${productDetails.varients[selectedIndex].unit}',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: kMainColor,
                                              fontSize: 15)),
                                    ],
                                  ),
                                ),
                                (int.parse('${productDetails.varients[selectedIndex].stock}') >
                                        0)
                                    ? qty > 0
                                        ? Container(
                                            height: 33,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color:
                                                    kMainColor.withOpacity(0.4),
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                buildIconButton(
                                                    Icons.remove, context,
                                                    onpressed: () {
                                                  if (qty > 0 &&
                                                      dVal.status == false) {
                                                    a2cartSnap.hitSnap(
                                                        int.parse(
                                                            '${productDetails.productId}'),
                                                        true);
                                                    addtocart2(
                                                        '${productDetails.storeId}',
                                                        '${productDetails.varients[selectedIndex].varientId}',
                                                        (qty - 1),
                                                        '0',
                                                        context,
                                                        0);
                                                  } else {
                                                    Toast.show(
                                                        locale.pcurprogress,
                                                        context,
                                                        duration:
                                                            Toast.LENGTH_SHORT,
                                                        gravity: Toast.CENTER);
                                                  }
                                                }),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                (dVal.status == true &&
                                                        '${dVal.prodId}' ==
                                                            '${productDetails.productId}')
                                                    ? SizedBox(
                                                        height: 10,
                                                        width: 10,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 1,
                                                        ),
                                                      )
                                                    : Text('x$qty',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .subtitle1),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                buildIconButton(
                                                    Icons.add, context, type: 1,
                                                    onpressed: () {
                                                  if ((qty + 1) <=
                                                          int.parse(
                                                              '${productDetails.varients[selectedIndex].stock}') &&
                                                      dVal.status == false) {
                                                    a2cartSnap.hitSnap(
                                                        int.parse(
                                                            '${productDetails.productId}'),
                                                        true);
                                                    addtocart2(
                                                        '${productDetails.storeId}',
                                                        '${productDetails.varients[selectedIndex].varientId}',
                                                        (qty + 1),
                                                        '0',
                                                        context,
                                                        0);
                                                  } else {
                                                    if (dVal.status == false) {
                                                      Toast.show(
                                                          locale.outstock2,
                                                          context,
                                                          duration: Toast
                                                              .LENGTH_SHORT,
                                                          gravity:
                                                              Toast.CENTER);
                                                    } else {
                                                      Toast.show(
                                                          locale.pcurprogress,
                                                          context,
                                                          duration: Toast
                                                              .LENGTH_SHORT,
                                                          gravity:
                                                              Toast.CENTER);
                                                    }
                                                  }
                                                }),
                                              ],
                                            ),
                                          )
                                        : (dVal.status == true &&
                                                '${dVal.prodId}' ==
                                                    '${productDetails.productId}')
                                            ? SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 1,
                                                  color: kMainColor,
                                                ),
                                              )
                                            : MaterialButton(
                                                onPressed: () {
                                                  if (int.parse(
                                                              '${productDetails.varients[selectedIndex].stock}') >
                                                          0 &&
                                                      dVal.status == false) {
                                                    a2cartSnap.hitSnap(
                                                        int.parse(
                                                            '${productDetails.productId}'),
                                                        true);
                                                    addtocart2(
                                                        '${productDetails.storeId}',
                                                        '${productDetails.varients[selectedIndex].varientId}',
                                                        (qty + 1),
                                                        '0',
                                                        context,
                                                        0);
                                                  } else {
                                                    if (dVal.status == false) {
                                                      Toast.show(
                                                          locale.outstock2,
                                                          context,
                                                          duration: Toast
                                                              .LENGTH_SHORT,
                                                          gravity:
                                                              Toast.CENTER);
                                                    } else {
                                                      Toast.show(
                                                          locale.pcurprogress,
                                                          context,
                                                          duration: Toast
                                                              .LENGTH_SHORT,
                                                          gravity:
                                                              Toast.CENTER);
                                                    }
                                                  }
                                                },
                                                splashColor: kMainColor,
                                                color:
                                                    kMainColor.withOpacity(0.4),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'ADD',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: kMainColor,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    Icon(Icons.add_sharp,
                                                        size: 15,
                                                        color: kMainColor)
                                                  ],
                                                ),
                                                elevation: 0,
                                                height: 33,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                              )
                                    : Text(
                                        locale.outstock,
                                        style: TextStyle(
                                          color: kRedColor,
                                          fontSize: 11,
                                        ),
                                      )
                              ],
                            )
                            ,
                          );
                        }),
                        Visibility(
                          visible: (cartItemd.length > 0),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 2),
                            decoration: BoxDecoration(
                              color: kMainColor,
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${cartItemd.length} Items',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: kWhiteColor,
                                              letterSpacing: 1.5,
                                              fontSize: 12)),
                                      Text("$apCurrency ${cartListPro.cartprice}",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: kWhiteColor,
                                              letterSpacing: 1.5,
                                              fontSize: 14)),
                                    ],
                                  ),
                                ),
                                Text("View Basket",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: kWhiteColor,
                                        letterSpacing: 1.5,
                                        fontSize: 13)),
                                BlocBuilder<CartCountProvider, int>(
                                    builder: (context, cartCount) {
                                  return Badge(
                                    position:
                                        BadgePosition.topEnd(top: 5, end: 5),
                                    padding: EdgeInsets.all(5),
                                    animationDuration:
                                        Duration(milliseconds: 300),
                                    animationType: BadgeAnimationType.slide,
                                    badgeContent: Text(
                                      cartCount.toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 8),
                                    ),
                                    child: IconButton(
                                      onPressed: () async {
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        if (prefs.containsKey('islogin') &&
                                            prefs.getBool('islogin')) {
                                          Navigator.pushNamed(
                                              context, PageRoutes.cartPage);
                                        } else {
                                          Toast.show(locale.loginfirst, context,
                                              gravity: Toast.CENTER,
                                              duration: Toast.LENGTH_SHORT);
                                        }
                                      },
                                      iconSize: 17,
                                      icon: ImageIcon(
                                        AssetImage('assets/ic_cart.png'),
                                        size: 17,
                                      ),
                                      color: kWhiteColor,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
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
